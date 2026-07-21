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
       _networkInfo = networkInfo;

  final MenuRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<MenuCategory>>> getCategories(
    String businessId, {
    bool includeInactive = false,
  }) {
    if (!_remoteDataSource.canCallBackend) {
      return _backendRequired();
    }
    return runSafe(() async {
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
    if (!_remoteDataSource.canCallBackend) {
      return _backendRequired();
    }
    return runSafe(() async {
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
    if (!_remoteDataSource.canCallBackend) {
      return _backendRequired();
    }
    return runSafe(() async {
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
    if (!_remoteDataSource.canCallBackend) {
      return _backendRequired();
    }
    return runSafe(() async {
      await _remoteDataSource.deleteCategory(id);
      return unit;
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, Unit>> restoreCategory(String id) {
    if (!_remoteDataSource.canCallBackend) {
      return _backendRequired();
    }
    return runSafe(() async {
      await _remoteDataSource.restoreCategory(id);
      return unit;
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, List<MenuCategory>>> reorderCategories({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) {
    if (!_remoteDataSource.canCallBackend) {
      return _backendRequired();
    }
    return runSafe(() async {
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
    if (!_remoteDataSource.canCallBackend) {
      return _backendRequired();
    }
    return runSafe(() async {
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
    bool isAvailable = true,
  }) {
    if (!_remoteDataSource.canCallBackend) {
      return _backendRequired();
    }
    return runSafe(() async {
      final model = await _remoteDataSource.createItem(
        businessId: businessId,
        categoryId: categoryId,
        name: name,
        description: description,
        priceCents: priceCents,
        isAvailable: isAvailable,
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
    if (!_remoteDataSource.canCallBackend) {
      return _backendRequired();
    }
    return runSafe(() async {
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
    if (!_remoteDataSource.canCallBackend) {
      return _backendRequired();
    }
    return runSafe(() async {
      await _remoteDataSource.deleteItem(id);
      return unit;
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, Unit>> restoreItem(String id) {
    if (!_remoteDataSource.canCallBackend) {
      return _backendRequired();
    }
    return runSafe(() async {
      await _remoteDataSource.restoreItem(id);
      return unit;
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, List<MenuItem>>> reorderItems({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) {
    if (!_remoteDataSource.canCallBackend) {
      return _backendRequired();
    }
    return runSafe(() async {
      final models = await _remoteDataSource.reorderItems(
        businessId: businessId,
        orders: orders,
      );
      return models.map((model) => model.toEntity()).toList();
    }, _networkInfo);
  }

  Future<Either<Failure, T>> _backendRequired<T>() async {
    return const Left(ServerFailure());
  }
}
