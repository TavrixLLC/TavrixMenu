import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_action_result.dart';
import '../entities/loyalty_requests.dart';
import '../repositories/loyalty_repository.dart';

class AddLoyaltyStamps {
  const AddLoyaltyStamps(this._repository);

  final LoyaltyRepository _repository;

  Future<Either<Failure, LoyaltyActionResult>> call({
    required String businessId,
    required String membershipId,
    required AddStampsRequest request,
  }) {
    return _repository.addStamps(
      businessId: businessId,
      membershipId: membershipId,
      request: request,
    );
  }
}
