import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/business.dart';
import '../repositories/business_repository.dart';

class GetMyBusiness {
  const GetMyBusiness(this._repository);

  final BusinessRepository _repository;

  Future<Either<Failure, Business?>> call() {
    return _repository.getMyBusiness();
  }
}
