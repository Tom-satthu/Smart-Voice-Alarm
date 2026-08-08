import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:smart_voice_alarm/core/constants/app_constants.dart';
import 'package:smart_voice_alarm/core/services/premium_purchase_service.dart';
import 'package:smart_voice_alarm/core/services/trial_entitlement_service.dart';

void main() {
  group('annual subscription billing', () {
    late _FakeBillingGateway gateway;
    late PremiumPurchaseService service;

    setUp(() {
      gateway = _FakeBillingGateway();
      service = PremiumPurchaseService(gateway: gateway);
    });

    tearDown(() async {
      await service.dispose();
      await gateway.close();
    });

    test(
      'queries exact product and exposes only localized Play price',
      () async {
        await service.init();
        expect(gateway.productQueries, 1);
        expect(service.state.product?.id, AppConstants.premiumSubscriptionId);
        expect(service.state.product?.basePlanId, 'annual-auto');
        expect(service.state.localizedPrice, '79.000 ₫');
      },
    );

    test(
      'missing ProductDetails has no fake price and cannot launch',
      () async {
        gateway.productResult = const BillingQueryResult.failure(
          'product_unavailable',
        );
        await service.init();
        expect(service.state.localizedPrice, isNull);

        await service.buy();
        expect(gateway.launchCount, 0);
        expect(service.state.status, PurchaseFlowStatus.productUnavailable);
      },
    );

    test('purchase launches only after explicit buy', () async {
      await service.init();
      expect(gateway.launchCount, 0);
      await service.buy();
      expect(gateway.launchCount, 1);
      expect(service.state.status, PurchaseFlowStatus.purchasing);
    });

    test('pending and cancelled purchases never unlock', () async {
      await service.init();
      gateway.emit([_purchase(BillingPurchaseStatus.pending)]);
      await _eventLoop();
      expect(
        service.state.verification,
        SubscriptionVerificationResult.pending,
      );
      expect(service.state.isSubscriptionActive, isFalse);

      gateway.emit([_purchase(BillingPurchaseStatus.cancelled)]);
      await _eventLoop();
      expect(
        service.state.verification,
        SubscriptionVerificationResult.inactive,
      );
      expect(service.state.isSubscriptionActive, isFalse);
    });

    test(
      'exact purchased product with token unlocks and acknowledges once',
      () async {
        await service.init();
        final purchase = _purchase(BillingPurchaseStatus.purchased);
        gateway.emit([purchase]);
        await _eventLoop();

        expect(
          service.state.verification,
          SubscriptionVerificationResult.active,
        );
        expect(gateway.acknowledged, [purchase]);
        expect(gateway.consumeCount, 0);
      },
    );

    test('wrong product or empty token never unlocks', () async {
      await service.init();
      gateway.emit([
        _purchase(
          BillingPurchaseStatus.purchased,
          productId: 'premium_monthly',
        ),
      ]);
      await _eventLoop();
      expect(service.state.isSubscriptionActive, isFalse);

      gateway.emit([_purchase(BillingPurchaseStatus.purchased, token: '')]);
      await _eventLoop();
      expect(service.state.isSubscriptionActive, isFalse);
      expect(gateway.acknowledged, isEmpty);
    });

    test('current purchase query restores access', () async {
      gateway.currentPurchases = [
        _purchase(BillingPurchaseStatus.restored, pendingComplete: false),
      ];
      await service.init();
      expect(service.state.verification, SubscriptionVerificationResult.active);
    });

    test('empty current purchases revoke prior entitlement', () async {
      gateway.currentPurchases = [_purchase(BillingPurchaseStatus.purchased)];
      await service.init();
      gateway.currentPurchases = [];
      await service.syncEntitlementsFromStore();
      expect(
        service.state.verification,
        SubscriptionVerificationResult.inactive,
      );
    });

    test('unavailable Billing is finite and does not crash', () async {
      gateway.available = false;
      await service.init();
      expect(service.state.status, PurchaseFlowStatus.unavailable);
      expect(
        service.state.verification,
        SubscriptionVerificationResult.unavailable,
      );
    });

    test('init subscribes to purchase stream only once', () async {
      await service.init();
      await service.init();
      expect(gateway.listenCount, 1);
    });

    test(
      'restore invokes store restore and re-queries current purchase',
      () async {
        await service.init();
        gateway.currentPurchases = [
          _purchase(BillingPurchaseStatus.purchased, pendingComplete: false),
        ];
        await service.restore();
        expect(gateway.restoreCount, 1);
        expect(service.state.status, PurchaseFlowStatus.restored);
      },
    );

    test('purchase error status never grants access', () async {
      await service.init();
      gateway.emit([_purchase(BillingPurchaseStatus.error)]);
      await _eventLoop();
      expect(service.state.verification, SubscriptionVerificationResult.failed);
      expect(service.state.isSubscriptionActive, isFalse);
    });

    test(
      'purchase listener is attached before the first entitlement query',
      () async {
        await service.init();
        expect(gateway.callOrder.first, 'listen');
        expect(gateway.callOrder, contains('queryCurrentPurchases'));
        expect(
          gateway.callOrder.indexOf('listen'),
          lessThan(gateway.callOrder.indexOf('queryCurrentPurchases')),
        );
      },
    );

    test('iOS transaction-query transport failure is unavailable, not a hard '
        'failure, and does not clear an active purchase state that is still '
        'valid', () async {
      // Prime an active purchase via the stream first, as a real
      // purchase or restore event would.
      await service.init();
      gateway.emit([
        _purchase(BillingPurchaseStatus.purchased, pendingComplete: false),
      ]);
      await _eventLoop();
      expect(service.state.verification, SubscriptionVerificationResult.active);

      // Simulate the real iOS gateway when SK2Transaction.transactions()
      // itself throws (channel/plugin error) — see
      // InAppPurchaseBillingGateway.iosEntitlementQueryFailedCode. This
      // is a transport failure, never a claim that the subscription is
      // inactive.
      gateway.queryCurrentPurchasesOverride = const BillingQueryResult.failure(
        InAppPurchaseBillingGateway.iosEntitlementQueryFailedCode,
      );
      await service.syncEntitlementsFromStore();

      expect(
        service.state.verification,
        SubscriptionVerificationResult.unavailable,
      );
      expect(service.state.status, isNot(PurchaseFlowStatus.error));
      expect(service.state.errorMessage, isNull);
    });

    test('a genuine query failure (not the iOS transport marker) still reports '
        'failed', () async {
      await service.init();
      gateway.queryCurrentPurchasesOverride = const BillingQueryResult.failure(
        'current_query_failed',
      );
      await service.syncEntitlementsFromStore();
      expect(service.state.verification, SubscriptionVerificationResult.failed);
      expect(service.state.status, PurchaseFlowStatus.error);
    });
  });

  group('AppStore.sync() call-site invariant', () {
    // No real StoreKit runtime is available in unit tests, so this checks
    // the invariant structurally against the actual source instead of
    // behaviorally — see the final report for why this still needs a real
    // device/TestFlight pass to fully confirm.
    test('sync() is only reachable from restorePurchases(), never from '
        'queryCurrentPurchases (the startup/resume path)', () {
      final source = File(
        'lib/core/services/premium_purchase_service.dart',
      ).readAsStringSync();

      final queryStart = source.indexOf('queryCurrentPurchases() async {');
      final queryEnd = source.indexOf(
        '\n  /// Picks the most recent',
        queryStart,
      );
      expect(queryStart, greaterThan(-1));
      expect(queryEnd, greaterThan(queryStart));
      expect(
        source.substring(queryStart, queryEnd).contains('.sync()'),
        isFalse,
      );

      final restoreStart = source.indexOf(
        'Future<void> restorePurchases() async {',
      );
      final restoreEnd = source.indexOf('\n  }', restoreStart);
      expect(restoreStart, greaterThan(-1));
      expect(restoreEnd, greaterThan(restoreStart));
      expect(
        source.substring(restoreStart, restoreEnd).contains('.sync()'),
        isTrue,
      );

      // Exactly one call site in the whole file — count only executable
      // lines, ignoring `//` comments (which mention "sync()" in prose).
      final codeOnly = source
          .split('\n')
          .map((line) => line.trim())
          .where((line) => !line.startsWith('//'))
          .join('\n');
      expect('.sync()'.allMatches(codeOnly).length, 1);
    });
  });

  group('InAppPurchaseBillingGateway.activeIosPurchasesFrom', () {
    SK2Transaction transaction({
      String productId = AppConstants.premiumSubscriptionId,
      String id = 'txn-1',
      String? expirationDate,
    }) => SK2Transaction(
      id: id,
      originalId: id,
      productId: productId,
      purchaseDate: '2026-01-01 00:00:00',
      expirationDate: expirationDate,
      appAccountToken: null,
    );

    String isoIn(Duration delta) =>
        DateTime.now().add(delta).toString().substring(0, 19);

    test('active transaction with a future expiration is active', () {
      final result = InAppPurchaseBillingGateway.activeIosPurchasesFrom([
        transaction(expirationDate: isoIn(const Duration(days: 200))),
      ]);
      expect(result, hasLength(1));
      expect(result.single.status, BillingPurchaseStatus.purchased);
      expect(result.single.purchaseToken, isNotEmpty);
    });

    test('a transaction past its expirationDate is not active', () {
      final result = InAppPurchaseBillingGateway.activeIosPurchasesFrom([
        transaction(expirationDate: isoIn(const Duration(days: -1))),
      ]);
      expect(result, isEmpty);
    });

    test('a cancelled-but-still-paid transaction stays active until '
        'expiration (no separate "auto-renew off" handling needed)', () {
      final result = InAppPurchaseBillingGateway.activeIosPurchasesFrom([
        transaction(expirationDate: isoIn(const Duration(days: 30))),
      ]);
      expect(result, hasLength(1));
    });

    test('wrong product id is never active', () {
      final result = InAppPurchaseBillingGateway.activeIosPurchasesFrom([
        transaction(
          productId: 'premium_monthly',
          expirationDate: isoIn(const Duration(days: 30)),
        ),
      ]);
      expect(result, isEmpty);
    });

    test('missing or unparseable expirationDate never grants access', () {
      expect(
        InAppPurchaseBillingGateway.activeIosPurchasesFrom([
          transaction(expirationDate: null),
        ]),
        isEmpty,
      );
      expect(
        InAppPurchaseBillingGateway.activeIosPurchasesFrom([
          transaction(expirationDate: 'not-a-date'),
        ]),
        isEmpty,
      );
    });

    test('multiple transactions for the product: the latest expiration wins '
        '(renewal case)', () {
      final result = InAppPurchaseBillingGateway.activeIosPurchasesFrom([
        transaction(
          id: 'old',
          expirationDate: isoIn(const Duration(days: -400)),
        ),
        transaction(
          id: 'current',
          expirationDate: isoIn(const Duration(days: 300)),
        ),
      ]);
      expect(result, hasLength(1));
      expect(result.single.purchaseToken, 'current');
    });

    test('empty transaction list is not active', () {
      expect(InAppPurchaseBillingGateway.activeIosPurchasesFrom([]), isEmpty);
    });
  });
}

