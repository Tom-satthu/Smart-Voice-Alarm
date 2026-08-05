import 'package:uuid/uuid.dart';

import '../../shared/models/ui_models.dart';
import 'ios_alarm_scheduler.dart';

class PreparedAlarmClip {
  const PreparedAlarmClip({
    required this.fileName,
    required this.duration,
    this.label = '',
  });

  final String fileName;
  final Duration duration;
  final String label;
}

PreparedAlarmClip preparedClip({
  required String fileName,
  required Duration duration,
  String label = '',
}) => PreparedAlarmClip(fileName: fileName, duration: duration, label: label);

class IosPlanValidationException implements Exception {
  IosPlanValidationException(this.code, this.message);
  final String code;
  final String message;
  @override
  String toString() => 'IosPlanValidationException($code): $message';
}

/// Pure planner for iOS fan-out segments.
///
/// Voice sequence is repeated [AlarmUiModel.repeatCount] times.
/// Ringtone (mixed) starts after the last voice of the last repeat + gap.
class IosAlarmSegmentPlanner {
  IosAlarmSegmentPlanner({
    this.maxVoiceSegments = 5,
    this.maxRingtoneSegments = 2,
    this.gap = const Duration(seconds: 5),
    this.maxVoiceDuration = const Duration(seconds: 20),
    this.maxNotifications = 64,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final int maxVoiceSegments;
  final int maxRingtoneSegments;
  final Duration gap;
  final Duration maxVoiceDuration;
  final int maxNotifications;
  final Uuid _uuid;

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

  int estimateNotificationCount({
    required AlarmUiModel alarm,
    required int voiceClipCount,
    required int ringtoneClipCount,
  }) {
    final voices = alarm.type == AlarmType.ringtone
        ? 0
        : voiceClipCount.clamp(0, maxVoiceSegments);
    final repeats = alarm.repeatCount.clamp(1, 20);
    final tones = alarm.type == AlarmType.voice
        ? 0
        : ringtoneClipCount.clamp(0, maxRingtoneSegments);
    if (alarm.type == AlarmType.ringtone) {
      return tones.clamp(1, maxRingtoneSegments);
    }
    if (alarm.type == AlarmType.voice) {
      return voices * repeats;
    }
    return voices * repeats + tones;
  }

  /// Builds timed segments from already-rendered sound durations.
  List<IosAlarmSegment> plan({
    required AlarmUiModel alarm,
    required String occurrenceId,
    required DateTime occurrenceStart,
    required List<PreparedAlarmClip> voiceClips,
    required List<PreparedAlarmClip> ringtoneClips,
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

    final repeats = alarm.type == AlarmType.ringtone
        ? 1
        : alarm.repeatCount.clamp(1, 20);

    final estimated = estimateNotificationCount(
      alarm: alarm,
      voiceClipCount: voices.length,
      ringtoneClipCount: tones.length,
    );
    if (estimated > maxNotifications) {
      throw IosPlanValidationException(
        'notification_limit',
        'Plan would schedule $estimated notifications (max $maxNotifications)',
      );
    }

    final out = <IosAlarmSegment>[];
    var cursor = occurrenceStart;
    var index = 0;

    if (alarm.type != AlarmType.ringtone) {
      for (var repeatIndex = 0; repeatIndex < repeats; repeatIndex++) {
        for (final clip in voices) {
          final duration = _clampVoice(clip.duration);
          out.add(
            IosAlarmSegment(
              parentAlarmId: alarm.id,
              occurrenceId: occurrenceId,
              segmentIndex: index,
              childId: _uuid.v4(),
              startAt: cursor,
              soundFileName: clip.fileName,
              duration: duration,
              label: clip.label,
            ),
          );
          cursor = cursor.add(duration).add(gap);
          index += 1;
        }
      }
    }

    if (includeRingtone) {
      for (final clip in tones) {
        final duration = clip.duration <= Duration.zero
            ? const Duration(seconds: 8)
            : clip.duration;
        out.add(
          IosAlarmSegment(
            parentAlarmId: alarm.id,
            occurrenceId: occurrenceId,
            segmentIndex: index,
            childId: _uuid.v4(),
            startAt: cursor,
            soundFileName: clip.fileName,
            duration: duration,
            label: clip.label,
          ),
        );
        cursor = cursor.add(duration).add(gap);
        index += 1;
      }
    }

    return out;
  }

  Duration _clampVoice(Duration duration) {
    if (duration <= Duration.zero) return const Duration(seconds: 1);
    if (duration > maxVoiceDuration) return maxVoiceDuration;
    return duration;
  }
}
