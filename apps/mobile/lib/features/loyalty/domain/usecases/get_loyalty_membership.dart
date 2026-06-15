import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_membership.dart';
import '../repositories/loyalty_repository.dart';

class GetLoyaltyMembership {
  const GetLoyaltyMembership(this._repository);

  final LoyaltyRepository _repository;

  Future<Either<Failure, LoyaltyMembership>> call({
    required String businessId,
    required String membershipId,
  }) {
    return _repository.getMembership(
      businessId: businessId,
      membershipId: membershipId,
    );
  }
}
