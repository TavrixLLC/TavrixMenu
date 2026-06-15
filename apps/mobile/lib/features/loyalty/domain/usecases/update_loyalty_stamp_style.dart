import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_requests.dart';
import '../entities/loyalty_stamp_style.dart';
import '../repositories/loyalty_repository.dart';

class UpdateLoyaltyStampStyle {
  const UpdateLoyaltyStampStyle(this._repository);

  final LoyaltyRepository _repository;

  Future<Either<Failure, LoyaltyStampStyle>> call({
    required String businessId,
    required UpdateLoyaltyStampStyleRequest request,
  }) {
    return _repository.updateStampStyle(
      businessId: businessId,
      request: request,
    );
  }
}
