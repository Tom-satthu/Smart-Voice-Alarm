import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens system TTS voice install / settings screens.
class TtsPlatformBridge {
  TtsPlatformBridge();

  static const _channel =
      MethodChannel('com.smartvoicealarm.app/tts');

  bool get canManageSystemVoicePacks =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

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
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final uri = Uri.parse('app-settings:');
        if (await canLaunchUrl(uri)) {
          return launchUrl(uri);
        }
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
}
