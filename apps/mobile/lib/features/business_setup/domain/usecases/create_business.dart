import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/business.dart';
import '../repositories/business_repository.dart';

class CreateBusiness {
  const CreateBusiness(this._repository);

  final BusinessRepository _repository;

  Future<Either<Failure, Business>> call({
    required String name,
    required String type,
    String? city,
    String currency = 'IQD',
    String language = 'ar',
  }) {
    return _repository.createBusiness(
      name: name,
      type: type,
      city: city,
      currency: currency,
      language: language,
    );
  }
}
