import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../localization/locale_codes.dart';
import '../../shared/models/ui_models.dart';
import 'tts_platform_bridge.dart';

class TtsService {
  TtsService({TtsPlatformBridge? bridge})
    : _tts = FlutterTts(),
      _bridge = bridge ?? TtsPlatformBridge();

  FlutterTts _tts;
  final TtsPlatformBridge _bridge;
  bool _ready = false;
  final Map<String, TtsEngineVoiceInfo?> _probeCache = {};

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
    _probeCache.clear();
    _tts = FlutterTts();
    return loadVoices();
  }

  /// Re-query voices without recreating the engine.
  Future<List<TtsVoiceUiModel>> refreshVoices() async {
    await init();
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
    await init();
    try {
      final platform = await _bridge.getPlatformVoices();
      final raw = platform ?? await _tts.getVoices;
      if (raw is! List || raw.isEmpty) {
        return _fallbackVoices;
      }
      final voices = <TtsVoiceUiModel>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final name = (map['name'] ?? map['voiceURI'] ?? 'Voice').toString();
        final platformLocale = (map['locale'] ?? 'en-US').toString();
        final locale = LocaleCodes.normalizeLocaleTag(platformLocale);
        final identifier = (map['identifier'] ?? map['voiceURI'] ?? name)
            .toString();
        final quality = _parseQuality(map);
        final availability = _parseAvailability(map);
        final usable = availability != TtsVoiceAvailability.notInstalled;
        final key = '$identifier|$platformLocale';
        if (platform != null && map['selectable'] != true) continue;
        if (platform != null) {
          final resolvedName = (map['resolvedName'] ?? name).toString();
          final resolvedLocale = (map['resolvedLocale'] ?? platformLocale)
              .toString();
          _probeCache['$name|$platformLocale'] = TtsEngineVoiceInfo(
            name: resolvedName,
            locale: resolvedLocale,
            identifier: resolvedName,
          );
        }
        voices.add(
          TtsVoiceUiModel(
            id: key,
            name: _displayName(name),
            locale: locale,
            isPremium: quality == TtsVoiceQuality.premium,
            quality: quality,
            availability: availability,
            isUsable: usable,
            platformName: name,
            platformLocale: platformLocale,
            platformIdentifier: identifier,
          ),
        );
      }
      final deduped = <String, TtsVoiceUiModel>{};
      for (final voice in voices) {
        final resolved =
            _probeCache['${voice.platformName}|${voice.platformLocale}'];
        final key = resolved?.id ?? voice.id;
        final existing = deduped[key];
        if (existing == null ||
            (existing.availability == TtsVoiceAvailability.networkRequired &&
                voice.availability == TtsVoiceAvailability.installedOffline)) {
          deduped[key] = voice;
        }
      }
      voices
        ..clear()
        ..addAll(deduped.values);
      final locales = voices.map((voice) => voice.locale).toSet();
      for (final locale in locales) {
        voices.add(systemDefaultVoice(locale));
      }
      if (voices.isEmpty) return _fallbackVoices;
      voices.sort((a, b) {
        final byLocale = a.locale.compareTo(b.locale);
        if (byLocale != 0) return byLocale;
        return a.name.compareTo(b.name);
      });
      return voices;
    } catch (_) {
      return _fallbackVoices;
    }
  }

  /// Current / default voice from the platform TTS engine.
  ///
  /// Prefers Android [TextToSpeech.getVoice] via the platform bridge.
  /// Falls back to flutter_tts [FlutterTts.getDefaultVoice] when needed.
  Future<TtsEngineVoiceInfo?> loadEngineVoice() async {
    final fromBridge = await _bridge.getEngineVoiceState();
    final bridged = fromBridge?.effective;
    if (bridged != null) return bridged;

    await init();
    try {
      final raw = await _tts.getDefaultVoice;
      if (raw is Map && raw.isNotEmpty) {
        return TtsEngineVoiceInfo.fromMap(Map<dynamic, dynamic>.from(raw));
      }
    } catch (_) {}
    return null;
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
    return TtsVoiceUiModel(
      id: 'system-default|$normalized',
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
      // A fresh engine lets Android/Samsung apply its settings-managed default.
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
      id: 'system-default|en-US',
      name: 'System Default',
      locale: 'en-US',
      availability: TtsVoiceAvailability.installedOffline,
      isUsable: true,
      isSystemDefault: true,
    ),
  ];
}
