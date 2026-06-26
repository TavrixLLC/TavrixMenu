import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/run_safe.dart';
import '../../../business_setup/domain/entities/business.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl({
    required DashboardRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required bool devFallbackEnabled,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo,
       _devFallbackEnabled = devFallbackEnabled;

  final DashboardRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final bool _devFallbackEnabled;

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String businessId,
  ) {
    return runSafe(() async {
      if (!_remoteDataSource.canCallBackend && _devFallbackEnabled) {
        return DashboardSummary(
          business: const Business(
            id: 'dev-business',
            name: 'Tavrix Demo Cafe',
            slug: 'tavrix-demo-cafe',
            publicMenuUrl: 'https://menu.tavrix.com/m/tavrix-demo-cafe',
            type: 'cafe',
            city: 'Baghdad',
            currency: 'IQD',
            language: 'ar',
            status: 'ACTIVE',
            role: 'OWNER',
            permissions: BusinessPermissions.owner(),
          ),
          currentUser: const DashboardCurrentUser(
            role: 'OWNER',
            permissions: BusinessPermissions.owner(),
          ),
          counts: const DashboardCounts(
            activeCategories: 1,
            activeItems: 1,
            availableItems: 1,
            activeMembers: 1,
          ),
          publicMenu: const DashboardPublicMenu(
            path: '/m/tavrix-demo-cafe',
            url: 'https://menu.tavrix.com/m/tavrix-demo-cafe',
            qrPayload: 'https://menu.tavrix.com/m/tavrix-demo-cafe',
          ),
          onboardingHints: const DashboardOnboardingHints(
            hasCategories: true,
            hasItems: true,
            hasPublicMenuReady: true,
            recommendedNextStep: 'SHARE_PUBLIC_MENU',
          ),
        );
      }

      final model = await _remoteDataSource.getDashboardSummary(businessId);
      return model.toEntity();
    }, _networkInfo);
  }
}
