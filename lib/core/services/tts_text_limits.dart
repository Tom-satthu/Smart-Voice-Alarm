/// Conservative TTS character limits by locale.
///
/// Character caps are a first-line UX guard only. Final acceptance always
/// requires measuring a real rendered TTS file duration (≤20s).
class TtsTextLimits {
  TtsTextLimits._();

  /// Fallback for locales without a measured profile.
  static const int fallbackMaxChars = 220;

  /// Measured conservatively for Vietnamese (slower reading + diacritics).
  static const int viVnMaxChars = 160;

  /// Measured conservatively for US English.
  static const int enUsMaxChars = 280;

  static int maxCharsForLocale(String? locale) {
    final key = (locale ?? '').toLowerCase().replaceAll('_', '-');
    if (key.startsWith('vi')) return viVnMaxChars;
    if (key.startsWith('en')) return enUsMaxChars;
    return fallbackMaxChars;
  }
}

/// Max seconds for any TTS / recording AlarmKit custom sound.
const double kMaxTtsSoundSeconds = 20;
