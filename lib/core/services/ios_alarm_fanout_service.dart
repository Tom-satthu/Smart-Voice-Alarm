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

  /// Launch-safe path: never renders audio, never schedules, never cancels.
  /// Existing pending notifications are left untouched.
  Future<void> reconcileWithoutRender(List<AlarmUiModel> alarms) async {
    if (!isSupported) return;
    debugPrint(
      '[SVA-Startup] reconcileWithoutRender no-op '
      '(alarms=${alarms.length}; no schedule/cancel/render)',
    );
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

    Future<IosScheduleResult> failRender({
      required String code,
      required String message,
    }) async {
      debugPrint('[SVA-Schedule] render abort code=$code msg=$message');
      for (final name in renderedNames) {
        try {
          await _scheduler.deleteSoundFile(name);
        } catch (_) {}
      }
      return IosScheduleResult(
        ok: false,
        errorCode: code,
        errorMessage: message,
        needsAudioRepair: true,
      );
    }

    if (alarm.type != AlarmType.ringtone) {
      final sequence = alarm.voiceSequenceId == null
          ? null
          : _sequences.findById(alarm.voiceSequenceId!);
      final segments = sequence?.segments ?? const <VoiceSegmentUiModel>[];
      if (segments.isEmpty && alarm.type == AlarmType.voice) {
        return failRender(
          code: 'voice_empty',
          message: 'Voice alarm has no segments to render',
        );
      }
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
          if (rendered.durationMs <= 0 || rendered.path.isEmpty) {
            return failRender(
              code: 'render_invalid',
              message: 'Rendered voice segment invalid: ${segment.id}',
            );
          }
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
          // Never silently drop a failed required voice segment.
          return failRender(code: 'voice_render_failed', message: '$e');
        }
      }
      if (alarm.type != AlarmType.ringtone &&
          segments.isNotEmpty &&
          voiceClips.isEmpty) {
        return failRender(
          code: 'voice_render_empty',
          message: 'No voice clips rendered',
        );
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
        // Ringtone-only may fall back to system default. Mixed/voice must not
        // become ringtone-only when voice was required — voice path already
        // failed hard above. For ringtone/mixed ringtone part, keep default.
        if (alarm.type == AlarmType.ringtone) {
          ringtoneClips.add(
            preparedClip(
              fileName: '',
              duration: const Duration(seconds: 8),
              label: 'fallback',
            ),
          );
        } else if (voiceClips.isEmpty) {
          return failRender(code: 'ringtone_render_failed', message: '$e');
        } else {
          // Mixed with successful voice: keep voice clips; omit broken ringtone.
          debugPrint(
            '[SVA-Schedule] mixed alarm keeps voice; ringtone omitted after error',
          );
        }
      }
    }

    if (voiceClips.isEmpty && ringtoneClips.isEmpty) {
      debugPrint('[SVA-Schedule] no clips — keeping old schedule');
      return failRender(
        code: 'render_empty',
        message: 'Unable to render alarm audio',
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
      for (final name in renderedNames) {
        try {
          await _scheduler.deleteSoundFile(name);
        } catch (_) {}
      }
      return IosScheduleResult(
        ok: false,
        errorCode: 'schedule_failed',
        errorMessage: '$e',
        needsAudioRepair: true,
      );
    }

    // Phase 3 — only now remove previous children for this parent.
    try {
      await _scheduler.cancelParentExcept(
        parentAlarmId: alarm.id,
        keepChildIds: planned.map((s) => s.childId).toSet(),
      );
    } catch (e) {
      debugPrint('[SVA-Schedule] selective cancel failed: $e');
    }

    // Do NOT cleanupOrphanSounds with only this alarm's new files — that would
    // delete other alarms' rendered CAF files. Only delete superseded files for
    // this parent once we have a full active manifest (not in this path).

    debugPrint(
      '[SVA-Schedule] success parent=${alarm.id} segments=${planned.length}',
    );
    return const IosScheduleResult(ok: true);
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
