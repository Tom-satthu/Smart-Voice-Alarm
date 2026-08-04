enum MonetizationMode { paidApp, inAppPurchase }

/// Single source of truth for release-only feature visibility.
abstract final class ReleaseConfig {
  /// The first Google Play release is configured as a paid app. Play Console
  /// owns the price; the app must not expose an unconfigured purchase flow.
  static const MonetizationMode monetizationMode = MonetizationMode.paidApp;

  static const bool showPremium =
      monetizationMode == MonetizationMode.inAppPurchase;
  static const bool initializeBilling = showPremium;
  static const bool enforceFreeAlarmLimit = showPremium;
}
