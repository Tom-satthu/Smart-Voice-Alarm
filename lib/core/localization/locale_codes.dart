/// Shared locale / language-code normalization for TTS tags.
abstract final class LocaleCodes {
  /// ISO 639-2/3 (and a few aliases) → ISO 639-1 used in the app.
  static const Map<String, String> iso3ToIso1 = {
    'eng': 'en',
    'deu': 'de',
    'ger': 'de',
    'fra': 'fr',
    'fre': 'fr',
    'ita': 'it',
    'por': 'pt',
    'rus': 'ru',
    'spa': 'es',
    'vie': 'vi',
    'nld': 'nl',
    'dut': 'nl',
    'jpn': 'ja',
    'kor': 'ko',
    'zho': 'zh',
    'chi': 'zh',
    'cmn': 'zh',
    'ind': 'id',
    'may': 'ms',
    'msa': 'ms',
    'ara': 'ar',
    'hin': 'hi',
    'tha': 'th',
    'tur': 'tr',
    'pol': 'pl',
    'ukr': 'uk',
    'ces': 'cs',
    'cze': 'cs',
    'swe': 'sv',
    'dan': 'da',
    'nor': 'no',
    'nob': 'no',
    'fin': 'fi',
    'hun': 'hu',
    'ron': 'ro',
    'rum': 'ro',
    'ell': 'el',
    'gre': 'el',
    'heb': 'he',
    'iw': 'he',
    'cat': 'ca',
    'hrv': 'hr',
    'slk': 'sk',
    'slo': 'sk',
    'slv': 'sl',
    'bul': 'bg',
    'srp': 'sr',
  };

  /// ISO 3166-1 alpha-3 → alpha-2 for common TTS regions.
  static const Map<String, String> region3To2 = {
    'usa': 'US',
    'gbr': 'GB',
    'gbo': 'GB',
    'aus': 'AU',
    'can': 'CA',
    'nzl': 'NZ',
    'ind': 'IN',
    'irl': 'IE',
    'zaf': 'ZA',
    'vnm': 'VN',
    'deu': 'DE',
    'aut': 'AT',
    'che': 'CH',
    'fra': 'FR',
    'bel': 'BE',
    'ita': 'IT',
    'esp': 'ES',
    'mex': 'MX',
    'arg': 'AR',
    'col': 'CO',
    'bra': 'BR',
    'prt': 'PT',
    'rus': 'RU',
    'nld': 'NL',
    'jpn': 'JP',
    'kor': 'KR',
    'chn': 'CN',
    'twn': 'TW',
    'hkg': 'HK',
    'sgp': 'SG',
    'idn': 'ID',
    'mys': 'MY',
    'tha': 'TH',
    'tur': 'TR',
    'pol': 'PL',
    'ukr': 'UA',
    'cze': 'CZ',
    'svk': 'SK',
    'swe': 'SE',
    'dnk': 'DK',
    'nor': 'NO',
    'fin': 'FI',
    'hun': 'HU',
    'rou': 'RO',
    'grc': 'GR',
    'isr': 'IL',
  };

  /// Normalizes engine locale tags such as `vie`, `vie-VNM`, `eng_USA`.
  static String normalizeLocaleTag(String locale) {
    final trimmed = locale.trim();
    if (trimmed.isEmpty) return 'en';
    final parts = trimmed
        .replaceAll('_', '-')
        .split('-')
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'en';

    final lang = normalizeLanguageCode(parts.first);
    if (parts.length == 1) return lang;

    final rest = <String>[];
    for (var i = 1; i < parts.length; i++) {
      final part = parts[i];
      if (i == 1 &&
          part.length == 3 &&
          region3To2.containsKey(part.toLowerCase())) {
        rest.add(region3To2[part.toLowerCase()]!);
      } else if (i == 1 && part.length == 2) {
        rest.add(part.toUpperCase());
      } else {
        rest.add(part);
      }
    }
    return ([lang, ...rest]).join('-');
  }

  static String normalizeLanguageCode(String code) {
    final raw = code.trim().toLowerCase();
    if (raw.isEmpty) return 'en';
    if (raw.length == 2) return raw;
    return iso3ToIso1[raw] ?? raw;
  }

  static String languageCodeOf(String locale) {
    final normalized = normalizeLocaleTag(locale);
    return normalizeLanguageCode(normalized.split('-').first);
  }
}
