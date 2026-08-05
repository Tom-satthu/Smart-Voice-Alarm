import '../config/release_config.dart';
import '../../shared/data/local_store.dart';

enum EntitlementStatus {
  initializing,
  trialActive,
  trialExpired,
  subscriptionActive,
  subscriptionPending,
  billingUnavailable,
  entitlementCheckFailed,
}

enum SubscriptionVerificationResult {
  active,
  inactive,
  pending,
  unavailable,
  failed,
}

class TrialEntitlementState {
  const TrialEntitlementState({
    required this.status,
    this.trialStartedAtUtc,
    this.latestTrustedLocalTimeUtc,
    this.lastSubscriptionVerifiedAtUtc,
    this.remaining = Duration.zero,
    this.usingCachedSubscription = false,
  });

  const TrialEntitlementState.initializing()
    : this(status: EntitlementStatus.initializing);

  final EntitlementStatus status;
  final DateTime? trialStartedAtUtc;
  final DateTime? latestTrustedLocalTimeUtc;
  final DateTime? lastSubscriptionVerifiedAtUtc;
  final Duration remaining;
  final bool usingCachedSubscription;

  bool get hasFullAccess =>
      status == EntitlementStatus.trialActive ||
      status == EntitlementStatus.subscriptionActive;

  bool get isLocked =>
      status == EntitlementStatus.trialExpired ||
      status == EntitlementStatus.billingUnavailable ||
      status == EntitlementStatus.entitlementCheckFailed;

  bool get isTrialActive => status == EntitlementStatus.trialActive;

  int get countdownDays {
    if (!isTrialActive || remaining <= Duration.zero) return 0;
    final minutes = remaining.inMinutes;
    return (minutes / Duration.minutesPerDay).ceil().clamp(1, 7);
  }

  bool get hasLessThanOneDay =>
      isTrialActive &&
      remaining > Duration.zero &&
      remaining < const Duration(days: 1);
}

abstract interface class TrialEntitlementStore {
  DateTime? loadTrialStartedAtUtc();
  Future<void> saveTrialStartedAtUtc(DateTime value);
  DateTime? loadLatestTrustedLocalTimeUtc();
  Future<void> saveLatestTrustedLocalTimeUtc(DateTime value);
  bool loadTrialExpiredPermanently();
  Future<void> saveTrialExpiredPermanently(bool value);
  bool loadCachedSubscriptionActive();
  Future<void> saveCachedSubscriptionActive(bool value);
  DateTime? loadLastSubscriptionVerifiedAtUtc();
  Future<void> saveLastSubscriptionVerifiedAtUtc(DateTime value);
}

class SettingsTrialEntitlementStore implements TrialEntitlementStore {
  SettingsTrialEntitlementStore(this._repository);

  final SettingsRepository _repository;

  @override
  DateTime? loadTrialStartedAtUtc() => _repository.loadTrialStartedAtUtc();

  @override
  Future<void> saveTrialStartedAtUtc(DateTime value) =>
      _repository.saveTrialStartedAtUtc(value);

  @override
  DateTime? loadLatestTrustedLocalTimeUtc() =>
      _repository.loadLatestTrustedLocalTimeUtc();

  @override
  Future<void> saveLatestTrustedLocalTimeUtc(DateTime value) =>
      _repository.saveLatestTrustedLocalTimeUtc(value);

  @override
  bool loadTrialExpiredPermanently() =>
      _repository.loadTrialExpiredPermanently();

  @override
  Future<void> saveTrialExpiredPermanently(bool value) =>
      _repository.saveTrialExpiredPermanently(value);

  @override
  bool loadCachedSubscriptionActive() =>
      _repository.loadCachedSubscriptionActive();

  @override
  Future<void> saveCachedSubscriptionActive(bool value) =>
      _repository.saveCachedSubscriptionActive(value);

  @override
  DateTime? loadLastSubscriptionVerifiedAtUtc() =>
      _repository.loadLastSubscriptionVerifiedAtUtc();

