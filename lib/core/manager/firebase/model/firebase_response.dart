import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daisy/core/types/typedefs.dart';

class FirebaseResponse {
  FirebaseResponse({required this.data});

  factory FirebaseResponse.fromJson(DocumentSnapshot doc) {
    final data = doc.data()! as CommonMap;
    data['id'] = doc.id; // Add the document ID to the data map
    return FirebaseResponse(data: data);
  }
  final CommonMap data;
}
