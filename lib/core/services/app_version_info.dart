import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/app_constants.dart';

class AppVersionInfo {
  const AppVersionInfo({
    required this.version,
    required this.buildNumber,
    required this.appName,
  });

  final String version;
  final String buildNumber;
  final String appName;

  String get label => '$version ($buildNumber)';
}

final appVersionInfoProvider = FutureProvider<AppVersionInfo>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return AppVersionInfo(
      version: info.version.isEmpty ? AppConstants.appVersion : info.version,
      buildNumber: info.buildNumber.isEmpty
          ? AppConstants.appBuildNumber
          : info.buildNumber,
      appName: info.appName.isEmpty ? AppConstants.appName : info.appName,
    );
  } catch (_) {
    return const AppVersionInfo(
      version: AppConstants.appVersion,
      buildNumber: AppConstants.appBuildNumber,
      appName: AppConstants.appName,
    );
  }
});
