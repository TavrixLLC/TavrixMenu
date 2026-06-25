import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/run_safe.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/reorder_menu_record.dart';
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
        sortOrder: 0,
        isActive: true,
      ),
    ];
    _items = const [
      MenuItem(
        id: 'dev-item-latte',
        businessId: 'dev-business',
        categoryId: 'dev-category-drinks',
        name: 'House Latte',
        description: 'Warm espresso drink managed by the team.',
        priceCents: 450,
        isAvailable: true,
        sortOrder: 0,
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
  Future<Either<Failure, List<MenuCategory>>> getCategories(
    String businessId, {
    bool includeInactive = false,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        return includeInactive
            ? _sortedCategories(_categories)
            : _sortedCategories(
                _categories.where((category) => category.isActive).toList(),
              );
      }

      final models = await _remoteDataSource.getCategories(
        businessId,
        includeInactive: includeInactive,
      );
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
          sortOrder: _categories.length,
          isActive: true,
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
  Future<Either<Failure, Unit>> updateCategory({
    required String id,
    String? name,
    int? sortOrder,
    bool? isActive,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        _categories = _categories.map((category) {
          if (category.id != id) {
            return category;
          }
          return category.copyWith(
            name: name,
            sortOrder: sortOrder,
            isActive: isActive,
          );
        }).toList();
        return unit;
      }

      await _remoteDataSource.updateCategory(
        id: id,
        name: name,
        sortOrder: sortOrder,
        isActive: isActive,
      );
      return unit;
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String id) {
    return runSafe(() async {
      if (_useDevData) {
        _categories = _categories
            .map(
              (category) => category.id == id
                  ? category.copyWith(isActive: false)
                  : category,
            )
            .toList();
        return unit;
      }

      await _remoteDataSource.deleteCategory(id);
      return unit;
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, Unit>> restoreCategory(String id) {
    return runSafe(() async {
      if (_useDevData) {
        _categories = _categories
            .map(
              (category) => category.id == id
                  ? category.copyWith(isActive: true)
                  : category,
            )
            .toList();
        return unit;
      }

      await _remoteDataSource.restoreCategory(id);
      return unit;
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, List<MenuCategory>>> reorderCategories({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        _categories = _applyCategoryOrders(_categories, orders);
        return _sortedCategories(_categories);
      }

      final models = await _remoteDataSource.reorderCategories(
        businessId: businessId,
        orders: orders,
      );
      return models.map((model) => model.toEntity()).toList();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, List<MenuItem>>> getItems(
    String businessId, {
    bool includeInactive = false,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        return includeInactive
            ? _sortedItems(_items)
            : _sortedItems(_items.where((item) => item.isAvailable).toList());
      }

      final models = await _remoteDataSource.getItems(
        businessId,
        includeInactive: includeInactive,
      );
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
          sortOrder: _items.length,
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
        final updated = existing.copyWith(
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
        _items = _items
            .map(
              (item) =>
                  item.id == id ? item.copyWith(isAvailable: false) : item,
            )
            .toList();
        return unit;
      }

      await _remoteDataSource.deleteItem(id);
      return unit;
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, Unit>> restoreItem(String id) {
    return runSafe(() async {
      if (_useDevData) {
        _items = _items
            .map(
              (item) => item.id == id ? item.copyWith(isAvailable: true) : item,
            )
            .toList();
        return unit;
      }

      await _remoteDataSource.restoreItem(id);
      return unit;
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, List<MenuItem>>> reorderItems({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        _items = _applyItemOrders(_items, orders);
        return _sortedItems(_items);
      }

      final models = await _remoteDataSource.reorderItems(
        businessId: businessId,
        orders: orders,
      );
      return models.map((model) => model.toEntity()).toList();
    }, _networkInfo);
  }

  List<MenuCategory> _applyCategoryOrders(
    List<MenuCategory> categories,
    List<ReorderMenuRecord> orders,
  ) {
    return categories.map((category) {
      final order = orders
          .where((candidate) => candidate.id == category.id)
          .firstOrNull;
      return order == null
          ? category
          : category.copyWith(sortOrder: order.sortOrder);
    }).toList();
  }

  List<MenuItem> _applyItemOrders(
    List<MenuItem> items,
    List<ReorderMenuRecord> orders,
  ) {
    return items.map((item) {
      final order = orders
          .where((candidate) => candidate.id == item.id)
          .firstOrNull;
      return order == null ? item : item.copyWith(sortOrder: order.sortOrder);
    }).toList();
  }

  List<MenuCategory> _sortedCategories(List<MenuCategory> categories) {
    return [...categories]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<MenuItem> _sortedItems(List<MenuItem> items) {
    return [...items]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
