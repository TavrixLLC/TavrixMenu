import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_category.dart';
import '../repositories/menu_repository.dart';

class UpdateMenuCategory {
  const UpdateMenuCategory(this._repository);

  final MenuRepository _repository;

  Future<Either<Failure, MenuCategory>> call({
    required String id,
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  }) {
    return _repository.updateCategory(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      sortOrder: sortOrder,
      isActive: isActive,
    );
  }
}
