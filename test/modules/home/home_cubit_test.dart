import 'package:bloc_test/bloc_test.dart';
import 'package:daisy/feature/home/cubit/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeCubit', () {
    test('initial state has HomeStatus.initial and no error', () {
      final cubit = HomeCubit();
      expect(cubit.state.status, HomeStatus.initial);
      expect(cubit.state.errorMessage, isNull);
    });

    blocTest<HomeCubit, HomeState>(
      'emits [loading, success] when fetchInitialData succeeds',
      build: HomeCubit.new,
      act: (cubit) => cubit.fetchInitialData(),
      wait: const Duration(milliseconds: 1200),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(status: HomeStatus.success),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'copyWith preserves fields not passed',
      build: HomeCubit.new,
      act: (cubit) {
        cubit
          ..emit(
            const HomeState(
              status: HomeStatus.error,
              errorMessage: 'boom',
            ),
          )
          ..emit(cubit.state.copyWith(status: HomeStatus.loading));
      },
      expect: () => [
        const HomeState(status: HomeStatus.error, errorMessage: 'boom'),
        const HomeState(status: HomeStatus.loading, errorMessage: 'boom'),
      ],
    );
  });
}
