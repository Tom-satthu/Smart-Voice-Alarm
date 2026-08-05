import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'resolved_system_voice.dart';

/// Snapshot of the default TTS engine voice selection.
class TtsEngineVoiceInfo {
  const TtsEngineVoiceInfo({
    required this.name,
    required this.locale,
    this.networkRequired = false,
    this.identifier,
    this.engine,
  });

  final String name;
  final String locale;
  final bool networkRequired;
  final String? identifier;
  final String? engine;

  String get id {
    final key = identifier?.trim();
    if (key != null && key.isNotEmpty) return '$key|$locale';
    return '$name|$locale';
  }

  factory TtsEngineVoiceInfo.fromMap(Map<dynamic, dynamic> map) {
    final name = (map['name'] ?? map['identifier'] ?? 'Voice').toString();
    final locale = (map['locale'] ?? 'en').toString();
    final network =
        map['networkRequired'] ??
        map['network_required'] ??
        map['requiresNetwork'];
    final identifier = (map['identifier'] ?? map['name'])?.toString();
    return TtsEngineVoiceInfo(
      name: name,
      locale: locale,
      networkRequired: network == true || network?.toString() == '1',
      identifier: identifier,
      engine: map['engine']?.toString(),
    );
  }
}

class TtsEngineVoiceState {
  const TtsEngineVoiceState({this.current, this.defaultVoice});

  final TtsEngineVoiceInfo? current;
  final TtsEngineVoiceInfo? defaultVoice;

  TtsEngineVoiceInfo? get effective => current ?? defaultVoice;
}

/// Opens system TTS voice install / settings screens.
class TtsPlatformBridge {
  TtsPlatformBridge();

  static const _channel = MethodChannel('com.smartvoicealarm.app/tts');

  bool get canManageSystemVoicePacks =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Android: INSTALL_TTS_DATA, then System TTS Settings.
  /// iOS: public app-settings link.
  Future<bool> openDownloadMoreVoices() async {
    if (kIsWeb) return false;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          final opened =
              await _channel.invokeMethod<bool>('openInstallTtsData') ?? false;
          if (opened) return true;
        } catch (error) {
          debugPrint('openInstallTtsData failed: $error');
        }
        return openSystemTtsSettings();
      }
    } catch (error) {
      debugPrint('openDownloadMoreVoices failed: $error');
    }
    return false;
  }

  Future<void> checkTtsData() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('checkTtsData');
    } catch (error) {
      debugPrint('checkTtsData failed: $error');
    }
  }

  Future<bool> openSystemTtsSettings() async {
    if (kIsWeb) return false;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return await _channel.invokeMethod<bool>('openSystemTtsSettings') ??
            false;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final uri = Uri.parse('app-settings:');
        if (await canLaunchUrl(uri)) {
          return launchUrl(uri);
        }
      }
    } catch (error) {
      debugPrint('openSystemTtsSettings failed: $error');
    }
    return false;
  }

  /// Reads [TextToSpeech.getVoice] / defaultVoice from the default engine.
  Future<TtsEngineVoiceState?> getEngineVoiceState() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }
    try {
      final raw = await _channel.invokeMethod<dynamic>('getEngineVoiceState');
      if (raw is! Map) return null;
      final map = Map<dynamic, dynamic>.from(raw);
      TtsEngineVoiceInfo? parse(dynamic value) {
        if (value is! Map) return null;
        return TtsEngineVoiceInfo.fromMap(Map<dynamic, dynamic>.from(value));
      }

      return TtsEngineVoiceState(
        current: parse(map['current']),
        defaultVoice: parse(map['default']),
      );
    } catch (error) {
      debugPrint('getEngineVoiceState failed: $error');
      return null;
    }
  }

  /// Per-locale system defaults: setLanguage only, then read current voice.
  Future<Map<String, ResolvedSystemVoiceState>> resolveSystemDefaultsForLocales(
    List<String> locales,
  ) async {
    if (locales.isEmpty) return const {};
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const {};
    }
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>(
        'resolveSystemDefaultsForLocales',
        {'locales': locales},
      );
      if (raw == null) return const {};
      final out = <String, ResolvedSystemVoiceState>{};
      for (final item in raw) {
        if (item is! Map) continue;
        final state = ResolvedSystemVoiceState.fromMap(
          Map<dynamic, dynamic>.from(item),
        );
        if (state.requestedLocale.isEmpty) continue;
        out[state.requestedLocale.replaceAll('_', '-')] = state;
      }
      return out;
    } catch (error) {
      debugPrint('resolveSystemDefaultsForLocales failed: $error');
      return const {};
    }
  }

  Future<List<Map<String, dynamic>>?> getPlatformVoices() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>('getTtsVoices');
      return raw
          ?.whereType<Map>()
          .map((value) => Map<String, dynamic>.from(value))
          .toList();
    } catch (error) {
      debugPrint('getTtsVoices failed: $error');
      return null;
    }
  }

  /// Selects a voice on a silent native TTS instance and reads it back.
  Future<TtsEngineVoiceInfo?> probeVoice({
    required String name,
    required String locale,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'probeTtsVoice',
        {'name': name, 'locale': locale},
      );
      return raw == null ? null : TtsEngineVoiceInfo.fromMap(raw);
    } catch (error) {
      debugPrint('probeTtsVoice($name, $locale) failed: $error');
      return null;
    }
  }
}
