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

/// Pure planner for iOS fan-out segments.
///
/// nextStart = currentStart + actualDuration + gap (default 5s)
/// Defaults: up to 5 voice segments + up to 2 ringtone segments.
class IosAlarmSegmentPlanner {
  IosAlarmSegmentPlanner({
    this.maxVoiceSegments = 5,
    this.maxRingtoneSegments = 2,
    this.gap = const Duration(seconds: 5),
    this.maxVoiceDuration = const Duration(seconds: 20),
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final int maxVoiceSegments;
  final int maxRingtoneSegments;
  final Duration gap;
  final Duration maxVoiceDuration;
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
    // Keep names short — long Library/Sounds filenames can fail to load.
    final seed = '$parentId|$occurrenceId|$segmentIndex';
    final hash = seed.hashCode.toUnsigned(32).toRadixString(16);
    return 'sva_${hash}_$revision.caf';
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

    final out = <IosAlarmSegment>[];
    var cursor = occurrenceStart;
    var index = 0;

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

    for (final clip in tones) {
      final duration = clip.duration;
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

    return out;
  }

  Duration _clampVoice(Duration duration) {
    if (duration <= Duration.zero) return const Duration(seconds: 1);
    if (duration > maxVoiceDuration) return maxVoiceDuration;
    return duration;
  }
}
