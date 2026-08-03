abstract final class AppConstants {
  static const String appName = 'Smart Voice Alarm';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String applicationId = 'com.smartvoicealarm.app';
  static const String developerName = 'Tom Satthu';
  static const String githubRepoUrl =
      'https://github.com/Tom-satthu/Smart-Voice-Alarm';
  /// Owner contact — replace with a dedicated support inbox when available.
  static const String supportEmail = 'daonguyenduc209@gmail.com';
  static const String websiteUrl =
      'https://tom-satthu.github.io/Smart-Voice-Alarm/';
  static const String privacyUrl =
      'https://tom-satthu.github.io/Smart-Voice-Alarm/privacy/';
  static const String termsUrl =
      'https://tom-satthu.github.io/Smart-Voice-Alarm/terms/';
  static const String supportUrl =
      'https://tom-satthu.github.io/Smart-Voice-Alarm/support/';

  /// Non-consumable product shared conceptually on App Store and Play.
  static const String premiumProductId = 'smart_voice_alarm_unlimited';
  static const int freeAlarmLimit = 3;
  /// Display hint only when the store has not returned a localized price yet.
  static const String premiumPriceHintUsd = '\$1.99';

  static const Duration splashDuration = Duration(milliseconds: 1600);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 320);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const double maxContentWidth = 720;
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 48;

  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
}
