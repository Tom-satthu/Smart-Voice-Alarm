import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../constants/app_constants.dart';
import 'trial_entitlement_service.dart';

enum PurchaseFlowStatus {
  idle,
  loading,
  purchasing,
  purchased,
  restored,
  cancelled,
  pending,
  error,
  unavailable,
  productUnavailable,
}

enum BillingPurchaseStatus { pending, purchased, restored, cancelled, error }

class AnnualSubscriptionProduct {
  const AnnualSubscriptionProduct({
    required this.id,
    required this.basePlanId,
    required this.localizedPrice,
    required this.storeHandle,
    this.offerToken,
  });

  final String id;
  final String basePlanId;
  final String localizedPrice;
  final Object storeHandle;
  final String? offerToken;
}

class BillingPurchase {
  const BillingPurchase({
    required this.productId,
    required this.status,
    required this.purchaseToken,
    required this.pendingCompletePurchase,
    required this.storeHandle,
    this.errorMessage,
  });

  final String productId;
  final BillingPurchaseStatus status;
  final String purchaseToken;
  final bool pendingCompletePurchase;
  final Object storeHandle;
  final String? errorMessage;
}

class BillingQueryResult<T> {
  const BillingQueryResult.success(this.value) : errorMessage = null;
  const BillingQueryResult.failure(this.errorMessage) : value = null;

  final T? value;
  final String? errorMessage;
  bool get isSuccess => errorMessage == null;
}

abstract interface class BillingGateway {
  Stream<List<BillingPurchase>> get purchaseUpdates;
  Future<bool> isAvailable();
  Future<BillingQueryResult<AnnualSubscriptionProduct>> queryAnnualProduct();
  Future<BillingQueryResult<List<BillingPurchase>>> queryCurrentPurchases();
  Future<bool> launchPurchase(AnnualSubscriptionProduct product);
  Future<void> restorePurchases();
  Future<void> acknowledge(BillingPurchase purchase);
}

class InAppPurchaseBillingGateway implements BillingGateway {
  InAppPurchaseBillingGateway([InAppPurchase? purchase])
    : _purchase = purchase ?? InAppPurchase.instance;

  final InAppPurchase _purchase;

  @override
  Stream<List<BillingPurchase>> get purchaseUpdates =>
      _purchase.purchaseStream.map(_mapPurchases);

  @override
  Future<bool> isAvailable() => _purchase.isAvailable();

  @override
  Future<BillingQueryResult<AnnualSubscriptionProduct>>
  queryAnnualProduct() async {
    final response = await _purchase.queryProductDetails({
      AppConstants.premiumSubscriptionId,
    });
    if (response.error != null) {
      return BillingQueryResult.failure(response.error!.message);
    }

    for (final product in response.productDetails) {
      if (product.id != AppConstants.premiumSubscriptionId) continue;
      if (product is GooglePlayProductDetails) {
        final index = product.subscriptionIndex;
        final offers = product.productDetails.subscriptionOfferDetails;
        if (index == null || offers == null || index >= offers.length) {
          continue;
        }
        final offer = offers[index];
        if (offer.basePlanId != AppConstants.premiumAnnualBasePlanId ||
            offer.offerId != null) {
          continue;
        }
        return BillingQueryResult.success(
          AnnualSubscriptionProduct(
            id: product.id,
            basePlanId: offer.basePlanId,
            localizedPrice: product.price,
            offerToken: offer.offerIdToken,
            storeHandle: product,
          ),
        );
      }

      // StoreKit does not expose a Google Play base-plan ID. The product ID
      // remains exact; App Store configuration is verified separately.
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        return BillingQueryResult.success(
          AnnualSubscriptionProduct(
            id: product.id,
            basePlanId: AppConstants.premiumAnnualBasePlanId,
            localizedPrice: product.price,
            storeHandle: product,
          ),
        );
      }
    }
    return const BillingQueryResult.failure('product_unavailable');
  }

  @override
  Future<BillingQueryResult<List<BillingPurchase>>>
  queryCurrentPurchases() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      // StoreKit restore results arrive on purchaseUpdates. Do not claim an
      // inactive entitlement synchronously when the platform cannot prove it.
      return const BillingQueryResult.failure('current_query_unavailable');
    }
    try {
      final addition = _purchase
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final response = await addition.queryPastPurchases();
      if (response.error != null) {
        return BillingQueryResult.failure(response.error!.message);
      }
      return BillingQueryResult.success(_mapPurchases(response.pastPurchases));
    } catch (_) {
      return const BillingQueryResult.failure('current_query_failed');
    }
  }

  @override
  Future<bool> launchPurchase(AnnualSubscriptionProduct product) {
    final details = product.storeHandle;
    if (details is! ProductDetails) return Future.value(false);
    final param = defaultTargetPlatform == TargetPlatform.android
        ? GooglePlayPurchaseParam(
            productDetails: details,
            offerToken: product.offerToken,
          )
        : PurchaseParam(productDetails: details);
    // The Flutter API uses buyNonConsumable for subscriptions. No consume
    // call is made anywhere in this app.
    return _purchase.buyNonConsumable(purchaseParam: param);
  }

  @override
  Future<void> restorePurchases() => _purchase.restorePurchases();

  @override
  Future<void> acknowledge(BillingPurchase purchase) async {
    final handle = purchase.storeHandle;
    if (handle is PurchaseDetails && handle.pendingCompletePurchase) {
      await _purchase.completePurchase(handle);
    }
  }

  static List<BillingPurchase> _mapPurchases(List<PurchaseDetails> purchases) =>
      purchases.map(_mapPurchase).toList(growable: false);

  static BillingPurchase _mapPurchase(PurchaseDetails purchase) {
    final status = switch (purchase.status) {
      PurchaseStatus.pending => BillingPurchaseStatus.pending,
      PurchaseStatus.purchased => BillingPurchaseStatus.purchased,
      PurchaseStatus.restored => BillingPurchaseStatus.restored,
      PurchaseStatus.canceled => BillingPurchaseStatus.cancelled,
      PurchaseStatus.error => BillingPurchaseStatus.error,
    };
    return BillingPurchase(
      productId: purchase.productID,
      status: status,
      purchaseToken: purchase.verificationData.serverVerificationData,
      pendingCompletePurchase: purchase.pendingCompletePurchase,
      storeHandle: purchase,
      errorMessage: purchase.error?.message,
    );
  }
}

