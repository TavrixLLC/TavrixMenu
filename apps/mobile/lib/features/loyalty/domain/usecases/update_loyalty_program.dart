import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_program.dart';
import '../entities/loyalty_requests.dart';
import '../repositories/loyalty_repository.dart';

class UpdateLoyaltyProgram {
  const UpdateLoyaltyProgram(this._repository);

  final LoyaltyRepository _repository;

  Future<Either<Failure, LoyaltyProgram>> call({
    required String businessId,
    required String programId,
    required LoyaltyProgramRequest request,
  }) {
    return _repository.updateProgram(
      businessId: businessId,
      programId: programId,
      request: request,
    );
  }
}
