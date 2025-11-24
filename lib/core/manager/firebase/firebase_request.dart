import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daisy/core/manager/firebase/model/firebase_response.dart';
import 'package:daisy/core/types/typedefs.dart';

enum FirebaseCollections {
  tags,
  ;

  CollectionReference get reference =>
      FirebaseFirestore.instance.collection(name);
}

abstract class IFirebaseRequest {
  Future<List<FirebaseResponse>?> fetchList(FirebaseCollections collection);
  Future<FirebaseResponse?> fetchByDocId(
    FirebaseCollections collection,
    String id,
  );
  Future<List<FirebaseResponse>?> fetchListByQuery(
    FirebaseCollections collection,
    String field,
    dynamic value,
  );
  Future<List<FirebaseResponse>?> fetchListByArrayContains(
    FirebaseCollections collection,
    String field,
    dynamic value,
  );
  Future<void> add(FirebaseCollections collection, CommonMap data);
  Future<void> update(
    FirebaseCollections collection,
    String id,
    CommonMap data,
  );
  Future<void> delete(FirebaseCollections collection, String id);
}

class FirebaseRequest implements IFirebaseRequest {
  @override
  Future<List<FirebaseResponse>?> fetchList(
    FirebaseCollections collection,
  ) async {
    final snapshot = await collection.reference.get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.map(FirebaseResponse.fromJson).toList();
  }

  @override
  Future<FirebaseResponse?> fetchByDocId(
    FirebaseCollections collection,
    String id,
  ) async {
    final snapshot = await collection.reference.doc(id).get();
    if (!snapshot.exists) return null;
    return FirebaseResponse.fromJson(snapshot);
  }

  @override
  Future<List<FirebaseResponse>?> fetchListByQuery(
    FirebaseCollections collection,
    String field,
    dynamic value,
  ) async {
    final snapshot =
        await collection.reference.where(field, isEqualTo: value).get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.map(FirebaseResponse.fromJson).toList();
  }

  @override
  Future<List<FirebaseResponse>?> fetchListByArrayContains(
    FirebaseCollections collection,
    String field,
    dynamic value,
  ) async {
    final snapshot =
        await collection.reference.where(field, arrayContains: value).get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.map(FirebaseResponse.fromJson).toList();
  }

  @override
  Future<void> add(FirebaseCollections collection, CommonMap data) async {
    await collection.reference.add(data);
  }

  @override
  Future<void> update(
    FirebaseCollections collection,
    String id,
    CommonMap data,
  ) async {
    await collection.reference.doc(id).update(data);
  }

  @override
  Future<void> delete(FirebaseCollections collection, String id) async {
    await collection.reference.doc(id).delete();
  }
}
