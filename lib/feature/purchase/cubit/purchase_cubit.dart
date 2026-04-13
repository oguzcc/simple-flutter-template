import 'dart:developer';

import 'package:daisy/core/enum/common_enum.dart';
import 'package:daisy/core/manager/purchase/purchase_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'purchase_state.dart';

/// Purchase Cubit — RevenueCat customer state yöneticisi.
///
/// Satın alma akışı native paywall (`RevenueCatUI.presentPaywall()`) üzerinden
/// yürütüldüğü için bu cubit purchase/restore gibi işlemleri yapmaz. Sadece:
/// - SDK'yı başlatır
/// - CustomerInfo'yu yeniler (paywall kapandıktan sonra)
/// - Entitlement state'ini UI için dışarı sunar
class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit(this._purchaseService) : super(const PurchaseState());

  final PurchaseService _purchaseService;

  Future<void> initialize() async {
    emit(state.copyWith(status: Status.loading));

    final success = await _purchaseService.initialize();
    if (!success) {
      emit(
        state.copyWith(
          status: Status.error,
          errorMessage: 'Failed to initialize purchase system',
        ),
      );
      return;
    }

    _emitFromService(status: Status.success, isInitialized: true);
    log('✅ PurchaseCubit initialized');
  }

  /// Paywall kapandıktan sonra state'i RevenueCat'ten taze çek.
  Future<void> refresh() async {
    emit(state.copyWith(status: Status.loading));
    await _purchaseService.refreshCustomerInfo();
    _emitFromService(status: Status.success);
  }

  bool checkEntitlement(String entitlementId) {
    if (!state.isInitialized) return false;
    return _purchaseService.hasActiveEntitlement(entitlementId);
  }

  Future<void> setUserId(String userId) async {
    if (!state.isInitialized) return;
    await _purchaseService.setUserId(userId);
    _emitFromService();
  }

  Future<void> clearUserId() async {
    if (!state.isInitialized) return;
    await _purchaseService.clearUserId();
    _emitFromService();
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null, status: Status.initial));
  }

  /// Service'ten taze değerleri state'e yansıt.
  void _emitFromService({Status? status, bool? isInitialized}) {
    emit(
      state.copyWith(
        status: status,
        isInitialized: isInitialized,
        customerInfo: _purchaseService.cachedCustomerInfo,
        hasPremium: _purchaseService.hasPremium,
        hasPro: _purchaseService.hasPro,
        isAdFree: _purchaseService.isAdFree,
        subscriptionStatus: _purchaseService.getSubscriptionStatus(),
        premiumExpirationDate: _purchaseService.premiumExpirationDate,
        errorMessage: null,
      ),
    );
  }

  bool get hasActiveSubscription => state.subscriptionStatus.isActive;
}
