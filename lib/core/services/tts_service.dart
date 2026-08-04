import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../localization/locale_codes.dart';
import '../localization/voice_catalog.dart';
import '../../shared/models/ui_models.dart';
import 'tts_platform_bridge.dart';
import 'tts_voice_source.dart';

class TtsService {
  TtsService({TtsPlatformBridge? bridge, VoiceSource? source})
    : _tts = FlutterTts(),
      _source = source ?? createVoiceSource(bridge ?? TtsPlatformBridge());

  FlutterTts _tts;
  final VoiceSource _source;
  bool _ready = false;
  List<TtsVoiceUiModel>? _voiceCache;

  VoiceCapabilities get capabilities => _source.capabilities;

  Future<void> init() async {
    if (_ready) return;
    await _tts.awaitSpeakCompletion(true);
    if (!kIsWeb) {
      try {
        await _tts.setSharedInstance(true);
      } catch (_) {}
    }
    _ready = true;
  }

  /// Force a fresh voice query from the platform TTS engine.
  Future<List<TtsVoiceUiModel>> reloadVoices() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _ready = false;
    _voiceCache = null;
    _tts = FlutterTts();
    return loadVoices();
  }

  /// Re-query voices without recreating the engine.
  Future<List<TtsVoiceUiModel>> refreshVoices() async {
    await init();
    _voiceCache = null;
    return loadVoices();
  }

  /// Returns only voices that can be selected for preview / alarms.
  Future<List<TtsVoiceUiModel>> loadUsableVoices() async {
    final all = await loadVoices();
    final usable = all.where((v) => v.isUsable).toList();
    if (usable.isEmpty) return _fallbackVoices;
    return usable;
  }

  Future<List<TtsVoiceUiModel>> loadVoices() async {
    final cached = _voiceCache;
    if (cached != null) return cached;
    await init();
    try {
      final raw = await _source.loadVoices(_tts);
      if (raw.isEmpty) {
        return _voiceCache = _fallbackVoices;
      }
      final voices = <TtsVoiceUiModel>[];
      for (final item in raw) {
        final map = Map<String, dynamic>.from(item);
        final name = (map['name'] ?? map['voiceURI'] ?? 'Voice').toString();
        final platformLocale = (map['locale'] ?? 'en-US').toString();
        final locale = LocaleCodes.normalizeLocaleTag(platformLocale);
        final identifier = (map['identifier'] ?? map['voiceURI'] ?? name)
            .toString();
        final engine = map['engine']?.toString();
        final quality = _parseQuality(map);
        final availability = _parseAvailability(map);
        final usable = availability != TtsVoiceAvailability.notInstalled;
        final stablePlatformId = [
          if (engine != null && engine.isNotEmpty) engine,
          identifier,
          platformLocale,
        ].join('|');
        if (!_source.validateSelectableVoice(map)) continue;
        voices.add(
          TtsVoiceUiModel(
            id: stablePlatformId,
            name: _displayName(name),
            locale: locale,
            isPremium: quality == TtsVoiceQuality.premium,
            quality: quality,
            availability: availability,
            isUsable: usable,
            platformName: name,
            platformLocale: platformLocale,
            platformIdentifier: identifier,
            platformEngine: engine,
            platformQuality: map['quality'],
            resolvedIdentifier: map['resolvedName']?.toString(),
            resolvedLocale: map['resolvedLocale']?.toString(),
          ),
        );
      }
      final deduped = VoiceCatalog.deduplicate(voices);
      voices
        ..clear()
        ..addAll(deduped);
      voices.addAll(VoiceCatalog.systemDefaultsForLanguages(voices));
      if (voices.isEmpty) return _voiceCache = _fallbackVoices;
      voices.sort((a, b) {
        final byLocale = a.locale.compareTo(b.locale);
        if (byLocale != 0) return byLocale;
        return a.name.compareTo(b.name);
      });
      return _voiceCache = List.unmodifiable(voices);
    } catch (_) {
      return _voiceCache = _fallbackVoices;
    }
  }

  /// Current / default voice from the platform TTS engine.
  ///
  /// Prefers Android [TextToSpeech.getVoice] via the platform bridge.
  /// Falls back to flutter_tts [FlutterTts.getDefaultVoice] when needed.
  Future<TtsEngineVoiceInfo?> loadEngineVoice() async {
    await init();
    return _source.resolveSystemDefault(_tts);
  }

  /// Picks the exact saved voice. Missing voices become system-managed defaults;
  /// never silently substitute the first voice of a language.
  Future<TtsVoiceUiModel> resolveVoice({
    String? preferredId,
    String? preferredLocale,
  }) async {
    final voices = await loadUsableVoices();
    if (preferredId != null) {
      for (final voice in voices) {
        if (voice.id == preferredId) return voice;
      }
    }
    final locale = LocaleCodes.normalizeLocaleTag(preferredLocale ?? 'en-US');
    return systemDefaultVoice(locale);
  }

  static TtsVoiceUiModel systemDefaultVoice(String locale) {
    final normalized = LocaleCodes.normalizeLocaleTag(locale);
    final language = LocaleCodes.languageCodeOf(normalized);
    return TtsVoiceUiModel(
      id: 'system-default|$language',
      name: 'System Default',
      locale: normalized,
      platformName: '',
      platformLocale: locale,
      isSystemDefault: true,
    );
  }

  Future<void> preview({
    required String text,
    String? voiceId,
    String? locale,
  }) async {
    await init();
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final resolved = await resolveVoice(
      preferredId: voiceId,
      preferredLocale: locale,
    );
    await _tts.stop();
    if (resolved.isSystemDefault) {
      // A previous setVoice remains sticky on the same FlutterTts instance.
      // A fresh engine lets the platform apply its settings-managed default.
      _ready = false;
      _tts = FlutterTts();
      await init();
    }
    final languageResult = await _tts.setLanguage(resolved.platformLocale);
    if (!resolved.isSystemDefault) {
      final voiceResult = await _tts.setVoice({
        'name': resolved.platformName,
        'locale': resolved.platformLocale,
      });
      if (kDebugMode) {
        debugPrint(
          'TTS voice requested=${resolved.platformName} locale=${resolved.platformLocale} language=$languageResult result=$voiceResult',
        );
      }
    }
    await _tts.speak(trimmed);
  }

  Future<void> speakSegment({
    required String text,
    String? voiceId,
    String? locale,
  }) async {
    await preview(text: text, voiceId: voiceId, locale: locale);
  }

  Future<void> stop() => _tts.stop();

  /// Returns null when the platform does not expose a trustworthy quality value.
  TtsVoiceQuality? _parseQuality(Map<String, dynamic> map) {
    final q = map['quality'];
    final features = (map['features'] ?? '').toString().toLowerCase();
    final name = (map['name'] ?? '').toString().toLowerCase();

    if (name.contains('premium') || features.contains('premium')) {
      return TtsVoiceQuality.premium;
    }
    if (name.contains('enhanced') ||
        features.contains('enhanced') ||
        name.contains('compact')) {
      return TtsVoiceQuality.enhanced;
    }

    // iOS often exposes quality as an int.
    if (q is num) {
      if (q >= 300) return TtsVoiceQuality.premium;
      if (q >= 200) return TtsVoiceQuality.enhanced;
      if (q >= 100) return TtsVoiceQuality.defaultQuality;
      return null;
    }

    final quality = (q ?? '').toString().toLowerCase();
    if (quality.contains('premium')) return TtsVoiceQuality.premium;
    if (quality.contains('enhanced') || quality.contains('quality')) {
      return TtsVoiceQuality.enhanced;
    }
    if (quality.contains('default')) return TtsVoiceQuality.defaultQuality;

    // Many Android voices omit quality — hide rather than inventing a label.
    return null;
  }

  TtsVoiceAvailability _parseAvailability(Map<String, dynamic> map) {
    final network =
        map['networkConnectionRequired'] ??
        map['network_required'] ??
        map['requiresNetwork'];
    if (network == true || network?.toString() == '1') {
      return TtsVoiceAvailability.networkRequired;
    }
    final installed = map['installed'] ?? map['isInstalled'];
    if (installed == false || installed?.toString() == '0') {
      return TtsVoiceAvailability.notInstalled;
    }
    final features = (map['features'] ?? '').toString().toLowerCase();
    if (features.contains('notInstalled') ||
        features.contains('not_installed')) {
      return TtsVoiceAvailability.notInstalled;
    }
    return TtsVoiceAvailability.installedOffline;
  }

  String _displayName(String raw) {
    // Strip locale suffixes like "en-us-x-sfg-local" noise when present twice.
    return raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static const _fallbackVoices = [
    TtsVoiceUiModel(
      id: 'system-default|en',
      name: 'System Default',
      locale: 'en-US',
      availability: TtsVoiceAvailability.installedOffline,
      isUsable: true,
      isSystemDefault: true,
    ),
  ];
}
