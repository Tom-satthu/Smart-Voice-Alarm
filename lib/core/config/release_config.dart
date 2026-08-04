enum MonetizationMode { trialWithAnnualSubscription }

/// Single source of truth for release-only feature visibility.
abstract final class ReleaseConfig {
  static const MonetizationMode monetizationMode =
      MonetizationMode.trialWithAnnualSubscription;

  static const bool showPremium = true;
  static const bool initializeBilling = true;

  static const Duration trialDuration = Duration(days: 7);
  static const Duration verifiedSubscriptionOfflineGrace = Duration(days: 3);
}
