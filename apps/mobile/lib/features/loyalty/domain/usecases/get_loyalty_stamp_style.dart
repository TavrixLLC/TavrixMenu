import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_stamp_style.dart';
import '../repositories/loyalty_repository.dart';

class GetLoyaltyStampStyle {
  const GetLoyaltyStampStyle(this._repository);

  final LoyaltyRepository _repository;

  Future<Either<Failure, LoyaltyStampStyle?>> call(String businessId) {
    return _repository.getStampStyle(businessId);
  }
}
