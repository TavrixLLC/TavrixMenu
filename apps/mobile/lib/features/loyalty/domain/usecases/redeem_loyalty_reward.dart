import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_action_result.dart';
import '../entities/loyalty_requests.dart';
import '../repositories/loyalty_repository.dart';

class RedeemLoyaltyReward {
  const RedeemLoyaltyReward(this._repository);

  final LoyaltyRepository _repository;

  Future<Either<Failure, LoyaltyActionResult>> call({
    required String businessId,
    required String membershipId,
    required RedeemRewardRequest request,
  }) {
    return _repository.redeemReward(
      businessId: businessId,
      membershipId: membershipId,
      request: request,
    );
  }
}
