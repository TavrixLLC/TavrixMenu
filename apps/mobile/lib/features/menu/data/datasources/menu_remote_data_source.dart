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
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  });

  Future<MenuCategoryModel> updateCategory({
    required String id,
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  });

  Future<void> deleteCategory(String id);

  Future<List<MenuItemModel>> getItems(String businessId);

  Future<MenuItemModel> createItem({
    required String businessId,
    required String categoryId,
    required String nameAr,
    required String price,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? imageUrl,
    bool isAvailable = true,
    int sortOrder = 0,
  });

  Future<MenuItemModel> updateItem({
    required String id,
    required String categoryId,
    required String nameAr,
    required String price,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? imageUrl,
    bool isAvailable = true,
    int sortOrder = 0,
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
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final data = await apiClient.post(
      '/businesses/$businessId/categories',
      body: _categoryBody(
        nameAr: nameAr,
        nameEn: nameEn,
        sortOrder: sortOrder,
        isActive: isActive,
      ),
    );
    return _parseCategory(data, context: 'create category response');
  }

  @override
  Future<MenuCategoryModel> updateCategory({
    required String id,
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final data = await apiClient.patch(
      '/categories/$id',
      body: _categoryUpdateBody(
        nameAr: nameAr,
        nameEn: nameEn,
        sortOrder: sortOrder,
        isActive: isActive,
      ),
    );
    return _parseCategory(data, context: 'update category response');
  }

  @override
  Future<void> deleteCategory(String id) async {
    await apiClient.delete('/categories/$id');
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
    required String nameAr,
    required String price,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? imageUrl,
    bool isAvailable = true,
    int sortOrder = 0,
  }) async {
    final data = await apiClient.post(
      '/businesses/$businessId/items',
      body: _itemBody(
        categoryId: categoryId,
        nameAr: nameAr,
        nameEn: nameEn,
        descriptionAr: descriptionAr,
        descriptionEn: descriptionEn,
        price: price,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        sortOrder: sortOrder,
      ),
    );
    return _parseItem(data, context: 'create menu item response');
  }

  @override
  Future<MenuItemModel> updateItem({
    required String id,
    required String categoryId,
    required String nameAr,
    required String price,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? imageUrl,
    bool isAvailable = true,
    int sortOrder = 0,
  }) async {
    final data = await apiClient.patch(
      '/items/$id',
      body: _itemUpdateBody(
        categoryId: categoryId,
        nameAr: nameAr,
        nameEn: nameEn,
        descriptionAr: descriptionAr,
        descriptionEn: descriptionEn,
        price: price,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        sortOrder: sortOrder,
      ),
    );
    return _parseItem(data, context: 'update menu item response');
  }

  @override
  Future<void> deleteItem(String id) async {
    await apiClient.delete('/items/$id');
  }

  Map<String, dynamic> _categoryBody({
    required String nameAr,
    String? nameEn,
    required int sortOrder,
    required bool isActive,
  }) {
    return {
      'nameAr': nameAr,
      if (nameEn != null && nameEn.trim().isNotEmpty) 'nameEn': nameEn.trim(),
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> _categoryUpdateBody({
    required String nameAr,
    String? nameEn,
    required int sortOrder,
    required bool isActive,
  }) {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> _itemBody({
    required String categoryId,
    required String nameAr,
    required String price,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? imageUrl,
    required bool isAvailable,
    required int sortOrder,
  }) {
    return {
      'categoryId': categoryId,
      'nameAr': nameAr,
      if (nameEn != null && nameEn.trim().isNotEmpty) 'nameEn': nameEn.trim(),
      if (descriptionAr != null && descriptionAr.trim().isNotEmpty)
        'descriptionAr': descriptionAr.trim(),
      if (descriptionEn != null && descriptionEn.trim().isNotEmpty)
        'descriptionEn': descriptionEn.trim(),
      'price': price,
      if (imageUrl != null && imageUrl.trim().isNotEmpty)
        'imageUrl': imageUrl.trim(),
      'isAvailable': isAvailable,
      'sortOrder': sortOrder,
    };
  }

  Map<String, dynamic> _itemUpdateBody({
    required String categoryId,
    required String nameAr,
    required String price,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? imageUrl,
    required bool isAvailable,
    required int sortOrder,
  }) {
    return {
      'categoryId': categoryId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'sortOrder': sortOrder,
    };
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
    final json = _toObject(data, context: context);

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
    final json = _toObject(data, context: context);

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

  Map<String, dynamic> _toObject(dynamic data, {required String context}) {
    final json = asJsonObject(data, context: context);
    final nested = json['data'] ?? json['item'] ?? json['category'];
    if (nested != null) {
      return asJsonObject(nested, context: context);
    }
    return json;
  }

  List<Map<String, dynamic>> _toObjectList(
    dynamic data, {
    required String context,
  }) {
    if (data is Map) {
      final json = asJsonObject(data, context: context);
      final nestedList = json['data'] ?? json['items'] ?? json['categories'];
      return asJsonObjectList(nestedList, context: context);
    }

    return asJsonObjectList(data, context: context);
  }
}
