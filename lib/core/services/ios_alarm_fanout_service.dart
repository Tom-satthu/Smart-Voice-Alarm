import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../shared/data/local_store.dart';
import '../../shared/models/ui_models.dart';
import 'ios_alarm_scheduler.dart';
import 'ios_alarm_segment_planner.dart';

/// Outcome of an iOS schedule attempt (structured for UI / logs).
class IosScheduleResult {
  const IosScheduleResult({
    required this.ok,
    this.errorCode,
    this.errorMessage,
    this.needsAudioRepair = false,
  });

  final bool ok;
  final String? errorCode;
  final String? errorMessage;
  final bool needsAudioRepair;
}

/// Renders voice/ringtone clips and schedules iOS fan-out segments.
///
/// Uses a two-phase transaction: never cancel the previous schedule until the
/// new revision has been fully rendered, validated, and scheduled.
class IosAlarmFanoutService {
  IosAlarmFanoutService({
    IosAlarmScheduler? scheduler,
    VoiceSequenceRepository? sequences,
    IosAlarmSegmentPlanner? planner,
  }) : _scheduler = scheduler ?? IosAlarmScheduler(),
       _sequences = sequences ?? VoiceSequenceRepository(),
       _planner = planner ?? IosAlarmSegmentPlanner();

  final IosAlarmScheduler _scheduler;
  final VoiceSequenceRepository _sequences;
  final IosAlarmSegmentPlanner _planner;
  final _uuid = const Uuid();

  IosAlarmScheduler get scheduler => _scheduler;

  bool get isSupported => _scheduler.isSupported;

  Future<IosAlarmCapability> capability() => _scheduler.getCapability();

  Future<void> cancelAlarm(String alarmId) => _scheduler.cancelParent(alarmId);

  Future<void> cancelOccurrence({
    required String parentAlarmId,
    required String occurrenceId,
  }) {
    return _scheduler.cancelOccurrence(
      parentAlarmId: parentAlarmId,
      occurrenceId: occurrenceId,
    );
  }

  /// Launch-safe path: never renders audio. Leaves existing system schedules
  /// intact and may add a default-sound placeholder for the next fire.
  Future<void> reconcileWithoutRender(List<AlarmUiModel> alarms) async {
    if (!isSupported) return;
    debugPrint('[SVA-Startup] reconcileWithoutRender alarms=${alarms.length}');
    for (final alarm in alarms) {
      if (!alarm.isEnabled) continue;
      final next = _nextOccurrence(alarm);
      if (next == null) continue;
      try {
        // Placeholder only — empty soundFileName → system default. New child
        // UUID so we never collide with / cancel existing revision children.
        final occurrenceId = IosAlarmSegmentPlanner.occurrenceIdFor(
          alarm,
          next,
        );
        final placeholder = IosAlarmSegment(
          parentAlarmId: alarm.id,
          occurrenceId: occurrenceId,
          segmentIndex: 900,
          childId: 'sva_fallback_${alarm.id}_${_uuid.v4().substring(0, 8)}',
          startAt: next,
          soundFileName: '',
          duration: const Duration(seconds: 8),
          label: 'fallback',
        );
        await _scheduler.scheduleSegments(
          segments: [placeholder],
          title: alarm.label.isEmpty ? 'Smart Voice Alarm' : alarm.label,
          body: 'Solve to stop',
        );
        debugPrint(
          '[SVA-Schedule] fallback placeholder scheduled for ${alarm.id}',
        );
      } catch (e) {
        debugPrint('[SVA-Schedule] fallback failed for ${alarm.id}: $e');
      }
    }
  }

