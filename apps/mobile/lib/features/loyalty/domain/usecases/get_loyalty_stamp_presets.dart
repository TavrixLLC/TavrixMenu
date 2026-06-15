import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_stamp_style.dart';
import '../repositories/loyalty_repository.dart';

class GetLoyaltyStampPresets {
  const GetLoyaltyStampPresets(this._repository);

  final LoyaltyRepository _repository;

  Future<Either<Failure, LoyaltyStampPresets>> call() {
    return _repository.getStampPresets();
  }
}
