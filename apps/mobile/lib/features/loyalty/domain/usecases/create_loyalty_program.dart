import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_program.dart';
import '../entities/loyalty_requests.dart';
import '../repositories/loyalty_repository.dart';

class CreateLoyaltyProgram {
  const CreateLoyaltyProgram(this._repository);

  final LoyaltyRepository _repository;

  Future<Either<Failure, LoyaltyProgram>> call({
    required String businessId,
    required LoyaltyProgramRequest request,
  }) {
    return _repository.createProgram(businessId: businessId, request: request);
  }
}
