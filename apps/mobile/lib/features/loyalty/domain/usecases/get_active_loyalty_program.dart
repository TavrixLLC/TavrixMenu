import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_program.dart';
import '../repositories/loyalty_repository.dart';

class GetActiveLoyaltyProgram {
  const GetActiveLoyaltyProgram(this._repository);

  final LoyaltyRepository _repository;

  Future<Either<Failure, LoyaltyProgram?>> call(String businessId) {
    return _repository.getActiveProgram(businessId);
  }
}
