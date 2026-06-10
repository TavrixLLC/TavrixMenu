import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_category.dart';
import '../entities/menu_item.dart';

abstract class MenuRepository {
  Future<Either<Failure, List<MenuCategory>>> getCategories(String businessId);

  Future<Either<Failure, MenuCategory>> createCategory({
    required String businessId,
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  });

  Future<Either<Failure, MenuCategory>> updateCategory({
    required String id,
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  });

  Future<Either<Failure, Unit>> deleteCategory(String id);

  Future<Either<Failure, List<MenuItem>>> getItems(String businessId);

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
  });

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
  });

  Future<Either<Failure, Unit>> deleteItem(String id);
}
