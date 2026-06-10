import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/business.dart';

abstract class BusinessRepository {
  Future<Either<Failure, List<Business>>> getMyBusinesses();

  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String type,
    String? city,
    String currency = 'IQD',
    String language = 'ar',
  });

  Future<Either<Failure, Business>> updateBusiness({
    required String id,
    required String name,
    required String type,
    String? city,
    String currency = 'IQD',
    String language = 'ar',
  });
}
