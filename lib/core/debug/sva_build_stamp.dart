import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Temporary review/diagnostic build stamp (not a product feature).
class SvaBuildStamp {
  SvaBuildStamp._();

  static const gitSha = String.fromEnvironment('SVA_GIT_SHA', defaultValue: '');
  static const gitBranch = String.fromEnvironment(
    'SVA_GIT_BRANCH',
    defaultValue: '',
  );
  static const buildStamp = String.fromEnvironment(
    'SVA_BUILD_STAMP',
    defaultValue: '',
  );
  static const buildMode = String.fromEnvironment(
    'SVA_BUILD_MODE',
    defaultValue: '',
  );
  static const buildTime = String.fromEnvironment(
    'SVA_BUILD_TIME',
    defaultValue: '',
  );
  static const alarmKitStartup = String.fromEnvironment(
    'SVA_ALARMKIT_STARTUP',
    defaultValue: '',
  );
  static const alarmKitForceOff = String.fromEnvironment(
    'SVA_ALARMKIT_FORCE_OFF',
    defaultValue: '0',
  );
  static const diagStage = String.fromEnvironment(
    'SVA_DIAG_STAGE',
    defaultValue: '',
  );

  /// True when `--dart-define=SVA_REVIEW_BUILD=true` or `=1` (review builds only).
  static bool get reviewBuild {
    const raw = String.fromEnvironment('SVA_REVIEW_BUILD', defaultValue: '');
    return raw == 'true' || raw == '1';
  }

  /// Review-only automated staged probe (off in production).
  static bool get autoProbe {
    const raw = String.fromEnvironment('SVA_DIAG_AUTO_PROBE', defaultValue: '');
    return reviewBuild && (raw == 'true' || raw == '1');
  }

  static const MethodChannel _channel = MethodChannel(
    'com.smartvoicealarm.app/ios_alarms',
  );

  static bool get hasDartStamp => buildStamp.isNotEmpty;

  static String get oneLineSummary {
    if (!hasDartStamp) return 'SVA_BUILD=unknown';
    return 'SVA_BUILD=$buildStamp '
        'SVA_MODE=$buildMode '
        'SVA_ALARMKIT_STARTUP=$alarmKitStartup '
        'SVA_STAGE=$diagStage';
  }

  /// Log immediately after Flutter binding/engine init.
  static void logStartup() {
    debugPrint('[SVA-Build] $oneLineSummary time=$buildTime sha=$gitSha');
  }

  static Future<Map<String, dynamic>> fetchNativeStamp() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return {};
    }
    try {
      final raw = await _channel.invokeMethod<Map<Object?, Object?>>(
        'getBuildStamp',
      );
      return raw?.map((k, v) => MapEntry(k.toString(), v)) ?? {};
    } catch (e) {
      debugPrint('[SVA-Build] native stamp fetch failed: $e');
      return {};
    }
  }

  /// Settings card text — dart defines first, native stamp enriches async.
  static String formatForSettings({Map<String, dynamic> native = const {}}) {
    final stamp = _firstNonEmpty([
      native['buildStamp']?.toString(),
      buildStamp,
    ]);
    final mode = _firstNonEmpty([native['buildMode']?.toString(), buildMode]);
    final ak = _firstNonEmpty([
      native['alarmKitStartup']?.toString(),
      alarmKitStartup,
    ]);
    final stage = _firstNonEmpty([native['diagStage']?.toString(), diagStage]);
    final time = _firstNonEmpty([native['buildTime']?.toString(), buildTime]);
    final uuid = _firstNonEmpty([native['binaryUuid']?.toString()]);
    final lines = <String>[
      'SVA_BUILD=$stamp',
      'SVA_MODE=$mode',
      'SVA_ALARMKIT_STARTUP=$ak',
      'SVA_DIAG_STAGE=$stage',
      'SVA_BUILD_TIME=$time',
    ];
    if (uuid.isNotEmpty) {
      lines.add('BINARY_UUID=$uuid');
    }
    return lines.join('\n');
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.isNotEmpty) return v;
    }
    return 'unknown';
  }
}
