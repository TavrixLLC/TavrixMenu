import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_item.dart';
import '../repositories/menu_repository.dart';

class CreateMenuItem {
  const CreateMenuItem(this._repository);

  final MenuRepository _repository;

  Future<Either<Failure, MenuItem>> call({
    required String businessId,
    required String categoryId,
    required String name,
    required String description,
    required String price,
  }) {
    return _repository.createItem(
      businessId: businessId,
      categoryId: categoryId,
      name: name,
      description: description,
      price: price,
    );
  }
}
