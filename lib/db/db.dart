import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // Fetch all replays as a stream
  Stream<List<Map<String, dynamic>>> getReplays() {
    return FirebaseFirestore.instance
        .collection('replays')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
