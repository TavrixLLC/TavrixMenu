import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/response_parser.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';

abstract class MenuRemoteDataSource {
  bool get canCallBackend;

  Future<List<MenuCategoryModel>> getCategories(String businessId);

  Future<MenuCategoryModel> createCategory({
    required String businessId,
    required String name,
  });

  Future<List<MenuItemModel>> getItems(String businessId);

  Future<MenuItemModel> createItem({
    required String businessId,
    required String categoryId,
    required String name,
    required String description,
    required int priceCents,
  });

  Future<MenuItemModel> updateItem({
    required String id,
    required String name,
    required String description,
    required int priceCents,
    required bool isAvailable,
  });

  Future<void> deleteItem(String id);
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  const MenuRemoteDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  bool get canCallBackend => apiClient.canCallBackend;

  @override
  Future<List<MenuCategoryModel>> getCategories(String businessId) async {
    final data = await apiClient.get('/businesses/$businessId/categories');
    return _parseCategories(data);
  }

  @override
  Future<MenuCategoryModel> createCategory({
    required String businessId,
    required String name,
  }) async {
    final data = await apiClient.post(
      '/businesses/$businessId/categories',
      body: {'name': name},
    );
    return _parseCategory(data, context: 'create category response');
  }

  @override
  Future<List<MenuItemModel>> getItems(String businessId) async {
    final data = await apiClient.get('/businesses/$businessId/items');
    return _parseItems(data);
  }

  @override
  Future<MenuItemModel> createItem({
    required String businessId,
    required String categoryId,
    required String name,
    required String description,
    required int priceCents,
  }) async {
    final data = await apiClient.post(
      '/businesses/$businessId/items',
      body: {
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price_cents': priceCents,
      },
    );
    return _parseItem(data, context: 'create menu item response');
  }

  @override
  Future<MenuItemModel> updateItem({
    required String id,
    required String name,
    required String description,
    required int priceCents,
    required bool isAvailable,
  }) async {
    final data = await apiClient.patch(
      '/items/$id',
      body: {
        'name': name,
        'description': description,
        'price_cents': priceCents,
        'is_available': isAvailable,
      },
    );
    return _parseItem(data, context: 'update menu item response');
  }

  @override
  Future<void> deleteItem(String id) async {
    await apiClient.delete('/items/$id');
  }

  List<MenuCategoryModel> _parseCategories(dynamic data) {
    final list = _toObjectList(data, context: 'categories response');

    try {
      return list.map(MenuCategoryModel.fromJson).toList();
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw const ServerException('Invalid categories response.');
    }
  }

  MenuCategoryModel _parseCategory(dynamic data, {required String context}) {
    final json = asJsonObject(data, context: context);

    try {
      return MenuCategoryModel.fromJson(json);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw ServerException('Invalid $context.');
    }
  }

  List<MenuItemModel> _parseItems(dynamic data) {
    final list = _toObjectList(data, context: 'menu items response');

    try {
      return list.map(MenuItemModel.fromJson).toList();
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw const ServerException('Invalid menu items response.');
    }
  }

  MenuItemModel _parseItem(dynamic data, {required String context}) {
    final json = asJsonObject(data, context: context);

    try {
      return MenuItemModel.fromJson(json);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw ServerException('Invalid $context.');
    }
  }

  List<Map<String, dynamic>> _toObjectList(
    dynamic data, {
    required String context,
  }) {
    if (data is Map) {
      final json = asJsonObject(data, context: context);
      final nestedList = json['data'] ?? json['items'];
      return asJsonObjectList(nestedList, context: context);
    }

    return asJsonObjectList(data, context: context);
  }
}