  @override
  Future<void> saveLastSubscriptionVerifiedAtUtc(DateTime value) =>
      _repository.saveLastSubscriptionVerifiedAtUtc(value);
}

typedef UtcClock = DateTime Function();

/// Owns the app-managed trial and the short offline cache for a subscription
/// that Google Play previously verified as active.
class TrialEntitlementService {
  TrialEntitlementService({
    required TrialEntitlementStore store,
    UtcClock? clock,
    this.trialDuration = ReleaseConfig.trialDuration,
    this.offlineGrace = ReleaseConfig.verifiedSubscriptionOfflineGrace,
  }) : _store = store,
       _clock = clock ?? _systemUtcNow;

  final TrialEntitlementStore _store;
  final UtcClock _clock;
  final Duration trialDuration;
  final Duration offlineGrace;

  TrialEntitlementState _state = const TrialEntitlementState.initializing();

  TrialEntitlementState get state => _state;

  /// Called from the first foreground UI, never from receivers/services.
  Future<TrialEntitlementState> initializeSuccessfulLaunch() async {
    final now = _clock().toUtc();
    var startedAt = _store.loadTrialStartedAtUtc();
    if (startedAt == null) {
      startedAt = now;
      await _store.saveTrialStartedAtUtc(startedAt);
    }

    final trusted = _trustedNow(now);
    await _store.saveLatestTrustedLocalTimeUtc(trusted);

    var expired = _store.loadTrialExpiredPermanently();
    if (!expired && !trusted.isBefore(startedAt.add(trialDuration))) {
      expired = true;
      await _store.saveTrialExpiredPermanently(true);
    }

    final lastVerified = _store.loadLastSubscriptionVerifiedAtUtc();
    final cachedActive = _store.loadCachedSubscriptionActive();
    final cacheFresh =
        cachedActive &&
        lastVerified != null &&
        trusted.difference(lastVerified) <= offlineGrace;

    _state = cacheFresh
        ? TrialEntitlementState(
            status: EntitlementStatus.subscriptionActive,
            trialStartedAtUtc: startedAt,
            latestTrustedLocalTimeUtc: trusted,
            lastSubscriptionVerifiedAtUtc: lastVerified,
            usingCachedSubscription: true,
          )
        : _trialState(
            startedAt: startedAt,
            trusted: trusted,
            expired: expired,
            lastVerified: lastVerified,
          );
    return _state;
  }

  Future<TrialEntitlementState> refreshLocalTime() async {
    if (_state.trialStartedAtUtc == null) return _state;
    final trusted = _trustedNow(_clock().toUtc());
    await _store.saveLatestTrustedLocalTimeUtc(trusted);
    var expired = _store.loadTrialExpiredPermanently();
    if (!expired &&
        !trusted.isBefore(_state.trialStartedAtUtc!.add(trialDuration))) {
      expired = true;
      await _store.saveTrialExpiredPermanently(true);
    }
    if (_state.status == EntitlementStatus.subscriptionActive) {
      _state = TrialEntitlementState(
        status: EntitlementStatus.subscriptionActive,
        trialStartedAtUtc: _state.trialStartedAtUtc,
        latestTrustedLocalTimeUtc: trusted,
        lastSubscriptionVerifiedAtUtc: _state.lastSubscriptionVerifiedAtUtc,
        usingCachedSubscription: _state.usingCachedSubscription,
      );
      return _state;
    }
    _state = _trialState(
      startedAt: _state.trialStartedAtUtc!,
      trusted: trusted,
      expired: expired,
      lastVerified: _state.lastSubscriptionVerifiedAtUtc,
    );
    return _state;
  }

