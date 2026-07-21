import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/response_parser.dart';
import '../../domain/entities/reorder_menu_record.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';

abstract class MenuRemoteDataSource {
  bool get canCallBackend;

  Future<List<MenuCategoryModel>> getCategories(
    String businessId, {
    bool includeInactive = false,
  });

  Future<MenuCategoryModel> createCategory({
    required String businessId,
    required String name,
  });

  Future<MenuCategoryModel> updateCategory({
    required String id,
    String? name,
    int? sortOrder,
    bool? isActive,
  });

  Future<void> deleteCategory(String id);

  Future<MenuCategoryModel> restoreCategory(String id);

  Future<List<MenuCategoryModel>> reorderCategories({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  });

  Future<List<MenuItemModel>> getItems(
    String businessId, {
    bool includeInactive = false,
  });

  Future<MenuItemModel> createItem({
    required String businessId,
    required String categoryId,
    required String name,
    required String description,
    required int priceCents,
    bool isAvailable = true,
  });

  Future<MenuItemModel> updateItem({
    required String id,
    required String name,
    required String description,
    required int priceCents,
    required bool isAvailable,
  });

  Future<void> deleteItem(String id);

  Future<MenuItemModel> restoreItem(String id);

  Future<List<MenuItemModel>> reorderItems({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  });
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  const MenuRemoteDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  bool get canCallBackend => apiClient.canCallBackend;

  @override
  Future<List<MenuCategoryModel>> getCategories(
    String businessId, {
    bool includeInactive = false,
  }) async {
    final data = await apiClient.get(
      '/businesses/$businessId/categories',
      queryParameters: includeInactive ? {'includeInactive': true} : null,
    );
    return _parseCategories(data);
  }

  @override
  Future<MenuCategoryModel> createCategory({
    required String businessId,
    required String name,
  }) async {
    final data = await apiClient.post(
      '/businesses/$businessId/categories',
      body: {'nameAr': name, 'sortOrder': 0, 'isActive': true},
    );
    return _parseCategory(data, context: 'create category response');
  }

  @override
  Future<MenuCategoryModel> updateCategory({
    required String id,
    String? name,
    int? sortOrder,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) {
      body['nameAr'] = name;
    }
    if (sortOrder != null) {
      body['sortOrder'] = sortOrder;
    }
    if (isActive != null) {
      body['isActive'] = isActive;
    }

    final data = await apiClient.patch('/categories/$id', body: body);
    return _parseCategory(data, context: 'update category response');
  }

  @override
  Future<void> deleteCategory(String id) async {
    await apiClient.delete('/categories/$id');
  }

  @override
  Future<MenuCategoryModel> restoreCategory(String id) async {
    final data = await apiClient.patch(
      '/categories/$id',
      body: {'isActive': true},
    );
    return _parseCategory(data, context: 'restore category response');
  }

  @override
  Future<List<MenuCategoryModel>> reorderCategories({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) async {
    final data = await apiClient.patch(
      '/businesses/$businessId/categories/reorder',
      body: {'orders': orders.map((order) => order.toJson()).toList()},
    );
    return _parseCategories(data);
  }

  @override
  Future<List<MenuItemModel>> getItems(
    String businessId, {
    bool includeInactive = false,
  }) async {
    final data = await apiClient.get(
      '/businesses/$businessId/items',
      queryParameters: includeInactive ? {'includeInactive': true} : null,
    );
    return _parseItems(data);
  }

  @override
  Future<MenuItemModel> createItem({
    required String businessId,
    required String categoryId,
    required String name,
    required String description,
    required int priceCents,
    bool isAvailable = true,
  }) async {
    final data = await apiClient.post(
      '/businesses/$businessId/items',
      body: {
        'categoryId': categoryId,
        'nameAr': name,
        if (description.trim().isNotEmpty) 'descriptionAr': description,
        'price': priceCents.toString(),
        'isAvailable': isAvailable,
        'sortOrder': 0,
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
        'nameAr': name,
        'descriptionAr': description,
        'price': priceCents.toString(),
        'isAvailable': isAvailable,
      },
    );
    return _parseItem(data, context: 'update menu item response');
  }

  @override
  Future<void> deleteItem(String id) async {
    await apiClient.delete('/items/$id');
  }

  @override
  Future<MenuItemModel> restoreItem(String id) async {
    final data = await apiClient.patch(
      '/items/$id',
      body: {'isAvailable': true},
    );
    return _parseItem(data, context: 'restore menu item response');
  }

  @override
  Future<List<MenuItemModel>> reorderItems({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) async {
    final data = await apiClient.patch(
      '/businesses/$businessId/items/reorder',
      body: {'orders': orders.map((order) => order.toJson()).toList()},
    );
    return _parseItems(data);
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
