import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_category.dart';
import '../repositories/menu_repository.dart';

class CreateMenuCategory {
  const CreateMenuCategory(this._repository);

  final MenuRepository _repository;

  Future<Either<Failure, MenuCategory>> call({
    required String businessId,
    required String name,
  }) {
    return _repository.createCategory(businessId: businessId, name: name);
  }
}
