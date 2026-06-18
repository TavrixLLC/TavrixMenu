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
          clerkUserId: 'user_tavrix_owner',
          email: 'owner@tavrix.local',
          fullName: 'Tavrix Owner',
          role: 'OWNER',
          status: 'ACTIVE',
          onboarding: CurrentUserOnboarding(
            hasBusiness: true,
            activeBusinessCount: 1,
            recommendedNextStep: 'OPEN_DASHBOARD',
          ),
          businesses: [
            CurrentUserBusiness(
              id: 'dev-business',
              name: 'Tavrix Demo Cafe',
              slug: 'tavrix-demo-cafe',
              type: 'cafe',
              role: 'OWNER',
            ),
          ],
        );
      }

      final model = await _remoteDataSource.getMe();
      return model.toEntity();
    }, _networkInfo);
  }
}
