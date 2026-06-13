import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_enroll_result.dart';
import '../entities/loyalty_requests.dart';
import '../repositories/loyalty_repository.dart';

class EnrollLoyaltyCustomer {
  const EnrollLoyaltyCustomer(this._repository);

  final LoyaltyRepository _repository;

  Future<Either<Failure, LoyaltyEnrollResult>> call({
    required String businessId,
    required EnrollLoyaltyCustomerRequest request,
  }) {
    return _repository.enrollCustomer(businessId: businessId, request: request);
  }
}
