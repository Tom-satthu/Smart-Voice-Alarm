import '../../shared/models/ui_models.dart';
import 'alarm_kit_timeline_config.dart';
import 'ios_alarm_scheduler.dart';

class PreparedAlarmClip {
  const PreparedAlarmClip({
    required this.fileName,
    required this.duration,
    this.label = '',
    this.contentDuration,
    this.trailingSilence = Duration.zero,
  });

  final String fileName;

  /// Finalized CAF duration (content + trailing silence) used by the planner.
  final Duration duration;
  final String label;
  final Duration? contentDuration;
  final Duration trailingSilence;
}

PreparedAlarmClip preparedClip({
  required String fileName,
  required Duration duration,
  String label = '',
  Duration? contentDuration,
  Duration trailingSilence = Duration.zero,
}) => PreparedAlarmClip(
  fileName: fileName,
  duration: duration,
  label: label,
  contentDuration: contentDuration,
  trailingSilence: trailingSilence,
);

class IosPlanValidationException implements Exception {
  IosPlanValidationException(this.code, this.message);
  final String code;
  final String message;
  @override
  String toString() => 'IosPlanValidationException($code): $message';
}

/// Result of [IosAlarmSegmentPlanner.plan] including rolling-horizon metadata.
class IosAlarmPlan {
  const IosAlarmPlan({
    required this.segments,
    required this.cycleDuration,
    required this.cyclesScheduled,
    required this.rollingHorizon,
    required this.audibleChildCount,
    required this.silentChildCount,
    required this.childrenPerCycle,
  });

  final List<IosAlarmSegment> segments;
  final Duration cycleDuration;
  final int cyclesScheduled;
  final Duration rollingHorizon;
  final int audibleChildCount;
  final int silentChildCount;
  final int childrenPerCycle;

  int get childCount => segments.length;
  DateTime? get lastScheduledEnd {
    if (segments.isEmpty) return null;
    final last = segments.last;
    return last.startAt.add(last.duration);
  }
}

/// Pure planner for iOS AlarmKit / notification fan-out.
///
/// Timeline (mixed):
/// voice(file=content+trailingSilence) → silence gap 5s → …
/// → ringtone(file=10s+trailing) → silence gap 5s → next cycle
///
/// Planner does **not** add extra transition padding; that lives inside CAF files.
class IosAlarmSegmentPlanner {
  IosAlarmSegmentPlanner({
    this.maxVoiceSegments = 5,
    this.maxRingtoneSegments = 1,
    this.gap = AlarmKitTimelineConfig.silenceGap,
    this.maxVoiceDuration = AlarmKitTimelineConfig.maxVoiceContentDuration,
    this.ringtoneDuration = AlarmKitTimelineConfig.ringtoneDuration,
    this.maxChildren = AlarmKitTimelineConfig.maxChildren,
    this.targetHorizon = AlarmKitTimelineConfig.targetHorizon,
    this.silenceFileName = kSvaSilenceFileName,
  });

  static const defaultSilenceFileName = kSvaSilenceFileName;

  final int maxVoiceSegments;
  final int maxRingtoneSegments;
  final Duration gap;
  final Duration maxVoiceDuration;
  final Duration ringtoneDuration;
  final int maxChildren;
  final Duration targetHorizon;
  final String silenceFileName;

  @Deprecated('Use maxChildren / childrenPerCycle instead')
  int get maxNotifications => maxChildren;

  static String occurrenceIdFor(AlarmUiModel alarm, DateTime occurrence) {
    final stamp =
        '${occurrence.year}${occurrence.month.toString().padLeft(2, '0')}'
        '${occurrence.day.toString().padLeft(2, '0')}_'
        '${occurrence.hour.toString().padLeft(2, '0')}'
        '${occurrence.minute.toString().padLeft(2, '0')}';
    return '${alarm.id}_$stamp';
  }

