import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/app_notification.dart';

class NotificationFirestoreService {
  NotificationFirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _ref => _db.collection('notifications');

  Stream<List<AppNotification>> watchForUser(String userId) => _ref
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        final items = snapshot.docs
            .map((doc) => AppNotification.fromJson(doc.data(), doc.id))
            .toList();
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });

  Future<void> create({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) => _ref.add({
    'userId': userId,
    'title': title,
    'body': body,
    'type': type,
    'read': false,
    'createdAt': FieldValue.serverTimestamp(),
  });

  Future<void> markAllRead(String userId) async {
    final snapshot = await _ref.where('userId', isEqualTo: userId).where('read', isEqualTo: false).get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
