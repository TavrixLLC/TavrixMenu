import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_item.dart';
import '../repositories/menu_repository.dart';

class UpdateMenuItem {
  const UpdateMenuItem(this._repository);

  final MenuRepository _repository;

  Future<Either<Failure, MenuItem>> call({
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
    return _repository.updateItem(
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
  }
}
