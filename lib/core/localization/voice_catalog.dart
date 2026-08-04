import '../localization/locale_display_names.dart';
import '../../shared/models/ui_models.dart';
import 'locale_codes.dart';

class VoiceLanguageGroup {
  const VoiceLanguageGroup({
    required this.languageCode,
    required this.languageLabel,
    required this.locales,
  });

  final String languageCode;
  final String languageLabel;
  final List<VoiceLocaleGroup> locales;

  int get voiceCount =>
      locales.fold(0, (sum, locale) => sum + locale.voices.length);
}

class VoiceLocaleGroup {
  const VoiceLocaleGroup({
    required this.localeTag,
    required this.localeLabel,
    required this.voices,
  });

  final String localeTag;
  final String localeLabel;
  final List<TtsVoiceUiModel> voices;
}

/// Groups system TTS voices by language, then by locale/region.
abstract final class VoiceCatalog {
  static String normalizeLocaleTag(String locale) =>
      LocaleCodes.normalizeLocaleTag(locale);

  static String normalizeLanguageCode(String code) =>
      LocaleCodes.normalizeLanguageCode(code);

  static String languageCodeOf(String locale) =>
      LocaleCodes.languageCodeOf(locale);

  /// Stable friendly labels per locale: Voice 01, Voice 02, …
  /// Sorted by technical voice [TtsVoiceUiModel.id], never using the number as id.
  static Map<String, String> friendlyLabels(
    List<TtsVoiceUiModel> voices, {
    required String Function(String paddedNumber) labelFor,
  }) {
    final byLocale = <String, List<TtsVoiceUiModel>>{};
    for (final voice in voices) {
      final key = normalizeLocaleTag(voice.locale).toLowerCase();
      byLocale.putIfAbsent(key, () => []).add(voice);
    }
    final labels = <String, String>{};
    for (final entry in byLocale.entries) {
      final sorted = List<TtsVoiceUiModel>.from(entry.value)
        ..sort((a, b) => a.id.compareTo(b.id));
      for (var i = 0; i < sorted.length; i++) {
        final padded = (i + 1).toString().padLeft(2, '0');
        labels[sorted[i].id] = labelFor(padded);
      }
    }
    return labels;
  }

  static String previewSampleForLocale(String locale) {
    return switch (languageCodeOf(locale)) {
      'vi' => 'Xin chào. Đây là bản nghe thử giọng nói.',
      'en' => 'Hello. This is a short voice preview.',
      'es' => 'Hola. Esta es una vista previa breve de esta voz.',
      'pt' => 'Olá. Esta é uma pré-visualização curta desta voz.',
      'fr' => 'Bonjour. Ceci est un court aperçu de cette voix.',
      'de' => 'Hallo. Dies ist eine kurze Stimmvorschau.',
      'it' => 'Ciao. Questa è una breve anteprima di questa voce.',
      'nl' => 'Hallo. Dit is een korte stemvoorbeeld.',
      'id' => 'Halo. Ini adalah pratinjau singkat suara ini.',
      'ja' => 'こんにちは。これは音声の短いプレビューです。',
      'ko' => '안녕하세요. 이 음성의 짧은 미리듣기입니다.',
      'zh' => '你好。这是此语音的简短预览。',
      'ru' => 'Здравствуйте. Это короткий образец этого голоса.',
      _ => 'Hello. This is a short voice preview.',
    };
  }

  static List<VoiceLanguageGroup> group(
    List<TtsVoiceUiModel> voices, {
    String? preferredLanguage,
    String? appLanguage,
    String? systemLanguage,
    String query = '',
  }) {
    final preferred = preferredLanguage == null
        ? null
        : normalizeLanguageCode(preferredLanguage);
    final app = appLanguage == null ? null : normalizeLanguageCode(appLanguage);
    final system =
        systemLanguage == null ? null : normalizeLanguageCode(systemLanguage);

    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? voices
        : voices.where((voice) {
            final haystack = [
              voice.name,
              voice.locale,
              LocaleDisplayNames.friendly(voice.locale),
              languageCodeOf(voice.locale),
            ].join(' ').toLowerCase();
            return haystack.contains(q);
          }).toList();

    final byLanguage = <String, Map<String, List<TtsVoiceUiModel>>>{};
    for (final voice in filtered) {
      final lang = languageCodeOf(voice.locale);
      final localeKey = normalizeLocaleTag(voice.locale);
      byLanguage.putIfAbsent(lang, () => {});
      byLanguage[lang]!.putIfAbsent(localeKey, () => []).add(voice);
    }

    final groups = <VoiceLanguageGroup>[];
    for (final entry in byLanguage.entries) {
      final locales = entry.value.entries.map((localeEntry) {
        final list = List<TtsVoiceUiModel>.from(localeEntry.value)
          ..sort((a, b) => a.id.compareTo(b.id));
        return VoiceLocaleGroup(
          localeTag: localeEntry.key,
          localeLabel: LocaleDisplayNames.friendly(localeEntry.key),
          voices: list,
        );
      }).toList()
        ..sort((a, b) => a.localeLabel.compareTo(b.localeLabel));

      groups.add(
        VoiceLanguageGroup(
          languageCode: entry.key,
          languageLabel: LocaleDisplayNames.friendly(entry.key),
          locales: locales,
        ),
      );
    }

    int rank(String code) {
      if (code == preferred) return 0;
      if (code == app) return 1;
      if (code == system) return 2;
      return 10;
    }

    groups.sort((a, b) {
      final byRank = rank(a.languageCode).compareTo(rank(b.languageCode));
      if (byRank != 0) return byRank;
      return a.languageLabel.compareTo(b.languageLabel);
    });
    return groups;
  }
}
