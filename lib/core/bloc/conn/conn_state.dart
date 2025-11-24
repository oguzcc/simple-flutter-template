part of 'conn_cubit.dart';

enum ConnStatus {
  online(CoreStrings.online),
  offline(CoreStrings.offline),
  ;

  const ConnStatus(this.message);
  final String message;
}

class ConnState extends Equatable {
  const ConnState({
    this.status = ConnStatus.offline,
  });

  final ConnStatus status;

  @override
  List<Object?> get props => [status];

  ConnState copyWith({
    ConnStatus? status,
  }) {
    return ConnState(
      status: status ?? this.status,
    );
  }
}
