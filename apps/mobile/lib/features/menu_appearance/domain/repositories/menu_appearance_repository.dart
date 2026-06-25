import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/business_appearance.dart';
import '../entities/menu_template.dart';

abstract class MenuAppearanceRepository {
  Future<Either<Failure, List<MenuTemplate>>> getTemplates();

  Future<Either<Failure, BusinessAppearance>> getBusinessAppearance(
    String businessId,
  );

  Future<Either<Failure, BusinessAppearance>> updateBusinessAppearance({
    required String businessId,
    required String menuTemplateId,
  });
}
