import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/business_app_context.dart';
import '../repositories/business_repository.dart';

class GetBusinessAppContext {
  const GetBusinessAppContext(this._repository);

  final BusinessRepository _repository;

  Future<Either<Failure, BusinessAppContext>> call(String businessId) {
    return _repository.getBusinessAppContext(businessId);
  }
}
