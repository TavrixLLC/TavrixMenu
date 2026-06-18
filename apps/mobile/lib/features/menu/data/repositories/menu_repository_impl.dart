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
        id: 'dev-category-drinks',
        businessId: 'dev-business',
        name: 'Drinks',
        sortOrder: 1,
      ),
    ];
    _items = const [
      MenuItem(
        id: 'dev-item-latte',
        businessId: 'dev-business',
        categoryId: 'dev-category-drinks',
        name: 'House Latte',
        description: 'Warm espresso drink managed by staff.',
        priceCents: 450,
        isAvailable: true,
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
    required String name,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        final category = MenuCategory(
          id: 'dev-category-${_categories.length + 1}',
          businessId: businessId,
          name: name,
          sortOrder: _categories.length + 1,
        );
        _categories = [..._categories, category];
        return category;
      }

      final model = await _remoteDataSource.createCategory(
        businessId: businessId,
        name: name,
      );
      return model.toEntity();
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
    required String name,
    required String description,
    required int priceCents,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        final item = MenuItem(
          id: 'dev-item-${_items.length + 1}',
          businessId: businessId,
          categoryId: categoryId,
          name: name,
          description: description,
          priceCents: priceCents,
          isAvailable: true,
        );
        _items = [..._items, item];
        return item;
      }

      final model = await _remoteDataSource.createItem(
        businessId: businessId,
        categoryId: categoryId,
        name: name,
        description: description,
        priceCents: priceCents,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, Unit>> updateItem({
    required String id,
    required String name,
    required String description,
    required int priceCents,
    required bool isAvailable,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        final index = _items.indexWhere((item) => item.id == id);
        final existing = index == -1 ? _items.first : _items[index];
        final updated = MenuItem(
          id: existing.id,
          businessId: existing.businessId,
          categoryId: existing.categoryId,
          name: name,
          description: description,
          priceCents: priceCents,
          isAvailable: isAvailable,
        );
        if (index == -1) {
          _items = [..._items, updated];
        } else {
          _items = [..._items]..[index] = updated;
        }
        return unit;
      }

      await _remoteDataSource.updateItem(
        id: id,
        name: name,
        description: description,
        priceCents: priceCents,
        isAvailable: isAvailable,
      );
      return unit;
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
