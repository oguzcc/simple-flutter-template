part of 'purchase_cubit.dart';

class PurchaseState extends Equatable {
  const PurchaseState({
    this.status = Status.initial,
    this.isInitialized = false,
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
