import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_content_models.dart';
import '../repositories/admin_content_repository.dart';
import '../services/Firebase/admin_content_firestore_service.dart';

final adminContentServiceProvider = Provider<AdminContentFirestoreService>(
  (ref) => AdminContentFirestoreService(),
);

final adminContentRepositoryProvider = Provider<AdminContentRepository>(
  (ref) => AdminContentRepository(ref.watch(adminContentServiceProvider)),
);

final equipmentProvider = StreamProvider<List<InventoryItem>>(
  (ref) => ref.watch(adminContentRepositoryProvider).watchEquipment(),
);
final consumablesProvider = StreamProvider<List<InventoryItem>>(
  (ref) => ref.watch(adminContentRepositoryProvider).watchConsumables(),
);
final newsProvider = StreamProvider<List<NewsArticle>>(
  (ref) => ref.watch(adminContentRepositoryProvider).watchNews(),
);
final policyCategoriesProvider = StreamProvider<List<PolicyCategory>>(
  (ref) => ref.watch(adminContentRepositoryProvider).watchPolicyCategories(),
);
final policiesProvider = StreamProvider<List<PolicyDocument>>(
  (ref) => ref.watch(adminContentRepositoryProvider).watchPolicies(),
);

class AdminContentActionNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<String?> saveInventory(String collection, InventoryItem item) => _run(
    () => ref
        .read(adminContentRepositoryProvider)
        .saveInventory(collection, item),
  );

  Future<String?> deleteInventory(String collection, String id) => _run(
    () => ref
        .read(adminContentRepositoryProvider)
        .deleteInventory(collection, id),
  );

  Future<String?> saveNews(NewsArticle article) =>
      _run(() => ref.read(adminContentRepositoryProvider).saveNews(article));
  Future<String?> deleteNews(String id) =>
      _run(() => ref.read(adminContentRepositoryProvider).deleteNews(id));
  Future<String?> savePolicyCategory(PolicyCategory category) => _run(
    () => ref.read(adminContentRepositoryProvider).savePolicyCategory(category),
  );
  Future<String?> deletePolicyCategory(String id) => _run(
    () => ref.read(adminContentRepositoryProvider).deletePolicyCategory(id),
  );
  Future<String?> savePolicy(PolicyDocument policy) =>
      _run(() => ref.read(adminContentRepositoryProvider).savePolicy(policy));
  Future<String?> deletePolicy(String id) =>
      _run(() => ref.read(adminContentRepositoryProvider).deletePolicy(id));

  Future<String?> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      ref.invalidate(equipmentProvider);
      ref.invalidate(consumablesProvider);
      ref.invalidate(newsProvider);
      ref.invalidate(policyCategoriesProvider);
      ref.invalidate(policiesProvider);
      return null;
    } on AdminContentValidationException catch (error) {
      state = const AsyncData(null);
      return error.message;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return 'Không thể lưu dữ liệu quản trị lúc này.';
    }
  }
}

final adminContentActionProvider =
    AsyncNotifierProvider<AdminContentActionNotifier, void>(
      AdminContentActionNotifier.new,
    );
