import '../localization/locale_codes.dart';

/// System-default voice resolved for one requested locale (setLanguage only).
class ResolvedSystemVoiceState {
  const ResolvedSystemVoiceState({
    required this.requestedLocale,
    this.resolvedVoiceName,
    this.resolvedLocale,
    this.enginePackage,
    this.languageAvailability,
  });

  final String requestedLocale;
  final String? resolvedVoiceName;
  final String? resolvedLocale;
  final String? enginePackage;

  /// Android [TextToSpeech.setLanguage] / availability result when known.
  final int? languageAvailability;

  String get fingerprint {
    final locale = LocaleCodes.normalizeLocaleTag(
      resolvedLocale ?? requestedLocale,
    );
    return [
      enginePackage ?? '',
      resolvedVoiceName ?? '',
      locale,
    ].join('|').toLowerCase();
  }

  bool get hasResolvedVoice =>
      resolvedVoiceName != null && resolvedVoiceName!.trim().isNotEmpty;

  Map<String, Object?> toJson() => {
    'requestedLocale': requestedLocale,
    'resolvedVoiceName': resolvedVoiceName,
    'resolvedLocale': resolvedLocale,
    'enginePackage': enginePackage,
    'languageAvailability': languageAvailability,
  };

  factory ResolvedSystemVoiceState.fromJson(Map<String, dynamic> json) {
    return ResolvedSystemVoiceState(
      requestedLocale: (json['requestedLocale'] ?? '').toString(),
      resolvedVoiceName: json['resolvedVoiceName']?.toString(),
      resolvedLocale: json['resolvedLocale']?.toString(),
      enginePackage: json['enginePackage']?.toString(),
      languageAvailability: json['languageAvailability'] is int
          ? json['languageAvailability'] as int
          : int.tryParse('${json['languageAvailability'] ?? ''}'),
    );
  }

  factory ResolvedSystemVoiceState.fromMap(Map<dynamic, dynamic> map) {
    return ResolvedSystemVoiceState(
      requestedLocale: (map['requestedLocale'] ?? map['locale'] ?? '')
          .toString(),
      resolvedVoiceName:
          (map['resolvedVoiceName'] ?? map['name'] ?? map['identifier'])
              ?.toString(),
      resolvedLocale: (map['resolvedLocale'] ?? map['locale'])?.toString(),
      enginePackage: (map['enginePackage'] ?? map['engine'])?.toString(),
      languageAvailability: map['languageAvailability'] is int
          ? map['languageAvailability'] as int
          : int.tryParse('${map['languageAvailability'] ?? ''}'),
    );
  }
}

/// Persisted notice that device TTS settings changed for a language/locale.
class SystemVoiceChangeEvent {
  const SystemVoiceChangeEvent({
    required this.locale,
    required this.language,
    required this.timestampMs,
    this.type = 'system_default_changed',
  });

  final String locale;
  final String language;
  final int timestampMs;
  final String type;

  Map<String, Object?> toJson() => {
    'locale': locale,
    'language': language,
    'timestampMs': timestampMs,
    'type': type,
  };

  factory SystemVoiceChangeEvent.fromJson(Map<String, dynamic> json) {
    return SystemVoiceChangeEvent(
      locale: (json['locale'] ?? '').toString(),
      language: (json['language'] ?? '').toString(),
      timestampMs: json['timestampMs'] is int
          ? json['timestampMs'] as int
          : int.tryParse('${json['timestampMs'] ?? 0}') ?? 0,
      type: (json['type'] ?? 'system_default_changed').toString(),
    );
  }
}

/// Plan used by [TtsService] so preview and alarm share one code path.
class TtsSpeakPlan {
  const TtsSpeakPlan({
    required this.recreateEngine,
    required this.languageLocale,
    this.engine,
    this.voiceName,
    this.voiceLocale,
  });

  final bool recreateEngine;
  final String? engine;
  final String languageLocale;
  final String? voiceName;
  final String? voiceLocale;

  bool get shouldSetVoice =>
      voiceName != null &&
      voiceName!.trim().isNotEmpty &&
      voiceLocale != null &&
      voiceLocale!.trim().isNotEmpty;
}
