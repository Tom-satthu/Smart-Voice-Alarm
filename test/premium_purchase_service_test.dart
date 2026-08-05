import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
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
      onListen: () => listenCount++,
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
  BillingQueryResult<AnnualSubscriptionProduct>? productResult;

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
  queryCurrentPurchases() async => BillingQueryResult.success(currentPurchases);

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
