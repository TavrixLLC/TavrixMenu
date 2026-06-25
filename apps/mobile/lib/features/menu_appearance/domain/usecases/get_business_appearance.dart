import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/business_appearance.dart';
import '../repositories/menu_appearance_repository.dart';

class GetBusinessAppearance {
  const GetBusinessAppearance(this._repository);

  final MenuAppearanceRepository _repository;

  Future<Either<Failure, BusinessAppearance>> call(String businessId) {
    return _repository.getBusinessAppearance(businessId);
  }
}
