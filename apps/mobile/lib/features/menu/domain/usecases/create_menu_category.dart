import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_category.dart';
import '../repositories/menu_repository.dart';

class CreateMenuCategory {
  const CreateMenuCategory(this._repository);

  final MenuRepository _repository;

  Future<Either<Failure, MenuCategory>> call({
    required String businessId,
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  }) {
    return _repository.createCategory(
      businessId: businessId,
      nameAr: nameAr,
      nameEn: nameEn,
      sortOrder: sortOrder,
      isActive: isActive,
    );
  }
}
