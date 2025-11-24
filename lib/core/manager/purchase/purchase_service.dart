import 'dart:developer';

import 'package:daisy/core/config/purchase_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Comprehensive RevenueCat Purchase Service
/// 
/// Features:
/// - Complete RevenueCat SDK integration
/// - Purchase flow management
/// - Subscription state tracking
/// - Receipt validation
/// - Restore purchases functionality
/// - Offline mode handling
/// - Comprehensive error handling
class PurchaseService {
  PurchaseService._internal();
  static PurchaseService? _instance;
  static PurchaseService get instance => _instance ??= PurchaseService._internal();

  bool _isInitialized = false;
  CustomerInfo? _cachedCustomerInfo;
  List<Package>? _cachedPackages;

  /// Initialize RevenueCat SDK
  /// 
  /// Must be called before any other purchase operations
  /// Usually called during app startup
  Future<bool> initialize() async {
    if (_isInitialized) {
      log('PurchaseService already initialized');
      return true;
    }

    try {
      // Development mode warning
      if (kDebugMode && PurchaseConfig.isDummyMode) {
        log('⚠️ Using dummy RevenueCat credentials - purchases will fail');
        log(PurchaseConfig.dummyModeWarning);
      }

      // Configure RevenueCat
      final configuration = PurchasesConfiguration(PurchaseConfig.dummyRevenueCatApiKey);
      
      if (kDebugMode) {
        // Enable debug logs in development
        await Purchases.setLogLevel(LogLevel.debug);
      }

      await Purchases.configure(configuration);

      // Set user ID if available (optional)
      // await Purchases.logIn('user_id_here');

      // Enable additional debugging in debug mode
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      _isInitialized = true;
      log('✅ PurchaseService initialized successfully');

      // Pre-load customer info and offerings for better UX
      await _loadInitialData();

      return true;
    } on PlatformException catch (e) {
      log('❌ Platform exception during RevenueCat initialization: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      log('❌ Unexpected error during RevenueCat initialization: $e');
      return false;
    }
  }

  /// Pre-load customer info and offerings for better UX
  Future<void> _loadInitialData() async {
    try {
      // Load customer info
      await getCustomerInfo();
      
      // Load available offerings
      await getOfferings();
      
      log('ℹ️ Initial purchase data loaded');
    } catch (e) {
      log('⚠️ Failed to load initial purchase data: $e');
      // Don't throw - this is not critical
    }
  }

  /// Get current customer info
  /// 
  /// Returns cached info if available, otherwise fetches from RevenueCat
  Future<CustomerInfo?> getCustomerInfo({bool forceRefresh = false}) async {
    if (!_isInitialized) {
      log('⚠️ PurchaseService not initialized');
      return null;
    }

    try {
      if (_cachedCustomerInfo != null && !forceRefresh) {
        return _cachedCustomerInfo;
      }

      _cachedCustomerInfo = await Purchases.getCustomerInfo();
      log('ℹ️ Customer info loaded: ${_cachedCustomerInfo?.activeSubscriptions.length ?? 0} active subscriptions');
      
      return _cachedCustomerInfo;
    } on PlatformException catch (e) {
      log('❌ Error getting customer info: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      log('❌ Unexpected error getting customer info: $e');
      return null;
    }
  }

  /// Get available offerings and packages
  /// 
  /// Returns cached offerings if available, otherwise fetches from RevenueCat
  Future<List<Package>> getOfferings({bool forceRefresh = false}) async {
    if (!_isInitialized) {
      log('⚠️ PurchaseService not initialized');
      return [];
    }

    try {
      if (_cachedPackages != null && !forceRefresh) {
        return _cachedPackages!;
      }

      final offerings = await Purchases.getOfferings();
      final currentOffering = offerings.current;
      
      if (currentOffering != null) {
        _cachedPackages = currentOffering.availablePackages;
        log('ℹ️ Offerings loaded: ${_cachedPackages!.length} packages available');
      } else {
        _cachedPackages = [];
        log('⚠️ No current offering found');
      }

      return _cachedPackages!;
    } on PlatformException catch (e) {
      log('❌ Error getting offerings: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      log('❌ Unexpected error getting offerings: $e');
      return [];
    }
  }

  /// Purchase a package
  /// 
  /// Returns purchase result with comprehensive error handling
  Future<PurchaseResult> purchasePackage(Package package) async {
    if (!_isInitialized) {
      return PurchaseResult.error('PurchaseService not initialized');
    }

    try {
      log('🛒 Starting purchase for package: ${package.storeProduct.identifier}');

      final purchaseResult = await Purchases.purchasePackage(package);
      
      // Update cached customer info
      _cachedCustomerInfo = purchaseResult.customerInfo;

      final entitlementInfo = purchaseResult.customerInfo.entitlements.active[PurchaseConfig.dummyEntitlements['premium']];
      
      if (entitlementInfo != null) {
        log('✅ Purchase successful: ${package.storeProduct.identifier}');
        return PurchaseResult.success(purchaseResult.customerInfo);
      } else {
        log('⚠️ Purchase completed but no active entitlement found');
        return PurchaseResult.error('Purchase completed but entitlement not activated');
      }
    } on PlatformException catch (e) {
      log('❌ Purchase failed: ${e.code} - ${e.message}');
      
      // Handle specific error cases
      String userFriendlyMessage;
      switch (e.code) {
        case 'purchase_cancelled':
          userFriendlyMessage = PurchaseConfig.getErrorMessage('user-cancelled');
        case 'store_problem':
          userFriendlyMessage = PurchaseConfig.getErrorMessage('store-problem');
        case 'network_error':
          userFriendlyMessage = PurchaseConfig.getErrorMessage('network-error');
        case 'purchase_not_allowed':
          userFriendlyMessage = PurchaseConfig.getErrorMessage('not-allowed-to-make-payments');
        case 'payment_pending':
          userFriendlyMessage = PurchaseConfig.getErrorMessage('payment-pending');
        case 'invalid_credentials':
          userFriendlyMessage = PurchaseConfig.getErrorMessage('invalid-credentials');
        case 'product_not_available':
          userFriendlyMessage = PurchaseConfig.getErrorMessage('product-not-available');
        default:
          userFriendlyMessage = PurchaseConfig.getErrorMessage('unknown');
      }

      return PurchaseResult.error(userFriendlyMessage, e.code);
    } catch (e) {
      log('❌ Unexpected purchase error: $e');
      return PurchaseResult.error(PurchaseConfig.getErrorMessage('unknown'));
    }
  }

  /// Restore previous purchases
  /// 
  /// Useful for users who reinstalled the app or signed in on a new device
  Future<PurchaseResult> restorePurchases() async {
    if (!_isInitialized) {
      return PurchaseResult.error('PurchaseService not initialized');
    }

    try {
      log('🔄 Restoring purchases...');

      final customerInfo = await Purchases.restorePurchases();
      
      // Update cached customer info
      _cachedCustomerInfo = customerInfo;

      final activeEntitlements = customerInfo.entitlements.active;
      
      if (activeEntitlements.isNotEmpty) {
        log('✅ Purchases restored: ${activeEntitlements.length} active entitlements');
        return PurchaseResult.success(customerInfo);
      } else {
        log('ℹ️ No previous purchases to restore');
        return PurchaseResult.error('No previous purchases found to restore');
      }
    } on PlatformException catch (e) {
      log('❌ Restore failed: ${e.code} - ${e.message}');
      
      String userFriendlyMessage;
      switch (e.code) {
        case 'network_error':
          userFriendlyMessage = PurchaseConfig.getErrorMessage('network-error');
        case 'invalid_credentials':
          userFriendlyMessage = PurchaseConfig.getErrorMessage('invalid-credentials');
        default:
          userFriendlyMessage = 'Failed to restore purchases. Please try again.';
      }

      return PurchaseResult.error(userFriendlyMessage, e.code);
    } catch (e) {
      log('❌ Unexpected restore error: $e');
      return PurchaseResult.error('Failed to restore purchases. Please try again.');
    }
  }

  /// Check if user has active entitlement
  /// 
  /// Useful for checking premium status throughout the app
  Future<bool> hasActiveEntitlement(String entitlementId) async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) return false;

      return customerInfo.entitlements.active.containsKey(entitlementId);
    } catch (e) {
      log('❌ Error checking entitlement: $e');
      return false;
    }
  }

