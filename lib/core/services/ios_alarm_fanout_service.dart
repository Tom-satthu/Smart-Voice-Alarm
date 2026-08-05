import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../shared/data/local_store.dart';
import '../../shared/models/ui_models.dart';
import 'ios_alarm_scheduler.dart';
import 'ios_alarm_segment_planner.dart';

/// Renders voice/ringtone clips and schedules iOS fan-out segments.
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

  Future<void> scheduleAlarm(AlarmUiModel alarm, DateTime occurrence) async {
    if (!_scheduler.isSupported) return;
    if (!alarm.isEnabled) {
      await cancelAlarm(alarm.id);
      return;
    }

    // Replace any prior children for this parent before materializing.
    await cancelAlarm(alarm.id);

    final occurrenceId = IosAlarmSegmentPlanner.occurrenceIdFor(
      alarm,
      occurrence,
    );
    final revision = _uuid.v4().substring(0, 8);

    final voiceClips = <PreparedAlarmClip>[];
    final ringtoneClips = <PreparedAlarmClip>[];

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
          voiceClips.add(
            preparedClip(
              fileName: rendered.fileName,
              duration: Duration(milliseconds: rendered.durationMs),
              label: segment.name,
            ),
          );
          voiceIndex += 1;
        } catch (e) {
          debugPrint('iOS voice render failed for ${segment.id}: $e');
          // Skip failed segment rather than scheduling silent alarm.
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
        final full = Duration(milliseconds: rendered.durationMs);
        // Split long ringtone into at most 2 segments of ~15s each.
        if (full.inSeconds > 20) {
          final first = Duration(
            milliseconds: (full.inMilliseconds / 2).round().clamp(1000, 15000),
          );
          ringtoneClips.add(
            preparedClip(
              fileName: rendered.fileName,
              duration: first,
              label: alarm.ringtoneName ?? 'Ringtone',
            ),
          );
          final secondName = IosAlarmSegmentPlanner.soundFileName(
            parentId: alarm.id,
            occurrenceId: occurrenceId,
            segmentIndex: 101,
            revision: revision,
          );
          final secondRendered = await _scheduler.renderSound(
            fileName: secondName,
            assetKey: key,
            maxSeconds: 15,
          );
          ringtoneClips.add(
            preparedClip(
              fileName: secondRendered.fileName,
              duration: Duration(milliseconds: secondRendered.durationMs),
              label: alarm.ringtoneName ?? 'Ringtone',
            ),
          );
        } else {
          ringtoneClips.add(
            preparedClip(
              fileName: rendered.fileName,
              duration: full <= Duration.zero
                  ? const Duration(seconds: 5)
                  : full,
              label: alarm.ringtoneName ?? 'Ringtone',
            ),
          );
        }
      } catch (e) {
        debugPrint('iOS ringtone render failed: $e');
        // Fallback: schedule with empty sound name → system default.
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
      // Always schedule at least one audible system notification so the
      // Math Challenge path can open even when render fails.
      debugPrint('iOS schedule: no rendered clips — using default sound');
      ringtoneClips.add(
        preparedClip(
          fileName: '',
          duration: const Duration(seconds: 8),
          label: 'fallback',
        ),
      );
    }

    final planned = _planner.plan(
      alarm: alarm,
      occurrenceId: occurrenceId,
      occurrenceStart: occurrence,
      voiceClips: voiceClips,
      ringtoneClips: ringtoneClips,
    );

    // Also materialize the next occurrence for repeating alarms if within 36h.
    final segments = List<IosAlarmSegment>.from(planned);
    await _scheduler.scheduleSegments(
      segments: segments,
      title: alarm.label.isEmpty ? 'Smart Voice Alarm' : alarm.label,
      body: 'Solve to stop',
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
    // Map display names like "Soft Chime" → soft_chime
    return slug;
  }

  /// Next occurrence helper for optional second materialization.
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
