// PurchaseCubit birim testleri.
//
// Satın alma akışı RevenueCat native paywall (purchases_ui_flutter) üzerinden
// yürütüldüğü için cubit yalnızca:
// - initialize() SDK'yı başlatır
// - refresh() CustomerInfo'yu yeniler (paywall kapandıktan sonra)
// - checkEntitlement() senkron entitlement kontrolü
// davranışlarını test eder.

import 'package:bloc_test/bloc_test.dart';
import 'package:daisy/core/enum/common_enum.dart';
import 'package:daisy/core/manager/purchase/purchase_service.dart';
import 'package:daisy/feature/purchase/cubit/purchase_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPurchaseService extends Mock implements PurchaseService {}

void main() {
  group('PurchaseCubit', () {
    late MockPurchaseService service;

    setUp(() {
      service = MockPurchaseService();
      when(() => service.cachedCustomerInfo).thenReturn(null);
      when(() => service.hasPremium).thenReturn(false);
      when(() => service.hasPro).thenReturn(false);
      when(() => service.isAdFree).thenReturn(false);
      when(() => service.getSubscriptionStatus())
          .thenReturn(SubscriptionStatus.none);
      when(() => service.premiumExpirationDate).thenReturn(null);
      when(() => service.refreshCustomerInfo()).thenAnswer((_) async => null);
    });

    test('initial state', () {
      final cubit = PurchaseCubit(service);
      expect(cubit.state.status, Status.initial);
      expect(cubit.state.isInitialized, isFalse);
      expect(cubit.state.hasPremium, isFalse);
    });

    blocTest<PurchaseCubit, PurchaseState>(
      'emits [loading, success] and marks initialized when init succeeds',
      setUp: () {
        when(() => service.initialize()).thenAnswer((_) async => true);
      },
      build: () => PurchaseCubit(service),
      act: (cubit) => cubit.initialize(),
      expect: () => [
        predicate<PurchaseState>((s) => s.status == Status.loading),
        predicate<PurchaseState>(
          (s) => s.status == Status.success && s.isInitialized,
        ),
      ],
      verify: (_) {
        verify(() => service.initialize()).called(1);
      },
    );

    blocTest<PurchaseCubit, PurchaseState>(
      'emits [loading, error] when init fails',
      setUp: () {
        when(() => service.initialize()).thenAnswer((_) async => false);
      },
      build: () => PurchaseCubit(service),
      act: (cubit) => cubit.initialize(),
      expect: () => [
        predicate<PurchaseState>((s) => s.status == Status.loading),
        predicate<PurchaseState>(
          (s) =>
              s.status == Status.error &&
              !s.isInitialized &&
              s.errorMessage != null,
        ),
      ],
    );

    blocTest<PurchaseCubit, PurchaseState>(
      'refresh calls service and emits success',
      setUp: () {
        when(() => service.initialize()).thenAnswer((_) async => true);
      },
      build: () => PurchaseCubit(service),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.refresh();
      },
      verify: (_) {
        verify(() => service.refreshCustomerInfo()).called(1);
      },
    );

    test('checkEntitlement returns false when not initialized', () {
      final cubit = PurchaseCubit(service);
      expect(cubit.checkEntitlement('premium'), isFalse);
      verifyNever(() => service.hasActiveEntitlement(any()));
    });
  });
}
