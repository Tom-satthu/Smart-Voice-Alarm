/// Shared AlarmKit timeline constants (Dart + mirrored in native recovery).
class AlarmKitTimelineConfig {
  AlarmKitTimelineConfig._();

  /// Trailing PCM silence baked into each custom audible CAF after real content.
  /// Prevents AlarmKit from looping the start of the clip before the next child.
  static const Duration trailingSilence = Duration(milliseconds: 1250);

  /// Product rest gap between audible segments (separate silence CAF child).
  static const Duration silenceGap = Duration(seconds: 5);

  /// Ringtone audible content length (file is fit to this before trailing silence).
  static const Duration ringtoneDuration = Duration(seconds: 10);

  /// Soft ceiling for voice/TTS/recording *content* (trailing silence excluded).
  static const Duration maxVoiceContentDuration = Duration(seconds: 20);

  /// Soft ceiling for AlarmKit children per occurrence rolling window.
  static const int maxChildren = 64;

  /// Preferred continuous horizon when child budget allows.
  static const Duration targetHorizon = Duration(minutes: 30);

  /// App-enforced minimum lead time before AlarmKit fire (must be > 0.5s skip gate).
  static const Duration minScheduleLead = Duration(milliseconds: 600);
}
