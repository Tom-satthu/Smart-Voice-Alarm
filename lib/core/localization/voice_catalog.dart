import '../localization/locale_display_names.dart';
import '../services/resolved_system_voice.dart';
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

  /// Removes duplicate platform records and aliases that resolve to one voice.
  /// Offline metadata wins when an engine exposes both network and local rows.
  static List<TtsVoiceUiModel> deduplicate(List<TtsVoiceUiModel> voices) {
    final unique = <String, TtsVoiceUiModel>{};
    for (final voice in voices) {
      if (voice.isSystemDefault) continue;
      final resolvedName = voice.resolvedIdentifier?.trim();
      final resolvedLocale = normalizeLocaleTag(
        voice.resolvedLocale ?? voice.platformLocale,
      );
      final key = [
        voice.platformEngine ?? '',
        resolvedName == null || resolvedName.isEmpty
            ? voice.platformIdentifier ?? voice.platformName
            : resolvedName,
        resolvedLocale,
      ].join('|').toLowerCase();
      final existing = unique[key];
      if (existing == null ||
          (existing.availability == TtsVoiceAvailability.networkRequired &&
              voice.availability == TtsVoiceAvailability.installedOffline)) {
        unique[key] = voice;
      }
    }
    return unique.values.toList();
  }

  /// Locales to probe for system-default changes (deduped).
  static List<String> localesForSystemDefaultProbe({
    required Iterable<TtsVoiceUiModel> voices,
    String? preferredLocale,
    String? appLocale,
    String? systemLocale,
  }) {
    final out = <String>{};
    void add(String? raw) {
      if (raw == null) return;
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return;
      out.add(trimmed.replaceAll('_', '-'));
    }

    for (final voice in voices) {
      if (voice.isSystemDefault) continue;
      add(voice.platformLocale);
    }
    add(preferredLocale);
    add(appLocale);
    add(systemLocale);
    final list = out.toList()..sort();
    return list;
  }

  /// Exactly one device-managed default per language, not per region.
  ///
  /// Locale priority: preferred → app/system → platform-resolved → stable first.
  static List<TtsVoiceUiModel> systemDefaultsForLanguages(
    List<TtsVoiceUiModel> voices, {
    String? preferredLocale,
    String? appLocale,
    String? systemLocale,
    Map<String, ResolvedSystemVoiceState>? resolvedByLocale,
  }) {
    final byLanguage = <String, List<TtsVoiceUiModel>>{};
    for (final voice in voices) {
      if (voice.isSystemDefault) continue;
      byLanguage.putIfAbsent(languageCodeOf(voice.locale), () => []).add(voice);
    }

    final preferred = preferredLocale == null
        ? null
        : normalizeLocaleTag(preferredLocale);
    final app = appLocale == null ? null : normalizeLocaleTag(appLocale);
    final system =
        systemLocale == null ? null : normalizeLocaleTag(systemLocale);

    return [
      for (final entry in byLanguage.entries)
        _systemDefaultForLanguage(
          language: entry.key,
          candidates: entry.value,
          preferredLocale: preferred,
          appLocale: app,
          systemLocale: system,
          resolvedByLocale: resolvedByLocale ?? const {},
        ),
    ];
  }

  static TtsVoiceUiModel _systemDefaultForLanguage({
    required String language,
    required List<TtsVoiceUiModel> candidates,
    required String? preferredLocale,
    required String? appLocale,
    required String? systemLocale,
    required Map<String, ResolvedSystemVoiceState> resolvedByLocale,
  }) {
    TtsVoiceUiModel? matchNormalized(String? locale) {
      if (locale == null || languageCodeOf(locale) != language) return null;
      for (final voice in candidates) {
        if (normalizeLocaleTag(voice.locale) == locale ||
            normalizeLocaleTag(voice.platformLocale) == locale) {
          return voice;
        }
      }
      return null;
    }

    ResolvedSystemVoiceState? platformForLanguage() {
      ResolvedSystemVoiceState? best;
      for (final entry in resolvedByLocale.entries) {
        if (languageCodeOf(entry.key) != language) continue;
        if (!entry.value.hasResolvedVoice) continue;
        best ??= entry.value;
        if (preferredLocale != null &&
            normalizeLocaleTag(entry.key) == preferredLocale) {
          return entry.value;
        }
      }
      return best;
    }

    final preferredMatch = matchNormalized(preferredLocale);
    final appMatch = matchNormalized(appLocale);
    final systemMatch = matchNormalized(systemLocale);
    final platform = platformForLanguage();

    late final String platformLocale;
    String? platformEngine;
    String uiLocale;

    if (preferredMatch != null) {
      platformLocale = preferredMatch.platformLocale;
      platformEngine = preferredMatch.platformEngine;
      uiLocale = preferredMatch.locale;
    } else if (appMatch != null) {
      platformLocale = appMatch.platformLocale;
      platformEngine = appMatch.platformEngine;
      uiLocale = appMatch.locale;
    } else if (systemMatch != null) {
      platformLocale = systemMatch.platformLocale;
      platformEngine = systemMatch.platformEngine;
      uiLocale = systemMatch.locale;
    } else if (platform != null) {
      platformLocale = platform.resolvedLocale?.isNotEmpty == true
          ? platform.resolvedLocale!
          : platform.requestedLocale;
      platformEngine = platform.enginePackage;
      uiLocale = normalizeLocaleTag(platformLocale);
    } else {
      final sorted = List<TtsVoiceUiModel>.from(candidates)
        ..sort((a, b) => a.platformLocale.compareTo(b.platformLocale));
      final pick = sorted.first;
      platformLocale = pick.platformLocale;
      platformEngine = pick.platformEngine;
      uiLocale = pick.locale;
    }

    // Prefer an engine from any concrete voice of this language when missing.
    if (platformEngine == null || platformEngine.isEmpty) {
      for (final voice in candidates) {
        final engine = voice.platformEngine;
        if (engine != null && engine.isNotEmpty) {
          platformEngine = engine;
          break;
        }
      }
    }

    return TtsVoiceUiModel(
      id: 'system-default|$language',
      name: 'System Default',
      locale: uiLocale,
      platformName: '',
      platformLocale: platformLocale,
      platformEngine: platformEngine,
      isSystemDefault: true,
    );
  }

  static TtsSpeakPlan speakPlanFor(TtsVoiceUiModel voice) {
    if (voice.isSystemDefault) {
      return TtsSpeakPlan(
        recreateEngine: true,
        engine: voice.platformEngine,
        languageLocale: voice.platformLocale,
      );
    }
    return TtsSpeakPlan(
      recreateEngine: false,
      engine: voice.platformEngine,
      languageLocale: voice.platformLocale,
      voiceName: voice.platformName,
      voiceLocale: voice.platformLocale,
    );
  }

  static Set<String> newlyInstalledIds({
    required Iterable<TtsVoiceUiModel> before,
    required Iterable<TtsVoiceUiModel> after,
  }) {
    final oldIds = before
        .where((voice) => !voice.isSystemDefault && voice.isUsable)
        .map((voice) => voice.id)
        .toSet();
    return after
        .where((voice) => !voice.isSystemDefault && voice.isUsable)
        .map((voice) => voice.id)
        .where((id) => !oldIds.contains(id))
        .toSet();
  }

  /// Exact-locale fingerprint diffs only. Sibling locales and newly probed
  /// locales (no prior fingerprint) are not treated as configuration changes.
  static List<String> changedSystemDefaultLocales({
    required Map<String, ResolvedSystemVoiceState> before,
    required Map<String, ResolvedSystemVoiceState> after,
  }) {
    final changed = <String>[];
    for (final entry in after.entries) {
      final previous = before[entry.key];
      if (previous == null) continue;
      if (previous.fingerprint != entry.value.fingerprint) {
        changed.add(entry.key);
      }
    }
    return changed;
  }

  /// Legacy `system-default|en-US` → `system-default|en`.
  static String? normalizeSystemDefaultVoiceId(String? id) {
    if (id == null || !id.startsWith('system-default|')) return id;
    final suffix = id.substring('system-default|'.length);
    final language = languageCodeOf(suffix);
    if (language.isEmpty) return id;
    return 'system-default|$language';
  }

  /// Retarget preferred only when it is already system-default for a language
  /// that actually changed. Never overwrite a concrete voice selection.
  static String? preferredSystemDefaultLanguageToRetarget({
    required String? preferredId,
    required String? preferredLanguage,
    required Iterable<String> changedLocales,
  }) {
    if (changedLocales.isEmpty) return null;
    final id = preferredId;
    if (id == null || !id.startsWith('system-default|')) return null;
    final language = normalizeLanguageCode(
      preferredLanguage ?? languageCodeOf(id.substring('system-default|'.length)),
    );
    if (language.isEmpty) return null;
    final matched = changedLocales.any(
      (locale) => languageCodeOf(locale) == language,
    );
    return matched ? language : null;
  }

  /// Stable device-list order: selected → preferred/app language → others → name.
  static List<TtsVoiceUiModel> sortForDeviceDiscovery({
    required List<TtsVoiceUiModel> voices,
    String? selectedId,
    String? preferredLanguage,
    String? appLanguage,
    Map<String, String> friendlyLabels = const {},
  }) {
    final preferredLang = normalizeLanguageCode(preferredLanguage ?? '');
    final appLang = normalizeLanguageCode(appLanguage ?? '');
    final normalizedSelected =
        normalizeSystemDefaultVoiceId(selectedId) ?? selectedId;

    int rank(TtsVoiceUiModel voice) {
      if (normalizedSelected != null && voice.id == normalizedSelected) {
        return 0;
      }
      final lang = languageCodeOf(voice.locale);
      if (preferredLang.isNotEmpty && lang == preferredLang) return 1;
      if (appLang.isNotEmpty && lang == appLang) return 2;
      return 3;
    }

    String label(TtsVoiceUiModel voice) {
      if (voice.isSystemDefault) return '0';
      return friendlyLabels[voice.id] ?? voice.name;
    }

    final sorted = List<TtsVoiceUiModel>.from(voices);
    sorted.sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      final byLabel = label(a).toLowerCase().compareTo(label(b).toLowerCase());
      if (byLabel != 0) return byLabel;
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  /// Resolve preferred voice from a list, with legacy system-default id support.
  static TtsVoiceUiModel? resolvePreferredVoice({
    required List<TtsVoiceUiModel> voices,
    String? preferredId,
    String? preferredLanguage,
  }) {
    if (preferredId != null) {
      final normalized = normalizeSystemDefaultVoiceId(preferredId) ?? preferredId;
      for (final voice in voices) {
        if (voice.id == preferredId || voice.id == normalized) return voice;
      }
      if (preferredId.startsWith('system-default|')) {
        final language = languageCodeOf(
          preferredId.substring('system-default|'.length),
        );
        for (final voice in voices) {
          if (voice.isSystemDefault && languageCodeOf(voice.locale) == language) {
            return voice;
          }
        }
      }
    }
    final language = normalizeLanguageCode(preferredLanguage ?? '');
    if (language.isNotEmpty) {
      for (final voice in voices) {
        if (voice.isSystemDefault && languageCodeOf(voice.locale) == language) {
          return voice;
        }
      }
    }
    for (final voice in voices) {
      if (voice.isSystemDefault) return voice;
    }
    return voices.isEmpty ? null : voices.first;
  }

  /// Stable friendly labels per locale: Voice 01, Voice 02, …
  /// Sorted by technical voice [TtsVoiceUiModel.id], never using the number as id.
  static Map<String, String> friendlyLabels(
    List<TtsVoiceUiModel> voices, {
    required String Function(String paddedNumber) labelFor,
  }) {
    final byLanguage = <String, List<TtsVoiceUiModel>>{};
    for (final voice in voices) {
      final key = languageCodeOf(voice.locale);
      byLanguage.putIfAbsent(key, () => []).add(voice);
    }
    final labels = <String, String>{};
    for (final entry in byLanguage.entries) {
      final sorted = List<TtsVoiceUiModel>.from(entry.value)
        ..sort((a, b) => a.id.compareTo(b.id));
      var voiceNumber = 0;
      for (final voice in sorted) {
        if (voice.isSystemDefault) continue;
        voiceNumber++;
        final padded = voiceNumber.toString().padLeft(2, '0');
        labels[voice.id] = labelFor(padded);
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
    final system = systemLanguage == null
        ? null
        : normalizeLanguageCode(systemLanguage);

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
      }).toList()..sort((a, b) => a.localeLabel.compareTo(b.localeLabel));

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
