import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> fetchInitialData() async {
    emit(state.copyWith(status: HomeStatus.loading));
    
    try {
      // Simulate fetching data
      await Future.delayed(const Duration(seconds: 1));
      
      // Here you would normally fetch:
      // - Home stories
      // - Home sliders
      // - Categories
      // - Products
      // - Campaigns
      // etc.
      
      emit(state.copyWith(
        status: HomeStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}