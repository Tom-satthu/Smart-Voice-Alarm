import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../shared/models/ui_models.dart';

class TtsService {
  TtsService() : _tts = FlutterTts();

  final FlutterTts _tts;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await _tts.awaitSpeakCompletion(true);
    if (!kIsWeb) {
      await _tts.setSharedInstance(true);
    }
    _ready = true;
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
        if (!locale.toLowerCase().startsWith('en')) continue;
        voices.add(
          TtsVoiceUiModel(
            id: '$name|$locale',
            name: name,
            locale: locale,
          ),
        );
      }
      if (voices.isEmpty) return _fallbackVoices;
      voices.sort((a, b) => a.name.compareTo(b.name));
      return voices;
    } catch (_) {
      return _fallbackVoices;
    }
  }

  Future<void> preview({
    required String text,
    String? voiceId,
    String? locale,
  }) async {
    await init();
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (locale != null && locale.isNotEmpty) {
      await _tts.setLanguage(locale);
    }
    if (voiceId != null && voiceId.contains('|')) {
      final name = voiceId.split('|').first;
      try {
        await _tts.setVoice({'name': name, 'locale': locale ?? 'en-US'});
      } catch (_) {}
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

  static const _fallbackVoices = [
    TtsVoiceUiModel(id: 'default|en-US', name: 'System Default', locale: 'en-US'),
  ];
}
