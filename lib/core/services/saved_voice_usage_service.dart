import '../../shared/data/local_store.dart';
import '../../shared/models/ui_models.dart';
import 'io_dir_stub.dart' if (dart.library.io) 'io_dir_io.dart' as io_file;
import 'recording_file_store.dart';

enum SavedVoiceBlockingReason { none, activeAlarms, openDraft }

/// Describes how a saved voice is referenced by sequences / alarms / drafts.
class SavedVoiceUsage {
  const SavedVoiceUsage({
    required this.voiceId,
    required this.activeAlarmIds,
    required this.activeSequenceIds,
    required this.orphanSequenceIds,
    required this.draftSequenceIds,
    this.blockingReason = SavedVoiceBlockingReason.none,
  });

  final String voiceId;
  final Set<String> activeAlarmIds;
  final Set<String> activeSequenceIds;
  final Set<String> orphanSequenceIds;
  final Set<String> draftSequenceIds;
  final SavedVoiceBlockingReason blockingReason;

  /// Alarm-backed usage only (what the UI should count).
  int get usageCount => activeAlarmIds.length;

  @Deprecated('Use activeAlarmIds')
  Set<String> get alarmIds => activeAlarmIds;

  @Deprecated('Use activeSequenceIds ∪ orphanSequenceIds')
  Set<String> get sequenceIds => {...activeSequenceIds, ...orphanSequenceIds};

  /// Only active persisted alarms block delete. Orphans and open drafts do not.
  bool get canDelete => activeAlarmIds.isEmpty;

  bool get canDeleteSafely => canDelete;

  bool get isInOpenDraft =>
      blockingReason == SavedVoiceBlockingReason.openDraft ||
      draftSequenceIds.isNotEmpty;
}

/// Resolves saved-voice usage across sequences and alarms.
class SavedVoiceUsageService {
  SavedVoiceUsageService({
    AlarmRepository? alarms,
    VoiceSequenceRepository? sequences,
    SavedVoiceRepository? savedVoices,
    Set<String> draftSequenceIds = const {},
  }) : _alarms = alarms ?? AlarmRepository(),
       _sequences = sequences ?? VoiceSequenceRepository(),
       _savedVoices = savedVoices ?? SavedVoiceRepository(),
       _draftSequenceIds = draftSequenceIds;

  final AlarmRepository _alarms;
  final VoiceSequenceRepository _sequences;
  final SavedVoiceRepository _savedVoices;
  final Set<String> _draftSequenceIds;

  SavedVoiceUsage usageFor(String savedVoiceId) {
    final alarms = _alarms.loadAll();
    final linkedSequenceIds = alarms
        .map((a) => a.voiceSequenceId)
        .whereType<String>()
        .toSet();

    final activeSequenceIds = <String>{};
    final orphanSequenceIds = <String>{};
    final draftSequenceIds = <String>{};

    for (final sequence in _sequences.loadAll()) {
      final hits = sequence.segments.any(
        (s) => s.sourceSavedVoiceId == savedVoiceId || s.id == savedVoiceId,
      );
      if (!hits) continue;
      if (_draftSequenceIds.contains(sequence.id)) {
        draftSequenceIds.add(sequence.id);
      } else if (linkedSequenceIds.contains(sequence.id)) {
        activeSequenceIds.add(sequence.id);
      } else {
        orphanSequenceIds.add(sequence.id);
      }
    }

    // In-memory drafts that were never persisted.
    for (final draftId in _draftSequenceIds) {
      // Draft membership for unpersisted sequences is supplied by caller via
      // [draftSequenceIds] when the voice appears in the open draft provider.
      if (draftSequenceIds.contains(draftId)) continue;
    }

    final activeAlarmIds = <String>{};
    for (final alarm in alarms) {
      final seqId = alarm.voiceSequenceId;
      if (seqId != null && activeSequenceIds.contains(seqId)) {
        activeAlarmIds.add(alarm.id);
      }
    }

    var reason = SavedVoiceBlockingReason.none;
    if (activeAlarmIds.isNotEmpty) {
      reason = SavedVoiceBlockingReason.activeAlarms;
    } else if (draftSequenceIds.isNotEmpty) {
      reason = SavedVoiceBlockingReason.openDraft;
    }

    return SavedVoiceUsage(
      voiceId: savedVoiceId,
      activeAlarmIds: activeAlarmIds,
      activeSequenceIds: activeSequenceIds,
      orphanSequenceIds: orphanSequenceIds,
      draftSequenceIds: draftSequenceIds,
      blockingReason: reason,
    );
  }

