part of 'purchase_cubit.dart';

class PurchaseState extends Equatable {
  const PurchaseState({
    this.status = Status.initial,
    this.isInitialized = false,
    this.purchaseInProgress = false,
    this.lastPurchaseSuccess = false,
    this.availablePackages = const [],
    this.customerInfo,
    this.hasPremium = false,
    this.hasPro = false,
    this.isAdFree = false,
    this.subscriptionStatus = SubscriptionStatus.none,
    this.premiumExpirationDate,
    this.errorMessage,
  });

  final Status status;
  final bool isInitialized;
  final bool purchaseInProgress;
  final bool lastPurchaseSuccess;
  final List<Package> availablePackages;
  final CustomerInfo? customerInfo;
  final bool hasPremium;
  final bool hasPro;
  final bool isAdFree;
  final SubscriptionStatus subscriptionStatus;
  final DateTime? premiumExpirationDate;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        status,
        isInitialized,
        purchaseInProgress,
        lastPurchaseSuccess,
        availablePackages,
        customerInfo,
        hasPremium,
        hasPro,
        isAdFree,
        subscriptionStatus,
        premiumExpirationDate,
        errorMessage,
      ];

  PurchaseState copyWith({
    Status? status,
    bool? isInitialized,
    bool? purchaseInProgress,
    bool? lastPurchaseSuccess,
    List<Package>? availablePackages,
    CustomerInfo? customerInfo,
    bool? hasPremium,
    bool? hasPro,
    bool? isAdFree,
    SubscriptionStatus? subscriptionStatus,
    DateTime? premiumExpirationDate,
    String? errorMessage,
  }) {
    return PurchaseState(
      status: status ?? this.status,
      isInitialized: isInitialized ?? this.isInitialized,
      purchaseInProgress: purchaseInProgress ?? this.purchaseInProgress,
      lastPurchaseSuccess: lastPurchaseSuccess ?? this.lastPurchaseSuccess,
      availablePackages: availablePackages ?? this.availablePackages,
      customerInfo: customerInfo ?? this.customerInfo,
      hasPremium: hasPremium ?? this.hasPremium,
      hasPro: hasPro ?? this.hasPro,
      isAdFree: isAdFree ?? this.isAdFree,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      premiumExpirationDate:
          premiumExpirationDate ?? this.premiumExpirationDate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
