import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/menu_repository.dart';

class RestoreMenuCategory {
  const RestoreMenuCategory(this._repository);

  final MenuRepository _repository;

  Future<Either<Failure, Unit>> call(String id) {
    return _repository.restoreCategory(id);
  }
}
