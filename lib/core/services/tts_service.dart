import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../shared/models/ui_models.dart';

class TtsService {
  TtsService() : _tts = FlutterTts();

  FlutterTts _tts;
  bool _ready = false;

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
    _tts = FlutterTts();
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
      final raw = await _tts.getVoices;
      if (raw is! List || raw.isEmpty) {
        return _fallbackVoices;
      }
      final voices = <TtsVoiceUiModel>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final name = (map['name'] ?? map['voiceURI'] ?? 'Voice').toString();
        final locale = (map['locale'] ?? 'en-US').toString();
        final quality = _parseQuality(map);
        final availability = _parseAvailability(map);
        final usable = availability != TtsVoiceAvailability.notInstalled;
        voices.add(
          TtsVoiceUiModel(
            id: '$name|$locale',
            name: _displayName(name),
            locale: locale,
            isPremium: quality == TtsVoiceQuality.premium,
            quality: quality,
            availability: availability,
            isUsable: usable,
          ),
        );
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

  /// Picks [preferredId] when still installed; otherwise same-locale default.
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
    final locale = preferredLocale ?? 'en-US';
    for (final voice in voices) {
      if (voice.locale.toLowerCase() == locale.toLowerCase()) return voice;
    }
    final lang = locale.split(RegExp('[-_]')).first.toLowerCase();
    for (final voice in voices) {
      if (voice.locale.toLowerCase().startsWith(lang)) return voice;
    }
    return voices.first;
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
    try {
      await _tts.setLanguage(resolved.locale);
      final name = resolved.id.contains('|')
          ? resolved.id.split('|').first
          : resolved.name;
      await _tts.setVoice({'name': name, 'locale': resolved.locale});
    } catch (_) {}
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
    final network = map['networkConnectionRequired'] ??
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
    if (features.contains('notInstalled') || features.contains('not_installed')) {
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
      id: 'default|en-US',
      name: 'System Default',
      locale: 'en-US',
      availability: TtsVoiceAvailability.installedOffline,
      isUsable: true,
    ),
  ];
}
