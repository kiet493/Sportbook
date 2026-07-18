import '../models/admin_content_models.dart';
import '../services/Firebase/admin_content_firestore_service.dart';

class AdminContentValidationException implements Exception {
  final String message;
  const AdminContentValidationException(this.message);
}

class AdminContentRepository {
  AdminContentRepository(this._service);

  final AdminContentFirestoreService _service;

  Stream<List<InventoryItem>> watchEquipment() =>
      _service.watchInventory('equipments');
  Stream<List<InventoryItem>> watchConsumables() =>
      _service.watchInventory('consumables');
  Stream<List<NewsArticle>> watchNews() => _service.watchNews();
  Stream<List<PolicyCategory>> watchPolicyCategories() =>
      _service.watchPolicyCategories();
  Stream<List<PolicyDocument>> watchPolicies() => _service.watchPolicies();

  Future<void> saveInventory(String collection, InventoryItem item) {
    if (!const ['equipments', 'consumables'].contains(collection)) {
      throw const AdminContentValidationException('Loại kho không hợp lệ.');
    }
    if (item.name.trim().isEmpty || item.unit.trim().isEmpty) {
      throw const AdminContentValidationException(
        'Tên và đơn vị không được để trống.',
      );
    }
    if (item.quantity < 0 || item.price < 0) {
      throw const AdminContentValidationException(
        'Số lượng và đơn giá không được âm.',
      );
    }
    return _service.saveInventory(collection, item);
  }

  Future<void> deleteInventory(String collection, String id) =>
      _service.deleteInventory(collection, id);

  Future<void> saveNews(NewsArticle article) {
    if (article.title.trim().isEmpty || article.content.trim().isEmpty) {
      throw const AdminContentValidationException(
        'Tiêu đề và nội dung tin không được để trống.',
      );
    }
    return _service.saveNews(article);
  }

  Future<void> deleteNews(String id) => _service.deleteNews(id);

  Future<void> savePolicyCategory(PolicyCategory category) {
    if (category.name.trim().isEmpty) {
      throw const AdminContentValidationException(
        'Tên danh mục không được để trống.',
      );
    }
    return _service.savePolicyCategory(category);
  }

  Future<void> deletePolicyCategory(String id) =>
      _service.deletePolicyCategory(id);

  Future<void> savePolicy(PolicyDocument policy) {
    if (policy.categoryId.isEmpty ||
        policy.title.trim().isEmpty ||
        policy.content.trim().isEmpty) {
      throw const AdminContentValidationException(
        'Danh mục, tiêu đề và nội dung chính sách là bắt buộc.',
      );
    }
    return _service.savePolicy(policy);
  }

  Future<void> deletePolicy(String id) => _service.deletePolicy(id);
}
