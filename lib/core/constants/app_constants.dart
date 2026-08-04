abstract final class AppConstants {
  static const String appName = 'Smart Voice Alarm';

  /// Fallback only — prefer [PackageInfo] at runtime.
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  static const String applicationId = 'com.smartvoicealarm.app';

  /// Public Google Play developer display name (not legal account name).
  static const String developerName = 'Nguyên Đức';

  /// Public support inbox for users and store listings.
  static const String supportEmail = 'timeforwork789@gmail.com';

  /// Leave empty until the separately hosted legal site is live.
  static const String websiteUrl = '';
  static const String privacyPolicyUrl = '';
  static const String supportUrl = '';
  static const String termsOfUseUrl = '';

  /// Play / App Store public URLs — empty until published.
  static const String playStoreUrl = '';
  static const String appStoreUrl = '';
  static const String appStoreId = '';

  static bool get hasPrivacyPolicyUrl => privacyPolicyUrl.trim().isNotEmpty;
  static bool get hasTermsOfUseUrl => termsOfUseUrl.trim().isNotEmpty;
  static bool get hasWebsiteUrl => websiteUrl.trim().isNotEmpty;
  static bool get hasSupportUrl => supportUrl.trim().isNotEmpty;
  static bool get hasPlayStoreUrl => playStoreUrl.trim().isNotEmpty;
  static bool get hasAppStoreUrl =>
      appStoreUrl.trim().isNotEmpty || appStoreId.trim().isNotEmpty;

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
