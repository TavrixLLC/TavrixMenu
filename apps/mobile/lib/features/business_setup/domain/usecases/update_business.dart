import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/business.dart';
import '../repositories/business_repository.dart';

class UpdateBusiness {
  const UpdateBusiness(this._repository);

  final BusinessRepository _repository;

  Future<Either<Failure, Business>> call({
    required String id,
    required String name,
    required String type,
    required String currency,
    required String language,
    String? city,
  }) {
    return _repository.updateBusiness(
      id: id,
      name: name,
      type: type,
      city: city,
      currency: currency,
      language: language,
    );
  }
}
