import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_category.dart';
import '../entities/menu_item.dart';

abstract class MenuRepository {
  Future<Either<Failure, List<MenuCategory>>> getCategories(String businessId);

  Future<Either<Failure, MenuCategory>> createCategory({
    required String businessId,
    required String name,
  });

  Future<Either<Failure, List<MenuItem>>> getItems(String businessId);

  Future<Either<Failure, MenuItem>> createItem({
    required String businessId,
    required String categoryId,
    required String name,
    required String description,
    required String price,
  });

  Future<Either<Failure, Unit>> updateItem({
    required String id,
    required String name,
    required String description,
    required String price,
    required bool isAvailable,
  });

  Future<Either<Failure, Unit>> deleteItem(String id);
}