  /// Check if user has premium access
  bool get hasPremium {
    final customerInfo = _cachedCustomerInfo;
    if (customerInfo == null) return false;

    return customerInfo.entitlements.active.containsKey(PurchaseConfig.dummyEntitlements['premium']);
  }

  /// Check if user has pro access
  bool get hasPro {
    final customerInfo = _cachedCustomerInfo;
    if (customerInfo == null) return false;

    return customerInfo.entitlements.active.containsKey(PurchaseConfig.dummyEntitlements['pro']);
  }

  /// Check if user has ad-free access
  bool get isAdFree {
    final customerInfo = _cachedCustomerInfo;
    if (customerInfo == null) return false;

    return customerInfo.entitlements.active.containsKey(PurchaseConfig.dummyEntitlements['ad_free']) ||
           hasPremium || // Premium includes ad-free
           hasPro;     // Pro includes ad-free
  }

  /// Get subscription status information
  SubscriptionStatus getSubscriptionStatus() {
    final customerInfo = _cachedCustomerInfo;
    if (customerInfo == null) {
      return SubscriptionStatus.none;
    }

    if (customerInfo.entitlements.active.isNotEmpty) {
      // Check if any subscription is set to auto-renew
      final hasAutoRenew = customerInfo.entitlements.active.values
          .any((entitlement) => entitlement.willRenew);
      
      return hasAutoRenew ? SubscriptionStatus.active : SubscriptionStatus.expiring;
    }

    return SubscriptionStatus.none;
  }

