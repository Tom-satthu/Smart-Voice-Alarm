import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/services/trial_entitlement_service.dart';

void main() {
  final epoch = DateTime.utc(2026, 8, 1, 12);

  group('app-managed seven-day trial', () {
    test(
      'starts only when successful foreground launch is initialized',
      () async {
        final store = _MemoryTrialStore();
        final clock = _Clock(epoch);
        final service = TrialEntitlementService(
          store: store,
          clock: clock.call,
        );

        expect(store.startedAt, isNull);
        expect(service.state.status, EntitlementStatus.initializing);

        final state = await service.initializeSuccessfulLaunch();
        expect(store.startedAt, epoch);
        expect(state.status, EntitlementStatus.trialActive);
        expect(state.remaining, const Duration(days: 7));
        expect(state.countdownDays, 7);
      },
    );

    test('restart and app update retain the original start', () async {
      final store = _MemoryTrialStore(startedAt: epoch);
      final clock = _Clock(epoch.add(const Duration(days: 2)));
      final first = TrialEntitlementService(store: store, clock: clock.call);
      await first.initializeSuccessfulLaunch();

      clock.now = epoch.add(const Duration(days: 3));
      final afterRestart = TrialEntitlementService(
        store: store,
        clock: clock.call,
      );
      final state = await afterRestart.initializeSuccessfulLaunch();

      expect(store.startedAt, epoch);
      expect(state.remaining, const Duration(days: 4));
      expect(state.countdownDays, 4);
    });

    test('countdown boundaries are stable', () {
      TrialEntitlementState active(Duration remaining) => TrialEntitlementState(
        status: EntitlementStatus.trialActive,
        remaining: remaining,
      );

      expect(active(const Duration(days: 7)).countdownDays, 7);
      expect(active(const Duration(days: 6, hours: 23)).countdownDays, 7);
      expect(active(const Duration(days: 6)).countdownDays, 6);
      expect(active(const Duration(days: 1)).hasLessThanOneDay, isFalse);
      expect(
        active(const Duration(hours: 23, minutes: 59)).hasLessThanOneDay,
        isTrue,
      );
      expect(active(const Duration(minutes: 1)).countdownDays, 1);
      expect(active(Duration.zero).countdownDays, 0);
    });

    test(
      'expires exactly at seven days and remaining never goes negative',
      () async {
        final store = _MemoryTrialStore(startedAt: epoch);
        final clock = _Clock(epoch.add(const Duration(days: 7)));
        final service = TrialEntitlementService(
          store: store,
          clock: clock.call,
        );

        final state = await service.initializeSuccessfulLaunch();
        expect(state.status, EntitlementStatus.trialExpired);
        expect(state.remaining, Duration.zero);
        expect(store.expiredPermanently, isTrue);
      },
    );

    test('rolling the clock back cannot extend the trial', () async {
      final store = _MemoryTrialStore(startedAt: epoch);
      final clock = _Clock(epoch.add(const Duration(days: 5)));
      final service = TrialEntitlementService(store: store, clock: clock.call);
      await service.initializeSuccessfulLaunch();

      clock.now = epoch.add(const Duration(days: 1));
      final state = await service.refreshLocalTime();
      expect(state.remaining, const Duration(days: 2));
      expect(
        state.latestTrustedLocalTimeUtc,
        epoch.add(const Duration(days: 5)),
      );
    });

    test(
      'forward then backward clock cannot revive an expired trial',
      () async {
        final store = _MemoryTrialStore(startedAt: epoch);
        final clock = _Clock(epoch.add(const Duration(days: 8)));
        final service = TrialEntitlementService(
          store: store,
          clock: clock.call,
        );
        await service.initializeSuccessfulLaunch();

        clock.now = epoch.add(const Duration(days: 2));
        final state = await service.refreshLocalTime();
        expect(state.status, EntitlementStatus.trialExpired);
        expect(store.expiredPermanently, isTrue);
      },
    );

    test('permanent expiry survives a fresh service instance', () async {
      final store = _MemoryTrialStore(
        startedAt: epoch,
        trustedAt: epoch.add(const Duration(days: 8)),
        expiredPermanently: true,
      );
      final service = TrialEntitlementService(
        store: store,
        clock: () => epoch.add(const Duration(days: 1)),
      );

      expect(
        (await service.initializeSuccessfulLaunch()).status,
        EntitlementStatus.trialExpired,
      );
    });

    test('verified subscription bypasses trial expiry', () async {
      final store = _MemoryTrialStore(startedAt: epoch);
      final service = TrialEntitlementService(
        store: store,
        clock: () => epoch.add(const Duration(days: 8)),
      );
      await service.initializeSuccessfulLaunch();

      final state = await service.applySubscriptionVerification(
        SubscriptionVerificationResult.active,
      );
      expect(state.status, EntitlementStatus.subscriptionActive);
      expect(store.cachedActive, isTrue);
      expect(store.lastVerifiedAt, epoch.add(const Duration(days: 8)));
    });

    test('confirmed inactive subscription returns to locked state', () async {
      final now = epoch.add(const Duration(days: 8));
      final store = _MemoryTrialStore(startedAt: epoch);
      final service = TrialEntitlementService(store: store, clock: () => now);
      await service.initializeSuccessfulLaunch();
      await service.applySubscriptionVerification(
        SubscriptionVerificationResult.active,
      );

      final state = await service.applySubscriptionVerification(
        SubscriptionVerificationResult.inactive,
      );
      expect(state.status, EntitlementStatus.trialExpired);
      expect(store.cachedActive, isFalse);
    });

    test('fresh verified subscriber gets three-day offline grace', () async {
      final verified = epoch.add(const Duration(days: 8));
      final store = _MemoryTrialStore(
        startedAt: epoch,
        expiredPermanently: true,
        cachedActive: true,
        lastVerifiedAt: verified,
      );
      final service = TrialEntitlementService(
        store: store,
        clock: () => verified.add(const Duration(days: 2)),
      );

      final state = await service.initializeSuccessfulLaunch();
      expect(state.status, EntitlementStatus.subscriptionActive);
      expect(state.usingCachedSubscription, isTrue);
    });

    test('iOS deferred-sync signal within grace keeps subscription active '
        '(relaunch/resume before the 3-day grace expires)', () async {
      final verified = epoch.add(const Duration(days: 8));
      final store = _MemoryTrialStore(
        startedAt: epoch,
        expiredPermanently: true,
        cachedActive: true,
        lastVerifiedAt: verified,
      );
      final service = TrialEntitlementService(
        store: store,
        clock: () => verified.add(const Duration(days: 2)),
      );
      await service.initializeSuccessfulLaunch();

      // The real iOS gateway can never answer synchronously; it reports
      // `unavailable` while a StoreKit sync is triggered in the
      // background. Within the offline grace window this must not lock
      // out a genuinely active subscriber.
      final state = await service.applySubscriptionVerification(
        SubscriptionVerificationResult.unavailable,
      );
      expect(state.status, EntitlementStatus.subscriptionActive);
      expect(state.usingCachedSubscription, isTrue);
      expect(state.hasFullAccess, isTrue);
    });

    test('expired cache does not grant Premium when Billing fails', () async {
      final verified = epoch.add(const Duration(days: 8));
      final store = _MemoryTrialStore(
        startedAt: epoch,
        expiredPermanently: true,
        cachedActive: true,
        lastVerifiedAt: verified,
      );
      final service = TrialEntitlementService(
        store: store,
        clock: () => verified.add(const Duration(days: 4)),
      );
      await service.initializeSuccessfulLaunch();

      final state = await service.applySubscriptionVerification(
        SubscriptionVerificationResult.unavailable,
      );
      expect(state.status, EntitlementStatus.billingUnavailable);
      expect(state.hasFullAccess, isFalse);
    });

    test('fresh user is never granted Premium by a Billing error', () async {
      final store = _MemoryTrialStore(startedAt: epoch);
      final service = TrialEntitlementService(
        store: store,
        clock: () => epoch.add(const Duration(days: 8)),
      );
      await service.initializeSuccessfulLaunch();

      final state = await service.applySubscriptionVerification(
        SubscriptionVerificationResult.failed,
      );
      expect(state.status, EntitlementStatus.entitlementCheckFailed);
      expect(state.hasFullAccess, isFalse);
    });

    test('pending purchase does not unlock an expired trial', () async {
      final store = _MemoryTrialStore(startedAt: epoch);
      final service = TrialEntitlementService(
        store: store,
        clock: () => epoch.add(const Duration(days: 8)),
      );
      await service.initializeSuccessfulLaunch();

      final state = await service.applySubscriptionVerification(
        SubscriptionVerificationResult.pending,
      );
      expect(state.status, EntitlementStatus.subscriptionPending);
      expect(state.hasFullAccess, isFalse);
    });
  });
}