class PremiumPurchaseState {
  const PremiumPurchaseState({
    required this.status,
    required this.verification,
    this.product,
    this.errorMessage,
    this.storeAvailable = true,
  });

  const PremiumPurchaseState.initial()
    : this(
        status: PurchaseFlowStatus.idle,
        verification: SubscriptionVerificationResult.failed,
      );

  final PurchaseFlowStatus status;
  final SubscriptionVerificationResult verification;
  final AnnualSubscriptionProduct? product;
  final String? errorMessage;
  final bool storeAvailable;

  String? get localizedPrice => product?.localizedPrice;
  bool get isSubscriptionActive =>
      verification == SubscriptionVerificationResult.active;

  PremiumPurchaseState copyWith({
    PurchaseFlowStatus? status,
    SubscriptionVerificationResult? verification,
    AnnualSubscriptionProduct? product,
    String? errorMessage,
    bool? storeAvailable,
    bool clearError = false,
    bool clearProduct = false,
  }) => PremiumPurchaseState(
    status: status ?? this.status,
    verification: verification ?? this.verification,
    product: clearProduct ? null : product ?? this.product,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    storeAvailable: storeAvailable ?? this.storeAvailable,
  );
}

/// Client-only Google Play subscription adapter. Entitlement is granted only
/// for an exact product ID with PURCHASED/RESTORED state and a non-empty token.
class PremiumPurchaseService {
  PremiumPurchaseService({BillingGateway? gateway})
    : _gateway = gateway ?? InAppPurchaseBillingGateway();

  final BillingGateway _gateway;
  StreamSubscription<List<BillingPurchase>>? _subscription;
  final _controller = StreamController<PremiumPurchaseState>.broadcast();

  PremiumPurchaseState _state = const PremiumPurchaseState.initial();
  bool _initialized = false;

  Stream<PremiumPurchaseState> get stream => _controller.stream;
  PremiumPurchaseState get state => _state;

