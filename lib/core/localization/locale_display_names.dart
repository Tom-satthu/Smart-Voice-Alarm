import 'locale_codes.dart';

/// Human-readable labels for common TTS locale tags.
abstract final class LocaleDisplayNames {
  static String friendly(String raw) {
    final normalized = LocaleCodes.normalizeLocaleTag(raw);
    final known = _names[normalized] ??
        _names[normalized.toLowerCase()] ??
        _byLanguage(normalized);
    return known ?? normalized;
  }

  static String? _byLanguage(String tag) {
    final lang = LocaleCodes.languageCodeOf(tag);
    return switch (lang) {
      'en' => 'English',
      'es' => 'Spanish',
      'pt' => 'Portuguese',
      'fr' => 'French',
      'de' => 'German',
      'it' => 'Italian',
      'nl' => 'Dutch',
      'ja' => 'Japanese',
      'ko' => 'Korean',
      'zh' => 'Chinese',
      'id' => 'Indonesian',
      'vi' => 'Vietnamese',
      'ru' => 'Russian',
      'ar' => 'Arabic',
      'hi' => 'Hindi',
      'th' => 'Thai',
      'tr' => 'Turkish',
      'pl' => 'Polish',
      'uk' => 'Ukrainian',
      'cs' => 'Czech',
      'sv' => 'Swedish',
      'da' => 'Danish',
      'no' => 'Norwegian',
      'fi' => 'Finnish',
      'hu' => 'Hungarian',
      'ro' => 'Romanian',
      'el' => 'Greek',
      'he' => 'Hebrew',
      'ms' => 'Malay',
      _ => null,
    };
  }

  static const _names = {
    'en-US': 'English (United States)',
    'en-GB': 'English (United Kingdom)',
    'en-AU': 'English (Australia)',
    'en-IN': 'English (India)',
    'es-ES': 'Spanish (Spain)',
    'es-MX': 'Spanish (Mexico)',
    'es-US': 'Spanish (United States)',
    'pt-BR': 'Portuguese (Brazil)',
    'pt-PT': 'Portuguese (Portugal)',
    'fr-FR': 'French (France)',
    'fr-CA': 'French (Canada)',
    'de-DE': 'German (Germany)',
    'it-IT': 'Italian (Italy)',
    'nl-NL': 'Dutch (Netherlands)',
    'ja-JP': 'Japanese (Japan)',
    'ko-KR': 'Korean (Korea)',
    'zh-CN': 'Chinese (Simplified)',
    'zh-TW': 'Chinese (Traditional)',
    'zh-HK': 'Chinese (Hong Kong)',
    'id-ID': 'Indonesian (Indonesia)',
    'vi-VN': 'Vietnamese (Vietnam)',
    'ru-RU': 'Russian (Russia)',
  };
}