  static String soundFileName({
    required String parentId,
    required String occurrenceId,
    required int segmentIndex,
    required String revision,
  }) {
    final seed = '$parentId|$occurrenceId|$segmentIndex';
    final hash = seed.hashCode.toUnsigned(32).toRadixString(16);
    return 'sva_${hash}_$revision.caf';
  }

  static String childIdFor({
    required String parentId,
    required String occurrenceId,
    required int cycleIndex,
    required int segmentIndex,
    required String role,
    int recoveryGeneration = 0,
  }) {
    final seed =
        '$parentId|$occurrenceId|$cycleIndex|$segmentIndex|$role|g$recoveryGeneration';
    final hash = seed.hashCode.toUnsigned(32).toRadixString(16);
    return 'sva_c_${hash}_g${recoveryGeneration}_$cycleIndex'
        '_$segmentIndex';
  }

  int childrenPerCycle({
    required AlarmType type,
    required int voiceClipCount,
    required int ringtoneClipCount,
  }) {
    final voices = type == AlarmType.ringtone
        ? 0
        : voiceClipCount.clamp(0, maxVoiceSegments);
    final tones = type == AlarmType.voice
        ? 0
        : ringtoneClipCount.clamp(0, maxRingtoneSegments);
    if (type == AlarmType.ringtone) {
      return tones.clamp(1, maxRingtoneSegments) + 1;
    }
    if (type == AlarmType.voice) {
      return voices * 2;
    }
    return voices * 2 + tones + 1;
  }

  int estimateNotificationCount({
    required AlarmUiModel alarm,
    required int voiceClipCount,
    required int ringtoneClipCount,
    int cycles = 1,
  }) {
    return childrenPerCycle(
          type: alarm.type,
          voiceClipCount: voiceClipCount,
          ringtoneClipCount: ringtoneClipCount,
        ) *
        cycles.clamp(1, 1000);
  }

  Duration cycleDurationFor({
    required AlarmType type,
    required List<PreparedAlarmClip> voiceClips,
    required List<PreparedAlarmClip> ringtoneClips,
  }) {
    var total = Duration.zero;
    if (type != AlarmType.ringtone) {
      for (final clip in voiceClips.take(maxVoiceSegments)) {
        total += _clampFinalized(clip.duration) + gap;
      }
    }
    if (type != AlarmType.voice && ringtoneClips.isNotEmpty) {
      total += _clampRingtone(ringtoneClips.first) + gap;
    }
    return total;
  }

  List<Map<String, dynamic>> cycleTemplateMaps({
    required AlarmType type,
    required List<PreparedAlarmClip> voiceClips,
    required List<PreparedAlarmClip> ringtoneClips,
  }) {
    final out = <Map<String, dynamic>>[];
    if (type != AlarmType.ringtone) {
      for (final clip in voiceClips.take(maxVoiceSegments)) {
        final duration = _clampFinalized(clip.duration);
        out.add({
          'role': IosSegmentRole.voice.name,
          'soundFileName': clip.fileName,
          'durationMs': duration.inMilliseconds,
          'contentDurationMs':
              (clip.contentDuration ?? duration).inMilliseconds,
          'trailingSilenceMs': clip.trailingSilence.inMilliseconds,
          'label': clip.label.isEmpty ? 'voice' : clip.label,
        });
        out.add({
          'role': IosSegmentRole.silence.name,
          'soundFileName': silenceFileName,
          'durationMs': gap.inMilliseconds,
          'contentDurationMs': gap.inMilliseconds,
          'trailingSilenceMs': 0,
          'label': 'silence',
        });
      }
    }
    if (type != AlarmType.voice && ringtoneClips.isNotEmpty) {
      final clip = ringtoneClips.first;
      final duration = _clampRingtone(clip);
      out.add({
        'role': IosSegmentRole.ringtone.name,
        'soundFileName': clip.fileName,
        'durationMs': duration.inMilliseconds,
        'contentDurationMs':
            (clip.contentDuration ?? ringtoneDuration).inMilliseconds,
        'trailingSilenceMs':
            (clip.trailingSilence > Duration.zero
                    ? clip.trailingSilence
                    : AlarmKitTimelineConfig.trailingSilence)
                .inMilliseconds,
        'label': clip.label.isEmpty ? 'ringtone' : clip.label,
      });
      out.add({
        'role': IosSegmentRole.silence.name,
        'soundFileName': silenceFileName,
        'durationMs': gap.inMilliseconds,
        'contentDurationMs': gap.inMilliseconds,
        'trailingSilenceMs': 0,
        'label': 'silence',
      });
    }
    return out;
  }

