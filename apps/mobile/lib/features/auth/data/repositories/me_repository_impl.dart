import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/run_safe.dart';
import '../../domain/entities/current_user.dart';
import '../../domain/repositories/me_repository.dart';
import '../datasources/me_remote_data_source.dart';

class MeRepositoryImpl implements MeRepository {
  const MeRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  final AuthRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, CurrentUser>> getMe() {
    return runSafe(() async {
      final model = await _remoteDataSource.getMe();
      return model.toEntity();
    }, _networkInfo);
  }
}
