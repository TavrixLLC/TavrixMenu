import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_category.dart';
import '../entities/menu_item.dart';
import '../entities/reorder_menu_record.dart';

abstract class MenuRepository {
  Future<Either<Failure, List<MenuCategory>>> getCategories(
    String businessId, {
    bool includeInactive = false,
  });

  Future<Either<Failure, MenuCategory>> createCategory({
    required String businessId,
    required String name,
  });

  Future<Either<Failure, Unit>> updateCategory({
    required String id,
    String? name,
    int? sortOrder,
    bool? isActive,
  });

  Future<Either<Failure, Unit>> deleteCategory(String id);

  Future<Either<Failure, Unit>> restoreCategory(String id);

  Future<Either<Failure, List<MenuCategory>>> reorderCategories({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  });

  Future<Either<Failure, List<MenuItem>>> getItems(
    String businessId, {
    bool includeInactive = false,
  });

  Future<Either<Failure, MenuItem>> createItem({
    required String businessId,
    required String categoryId,
    required String name,
    required String description,
    required int priceCents,
    bool isAvailable = true,
  });

  Future<Either<Failure, Unit>> updateItem({
    required String id,
    required String name,
    required String description,
    required int priceCents,
    required bool isAvailable,
  });

  Future<Either<Failure, Unit>> deleteItem(String id);

  Future<Either<Failure, Unit>> restoreItem(String id);

  Future<Either<Failure, List<MenuItem>>> reorderItems({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  });
}