  /// Get expiration date for premium entitlement
  DateTime? get premiumExpirationDate {
    final customerInfo = _cachedCustomerInfo;
    if (customerInfo == null) return null;

    final premiumEntitlement = customerInfo.entitlements.active[PurchaseConfig.dummyEntitlements['premium']];
    final expirationDate = premiumEntitlement?.expirationDate;
    return expirationDate != null ? DateTime.parse(expirationDate) : null;
  }

  /// Set user ID for RevenueCat
  /// 
  /// Call this when user signs in to associate purchases with user account
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) return;

    try {
      final loginResult = await Purchases.logIn(userId);
      _cachedCustomerInfo = loginResult.customerInfo;
      
      log('ℹ️ User logged in to RevenueCat: $userId');
    } catch (e) {
      log('❌ Error setting user ID: $e');
    }
  }

  /// Clear user ID (logout)
  /// 
  /// Call this when user signs out
  Future<void> clearUserId() async {
    if (!_isInitialized) return;

    try {
      final customerInfo = await Purchases.logOut();
      _cachedCustomerInfo = customerInfo;
      
      log('ℹ️ User logged out from RevenueCat');
    } catch (e) {
      log('❌ Error clearing user ID: $e');
    }
  }

  /// Clear cached data
  /// 
  /// Useful for testing or when switching users
  void clearCache() {
    _cachedCustomerInfo = null;
    _cachedPackages = null;
    log('ℹ️ Purchase cache cleared');
  }

  /// Check if service is properly initialized
  bool get isInitialized => _isInitialized;

  /// Get cached customer info (may be null)
  CustomerInfo? get cachedCustomerInfo => _cachedCustomerInfo;

  /// Dispose resources
  void dispose() {
    // RevenueCat SDK doesn't require explicit disposal
    // but we can clear our cached data
    clearCache();
    log('ℹ️ PurchaseService disposed');
  }
}

/// Purchase operation result
class PurchaseResult {

  const PurchaseResult._({
    required this.isSuccess,
    this.errorMessage,
    this.errorCode,
    this.customerInfo,
  });

  factory PurchaseResult.success(CustomerInfo customerInfo) {
    return PurchaseResult._(
      isSuccess: true,
      customerInfo: customerInfo,
    );
  }

  factory PurchaseResult.error(String message, [String? code]) {
    return PurchaseResult._(
      isSuccess: false,
      errorMessage: message,
      errorCode: code,
    );
  }
  final bool isSuccess;
  final String? errorMessage;
  final String? errorCode;
  final CustomerInfo? customerInfo;

  bool get isError => !isSuccess;
}

/// Subscription status enum
enum SubscriptionStatus {
  none,      // No active subscription
  active,    // Active subscription with auto-renew
  expiring,  // Active subscription but will expire (cancelled)
}

/// Extension for SubscriptionStatus
extension SubscriptionStatusExtension on SubscriptionStatus {
  String get displayName {
    switch (this) {
      case SubscriptionStatus.none:
        return 'No Subscription';
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expiring:
        return 'Expires Soon';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionStatus.none:
        return "You don't have any active subscriptions";
      case SubscriptionStatus.active:
        return 'Your subscription will automatically renew';
      case SubscriptionStatus.expiring:
        return "Your subscription will expire and won't renew";
    }
  }

  bool get isActive => this != SubscriptionStatus.none;
}
