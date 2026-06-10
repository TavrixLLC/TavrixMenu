import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/run_safe.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_data_source.dart';

class MenuRepositoryImpl implements MenuRepository {
  MenuRepositoryImpl({
    required MenuRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required bool devFallbackEnabled,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo,
       _devFallbackEnabled = devFallbackEnabled {
    _categories = const [
      MenuCategory(
        id: 'dev-category-hot-drinks',
        businessId: 'dev-business',
        nameAr: 'Hot Drinks',
        nameEn: 'Hot Drinks',
        sortOrder: 1,
      ),
      MenuCategory(
        id: 'dev-category-desserts',
        businessId: 'dev-business',
        nameAr: 'Desserts',
        nameEn: 'Desserts',
        sortOrder: 2,
      ),
    ];
    _items = const [
      MenuItem(
        id: 'dev-item-turkish-coffee',
        businessId: 'dev-business',
        categoryId: 'dev-category-hot-drinks',
        nameAr: 'Turkish Coffee',
        nameEn: 'Turkish Coffee',
        descriptionAr: 'Rich coffee with cardamom.',
        price: '2500',
        isAvailable: true,
        sortOrder: 1,
      ),
      MenuItem(
        id: 'dev-item-tamriya',
        businessId: 'dev-business',
        categoryId: 'dev-category-desserts',
        nameAr: 'Tamriya',
        nameEn: 'Tamriya',
        descriptionAr: 'Date pastry with sesame.',
        price: '3000',
        isAvailable: true,
        sortOrder: 2,
      ),
      MenuItem(
        id: 'dev-item-baklava',
        businessId: 'dev-business',
        categoryId: 'dev-category-desserts',
        nameAr: 'Baklava',
        nameEn: 'Baklava',
        descriptionAr: 'Layered pastry with pistachio.',
        price: '3500',
        isAvailable: true,
        sortOrder: 3,
      ),
    ];
  }

  final MenuRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final bool _devFallbackEnabled;
  late List<MenuCategory> _categories;
  late List<MenuItem> _items;

  bool get _useDevData =>
      !_remoteDataSource.canCallBackend && _devFallbackEnabled;

  @override
  Future<Either<Failure, List<MenuCategory>>> getCategories(String businessId) {
    return runSafe(() async {
      if (_useDevData) {
        return _categories;
      }

      final models = await _remoteDataSource.getCategories(businessId);
      return models.map((model) => model.toEntity()).toList();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, MenuCategory>> createCategory({
    required String businessId,
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        final category = MenuCategory(
          id: 'dev-category-${_categories.length + 1}',
          businessId: businessId,
          nameAr: nameAr,
          nameEn: nameEn,
          sortOrder: sortOrder,
          isActive: isActive,
        );
        _categories = [..._categories, category];
        return category;
      }

      final model = await _remoteDataSource.createCategory(
        businessId: businessId,
        nameAr: nameAr,
        nameEn: nameEn,
        sortOrder: sortOrder,
        isActive: isActive,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, MenuCategory>> updateCategory({
    required String id,
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        final index = _categories.indexWhere((category) => category.id == id);
        final existing = index == -1 ? _categories.first : _categories[index];
        final updated = MenuCategory(
          id: existing.id,
          businessId: existing.businessId,
          nameAr: nameAr,
          nameEn: nameEn,
          sortOrder: sortOrder,
          isActive: isActive,
        );
        if (index == -1) {
          _categories = [..._categories, updated];
        } else {
          _categories = [..._categories]..[index] = updated;
        }
        return updated;
      }

      final model = await _remoteDataSource.updateCategory(
        id: id,
        nameAr: nameAr,
        nameEn: nameEn,
        sortOrder: sortOrder,
        isActive: isActive,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String id) {
    return runSafe(() async {
      if (_useDevData) {
        _categories = _categories
            .where((category) => category.id != id)
            .toList();
        _items = _items.where((item) => item.categoryId != id).toList();
        return unit;
      }

      await _remoteDataSource.deleteCategory(id);
      return unit;
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, List<MenuItem>>> getItems(String businessId) {
    return runSafe(() async {
      if (_useDevData) {
        return _items;
      }

      final models = await _remoteDataSource.getItems(businessId);
      return models.map((model) => model.toEntity()).toList();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, MenuItem>> createItem({
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
  }) {
    return runSafe(() async {
      if (_useDevData) {
        final item = MenuItem(
          id: 'dev-item-${_items.length + 1}',
          businessId: businessId,
          categoryId: categoryId,
          nameAr: nameAr,
          nameEn: nameEn,
          descriptionAr: descriptionAr,
          descriptionEn: descriptionEn,
          price: price,
          imageUrl: imageUrl,
          isAvailable: isAvailable,
          sortOrder: sortOrder,
        );
        _items = [..._items, item];
        return item;
      }

      final model = await _remoteDataSource.createItem(
        businessId: businessId,
        categoryId: categoryId,
        nameAr: nameAr,
        nameEn: nameEn,
        descriptionAr: descriptionAr,
        descriptionEn: descriptionEn,
        price: price,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        sortOrder: sortOrder,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, MenuItem>> updateItem({
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
  }) {
    return runSafe(() async {
      if (_useDevData) {
        final index = _items.indexWhere((item) => item.id == id);
        final existing = index == -1 ? _items.first : _items[index];
        final updated = MenuItem(
          id: existing.id,
          businessId: existing.businessId,
          categoryId: categoryId,
          nameAr: nameAr,
          nameEn: nameEn,
          descriptionAr: descriptionAr,
          descriptionEn: descriptionEn,
          price: price,
          imageUrl: imageUrl,
          isAvailable: isAvailable,
          sortOrder: sortOrder,
        );
        if (index == -1) {
          _items = [..._items, updated];
        } else {
          _items = [..._items]..[index] = updated;
        }
        return updated;
      }

      final model = await _remoteDataSource.updateItem(
        id: id,
        categoryId: categoryId,
        nameAr: nameAr,
        nameEn: nameEn,
        descriptionAr: descriptionAr,
        descriptionEn: descriptionEn,
        price: price,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        sortOrder: sortOrder,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, Unit>> deleteItem(String id) {
    return runSafe(() async {
      if (_useDevData) {
        _items = _items.where((item) => item.id != id).toList();
        return unit;
      }

      await _remoteDataSource.deleteItem(id);
      return unit;
    }, _networkInfo);
  }
}
