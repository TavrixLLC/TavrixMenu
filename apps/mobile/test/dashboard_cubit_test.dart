import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/entities/current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/repositories/me_repository.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/repositories/business_repository.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/get_my_business.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_state.dart';

void main() {
  test('reset clears stale staff role label after logout', () async {
    final cubit = DashboardCubit(
      getCurrentUser: GetCurrentUser(const _StaffMeRepository()),
      getMyBusiness: GetMyBusiness(const _BusinessRepository()),
      getDashboardSummary: GetDashboardSummary(const _DashboardRepository()),
    );

    await cubit.load();
    expect(cubit.state.status, DashboardStatus.success);
    expect(cubit.state.roleDisplayLabel, 'Staff');

    cubit.reset();

    expect(cubit.state.status, DashboardStatus.initial);
    expect(cubit.state.roleDisplayLabel, 'Business Operator');
    expect(cubit.state.roleDisplayLabel, isNot('Staff'));

    await cubit.close();
  });
}

const _business = Business(
  id: 'bus_123',
  name: 'Tavrix Cafe',
  slug: 'tavrix-cafe',
  publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
);

class _StaffMeRepository implements MeRepository {
  const _StaffMeRepository();

  @override
  Future<Either<Failure, CurrentUser>> getMe() async {
    return const Right(
      CurrentUser(
        id: 'usr_123',
        email: '',
        fullName: 'Operator',
        role: 'STAFF',
        onboarding: CurrentUserOnboarding(
          hasBusiness: true,
          activeBusinessCount: 1,
        ),
      ),
    );
  }
}

class _BusinessRepository implements BusinessRepository {
  const _BusinessRepository();

  @override
  Future<Either<Failure, Business>> getMyBusiness() async {
    return const Right(_business);
  }

  @override
  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Business>> updateBusiness({
    required String id,
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
    String? logoUrl,
    String? coverUrl,
  }) {
    throw UnimplementedError();
  }
}

class _DashboardRepository implements DashboardRepository {
  const _DashboardRepository();

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String businessId,
  ) async {
    return const Right(
      DashboardSummary(
        business: _business,
        currentUser: DashboardCurrentUser(
          role: 'STAFF',
          permissions: BusinessPermissions(canViewPublicLink: true),
          permissionsAvailable: true,
        ),
        counts: DashboardCounts(),
        publicMenu: DashboardPublicMenu(
          path: '/m/tavrix-cafe',
          url: 'https://menu.example.test/m/tavrix-cafe',
          qrPayload: 'https://menu.example.test/m/tavrix-cafe',
        ),
        onboardingHints: DashboardOnboardingHints(),
      ),
    );
  }
}
