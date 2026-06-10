import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/business.dart';
import '../repositories/business_repository.dart';

class GetMyBusinesses {
  const GetMyBusinesses(this._repository);

  final BusinessRepository _repository;

  Future<Either<Failure, List<Business>>> call() {
    return _repository.getMyBusinesses();
  }
}
