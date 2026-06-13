import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_transaction.dart';
import '../repositories/loyalty_repository.dart';

class ListLoyaltyTransactions {
  const ListLoyaltyTransactions(this._repository);

  final LoyaltyRepository _repository;

  Future<Either<Failure, List<LoyaltyTransaction>>> call({
    required String businessId,
    required String membershipId,
  }) {
    return _repository.listTransactions(
      businessId: businessId,
      membershipId: membershipId,
    );
  }
}
