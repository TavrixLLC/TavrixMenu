import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_category.dart';
import '../entities/reorder_menu_record.dart';
import '../repositories/menu_repository.dart';

class ReorderMenuCategories {
  const ReorderMenuCategories(this._repository);

  final MenuRepository _repository;

  Future<Either<Failure, List<MenuCategory>>> call({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) {
    return _repository.reorderCategories(
      businessId: businessId,
      orders: orders,
    );
  }
}
