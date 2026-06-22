import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_item.dart';
import '../entities/reorder_menu_record.dart';
import '../repositories/menu_repository.dart';

class ReorderMenuItems {
  const ReorderMenuItems(this._repository);

  final MenuRepository _repository;

  Future<Either<Failure, List<MenuItem>>> call({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) {
    return _repository.reorderItems(businessId: businessId, orders: orders);
  }
}
