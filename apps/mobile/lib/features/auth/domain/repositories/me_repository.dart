import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/current_user.dart';

abstract class MeRepository {
  Future<Either<Failure, CurrentUser>> getMe();
}