  Future<IosScheduleResult> scheduleAlarm(
    AlarmUiModel alarm,
    DateTime occurrence,
  ) async {
    if (!_scheduler.isSupported) {
      return const IosScheduleResult(ok: true);
    }
    if (!alarm.isEnabled) {
      await cancelAlarm(alarm.id);
      return const IosScheduleResult(ok: true);
    }

    final occurrenceId = IosAlarmSegmentPlanner.occurrenceIdFor(
      alarm,
      occurrence,
    );
    final revision = _uuid.v4().substring(0, 8);
    debugPrint(
      '[SVA-Schedule] begin parent=${alarm.id} occurrence=$occurrenceId rev=$revision',
    );

    // Phase 1 — render new revision (do NOT cancel old schedule yet).
    final voiceClips = <PreparedAlarmClip>[];
    final ringtoneClips = <PreparedAlarmClip>[];
    final renderedNames = <String>[];
    var renderFailed = false;

    if (alarm.type != AlarmType.ringtone) {
      final sequence = alarm.voiceSequenceId == null
          ? null
          : _sequences.findById(alarm.voiceSequenceId!);
      final segments = sequence?.segments ?? const <VoiceSegmentUiModel>[];
      var voiceIndex = 0;
      for (final segment in segments) {
        if (voiceIndex >= 5) break;
        try {
          final fileName = IosAlarmSegmentPlanner.soundFileName(
            parentId: alarm.id,
            occurrenceId: occurrenceId,
            segmentIndex: voiceIndex,
            revision: revision,
          );
          final rendered = await _renderVoiceSegment(segment, fileName);
          renderedNames.add(rendered.fileName);
          voiceClips.add(
            preparedClip(
              fileName: rendered.fileName,
              duration: Duration(milliseconds: rendered.durationMs),
              label: segment.name,
            ),
          );
          voiceIndex += 1;
        } catch (e) {
          debugPrint('[SVA-Audio] voice render failed ${segment.id}: $e');
          renderFailed = true;
        }
      }
    }

    if (alarm.type != AlarmType.voice) {
      final key = _ringtoneAssetKey(alarm.ringtoneName);
      try {
        final fileName = IosAlarmSegmentPlanner.soundFileName(
          parentId: alarm.id,
          occurrenceId: occurrenceId,
          segmentIndex: 100,
          revision: revision,
        );
        final rendered = await _scheduler.renderSound(
          fileName: fileName,
          assetKey: key,
          maxSeconds: 30,
        );
        renderedNames.add(rendered.fileName);
        final full = Duration(milliseconds: rendered.durationMs);
        ringtoneClips.add(
          preparedClip(
            fileName: rendered.fileName,
            duration: full <= Duration.zero
                ? const Duration(seconds: 5)
                : (full.inSeconds > 20 ? const Duration(seconds: 15) : full),
            label: alarm.ringtoneName ?? 'Ringtone',
          ),
        );
      } catch (e) {
        debugPrint('[SVA-Audio] ringtone render failed: $e');
        ringtoneClips.add(
          preparedClip(
            fileName: '',
            duration: const Duration(seconds: 8),
            label: 'fallback',
          ),
        );
      }
    }

    if (voiceClips.isEmpty && ringtoneClips.isEmpty) {
      debugPrint('[SVA-Schedule] no clips — keeping old schedule');
      return IosScheduleResult(
        ok: false,
        errorCode: 'render_empty',
        errorMessage: 'Unable to render alarm audio',
        needsAudioRepair: true,
      );
    }

    final planned = _planner.plan(
      alarm: alarm,
      occurrenceId: occurrenceId,
      occurrenceStart: occurrence,
      voiceClips: voiceClips,
      ringtoneClips: ringtoneClips,
    );

    // Phase 2 — schedule new children (unique UUIDs), then cancel old.
    try {
      await _scheduler.scheduleSegments(
        segments: planned,
        title: alarm.label.isEmpty ? 'Smart Voice Alarm' : alarm.label,
        body: 'Solve to stop',
      );
    } catch (e) {
      debugPrint('[SVA-Schedule] new schedule failed, keeping old: $e');
      // Leave old notifications + old files. Best-effort delete only the
      // newly rendered revision files that were never scheduled.
      for (final name in renderedNames) {
        try {
          await _scheduler.deleteSoundFile(name);
        } catch (_) {}
      }
      return IosScheduleResult(
        ok: false,
        errorCode: 'schedule_failed',
        errorMessage: '$e',
        needsAudioRepair: renderFailed,
      );
    }

    // Phase 3 — only now remove previous children for this parent.
    // New child IDs are already registered in the native child map; cancelParent
    // removes by map prefix then we re-save the new map entries by scheduling
    // again is wrong. Instead cancel only IDs not in the new plan.
    try {
      await _scheduler.cancelParentExcept(
        parentAlarmId: alarm.id,
        keepChildIds: planned.map((s) => s.childId).toSet(),
      );
    } catch (e) {
      debugPrint('[SVA-Schedule] selective cancel failed: $e');
    }

    // Cleanup orphaned CAF files not referenced by the new revision.
    try {
      await _scheduler.cleanupOrphanSounds(renderedNames.toSet());
    } catch (e) {
      debugPrint('[SVA-Audio] orphan cleanup skipped: $e');
    }

    debugPrint(
      '[SVA-Schedule] success parent=${alarm.id} segments=${planned.length}',
    );
    return IosScheduleResult(
      ok: true,
      needsAudioRepair: renderFailed && voiceClips.isEmpty,
    );
  }

