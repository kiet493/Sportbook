import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../models/user_model.dart';

/// Thin wrapper around the Cloud Firestore SDK for the `users` collection.
///
/// Responsibilities are intentionally narrow:
///   * CRUD primitives (create/update/delete/get/list)
///   * Timestamps (`createdAt` / `updatedAt`)
///
/// Higher-level rules (uniqueness, default role, validation) live in
/// [UserRepository] — that layer is what the Riverpod notifiers depend on.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String usersCollection = 'users';

  CollectionReference<Map<String, dynamic>> get _usersRef => _db
      .collection(usersCollection)
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
        toFirestore: (data, _) => data,
      );

  Stream<List<UserModel>> watchAllUsers() {
    return _usersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => UserModel.fromJson(doc.data(), fallbackId: doc.id))
              .toList(growable: false),
        );
  }

  Future<UserModel?> fetchUser(String id) async {
    final snap = await _usersRef.doc(id).get();
    final directUser = snap.exists
        ? UserModel.fromJson(snap.data()!, fallbackId: snap.id)
        : null;

    try {
      return await _fetchByFirebaseUid(id) ?? directUser;
    } on FirebaseException catch (error) {
      if (directUser != null && error.code == 'permission-denied') {
        return directUser;
      }

      rethrow;
    }
  }

  Future<UserModel?> _fetchByFirebaseUid(String id) async {
    final snap = await _usersRef
        .where('firebaseUID', isEqualTo: id)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return UserModel.fromJson(doc.data(), fallbackId: doc.id);
  }

  Future<List<UserModel>> findByField({
    required String field,
    required String value,
    String? excludeId,
  }) async {
    final results = await _usersRef.where(field, isEqualTo: value).get();
    return results.docs
        .where((doc) => doc.id != excludeId)
        .map((doc) => UserModel.fromJson(doc.data(), fallbackId: doc.id))
        .toList(growable: false);
  }

  Future<void> createUser(UserModel user) async {
    final now = FieldValue.serverTimestamp();
    await _usersRef.doc(user.id).set({
      ...user.toJson(),
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> updateUser(UserModel user) async {
    final data = <String, dynamic>{
      ...user.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    data.remove('createdAt');
    await _usersRef.doc(user.id).update(data);
  }

  Future<void> deleteUser(String id) async {
    await _usersRef.doc(id).delete();
  }

  Future<void> setBanned(String id, {required bool banned}) async {
    await _usersRef.doc(id).update({
      'status': banned ? UserStatus.banned : UserStatus.active,
      'isBanned': banned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
