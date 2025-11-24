import 'package:daisy/core/enum/common_enum.dart';
import 'package:daisy/core/manager/firebase/firebase_request.dart';
import 'package:daisy/core/manager/firebase/firebase_service.dart';
import 'package:daisy/feature/{{name.snakeCase()}}/model/{{name.snakeCase()}}_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{name.snakeCase()}}_cubit.freezed.dart';
part '{{name.snakeCase()}}_state.dart';

class {{name.pascalCase()}}Cubit extends Cubit<{{name.pascalCase()}}State> {
  {{name.pascalCase()}}Cubit() : super({{name.pascalCase()}}State());

  final _firebaseService = FirebaseService<{{name.pascalCase()}}Model>();

  Future<void> fetch{{name.pascalCase()}}List() async {
    emit(state.copyWith(status: Status.loading));
    try {
      final {{name.snakeCase()}}List = await _firebaseService.fetchList(
          FirebaseCollections.{{name.snakeCase()}}s, (json) => {{name.pascalCase()}}Model.fromJson(json));
      if ({{name.snakeCase()}}List != null) {
        emit(state.copyWith(status: Status.success, {{name.snakeCase()}}List: {{name.snakeCase()}}List));
      } else {
        emit(state.copyWith(status: Status.error));
      }
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }

  Future<void> fetchSingle{{name.pascalCase()}}(String id) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final {{name.snakeCase()}} = await _firebaseService.fetchByDocId(
          FirebaseCollections.{{name.snakeCase()}}s, id, (json) => {{name.pascalCase()}}Model.fromJson(json));
      if ({{name.snakeCase()}} != null) {
        emit(state.copyWith(status: Status.success, current{{name.pascalCase()}}: {{name.snakeCase()}}));
      } else {
        emit(state.copyWith(status: Status.error));
      }
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }

  Future<void> fetch{{name.pascalCase()}}ListByQuery(String field, dynamic value) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final {{name.snakeCase()}}List = await _firebaseService.fetchListByQuery(
          FirebaseCollections.{{name.snakeCase()}}s,
          field,
          value,
          (json) => {{name.pascalCase()}}Model.fromJson(json));
      if ({{name.snakeCase()}}List != null) {
        emit(state.copyWith(status: Status.success, {{name.snakeCase()}}List: {{name.snakeCase()}}List));
      } else {
        emit(state.copyWith(status: Status.error));
      }
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }

  Future<void> add{{name.pascalCase()}}({{name.pascalCase()}}Model {{name.snakeCase()}}) async {
    emit(state.copyWith(status: Status.loading));
    try {
      await _firebaseService.add(FirebaseCollections.{{name.snakeCase()}}s, {{name.snakeCase()}}.toJson());
      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }

  Future<void> update{{name.pascalCase()}}({{name.pascalCase()}}Model {{name.snakeCase()}}) async {
    emit(state.copyWith(status: Status.loading));
    try {
      if ({{name.snakeCase()}}.id == null) throw Exception('Id cannot be null');
      await _firebaseService.update(
          FirebaseCollections.{{name.snakeCase()}}s, {{name.snakeCase()}}.id!, {{name.snakeCase()}}.toJson());
      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }

  Future<void> delete{{name.pascalCase()}}(String id) async {
    emit(state.copyWith(status: Status.loading));
    try {
      await _firebaseService.delete(FirebaseCollections.{{name.snakeCase()}}s, id);
      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }
}
