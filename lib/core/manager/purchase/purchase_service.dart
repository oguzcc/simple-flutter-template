import 'dart:developer';

import 'package:daisy/core/config/purchase_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat wrapper — state okuma ve SDK başlatma için.
///
/// Bu sınıf satın alma akışını YÖNETMEZ. Satın alma RevenueCat dashboard'unda
/// yapılandırılmış **native paywall** üzerinden yürütülür
/// (`purchases_ui_flutter` paketindeki `RevenueCatUI.presentPaywall()`).
/// Paywall kapandıktan sonra `refreshCustomerInfo()` çağrılarak cache güncellenir.
class PurchaseService {
  PurchaseService();

  bool _isInitialized = false;
  CustomerInfo? _cachedCustomerInfo;

  bool get isInitialized => _isInitialized;
  CustomerInfo? get cachedCustomerInfo => _cachedCustomerInfo;

  /// RevenueCat SDK'sını başlatır. Uygulama bootstrap aşamasında çağırılır.
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      if (kDebugMode && PurchaseConfig.isDummyMode) {
        log('⚠️ Using dummy RevenueCat credentials - purchases will fail');
        log(PurchaseConfig.dummyModeWarning);
        await Purchases.setLogLevel(LogLevel.debug);
      }

      await Purchases.configure(
        PurchasesConfiguration(PurchaseConfig.dummyRevenueCatApiKey),
      );

      _isInitialized = true;
      log('✅ PurchaseService initialized');

      await refreshCustomerInfo();
      return true;
    } on PlatformException catch (e) {
      log('❌ RevenueCat init failed: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      log('❌ Unexpected RevenueCat init error: $e');
      return false;
    }
  }

  /// CustomerInfo'yu RevenueCat'ten çekip cache'ler. Paywall kapandıktan
  /// sonra çağrılmalı.
  Future<CustomerInfo?> refreshCustomerInfo() async {
    if (!_isInitialized) return null;
    try {
      _cachedCustomerInfo = await Purchases.getCustomerInfo();
      return _cachedCustomerInfo;
    } on PlatformException catch (e) {
      log('❌ getCustomerInfo failed: ${e.code} - ${e.message}');
      return null;
    }
  }

  /// Belirli bir entitlement aktif mi?
  bool hasActiveEntitlement(String entitlementId) {
    return _cachedCustomerInfo?.entitlements.active
            .containsKey(entitlementId) ??
        false;
  }

  bool get hasPremium =>
      hasActiveEntitlement(PurchaseConfig.dummyEntitlements['premium'] ?? '');

  bool get hasPro =>
      hasActiveEntitlement(PurchaseConfig.dummyEntitlements['pro'] ?? '');

  bool get isAdFree =>
      hasActiveEntitlement(PurchaseConfig.dummyEntitlements['ad_free'] ?? '') ||
      hasPremium ||
      hasPro;

  SubscriptionStatus getSubscriptionStatus() {
    final info = _cachedCustomerInfo;
    if (info == null || info.entitlements.active.isEmpty) {
      return SubscriptionStatus.none;
    }
    final hasAutoRenew =
        info.entitlements.active.values.any((e) => e.willRenew);
    return hasAutoRenew
        ? SubscriptionStatus.active
        : SubscriptionStatus.expiring;
  }

  DateTime? get premiumExpirationDate {
    final premium = _cachedCustomerInfo?.entitlements
        .active[PurchaseConfig.dummyEntitlements['premium']];
    final expiration = premium?.expirationDate;
    return expiration != null ? DateTime.tryParse(expiration) : null;
  }

  /// Kullanıcı girişinde çağrılır — RevenueCat satın almalarını bu user ID ile
  /// ilişkilendirir.
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) return;
    try {
      final result = await Purchases.logIn(userId);
      _cachedCustomerInfo = result.customerInfo;
      log('ℹ️ RevenueCat logged in: $userId');
    } catch (e) {
      log('❌ setUserId failed: $e');
    }
  }

  /// Kullanıcı çıkışında çağrılır.
  Future<void> clearUserId() async {
    if (!_isInitialized) return;
    try {
      _cachedCustomerInfo = await Purchases.logOut();
      log('ℹ️ RevenueCat logged out');
    } catch (e) {
      log('❌ clearUserId failed: $e');
    }
  }
}

enum SubscriptionStatus { none, active, expiring }

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

  bool get isActive => this != SubscriptionStatus.none;
}
