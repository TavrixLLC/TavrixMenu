import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_membership.dart';
import '../repositories/loyalty_repository.dart';

class ListLoyaltyMemberships {
  const ListLoyaltyMemberships(this._repository);

  final LoyaltyRepository _repository;

  Future<Either<Failure, List<LoyaltyMembership>>> call({
    required String businessId,
    String? search,
    String? status,
    bool? rewardReady,
  }) {
    return _repository.listMemberships(
      businessId: businessId,
      search: search,
      status: status,
      rewardReady: rewardReady,
    );
  }
}