  IosAlarmPlan plan({
    required AlarmUiModel alarm,
    required String occurrenceId,
    required DateTime occurrenceStart,
    required List<PreparedAlarmClip> voiceClips,
    required List<PreparedAlarmClip> ringtoneClips,
    int? maxCyclesOverride,
    int recoveryGeneration = 0,
  }) {
    final includeVoice =
        alarm.type != AlarmType.ringtone && voiceClips.isNotEmpty;
    final includeRingtone =
        alarm.type != AlarmType.voice && ringtoneClips.isNotEmpty;

    final voices = includeVoice
        ? voiceClips.take(maxVoiceSegments).toList()
        : const <PreparedAlarmClip>[];
    final tones = includeRingtone
        ? ringtoneClips.take(maxRingtoneSegments).toList()
        : const <PreparedAlarmClip>[];

    if (alarm.type == AlarmType.mixed && voices.isNotEmpty && tones.isEmpty) {
      throw IosPlanValidationException(
        'mixed_missing_ringtone',
        'Mixed alarm requires a ringtone clip',
      );
    }
    if (alarm.type == AlarmType.voice && voices.isEmpty) {
      throw IosPlanValidationException(
        'voice_empty',
        'Voice alarm requires at least one voice clip',
      );
    }
    if (alarm.type == AlarmType.ringtone && tones.isEmpty) {
      throw IosPlanValidationException(
        'ringtone_empty',
        'Ringtone alarm requires a ringtone clip',
      );
    }

    final perCycle = childrenPerCycle(
      type: alarm.type,
      voiceClipCount: voices.length,
      ringtoneClipCount: tones.length,
    );
    if (perCycle <= 0 || perCycle > maxChildren) {
      throw IosPlanValidationException(
        'notification_limit',
        'One cycle needs $perCycle children (max $maxChildren)',
      );
    }

    final cycleDuration = cycleDurationFor(
      type: alarm.type,
      voiceClips: voices,
      ringtoneClips: tones,
    );
    final maxByChildren = maxChildren ~/ perCycle;
    final maxByHorizon = cycleDuration.inMilliseconds <= 0
        ? 1
        : (targetHorizon.inMilliseconds / cycleDuration.inMilliseconds)
              .floor()
              .clamp(1, 1000);
    final cycles = (maxCyclesOverride ?? maxByHorizon).clamp(1, maxByChildren);

    final out = <IosAlarmSegment>[];
    var cursor = occurrenceStart;
    var index = 0;
    var audible = 0;
    var silent = 0;

    for (var cycle = 0; cycle < cycles; cycle++) {
      if (alarm.type != AlarmType.ringtone) {
        for (final clip in voices) {
          final duration = _clampFinalized(clip.duration);
          out.add(
            _segment(
              alarm: alarm,
              occurrenceId: occurrenceId,
              index: index,
              cycleIndex: cycle,
              startAt: cursor,
              duration: duration,
              fileName: clip.fileName,
              role: IosSegmentRole.voice,
              label: clip.label.isEmpty ? 'voice' : clip.label,
              recoveryGeneration: recoveryGeneration,
            ),
          );
          audible += 1;
          cursor = cursor.add(duration);
          index += 1;

          out.add(
            _segment(
              alarm: alarm,
              occurrenceId: occurrenceId,
              index: index,
              cycleIndex: cycle,
              startAt: cursor,
              duration: gap,
              fileName: silenceFileName,
              role: IosSegmentRole.silence,
              label: 'silence',
              recoveryGeneration: recoveryGeneration,
            ),
          );
          silent += 1;
          cursor = cursor.add(gap);
          index += 1;
        }
      }

      if (includeRingtone) {
        final clip = tones.first;
        final duration = _clampRingtone(clip);
        out.add(
          _segment(
            alarm: alarm,
            occurrenceId: occurrenceId,
            index: index,
            cycleIndex: cycle,
            startAt: cursor,
            duration: duration,
            fileName: clip.fileName,
            role: IosSegmentRole.ringtone,
            label: clip.label.isEmpty ? 'ringtone' : clip.label,
            recoveryGeneration: recoveryGeneration,
          ),
        );
        audible += 1;
        cursor = cursor.add(duration);
        index += 1;

        out.add(
          _segment(
            alarm: alarm,
            occurrenceId: occurrenceId,
            index: index,
            cycleIndex: cycle,
            startAt: cursor,
            duration: gap,
            fileName: silenceFileName,
            role: IosSegmentRole.silence,
            label: 'silence',
            recoveryGeneration: recoveryGeneration,
          ),
        );
        silent += 1;
        cursor = cursor.add(gap);
        index += 1;
      }
    }

    return IosAlarmPlan(
      segments: out,
      cycleDuration: cycleDuration,
      cyclesScheduled: cycles,
      rollingHorizon: cursor.difference(occurrenceStart),
      audibleChildCount: audible,
      silentChildCount: silent,
      childrenPerCycle: perCycle,
    );
  }

