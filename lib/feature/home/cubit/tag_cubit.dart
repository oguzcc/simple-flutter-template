import 'package:daisy/core/enum/common_enum.dart';
import 'package:daisy/core/manager/firebase/firebase_request.dart';
import 'package:daisy/core/manager/firebase/firebase_service.dart';
import 'package:daisy/feature/home/model/tag_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_cubit.freezed.dart';
part 'tag_state.dart';

class TagCubit extends Cubit<TagState> {
  TagCubit() : super(const TagState());
  final _firebaseService = FirebaseService<TagModel>();

  Future<void> addTag(TagModel tag) async {
    emit(state.copyWith(status: Status.loading));
    try {
      await _firebaseService.add(FirebaseCollections.tags, tag.toJson());
      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }

  Future<void> deleteTag(String id) async {
    emit(state.copyWith(status: Status.loading));
    try {
      await _firebaseService.delete(FirebaseCollections.tags, id);
      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }

  Future<void> fetchSingleTag(String id) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final tag = await _firebaseService.fetchByDocId(
        FirebaseCollections.tags,
        id,
        TagModel.fromJson,
      );
      if (tag != null) {
        emit(state.copyWith(status: Status.success, currentTag: tag));
      } else {
        emit(state.copyWith(status: Status.error));
      }
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }

  Future<void> fetchTagList() async {
    emit(state.copyWith(status: Status.loading));
    try {
      final tagList = await _firebaseService.fetchList(
        FirebaseCollections.tags,
        TagModel.fromJson,
      );
      if (tagList != null) {
        emit(state.copyWith(status: Status.success, tagList: tagList));
      } else {
        emit(state.copyWith(status: Status.error));
      }
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }

  Future<void> fetchTagListByArrayContains(String field, dynamic value) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final tagList = await _firebaseService.fetchListByQuery(
        FirebaseCollections.tags,
        field,
        value,
        TagModel.fromJson,
      );
      if (tagList != null) {
        emit(state.copyWith(status: Status.success, tagList: tagList));
      } else {
        emit(state.copyWith(status: Status.error));
      }
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }

  Future<void> fetchTagListByQuery(String field, dynamic value) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final tagList = await _firebaseService.fetchListByQuery(
        FirebaseCollections.tags,
        field,
        value,
        TagModel.fromJson,
      );
      if (tagList != null) {
        emit(state.copyWith(status: Status.success, tagList: tagList));
      } else {
        emit(state.copyWith(status: Status.error));
      }
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }

  Future<void> updateTag(TagModel tag) async {
    emit(state.copyWith(status: Status.loading));
    try {
      if (tag.id == null) throw Exception('Id cannot be null');
      await _firebaseService.update(
        FirebaseCollections.tags,
        tag.id!,
        tag.toJson(),
      );
      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }
}
