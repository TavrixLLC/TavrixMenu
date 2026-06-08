import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_item.dart';
import '../repositories/menu_repository.dart';

class GetMenuItems {
  const GetMenuItems(this._repository);

  final MenuRepository _repository;

  Future<Either<Failure, List<MenuItem>>> call(String businessId) {
    return _repository.getItems(businessId);
  }
}
