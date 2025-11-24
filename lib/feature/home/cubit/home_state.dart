part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, error }

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(HomeStatus.initial) HomeStatus status,
    String? errorMessage,
  }) = _HomeState;
}