  /// Marks a voice as present in an in-memory draft sequence.
  SavedVoiceUsage usageForWithDraftPresence(
    String savedVoiceId, {
    required bool inOpenDraft,
    String? openDraftSequenceId,
  }) {
    final base = usageFor(savedVoiceId);
    if (!inOpenDraft) return base;
    final drafts = {
      ...base.draftSequenceIds,
      if (openDraftSequenceId != null) openDraftSequenceId,
    };
    return SavedVoiceUsage(
      voiceId: savedVoiceId,
      activeAlarmIds: base.activeAlarmIds,
      activeSequenceIds: base.activeSequenceIds,
      orphanSequenceIds: base.orphanSequenceIds,
      draftSequenceIds: drafts,
      blockingReason: base.activeAlarmIds.isNotEmpty
          ? SavedVoiceBlockingReason.activeAlarms
          : SavedVoiceBlockingReason.openDraft,
    );
  }

  List<VoiceSegmentUiModel> unusedVoices() {
    return _savedVoices
        .loadAll()
        .where((v) => usageFor(v.id).canDelete)
        .toList();
  }

  List<AlarmUiModel> alarmsUsing(String savedVoiceId) {
    final usage = usageFor(savedVoiceId);
    if (usage.activeAlarmIds.isEmpty) return const [];
    return _alarms
        .loadAll()
        .where((a) => usage.activeAlarmIds.contains(a.id))
        .toList();
  }

  /// Idempotent: sequences not linked to any alarm are treated as orphans for
  /// usage (they do not block delete). Optionally delete empty orphan shells.
  Future<int> migrateOrphanSequences() async {
    final linked = _alarms
        .loadAll()
        .map((a) => a.voiceSequenceId)
        .whereType<String>()
        .toSet();
    var noted = 0;
    for (final sequence in _sequences.loadAll()) {
      if (linked.contains(sequence.id)) continue;
      noted += 1;
      // Do not delete automatically — orphans simply stop blocking usage.
    }
    return noted;
  }

  /// Idempotent best-effort backfill of [sourceSavedVoiceId] for old data.
  Future<int> migrateSourceLinks() async {
    var updated = 0;
    final saved = _savedVoices.loadAll();
    final byPath = <String, List<VoiceSegmentUiModel>>{};
    for (final voice in saved) {
      if (voice.type != VoiceSegmentType.recording) continue;
      final path = voice.filePath;
      if (path == null || path.isEmpty) continue;
      byPath.putIfAbsent(path, () => []).add(voice);
    }

    for (final sequence in _sequences.loadAll()) {
      var dirty = false;
      final segments = <VoiceSegmentUiModel>[];
      for (final segment in sequence.segments) {
        if (segment.sourceSavedVoiceId != null) {
          segments.add(segment);
          continue;
        }

        String? linked;
        if (segment.type == VoiceSegmentType.recording) {
          final path = segment.filePath;
          final candidates = path == null
              ? const <VoiceSegmentUiModel>[]
              : byPath[path];
          if (candidates != null && candidates.length == 1) {
            linked = candidates.single.id;
          } else if (saved.any((v) => v.id == segment.id)) {
            linked = segment.id;
          }
        } else if (segment.type == VoiceSegmentType.tts) {
          if (saved.any((v) => v.id == segment.id)) {
            linked = segment.id;
          } else {
            final text = segment.text?.trim() ?? '';
            final matches = saved.where(
              (v) =>
                  v.type == VoiceSegmentType.tts &&
                  (v.text?.trim() ?? '') == text &&
                  text.isNotEmpty &&
                  v.localeId == segment.localeId,
            );
            if (matches.length == 1) {
              linked = matches.single.id;
            }
          }
        }

        if (linked != null) {
          segments.add(segment.copyWith(sourceSavedVoiceId: linked));
          dirty = true;
          updated += 1;
        } else {
          segments.add(segment);
        }
      }
      if (dirty) {
        await _sequences.upsert(sequence.copyWith(segments: segments));
      }
    }
    return updated;
  }

  Future<bool> deleteUnused(VoiceSegmentUiModel voice) async {
    final usage = usageFor(voice.id);
    if (!usage.canDelete) return false;
    await _savedVoices.delete(voice.id);
    if (voice.type == VoiceSegmentType.recording) {
      await RecordingFileStore.deleteIfUnreferenced(
        voice.filePath,
        sequences: _sequences.loadAll(),
        savedVoices: _savedVoices.loadAll(),
      );
    }
    return true;
  }

  Future<int> estimateRecordingBytes(List<VoiceSegmentUiModel> voices) async {
    var total = 0;
    for (final voice in voices) {
      if (voice.type != VoiceSegmentType.recording) continue;
      final path = voice.filePath;
      if (path == null || path.isEmpty) continue;
      total += await io_file.fileLength(path);
    }
    return total;
  }
}
