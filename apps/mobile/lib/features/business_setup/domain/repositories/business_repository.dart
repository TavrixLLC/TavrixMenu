import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/business.dart';

abstract class BusinessRepository {
  Future<Either<Failure, Business>> getMyBusiness();

  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String slug,
  });

  Future<Either<Failure, Business>> updateBusiness({
    required String id,
    required String name,
    required String slug,
  });
}
