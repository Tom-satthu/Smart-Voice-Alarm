import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../constants/app_constants.dart';
import 'premium_entitlement_service.dart';

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
}

class PremiumPurchaseState {
  const PremiumPurchaseState({
    required this.isPremium,
    required this.status,
    this.product,
    this.errorMessage,
    this.storeAvailable = true,
  });

  final bool isPremium;
  final PurchaseFlowStatus status;
  final ProductDetails? product;
  final String? errorMessage;
  final bool storeAvailable;

  String? get localizedPrice => product?.price;

  PremiumPurchaseState copyWith({
    bool? isPremium,
    PurchaseFlowStatus? status,
    ProductDetails? product,
    String? errorMessage,
    bool? storeAvailable,
    bool clearError = false,
    bool clearProduct = false,
  }) {
    return PremiumPurchaseState(
      isPremium: isPremium ?? this.isPremium,
      status: status ?? this.status,
      product: clearProduct ? null : product ?? this.product,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      storeAvailable: storeAvailable ?? this.storeAvailable,
    );
  }
}

/// Loads, buys, restores, and syncs the lifetime premium non-consumable.
class PremiumPurchaseService {
  PremiumPurchaseService({
    PremiumEntitlementService? entitlement,
    InAppPurchase? iap,
  })  : _entitlement = entitlement ?? PremiumEntitlementService(),
        _iap = iap ?? InAppPurchase.instance;

  final PremiumEntitlementService _entitlement;
  final InAppPurchase _iap;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final _controller = StreamController<PremiumPurchaseState>.broadcast();

  PremiumPurchaseState _state = const PremiumPurchaseState(
    isPremium: false,
    status: PurchaseFlowStatus.idle,
  );

  Stream<PremiumPurchaseState> get stream => _controller.stream;
  PremiumPurchaseState get state => _state;
  bool get isPremium => _state.isPremium || _entitlement.isPremium;

  Future<void> init() async {
    _emit(
      _state.copyWith(
        isPremium: _entitlement.isPremium,
        status: PurchaseFlowStatus.loading,
        clearError: true,
      ),
    );

    if (kIsWeb) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.unavailable,
          storeAvailable: false,
          errorMessage: 'web_unavailable',
        ),
      );
      return;
    }

    final available = await _iap.isAvailable();
    if (!available) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.unavailable,
          storeAvailable: false,
          errorMessage: 'store_unavailable',
        ),
      );
      return;
    }

    _subscription ??= _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object error) {
        _emit(
          _state.copyWith(
            status: PurchaseFlowStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );

    await refreshProducts();
    await syncEntitlementsFromStore();
  }

  Future<void> refreshProducts() async {
    if (kIsWeb) return;
    if (!await _iap.isAvailable()) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.unavailable,
          storeAvailable: false,
        ),
      );
      return;
    }

    _emit(_state.copyWith(status: PurchaseFlowStatus.loading, clearError: true));
    final response = await _iap.queryProductDetails({
      AppConstants.premiumProductId,
    });

    if (response.error != null) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.error,
          errorMessage: response.error!.message,
        ),
      );
      return;
    }

    final product = response.productDetails.isEmpty
        ? null
        : response.productDetails.first;
    _emit(
      _state.copyWith(
        product: product,
        clearProduct: product == null,
        status: PurchaseFlowStatus.idle,
        storeAvailable: true,
      ),
    );
  }

  Future<void> buy() async {
    if (kIsWeb) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.unavailable,
          errorMessage: 'web_unavailable',
        ),
      );
      return;
    }
    if (_state.isPremium) {
      _emit(_state.copyWith(status: PurchaseFlowStatus.purchased));
      return;
    }

    var product = _state.product;
    if (product == null) {
      await refreshProducts();
      product = _state.product;
    }
    if (product == null) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.error,
          errorMessage: 'product_missing',
        ),
      );
      return;
    }

    _emit(
      _state.copyWith(
        status: PurchaseFlowStatus.purchasing,
        clearError: true,
      ),
    );
    final param = PurchaseParam(productDetails: product);
    final started = await _iap.buyNonConsumable(purchaseParam: param);
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
    if (kIsWeb) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.unavailable,
          errorMessage: 'web_unavailable',
        ),
      );
      return;
    }
    _emit(
      _state.copyWith(status: PurchaseFlowStatus.loading, clearError: true),
    );
    try {
      await _iap.restorePurchases();
    } catch (error) {
      _emit(
        _state.copyWith(
          status: PurchaseFlowStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Re-check past purchases / restore stream for entitlement on cold start.
  Future<void> syncEntitlementsFromStore() async {
    if (kIsWeb) return;
    if (!await _iap.isAvailable()) return;
    try {
      await _iap.restorePurchases();
    } catch (_) {
      // Keep local entitlement if store sync fails offline.
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    var unlocked = _state.isPremium;
    var status = _state.status;
    String? error;

    for (final purchase in purchases) {
      if (purchase.productID != AppConstants.premiumProductId) {
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          status = PurchaseFlowStatus.pending;
        case PurchaseStatus.purchased:
          unlocked = true;
          status = PurchaseFlowStatus.purchased;
        case PurchaseStatus.restored:
          unlocked = true;
          status = PurchaseFlowStatus.restored;
        case PurchaseStatus.canceled:
          status = PurchaseFlowStatus.cancelled;
        case PurchaseStatus.error:
          status = PurchaseFlowStatus.error;
          error = purchase.error?.message ?? 'purchase_error';
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }

    if (unlocked) {
      await _entitlement.setPremiumUnlocked(true);
    }

    _emit(
      _state.copyWith(
        isPremium: unlocked || _entitlement.isPremium,
        status: status,
        errorMessage: error,
        clearError: error == null,
      ),
    );
  }

  void _emit(PremiumPurchaseState next) {
    _state = next;
    if (!_controller.isClosed) {
      _controller.add(next);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
