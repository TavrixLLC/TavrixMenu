import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/menu_repository.dart';

class UpdateMenuItem {
  const UpdateMenuItem(this._repository);

  final MenuRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String id,
    required String name,
    required String description,
    required int priceCents,
    required bool isAvailable,
  }) {
    return _repository.updateItem(
      id: id,
      name: name,
      description: description,
      priceCents: priceCents,
      isAvailable: isAvailable,
    );
  }
}
