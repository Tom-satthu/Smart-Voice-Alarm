import 'package:flutter/foundation.dart';

/// Platform-specific public attribution (not App Store seller name).
abstract final class PlatformAttribution {
  static const androidDeveloperName = 'Nguyên Đức';
  static const iosDeveloperName = 'Trần Thị Cẩm Mỹ';

  static String get developerName {
    if (kIsWeb) return androidDeveloperName;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosDeveloperName;
    }
    return androidDeveloperName;
  }

  /// Test/helper for deterministic platform checks.
  static String developerNameFor(TargetPlatform platform) {
    return platform == TargetPlatform.iOS
        ? iosDeveloperName
        : androidDeveloperName;
  }
}
