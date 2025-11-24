part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.errorMessage,
  });

  final HomeStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];

  HomeState copyWith({
    HomeStatus? status,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}