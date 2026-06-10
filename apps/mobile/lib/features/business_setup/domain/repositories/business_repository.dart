import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/business.dart';
import '../entities/business_app_context.dart';
import '../entities/public_link.dart';

abstract class BusinessRepository {
  Future<Either<Failure, Business?>> getMyBusiness();

  Future<Either<Failure, BusinessAppContext>> getBusinessAppContext(
    String businessId,
  );

  Future<Either<Failure, PublicLink>> getPublicLink(String businessId);

  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String type,
    required String currency,
    required String language,
    String? city,
  });

  Future<Either<Failure, Business>> updateBusiness({
    required String id,
    required String name,
    required String type,
    required String currency,
    required String language,
    String? city,
  });
}