class _Clock {
  _Clock(this.now);
  DateTime now;
  DateTime call() => now;
}

class _MemoryTrialStore implements TrialEntitlementStore {
  _MemoryTrialStore({
    this.startedAt,
    this.trustedAt,
    this.expiredPermanently = false,
    this.cachedActive = false,
    this.lastVerifiedAt,
  });

  DateTime? startedAt;
  DateTime? trustedAt;
  bool expiredPermanently;
  bool cachedActive;
  DateTime? lastVerifiedAt;

  @override
  DateTime? loadTrialStartedAtUtc() => startedAt;
  @override
  Future<void> saveTrialStartedAtUtc(DateTime value) async => startedAt = value;
  @override
  DateTime? loadLatestTrustedLocalTimeUtc() => trustedAt;
  @override
  Future<void> saveLatestTrustedLocalTimeUtc(DateTime value) async =>
      trustedAt = value;
  @override
  bool loadTrialExpiredPermanently() => expiredPermanently;
  @override
  Future<void> saveTrialExpiredPermanently(bool value) async =>
      expiredPermanently = value;
  @override
  bool loadCachedSubscriptionActive() => cachedActive;
  @override
  Future<void> saveCachedSubscriptionActive(bool value) async =>
      cachedActive = value;
  @override
  DateTime? loadLastSubscriptionVerifiedAtUtc() => lastVerifiedAt;
  @override
  Future<void> saveLastSubscriptionVerifiedAtUtc(DateTime value) async =>
      lastVerifiedAt = value;
}
