import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/run_safe.dart';
import '../../../business_setup/domain/entities/business.dart';
import '../../domain/entities/current_user.dart';
import '../../domain/repositories/me_repository.dart';
import '../datasources/me_remote_data_source.dart';

class MeRepositoryImpl implements MeRepository {
  const MeRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required bool devFallbackEnabled,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo,
       _devFallbackEnabled = devFallbackEnabled;

  final AuthRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final bool _devFallbackEnabled;

  @override
  Future<Either<Failure, CurrentUser>> getMe() {
    return runSafe(() async {
      if (!_remoteDataSource.canCallBackend && _devFallbackEnabled) {
        return const CurrentUser(
          id: 'dev-owner',
          email: 'owner@tavrix.local',
          fullName: 'Tavrix Demo Owner',
          role: 'OWNER',
          businesses: [
            Business(
              id: 'dev-business',
              name: 'Tavrix Cafe',
              slug: 'tavrix-cafe',
              type: 'cafe',
              role: 'OWNER',
              publicMenuUrl: '',
              currency: 'IQD',
              language: 'ar',
            ),
          ],
        );
      }

      final model = await _remoteDataSource.getMe();
      return model.toEntity();
    }, _networkInfo);
  }
}