  Future<TrialEntitlementState> applySubscriptionVerification(
    SubscriptionVerificationResult result,
  ) async {
    if (_state.trialStartedAtUtc == null) {
      await initializeSuccessfulLaunch();
    }
    final now = _trustedNow(_clock().toUtc());
    await _store.saveLatestTrustedLocalTimeUtc(now);

    if (result == SubscriptionVerificationResult.active) {
      await _store.saveCachedSubscriptionActive(true);
      await _store.saveLastSubscriptionVerifiedAtUtc(now);
      _state = TrialEntitlementState(
        status: EntitlementStatus.subscriptionActive,
        trialStartedAtUtc: _state.trialStartedAtUtc,
        latestTrustedLocalTimeUtc: now,
        lastSubscriptionVerifiedAtUtc: now,
      );
      return _state;
    }

    if (result == SubscriptionVerificationResult.inactive) {
      await _store.saveCachedSubscriptionActive(false);
      await _store.saveLastSubscriptionVerifiedAtUtc(now);
      return _setTrialOrExpired(now, lastVerified: now);
    }

    if (result == SubscriptionVerificationResult.pending) {
      final local = await _setTrialOrExpired(
        now,
        lastVerified: _store.loadLastSubscriptionVerifiedAtUtc(),
      );
      if (local.isTrialActive) return local;
      _state = TrialEntitlementState(
        status: EntitlementStatus.subscriptionPending,
        trialStartedAtUtc: local.trialStartedAtUtc,
        latestTrustedLocalTimeUtc: now,
        lastSubscriptionVerifiedAtUtc: local.lastSubscriptionVerifiedAtUtc,
      );
      return _state;
    }

    final cachedActive = _store.loadCachedSubscriptionActive();
    final lastVerified = _store.loadLastSubscriptionVerifiedAtUtc();
    final cacheFresh =
        cachedActive &&
        lastVerified != null &&
        now.difference(lastVerified) <= offlineGrace;
    if (cacheFresh) {
      _state = TrialEntitlementState(
        status: EntitlementStatus.subscriptionActive,
        trialStartedAtUtc: _state.trialStartedAtUtc,
        latestTrustedLocalTimeUtc: now,
        lastSubscriptionVerifiedAtUtc: lastVerified,
        usingCachedSubscription: true,
      );
      return _state;
    }

    final local = await _setTrialOrExpired(now, lastVerified: lastVerified);
    if (local.isTrialActive) return local;
    _state = TrialEntitlementState(
      status: result == SubscriptionVerificationResult.unavailable
          ? EntitlementStatus.billingUnavailable
          : EntitlementStatus.entitlementCheckFailed,
      trialStartedAtUtc: local.trialStartedAtUtc,
      latestTrustedLocalTimeUtc: now,
      lastSubscriptionVerifiedAtUtc: lastVerified,
    );
    return _state;
  }

  Future<TrialEntitlementState> _setTrialOrExpired(
    DateTime trusted, {
    required DateTime? lastVerified,
  }) async {
    final startedAt = _state.trialStartedAtUtc!;
    var expired = _store.loadTrialExpiredPermanently();
    if (!expired && !trusted.isBefore(startedAt.add(trialDuration))) {
      expired = true;
      await _store.saveTrialExpiredPermanently(true);
    }
    _state = _trialState(
      startedAt: startedAt,
      trusted: trusted,
      expired: expired,
      lastVerified: lastVerified,
    );
    return _state;
  }

  TrialEntitlementState _trialState({
    required DateTime startedAt,
    required DateTime trusted,
    required bool expired,
    required DateTime? lastVerified,
  }) {
    final remaining = startedAt.add(trialDuration).difference(trusted);
    return TrialEntitlementState(
      status: expired
          ? EntitlementStatus.trialExpired
          : EntitlementStatus.trialActive,
      trialStartedAtUtc: startedAt,
      latestTrustedLocalTimeUtc: trusted,
      lastSubscriptionVerifiedAtUtc: lastVerified,
      remaining: remaining.isNegative ? Duration.zero : remaining,
    );
  }

  DateTime _trustedNow(DateTime observedUtc) {
    final previous = _store.loadLatestTrustedLocalTimeUtc();
    if (previous != null && observedUtc.isBefore(previous)) return previous;
    return observedUtc;
  }

  static DateTime _systemUtcNow() => DateTime.now().toUtc();
}
