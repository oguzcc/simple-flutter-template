import 'dart:developer';

import 'package:daisy/core/enum/common_enum.dart';
import 'package:daisy/core/manager/purchase/purchase_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'purchase_state.dart';

/// Purchase Cubit for managing in-app purchases and subscriptions
/// 
/// Features:
/// - Initialize RevenueCat
/// - Load available packages
/// - Handle purchase flows
/// - Restore previous purchases
/// - Track subscription status
/// - Manage premium features access
class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit() : super(const PurchaseState());

  /// Initialize purchase system
  Future<void> initialize() async {
    emit(state.copyWith(status: Status.loading));

    try {
      final success = await PurchaseService.instance.initialize();
      
      if (success) {
        log('✅ Purchase system initialized');
        
        // Load initial data
        await _loadInitialData();
        
        emit(state.copyWith(
          status: Status.success,
          isInitialized: true,
        ),);
      } else {
        emit(state.copyWith(
          status: Status.error,
          errorMessage: 'Failed to initialize purchase system',
          isInitialized: false,
        ),);
      }
    } catch (e) {
      log('❌ Error initializing purchases: $e');
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Purchase system initialization failed: $e',
        isInitialized: false,
      ),);
    }
  }

  /// Load customer info and available packages
  Future<void> _loadInitialData() async {
    try {
      // Load customer info
      final customerInfo = await PurchaseService.instance.getCustomerInfo();
      
      // Load available packages
      final packages = await PurchaseService.instance.getOfferings();
      
      emit(state.copyWith(
        customerInfo: customerInfo,
        availablePackages: packages,
        hasPremium: PurchaseService.instance.hasPremium,
        hasPro: PurchaseService.instance.hasPro,
        isAdFree: PurchaseService.instance.isAdFree,
        subscriptionStatus: PurchaseService.instance.getSubscriptionStatus(),
        premiumExpirationDate: PurchaseService.instance.premiumExpirationDate,
      ),);

      log('ℹ️ Initial purchase data loaded');
    } catch (e) {
      log('⚠️ Failed to load initial purchase data: $e');
      // Don't emit error state - initialization was successful
    }
  }

  /// Refresh customer info and offerings
  Future<void> refresh() async {
    emit(state.copyWith(status: Status.loading));

    try {
      // Force refresh customer info
      final customerInfo = await PurchaseService.instance.getCustomerInfo(forceRefresh: true);
      
      // Force refresh offerings
      final packages = await PurchaseService.instance.getOfferings(forceRefresh: true);

      emit(state.copyWith(
        status: Status.success,
        customerInfo: customerInfo,
        availablePackages: packages,
        hasPremium: PurchaseService.instance.hasPremium,
        hasPro: PurchaseService.instance.hasPro,
        isAdFree: PurchaseService.instance.isAdFree,
        subscriptionStatus: PurchaseService.instance.getSubscriptionStatus(),
        premiumExpirationDate: PurchaseService.instance.premiumExpirationDate,
        errorMessage: null,
      ),);

      log('✅ Purchase data refreshed');
    } catch (e) {
      log('❌ Error refreshing purchase data: $e');
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Failed to refresh purchase data: $e',
      ),);
    }
  }

  /// Purchase a specific package
  Future<void> purchasePackage(Package package) async {
    if (!state.isInitialized) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Purchase system not initialized',
      ),);
      return;
    }

    emit(state.copyWith(
      status: Status.loading,
      purchaseInProgress: true,
      errorMessage: null,
    ),);

    try {
      log('🛒 Starting purchase for: ${package.storeProduct.identifier}');
      
      final result = await PurchaseService.instance.purchasePackage(package);
      
      if (result.isSuccess && result.customerInfo != null) {
        emit(state.copyWith(
          status: Status.success,
          customerInfo: result.customerInfo,
          hasPremium: PurchaseService.instance.hasPremium,
          hasPro: PurchaseService.instance.hasPro,
          isAdFree: PurchaseService.instance.isAdFree,
          subscriptionStatus: PurchaseService.instance.getSubscriptionStatus(),
          premiumExpirationDate: PurchaseService.instance.premiumExpirationDate,
          purchaseInProgress: false,
          lastPurchaseSuccess: true,
        ),);
        
        log('✅ Purchase completed successfully');
      } else {
        emit(state.copyWith(
          status: Status.error,
          errorMessage: result.errorMessage ?? 'Purchase failed',
          purchaseInProgress: false,
          lastPurchaseSuccess: false,
        ),);
        
        log('❌ Purchase failed: ${result.errorMessage}');
      }
    } catch (e) {
      log('❌ Unexpected purchase error: $e');
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Unexpected purchase error: $e',
        purchaseInProgress: false,
        lastPurchaseSuccess: false,
      ),);
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (!state.isInitialized) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Purchase system not initialized',
      ),);
      return;
    }

    emit(state.copyWith(
      status: Status.loading,
      errorMessage: null,
    ),);

    try {
      log('🔄 Restoring purchases...');
      
      final result = await PurchaseService.instance.restorePurchases();
      
      if (result.isSuccess && result.customerInfo != null) {
        emit(state.copyWith(
          status: Status.success,
          customerInfo: result.customerInfo,
          hasPremium: PurchaseService.instance.hasPremium,
          hasPro: PurchaseService.instance.hasPro,
          isAdFree: PurchaseService.instance.isAdFree,
          subscriptionStatus: PurchaseService.instance.getSubscriptionStatus(),
          premiumExpirationDate: PurchaseService.instance.premiumExpirationDate,
        ),);
        
        log('✅ Purchases restored successfully');
      } else {
        emit(state.copyWith(
          status: Status.error,
          errorMessage: result.errorMessage ?? 'No purchases to restore',
        ),);
        
        log('ℹ️ No purchases to restore');
      }
    } catch (e) {
      log('❌ Unexpected restore error: $e');
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Unexpected restore error: $e',
      ),);
    }
  }

  /// Check if user has specific entitlement
  Future<bool> checkEntitlement(String entitlementId) async {
    if (!state.isInitialized) return false;
    
    return PurchaseService.instance.hasActiveEntitlement(entitlementId);
  }

  /// Set user ID for purchase tracking
  Future<void> setUserId(String userId) async {
    if (!state.isInitialized) return;

    try {
      await PurchaseService.instance.setUserId(userId);
      log('ℹ️ User ID set for purchases: $userId');
      
      // Refresh data after setting user ID
      await _loadInitialData();
    } catch (e) {
      log('❌ Error setting user ID: $e');
    }
  }

  /// Clear user ID (logout)
  Future<void> clearUserId() async {
    if (!state.isInitialized) return;

    try {
      await PurchaseService.instance.clearUserId();
      log('ℹ️ User ID cleared for purchases');
      
      // Refresh data after clearing user ID
      await _loadInitialData();
    } catch (e) {
      log('❌ Error clearing user ID: $e');
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(
      errorMessage: null,
      status: Status.initial,
    ),);
  }

  /// Get package by identifier
  Package? getPackageById(String identifier) {
    return state.availablePackages.cast<Package?>().firstWhere(
      (package) => package?.storeProduct.identifier == identifier,
      orElse: () => null,
    );
  }

  /// Get packages by type (monthly, yearly, lifetime, etc.)
  List<Package> getPackagesByType(PackageType type) {
    return state.availablePackages
        .where((package) => package.packageType == type)
        .toList();
  }

  /// Get monthly packages
  List<Package> get monthlyPackages => getPackagesByType(PackageType.monthly);

  /// Get yearly packages  
  List<Package> get yearlyPackages => getPackagesByType(PackageType.annual);

  /// Get lifetime packages
  List<Package> get lifetimePackages => getPackagesByType(PackageType.lifetime);

  /// Check if any purchase is in progress
  bool get isPurchasing => state.purchaseInProgress;

  /// Check if user has any active subscription
  bool get hasActiveSubscription => state.subscriptionStatus.isActive;

  /// Get subscription renewal status
  String get subscriptionStatusDisplay => state.subscriptionStatus.displayName;

  /// Get user-friendly expiration info
  String? get expirationInfo {
    final expirationDate = state.premiumExpirationDate;
    if (expirationDate == null) return null;

    final now = DateTime.now();
    final daysUntilExpiration = expirationDate.difference(now).inDays;

    if (daysUntilExpiration < 0) {
      return 'Expired';
    } else if (daysUntilExpiration == 0) {
      return 'Expires today';
    } else if (daysUntilExpiration == 1) {
      return 'Expires tomorrow';
    } else if (daysUntilExpiration <= 7) {
      return 'Expires in $daysUntilExpiration days';
    } else {
      return 'Expires on ${expirationDate.day}/${expirationDate.month}/${expirationDate.year}';
    }
  }

  @override
  Future<void> close() {
    // Clean up resources
    PurchaseService.instance.dispose();
    return super.close();
  }
}
