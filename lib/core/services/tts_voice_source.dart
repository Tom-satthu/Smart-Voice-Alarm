import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_platform_bridge.dart';

enum VoicePlatformKind { android, apple, web, other }

class VoiceCapabilities {
  const VoiceCapabilities({
    required this.platform,
    required this.supportsVoiceManagement,
    required this.validatesSelectability,
  });

  final VoicePlatformKind platform;
  final bool supportsVoiceManagement;
  final bool validatesSelectability;
}

abstract interface class VoiceSource {
  VoiceCapabilities get capabilities;

  Future<List<Map<String, dynamic>>> loadVoices(FlutterTts tts);

  Future<List<Map<String, dynamic>>> refreshVoices(FlutterTts tts) =>
      loadVoices(tts);

  Future<TtsEngineVoiceInfo?> resolveSystemDefault(FlutterTts tts);

  bool validateSelectableVoice(Map<String, dynamic> voice);
}

class AndroidVoiceSource implements VoiceSource {
  AndroidVoiceSource(this._bridge);

  final TtsPlatformBridge _bridge;

  @override
  VoiceCapabilities get capabilities => const VoiceCapabilities(
    platform: VoicePlatformKind.android,
    supportsVoiceManagement: true,
    validatesSelectability: true,
  );

  @override
  Future<List<Map<String, dynamic>>> loadVoices(FlutterTts tts) async {
    // Native metadata is used on Android because some engines expose aliases
    // that accept setVoice but resolve to another current voice.
    final verified = await _bridge.getPlatformVoices();
    if (verified != null && verified.isNotEmpty) return verified;
    return _flutterVoices(tts);
  }

  @override
  Future<List<Map<String, dynamic>>> refreshVoices(FlutterTts tts) =>
      loadVoices(tts);

  @override
  Future<TtsEngineVoiceInfo?> resolveSystemDefault(FlutterTts tts) async {
    final state = await _bridge.getEngineVoiceState();
    return state?.effective ?? _flutterDefaultVoice(tts);
  }

  @override
  bool validateSelectableVoice(Map<String, dynamic> voice) =>
      voice['selectable'] != false;
}

class PublicApiVoiceSource implements VoiceSource {
  const PublicApiVoiceSource(this.capabilities);

  @override
  final VoiceCapabilities capabilities;

  @override
  Future<List<Map<String, dynamic>>> loadVoices(FlutterTts tts) =>
      _flutterVoices(tts);

  @override
  Future<List<Map<String, dynamic>>> refreshVoices(FlutterTts tts) =>
      loadVoices(tts);

  @override
  Future<TtsEngineVoiceInfo?> resolveSystemDefault(FlutterTts tts) =>
      _flutterDefaultVoice(tts);

  @override
  bool validateSelectableVoice(Map<String, dynamic> voice) => true;
}

VoiceSource createVoiceSource(TtsPlatformBridge bridge) {
  if (kIsWeb) {
    return const PublicApiVoiceSource(
      VoiceCapabilities(
        platform: VoicePlatformKind.web,
        supportsVoiceManagement: false,
        validatesSelectability: false,
      ),
    );
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => AndroidVoiceSource(bridge),
    TargetPlatform.iOS || TargetPlatform.macOS => const PublicApiVoiceSource(
      VoiceCapabilities(
        platform: VoicePlatformKind.apple,
        supportsVoiceManagement: false,
        validatesSelectability: false,
      ),
    ),
    _ => const PublicApiVoiceSource(
      VoiceCapabilities(
        platform: VoicePlatformKind.other,
        supportsVoiceManagement: false,
        validatesSelectability: false,
      ),
    ),
  };
}

Future<List<Map<String, dynamic>>> _flutterVoices(FlutterTts tts) async {
  final raw = await tts.getVoices;
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((voice) => Map<String, dynamic>.from(voice))
      .toList();
}

Future<TtsEngineVoiceInfo?> _flutterDefaultVoice(FlutterTts tts) async {
  try {
    final raw = await tts.getDefaultVoice;
    if (raw is Map && raw.isNotEmpty) {
      return TtsEngineVoiceInfo.fromMap(Map<dynamic, dynamic>.from(raw));
    }
  } catch (error) {
    debugPrint('getDefaultVoice failed: $error');
  }
  return null;
}