  IosAlarmSegment _segment({
    required AlarmUiModel alarm,
    required String occurrenceId,
    required int index,
    required int cycleIndex,
    required DateTime startAt,
    required Duration duration,
    required String fileName,
    required IosSegmentRole role,
    required String label,
    required int recoveryGeneration,
  }) {
    return IosAlarmSegment(
      parentAlarmId: alarm.id,
      occurrenceId: occurrenceId,
      segmentIndex: index,
      childId: childIdFor(
        parentId: alarm.id,
        occurrenceId: occurrenceId,
        cycleIndex: cycleIndex,
        segmentIndex: index,
        role: role.name,
        recoveryGeneration: recoveryGeneration,
      ),
      startAt: startAt,
      soundFileName: fileName,
      duration: duration,
      label: label,
      role: role,
      cycleIndex: cycleIndex,
      recoveryGeneration: recoveryGeneration,
    );
  }

  /// Finalized CAF may be content+trailing; clamp soft upper to content max + trail + 1s.
  Duration _clampFinalized(Duration duration) {
    if (duration <= Duration.zero) return const Duration(seconds: 1);
    final maxFinal =
        maxVoiceDuration +
        AlarmKitTimelineConfig.trailingSilence +
        const Duration(seconds: 1);
    if (duration > maxFinal) return maxFinal;
    return duration;
  }

  /// Ringtone content is exactly [ringtoneDuration]; file may include trailing silence.
  Duration _clampRingtone(PreparedAlarmClip clip) {
    final trail = clip.trailingSilence > Duration.zero
        ? clip.trailingSilence
        : AlarmKitTimelineConfig.trailingSilence;
    final expected = ringtoneDuration + trail;
    if (clip.duration > Duration.zero &&
        clip.duration <= expected + const Duration(milliseconds: 500)) {
      // Prefer measured finalized duration when present.
      if (clip.contentDuration != null ||
          clip.trailingSilence > Duration.zero ||
          clip.duration >= ringtoneDuration) {
        return clip.duration <= expected ? clip.duration : expected;
      }
    }
    return expected;
  }
}
