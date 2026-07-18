import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/admin_content_models.dart';

class AdminContentFirestoreService {
  AdminContentFirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<InventoryItem>> watchInventory(String collection) =>
      _db.collection(collection).snapshots().map((snapshot) {
        final items = snapshot.docs
            .map(
              (doc) => InventoryItem.fromJson(doc.data(), fallbackId: doc.id),
            )
            .toList();
        items.sort((a, b) => a.name.compareTo(b.name));
        return items;
      });

  Future<void> saveInventory(String collection, InventoryItem item) async {
    final reference = item.id.isEmpty
        ? _db.collection(collection).doc()
        : _db.collection(collection).doc(item.id);
    final saved = item.copyWith(id: reference.id);
    await reference.set({
      ...saved.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (item.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteInventory(String collection, String id) =>
      _db.collection(collection).doc(id).delete();

  Stream<List<NewsArticle>> watchNews() =>
      _db.collection('news').snapshots().map((snapshot) {
        final items = snapshot.docs
            .map((doc) => NewsArticle.fromJson(doc.data(), fallbackId: doc.id))
            .toList();
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });

  Future<void> saveNews(NewsArticle article) async {
    final reference = article.id.isEmpty
        ? _db.collection('news').doc()
        : _db.collection('news').doc(article.id);
    final saved = article.copyWith(id: reference.id);
    await reference.set({
      ...saved.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (article.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteNews(String id) => _db.collection('news').doc(id).delete();

  Stream<List<PolicyCategory>> watchPolicyCategories() =>
      _db.collection('policy_categories').snapshots().map((snapshot) {
        final items = snapshot.docs
            .map(
              (doc) => PolicyCategory.fromJson(doc.data(), fallbackId: doc.id),
            )
            .toList();
        items.sort((a, b) => a.name.compareTo(b.name));
        return items;
      });

  Stream<List<PolicyDocument>> watchPolicies() =>
      _db.collection('policies').snapshots().map((snapshot) {
        final items = snapshot.docs
            .map(
              (doc) => PolicyDocument.fromJson(doc.data(), fallbackId: doc.id),
            )
            .toList();
        items.sort((a, b) => a.title.compareTo(b.title));
        return items;
      });

  Future<void> savePolicyCategory(PolicyCategory category) async {
    final reference = category.id.isEmpty
        ? _db.collection('policy_categories').doc()
        : _db.collection('policy_categories').doc(category.id);
    await reference.set({
      ...category.copyWith(id: reference.id).toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (category.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deletePolicyCategory(String id) async {
    final policies = await _db
        .collection('policies')
        .where('categoryId', isEqualTo: id)
        .get();
    final batch = _db.batch();
    for (final policy in policies.docs) {
      batch.delete(policy.reference);
    }
    batch.delete(_db.collection('policy_categories').doc(id));
    await batch.commit();
  }

  Future<void> savePolicy(PolicyDocument policy) async {
    final reference = policy.id.isEmpty
        ? _db.collection('policies').doc()
        : _db.collection('policies').doc(policy.id);
    await reference.set({
      ...policy.copyWith(id: reference.id).toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (policy.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deletePolicy(String id) =>
      _db.collection('policies').doc(id).delete();
}
