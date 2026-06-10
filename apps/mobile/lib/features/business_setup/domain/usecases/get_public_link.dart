import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/public_link.dart';
import '../repositories/business_repository.dart';

class GetPublicLink {
  const GetPublicLink(this._repository);

  final BusinessRepository _repository;

  Future<Either<Failure, PublicLink>> call(String businessId) {
    return _repository.getPublicLink(businessId);
  }
}