  Future<IosRenderedSound> _renderVoiceSegment(
    VoiceSegmentUiModel segment,
    String fileName,
  ) {
    if (segment.type == VoiceSegmentType.tts) {
      return _scheduler.renderSound(
        fileName: fileName,
        ttsText: segment.text ?? segment.name,
        ttsLocale: segment.localeId,
        maxSeconds: 20,
      );
    }
    final path = segment.filePath;
    if (path == null || path.isEmpty) {
      throw StateError('Recording segment missing file path');
    }
    return _scheduler.renderSound(
      fileName: fileName,
      sourcePath: path,
      maxSeconds: 20,
    );
  }

  String _ringtoneAssetKey(String? name) {
    if (name == null || name.isEmpty) return 'soft_chime';
    final slug = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (slug.isEmpty) return 'soft_chime';
    return slug;
  }

  DateTime? _nextOccurrence(AlarmUiModel alarm) {
    final now = DateTime.now();
    for (var offset = 0; offset < 8; offset++) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: offset));
      final candidate = DateTime(
        day.year,
        day.month,
        day.day,
        alarm.time.hour,
        alarm.time.minute,
      );
      if (!candidate.isAfter(now)) continue;
      if (alarm.repeatDays.isEmpty) return candidate;
      final weekday = switch (candidate.weekday) {
        DateTime.monday => Weekday.monday,
        DateTime.tuesday => Weekday.tuesday,
        DateTime.wednesday => Weekday.wednesday,
        DateTime.thursday => Weekday.thursday,
        DateTime.friday => Weekday.friday,
        DateTime.saturday => Weekday.saturday,
        _ => Weekday.sunday,
      };
      if (alarm.repeatDays.contains(weekday)) return candidate;
    }
    return null;
  }

  DateTime? nextAfter(AlarmUiModel alarm, DateTime from) {
    for (var offset = 1; offset < 8; offset++) {
      final day = from.add(Duration(days: offset));
      final candidate = DateTime(
        day.year,
        day.month,
        day.day,
        alarm.time.hour,
        alarm.time.minute,
      );
      if (alarm.repeatDays.isEmpty) return candidate;
      final weekday = switch (candidate.weekday) {
        DateTime.monday => Weekday.monday,
        DateTime.tuesday => Weekday.tuesday,
        DateTime.wednesday => Weekday.wednesday,
        DateTime.thursday => Weekday.thursday,
        DateTime.friday => Weekday.friday,
        DateTime.saturday => Weekday.saturday,
        _ => Weekday.sunday,
      };
      if (alarm.repeatDays.contains(weekday)) return candidate;
    }
    return null;
  }
}