Future<void> _eventLoop() => Future<void>.delayed(Duration.zero);

BillingPurchase _purchase(
  BillingPurchaseStatus status, {
  String productId = AppConstants.premiumSubscriptionId,
  String token = 'opaque-play-token',
  bool pendingComplete = true,
}) => BillingPurchase(
  productId: productId,
  status: status,
  purchaseToken: token,
  pendingCompletePurchase: pendingComplete,
  storeHandle: Object(),
);

class _FakeBillingGateway implements BillingGateway {
  _FakeBillingGateway() {
    updates = StreamController<List<BillingPurchase>>.broadcast(
      onListen: () {
        listenCount++;
        callOrder.add('listen');
      },
    );
  }

  late final StreamController<List<BillingPurchase>> updates;
  bool available = true;
  int productQueries = 0;
  int launchCount = 0;
  int restoreCount = 0;
  int listenCount = 0;
  int consumeCount = 0;
  List<BillingPurchase> currentPurchases = [];
  final List<BillingPurchase> acknowledged = [];
  final List<String> callOrder = [];
  BillingQueryResult<AnnualSubscriptionProduct>? productResult;

  /// When set, [queryCurrentPurchases] returns this instead of the default
  /// success-with-[currentPurchases] behavior — used to simulate the real
  /// iOS gateway's deferred-sync marker (see
  /// [InAppPurchaseBillingGateway.iosEntitlementQueryFailedCode]).
  BillingQueryResult<List<BillingPurchase>>? queryCurrentPurchasesOverride;

  @override
  Stream<List<BillingPurchase>> get purchaseUpdates => updates.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<BillingQueryResult<AnnualSubscriptionProduct>>
  queryAnnualProduct() async {
    productQueries++;
    return productResult ??
        BillingQueryResult.success(
          AnnualSubscriptionProduct(
            id: AppConstants.premiumSubscriptionId,
            basePlanId: AppConstants.premiumAnnualBasePlanId,
            localizedPrice: '79.000 ₫',
            storeHandle: Object(),
            offerToken: 'annual-auto-token',
          ),
        );
  }

  @override
  Future<BillingQueryResult<List<BillingPurchase>>>
  queryCurrentPurchases() async {
    callOrder.add('queryCurrentPurchases');
    return queryCurrentPurchasesOverride ??
        BillingQueryResult.success(currentPurchases);
  }

  @override
  Future<bool> launchPurchase(AnnualSubscriptionProduct product) async {
    launchCount++;
    return true;
  }

  @override
  Future<void> restorePurchases() async => restoreCount++;

  @override
  Future<void> acknowledge(BillingPurchase purchase) async =>
      acknowledged.add(purchase);

  void emit(List<BillingPurchase> purchases) => updates.add(purchases);
  Future<void> close() async => updates.close();
}
