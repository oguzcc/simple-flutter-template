import 'package:daisy/core/manager/remote/force_update_manager.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_update_state.dart';

class AppUpdateCubit extends Cubit<AppUpdateState> with WidgetsBindingObserver {
  AppUpdateCubit({ForceUpdateManager? manager})
      : _manager = manager ?? ForceUpdateManager(),
        super(const AppUpdateState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  final ForceUpdateManager _manager;

  Future<void> check({String? languageCode}) async {
    if (state.status == AppUpdateStatus.checking) return;
    // Once a forced update has been detected, don't downgrade the gate.
    if (state.isForced) return;

    emit(state.copyWith(status: AppUpdateStatus.checking));
    final result = await _manager.evaluate(languageCode: languageCode);
    emit(_stateFromResult(result));
  }

  AppUpdateState _stateFromResult(ForceUpdateResult result) {
    switch (result.requirement) {
      case UpdateRequirement.none:
        return const AppUpdateState(status: AppUpdateStatus.upToDate);
      case UpdateRequirement.optional:
        return AppUpdateState(
          status: AppUpdateStatus.optional,
          message: result.message,
          storeUrl: result.storeUrl,
        );
      case UpdateRequirement.forced:
        return AppUpdateState(
          status: AppUpdateStatus.forced,
          message: result.message,
          storeUrl: result.storeUrl,
        );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      check();
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
