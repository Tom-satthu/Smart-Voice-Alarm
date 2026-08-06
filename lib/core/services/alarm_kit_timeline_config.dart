/// Shared AlarmKit timeline constants (Dart + mirrored in native recovery).
class AlarmKitTimelineConfig {
  AlarmKitTimelineConfig._();

  /// Extra wait after rendered audio before the silent gap child starts.
  /// Protects the audible tail from being cut when AlarmKit fires the next child.
  static const Duration transitionPadding = Duration(milliseconds: 1250);

  /// Product rest gap between audible segments (silent CAF duration).
  static const Duration silenceGap = Duration(seconds: 5);

  /// Ringtone audible length (file is fit to this exact duration).
  static const Duration ringtoneDuration = Duration(seconds: 10);

  /// Soft ceiling for voice custom sounds.
  static const Duration maxVoiceDuration = Duration(seconds: 20);

  /// Soft ceiling for AlarmKit children per occurrence rolling window.
  static const int maxChildren = 64;

  /// Preferred continuous horizon when child budget allows.
  static const Duration targetHorizon = Duration(minutes: 30);

  /// App-enforced minimum lead time before AlarmKit fire (must be > 0.5s skip gate).
  static const Duration minScheduleLead = Duration(milliseconds: 600);
}
