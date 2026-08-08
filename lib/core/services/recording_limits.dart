/// Hard limit for voice recordings used by AlarmKit custom sounds.
const Duration kMaxRecordingDuration = Duration(seconds: 20);

/// Display helper: "elapsed / max" in whole seconds.
String recordingTimerLabel(
  Duration elapsed, {
  Duration max = kMaxRecordingDuration,
}) {
  final e = elapsed.inMilliseconds.clamp(0, max.inMilliseconds);
  final used = (e / 1000).ceil().clamp(0, max.inSeconds);
  return '$used/${max.inSeconds}';
}