  Future<void> init() async {
    if (_initialized) {
      await syncEntitlementsFromStore();
      return;
    }
    _initialized = true;
    _emit(
      _state.copyWith(status: PurchaseFlowStatus.loading, clearError: true),
    );

    if (kIsWeb || !await _gateway.isAvailable()) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.unavailable,
          verification: SubscriptionVerificationResult.unavailable,
          storeAvailable: false,
          errorMessage: kIsWeb ? 'web_unavailable' : 'store_unavailable',
        ),
      );
      return;
    }

    _subscription ??= _gateway.purchaseUpdates.listen(
      _onPurchaseUpdates,
      onError: (_) => _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.error,
          verification: SubscriptionVerificationResult.failed,
          errorMessage: 'purchase_stream_error',
        ),
      ),
    );
    await refreshProducts();
    await syncEntitlementsFromStore();
  }

  Future<void> refreshProducts() async {
    if (kIsWeb || !await _gateway.isAvailable()) return;
    final response = await _gateway.queryAnnualProduct();
    if (!response.isSuccess || response.value == null) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.productUnavailable,
          clearProduct: true,
          errorMessage: response.errorMessage ?? 'product_unavailable',
        ),
      );
      return;
    }
    _emit(
      _state.copyWith(
        status: PurchaseFlowStatus.idle,
        product: response.value,
        storeAvailable: true,
        clearError: true,
      ),
    );
  }

  /// Must be called only from an explicit user action.
  Future<void> buy() async {
    final product = _state.product;
    if (product == null) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.productUnavailable,
          errorMessage: 'product_unavailable',
        ),
      );
      return;
    }
    _emit(
      _state.copyWith(status: PurchaseFlowStatus.purchasing, clearError: true),
    );
    final started = await _gateway.launchPurchase(product);
    if (!started) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.error,
          errorMessage: 'purchase_start_failed',
        ),
      );
    }
  }

  Future<void> restore() async {
    if (kIsWeb || !await _gateway.isAvailable()) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.unavailable,
          verification: SubscriptionVerificationResult.unavailable,
          storeAvailable: false,
        ),
      );
      return;
    }
    _emit(
      _state.copyWith(status: PurchaseFlowStatus.loading, clearError: true),
    );
    try {
      await _gateway.restorePurchases();
      await syncEntitlementsFromStore(restored: true);
    } catch (_) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.error,
          verification: SubscriptionVerificationResult.failed,
          errorMessage: 'restore_failed',
        ),
      );
    }
  }

  Future<void> syncEntitlementsFromStore({bool restored = false}) async {
    if (kIsWeb || !await _gateway.isAvailable()) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.unavailable,
          verification: SubscriptionVerificationResult.unavailable,
          storeAvailable: false,
        ),
      );
      return;
    }
    final response = await _gateway.queryCurrentPurchases();
    if (!response.isSuccess || response.value == null) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.error,
          verification: SubscriptionVerificationResult.failed,
          errorMessage: response.errorMessage ?? 'entitlement_query_failed',
        ),
      );
      return;
    }
    await _applyPurchases(response.value!, restored: restored);
  }

  Future<void> _onPurchaseUpdates(List<BillingPurchase> purchases) =>
      _applyPurchases(purchases);

  Future<void> _applyPurchases(
    List<BillingPurchase> purchases, {
    bool restored = false,
  }) async {
    final expected = purchases
        .where(
          (purchase) =>
              purchase.productId == AppConstants.premiumSubscriptionId,
        )
        .toList(growable: false);

    final active = expected.where(_isVerifiedActivePurchase).toList();
    if (active.isNotEmpty) {
      for (final purchase in active) {
        if (purchase.pendingCompletePurchase) {
          await _gateway.acknowledge(purchase);
        }
      }
      _emit(
        _state.copyWith(
          status: restored
              ? PurchaseFlowStatus.restored
              : PurchaseFlowStatus.purchased,
          verification: SubscriptionVerificationResult.active,
          clearError: true,
        ),
      );
      return;
    }

    if (expected.any(
      (purchase) => purchase.status == BillingPurchaseStatus.pending,
    )) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.pending,
          verification: SubscriptionVerificationResult.pending,
          clearError: true,
        ),
      );
      return;
    }
    if (expected.any(
      (purchase) => purchase.status == BillingPurchaseStatus.cancelled,
    )) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.cancelled,
          verification: SubscriptionVerificationResult.inactive,
          clearError: true,
        ),
      );
      return;
    }
    if (expected.any(
      (purchase) => purchase.status == BillingPurchaseStatus.error,
    )) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.error,
          verification: SubscriptionVerificationResult.failed,
          errorMessage: 'purchase_error',
        ),
      );
      return;
    }

    _emit(
      _state.copyWith(
        status: PurchaseFlowStatus.idle,
        verification: SubscriptionVerificationResult.inactive,
        clearError: true,
      ),
    );
  }

  bool _isVerifiedActivePurchase(BillingPurchase purchase) =>
      AppConstants.applicationId == 'com.smartvoicealarm.app' &&
      purchase.productId == AppConstants.premiumSubscriptionId &&
      purchase.purchaseToken.trim().isNotEmpty &&
      (purchase.status == BillingPurchaseStatus.purchased ||
          purchase.status == BillingPurchaseStatus.restored);

  void _emit(PremiumPurchaseState next) {
    _state = next;
    if (!_controller.isClosed) _controller.add(next);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
