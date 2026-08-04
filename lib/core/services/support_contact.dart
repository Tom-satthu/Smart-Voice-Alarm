import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';

/// Central helpers for opening the public support mailbox.
abstract final class SupportContact {
  static const String defaultSubject = 'Smart Voice Alarm Support';

  /// Builds a mailto URI. Does not include alarm content or personal data.
  static Uri mailtoUri({
    String subject = defaultSubject,
    required String appVersion,
    required String buildNumber,
    String? platformLabel,
    String? osVersion,
    String? deviceModel,
  }) {
    final lines = <String>[
      '',
      '---',
      'App version: $appVersion ($buildNumber)',
      'Platform: ${platformLabel ?? _platformLabel()}',
      if (osVersion != null && osVersion.isNotEmpty) 'OS: $osVersion',
      if (deviceModel != null && deviceModel.isNotEmpty) 'Device: $deviceModel',
    ];
    final query = <String, String>{
      'subject': subject,
      'body': lines.join('\n'),
    };
    return Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      query: _encodeQuery(query),
    );
  }

  static String _platformLabel() {
    if (kIsWeb) return 'Web';
    return defaultTargetPlatform.name;
  }

  /// mailto query encoding: spaces as %20 (not +).
  static String _encodeQuery(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}
