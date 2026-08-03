import '../localization/locale_display_names.dart';
import '../../shared/models/ui_models.dart';

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
  static String languageCodeOf(String locale) {
    final normalized = locale.replaceAll('_', '-');
    final parts = normalized.split('-');
    return parts.first.toLowerCase();
  }

  static List<VoiceLanguageGroup> group(
    List<TtsVoiceUiModel> voices, {
    String? preferredLanguage,
    String? appLanguage,
    String? systemLanguage,
    String query = '',
  }) {
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
      final localeKey = voice.locale.replaceAll('_', '-');
      byLanguage.putIfAbsent(lang, () => {});
      byLanguage[lang]!.putIfAbsent(localeKey, () => []).add(voice);
    }

    final groups = <VoiceLanguageGroup>[];
    for (final entry in byLanguage.entries) {
      final locales = entry.value.entries.map((localeEntry) {
        final list = List<TtsVoiceUiModel>.from(localeEntry.value)
          ..sort((a, b) => a.name.compareTo(b.name));
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
      if (code == preferredLanguage) return 0;
      if (code == appLanguage) return 1;
      if (code == systemLanguage) return 2;
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
