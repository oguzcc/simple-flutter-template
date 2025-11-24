import 'package:daisy/core/manager/firebase/firebase_request.dart';
import 'package:daisy/core/types/typedefs.dart';

abstract class IFirebaseService<T> {
  Future<List<T>?> fetchList(
    FirebaseCollections collection,
    T Function(CommonMap) fromJson,
  );
  Future<T?> fetchByDocId(
    FirebaseCollections collection,
    String id,
    T Function(CommonMap) fromJson,
  );
  Future<List<T>?> fetchListByQuery(
    FirebaseCollections collection,
    String field,
    dynamic value,
    T Function(CommonMap) fromJson,
  );
  Future<void> add(FirebaseCollections collection, CommonMap data);
}

class FirebaseService<T> implements IFirebaseService<T> {
  final _firebaseRequest = FirebaseRequest();

  @override
  Future<List<T>?> fetchList(
    FirebaseCollections collection,
    T Function(CommonMap) fromJson,
  ) async {
    try {
      final jsonList = await _firebaseRequest.fetchList(collection);
      return jsonList?.map((e) => fromJson(e.data)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<T?> fetchByDocId(
    FirebaseCollections collection,
    String id,
    T Function(CommonMap) fromJson,
  ) async {
    try {
      final json = await _firebaseRequest.fetchByDocId(collection, id);
      return json != null ? fromJson(json.data) : null;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<T>?> fetchListByQuery(
    FirebaseCollections collection,
    String field,
    dynamic value,
    T Function(CommonMap) fromJson,
  ) async {
    try {
      final jsonList =
          await _firebaseRequest.fetchListByQuery(collection, field, value);
      return jsonList?.map((e) => fromJson(e.data)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> add(FirebaseCollections collection, CommonMap data) async {
    try {
      await _firebaseRequest.add(collection, data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> update(
    FirebaseCollections collection,
    String id,
    CommonMap data,
  ) async {
    try {
      await _firebaseRequest.update(collection, id, data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> delete(FirebaseCollections collection, String id) async {
    try {
      await _firebaseRequest.delete(collection, id);
    } catch (e) {
      throw Exception(e);
    }
  }
}
