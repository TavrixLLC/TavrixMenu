import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_category.dart';
import '../repositories/menu_repository.dart';

class GetMenuCategories {
  const GetMenuCategories(this._repository);

  final MenuRepository _repository;

  Future<Either<Failure, List<MenuCategory>>> call(String businessId) {
    return _repository.getCategories(businessId);
  }
}
