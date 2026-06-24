part of 'app_update_cubit.dart';

enum AppUpdateStatus { initial, checking, upToDate, optional, forced, error }

class AppUpdateState extends Equatable {
  const AppUpdateState({
    this.status = AppUpdateStatus.initial,
    this.message,
    this.storeUrl,
  });

  final AppUpdateStatus status;
  final String? message;
  final String? storeUrl;

  bool get hasUpdate =>
      status == AppUpdateStatus.optional || status == AppUpdateStatus.forced;
  bool get isForced => status == AppUpdateStatus.forced;

  AppUpdateState copyWith({
    AppUpdateStatus? status,
    String? message,
    String? storeUrl,
  }) {
    return AppUpdateState(
      status: status ?? this.status,
      message: message ?? this.message,
      storeUrl: storeUrl ?? this.storeUrl,
    );
  }

  @override
  List<Object?> get props => [status, message, storeUrl];
}
