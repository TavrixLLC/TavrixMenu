import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_template.dart';
import '../repositories/menu_appearance_repository.dart';

class GetMenuTemplateCatalog {
  const GetMenuTemplateCatalog(this._repository);

  final MenuAppearanceRepository _repository;

  Future<Either<Failure, List<MenuTemplate>>> call() {
    return _repository.getTemplates();
  }
}
