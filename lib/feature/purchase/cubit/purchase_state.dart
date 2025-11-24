part of 'purchase_cubit.dart';

@freezed
class PurchaseState with _$PurchaseState {
  const factory PurchaseState({
    @Default(Status.initial) Status status,
    @Default(false) bool isInitialized,
    @Default(false) bool purchaseInProgress,
    @Default(false) bool lastPurchaseSuccess,
    @Default([]) List<Package> availablePackages,
    CustomerInfo? customerInfo,
    @Default(false) bool hasPremium,
    @Default(false) bool hasPro,
    @Default(false) bool isAdFree,
    @Default(SubscriptionStatus.none) SubscriptionStatus subscriptionStatus,
    DateTime? premiumExpirationDate,
    String? errorMessage,
  }) = _PurchaseState;
}
