import 'package:firebase_database/firebase_database.dart';

abstract class IFirebaseRealtime {
  // Future<List<Map<String, dynamic>>?>
  //  fetchList(FirebaseCollections collection);
  // Future<Map<String, dynamic>?> fetchSingle(String path);
  Future<void> add(String path, Map<String, dynamic> data);
  // Future<void> update(String path, Map<String, dynamic> data);
  // Future<void> delete(String path);
}

class FirebaseRealtime implements IFirebaseRealtime {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  Future<void> add(String path, Map<String, dynamic> data) async {
    await _database.ref().child(path).push().set(data);
  }
}
