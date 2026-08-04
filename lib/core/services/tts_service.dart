import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../localization/locale_codes.dart';
import '../localization/voice_catalog.dart';
import '../../shared/models/ui_models.dart';
import 'resolved_system_voice.dart';
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
  String? _cacheKey;
  String? _activeEngine;
  Map<String, ResolvedSystemVoiceState> _resolvedDefaults = const {};

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
  Future<List<TtsVoiceUiModel>> reloadVoices({
    String? preferredLocale,
    String? appLocale,
    String? systemLocale,
    Map<String, ResolvedSystemVoiceState>? resolvedDefaults,
  }) async {
    try {
      await _tts.stop();
    } catch (_) {}
    _ready = false;
    _voiceCache = null;
    _cacheKey = null;
    _activeEngine = null;
    _tts = FlutterTts();
    return loadVoices(
      preferredLocale: preferredLocale,
      appLocale: appLocale,
      systemLocale: systemLocale,
      resolvedDefaults: resolvedDefaults,
    );
  }

  /// Re-query voices without recreating the engine.
  Future<List<TtsVoiceUiModel>> refreshVoices({
    String? preferredLocale,
    String? appLocale,
    String? systemLocale,
    Map<String, ResolvedSystemVoiceState>? resolvedDefaults,
  }) async {
    await init();
    _voiceCache = null;
    _cacheKey = null;
    return loadVoices(
      preferredLocale: preferredLocale,
      appLocale: appLocale,
      systemLocale: systemLocale,
      resolvedDefaults: resolvedDefaults,
    );
  }

  /// Returns only voices that can be selected for preview / alarms.
  Future<List<TtsVoiceUiModel>> loadUsableVoices({
    String? preferredLocale,
    String? appLocale,
    String? systemLocale,
    Map<String, ResolvedSystemVoiceState>? resolvedDefaults,
  }) async {
    final all = await loadVoices(
      preferredLocale: preferredLocale,
      appLocale: appLocale,
      systemLocale: systemLocale,
      resolvedDefaults: resolvedDefaults,
    );
    final usable = all.where((v) => v.isUsable).toList();
    if (usable.isEmpty) return _fallbackVoices;
    return usable;
  }

  Future<List<TtsVoiceUiModel>> loadVoices({
    String? preferredLocale,
    String? appLocale,
    String? systemLocale,
    Map<String, ResolvedSystemVoiceState>? resolvedDefaults,
  }) async {
    final defaults = resolvedDefaults ?? _resolvedDefaults;
    final key = [
      preferredLocale ?? '',
      appLocale ?? '',
      systemLocale ?? '',
      defaults.length,
      defaults.values.map((state) => state.fingerprint).join(','),
    ].join('::');
    final cached = _voiceCache;
    if (cached != null && _cacheKey == key) return cached;
    await init();
    try {
      final raw = await _source.loadVoices(_tts);
      if (raw.isEmpty) {
        _cacheKey = key;
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
      voices.addAll(
        VoiceCatalog.systemDefaultsForLanguages(
          voices,
          preferredLocale: preferredLocale,
          appLocale: appLocale,
          systemLocale: systemLocale,
          resolvedByLocale: defaults,
        ),
      );
      if (voices.isEmpty) {
        _cacheKey = key;
        return _voiceCache = _fallbackVoices;
      }
      voices.sort((a, b) {
        final byLocale = a.locale.compareTo(b.locale);
        if (byLocale != 0) return byLocale;
        return a.name.compareTo(b.name);
      });
      _resolvedDefaults = defaults;
      _cacheKey = key;
      return _voiceCache = List.unmodifiable(voices);
    } catch (_) {
      _cacheKey = key;
      return _voiceCache = _fallbackVoices;
    }
  }

  Future<TtsEngineVoiceInfo?> loadEngineVoice() async {
    await init();
    return _source.resolveSystemDefault(_tts);
  }

  Future<Map<String, ResolvedSystemVoiceState>> probeSystemDefaults(
    List<String> locales,
  ) async {
    await init();
    final probed = await _source.resolveSystemDefaultsForLocales(locales);
    if (probed.isNotEmpty) {
      _resolvedDefaults = probed;
    }
    return probed;
  }

  /// Picks the exact saved voice. Missing voices become system-managed defaults;
  /// never silently substitute the first voice of a language.
  Future<TtsVoiceUiModel> resolveVoice({
    String? preferredId,
    String? preferredLocale,
  }) async {
    final voices = await loadUsableVoices(preferredLocale: preferredLocale);
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
    final plan = VoiceCatalog.speakPlanFor(resolved);
    await _applySpeakPlan(plan);
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

  Future<void> _applySpeakPlan(TtsSpeakPlan plan) async {
    if (plan.recreateEngine) {
      _ready = false;
      _activeEngine = null;
      _tts = FlutterTts();
      await init();
    }

    final engineOk = await _ensureEngine(plan.engine);
    if (!engineOk && plan.engine != null && plan.engine!.isNotEmpty) {
      // Do not pretend the requested engine/voice applied.
      if (kDebugMode) {
        debugPrint('TTS setEngine failed for ${plan.engine}; using default');
      }
    }

    final languageResult = await _tts.setLanguage(plan.languageLocale);
    Object? voiceResult;
    if (plan.shouldSetVoice) {
      voiceResult = await _tts.setVoice({
        'name': plan.voiceName!,
        'locale': plan.voiceLocale!,
      });
    }

    if (kDebugMode) {
      debugPrint(
        'TTS engine=${plan.engine ?? _activeEngine ?? 'default'} '
        'lang=${plan.languageLocale} langResult=$languageResult '
        'voice=${plan.shouldSetVoice ? plan.voiceName : '(system-default)'} '
        'voiceResult=$voiceResult',
      );
    }
  }

  Future<bool> _ensureEngine(String? engine) async {
    if (engine == null || engine.trim().isEmpty) return true;
    if (_activeEngine == engine) return true;
    try {
      await _tts.setEngine(engine);
      _activeEngine = engine;
      // setEngine recreates the native engine; re-apply shared prefs.
      _ready = false;
      await init();
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('TTS setEngine($engine) failed: $error');
      }
      try {
        _ready = false;
        _activeEngine = null;
        _tts = FlutterTts();
        await init();
      } catch (_) {}
      return false;
    }
  }

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
