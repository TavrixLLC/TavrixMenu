import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/current_user.dart';
import '../repositories/me_repository.dart';

class GetCurrentUser {
  const GetCurrentUser(this._repository);

  final MeRepository _repository;

  Future<Either<Failure, CurrentUser>> call() {
    return _repository.getMe();
  }
}
