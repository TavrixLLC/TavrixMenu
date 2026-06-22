import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/app/router/route_names.dart';
import 'package:tavrix_menu_mobile/core/auth/auth_session_controller.dart';
import 'package:tavrix_menu_mobile/core/auth/clerk_token_provider.dart';
import 'package:tavrix_menu_mobile/core/auth/dev_token_provider.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/entities/current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/repositories/me_repository.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/repositories/business_repository.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/create_business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/get_my_business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/update_business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/presentation/bloc/business_setup_cubit.dart';
import 'package:tavrix_menu_mobile/features/business_setup/presentation/pages/business_setup_screen.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_state.dart';

void main() {
  testWidgets('business creation refreshes auth before opening dashboard', (
    tester,
  ) async {
    final meRepository = _QueuedMeRepository([
      _currentUser(
        hasBusiness: false,
        activeBusinessCount: 0,
        recommendedNextStep: 'CREATE_BUSINESS',
      ),
      _currentUser(
        hasBusiness: true,
        activeBusinessCount: 1,
        recommendedNextStep: 'OPEN_DASHBOARD',
      ),
    ]);
    final businessRepository = _FakeBusinessRepository();
    final authCubit = _authCubit(meRepository);
    final dashboardRepository = _FakeDashboardRepository();
    final businessSetupCubit = BusinessSetupCubit(
      createBusiness: CreateBusiness(businessRepository),
      updateBusiness: UpdateBusiness(businessRepository),
    );
    final dashboardCubit = DashboardCubit(
      getCurrentUser: GetCurrentUser(meRepository),
      getMyBusiness: GetMyBusiness(businessRepository),
      getDashboardSummary: GetDashboardSummary(dashboardRepository),
    );

    await authCubit.signInWithClerk();
    expect(authCubit.state.shouldOpenDashboard, isFalse);

    await tester.pumpWidget(
      _businessSetupWidget(
        authCubit: authCubit,
        businessSetupCubit: businessSetupCubit,
        dashboardCubit: dashboardCubit,
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'Tavrix Cafe');

    final meCallsBeforeSubmit = meRepository.getMeCalls;
    await tester.tap(find.text('Save business'));
    await tester.pumpAndSettle();

    expect(businessRepository.createBusinessCalls, 1);
    expect(
      meRepository.getMeCalls,
      meCallsBeforeSubmit + 1,
      reason: 'POST /businesses must trigger exactly one GET /me refresh',
    );
    expect(
      authCubit.state.user?.onboarding.recommendedNextStep,
      'OPEN_DASHBOARD',
    );
    expect(authCubit.state.shouldOpenDashboard, isTrue);
    expect(dashboardCubit.state.status, DashboardStatus.success);
    expect(dashboardCubit.state.business?.id, _createdBusiness.id);
    expect(find.text('Dashboard ready'), findsOneWidget);

    await authCubit.close();
    await businessSetupCubit.close();
    await dashboardCubit.close();
  });
}

Widget _businessSetupWidget({
  required AuthCubit authCubit,
  required BusinessSetupCubit businessSetupCubit,
  required DashboardCubit dashboardCubit,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>.value(value: authCubit),
      BlocProvider<BusinessSetupCubit>.value(value: businessSetupCubit),
      BlocProvider<DashboardCubit>.value(value: dashboardCubit),
    ],
    child: MaterialApp(
      initialRoute: AppRouteNames.businessSetup,
      routes: {
        AppRouteNames.businessSetup: (_) => const BusinessSetupScreen(),
        AppRouteNames.dashboard: (_) =>
            const Scaffold(body: Center(child: Text('Dashboard ready'))),
      },
    ),
  );
}

AuthCubit _authCubit(MeRepository repository) {
  final sessionController = AuthSessionController(
    config: _config,
    clerkTokenProvider: ClerkTokenProvider(),
    devTokenProvider: const DevTokenProvider(''),
  );

  return AuthCubit(
    getCurrentUser: GetCurrentUser(repository),
    authSessionController: sessionController,
  );
}

CurrentUser _currentUser({
  required bool hasBusiness,
  required int activeBusinessCount,
  required String recommendedNextStep,
}) {
  return CurrentUser(
    id: 'usr_owner',
    email: 'owner@tavrix.local',
    fullName: 'Tavrix Owner',
    role: 'OWNER',
    memberships: hasBusiness
        ? const [
            CurrentUserMembership(
              id: 'mem_123',
              role: 'OWNER',
              isActive: true,
              business: CurrentUserMembershipBusiness(
                id: 'bus_123',
                name: 'Tavrix Cafe',
                slug: 'tavrix-cafe',
                type: 'cafe',
              ),
            ),
          ]
        : const [],
    onboarding: CurrentUserOnboarding(
      hasBusiness: hasBusiness,
      activeBusinessCount: activeBusinessCount,
      recommendedNextStep: recommendedNextStep,
    ),
  );
}

const _config = AppConfig(
  apiBaseUrl: 'https://api.example.test',
  customerWebBaseUrl: 'https://menu.example.test',
  devAuthToken: '',
  appEnv: 'development',
  enableDevAuth: false,
  clerkPublishableKey: 'pk_test_example',
);

const _createdBusiness = Business(
  id: 'bus_123',
  name: 'Tavrix Cafe',
  slug: 'tavrix-cafe',
  publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
  type: 'cafe',
  city: 'Baghdad',
  currency: 'IQD',
  language: 'ar',
);

class _QueuedMeRepository implements MeRepository {
  _QueuedMeRepository(this.users);

  final List<CurrentUser> users;
  int getMeCalls = 0;

  @override
  Future<Either<Failure, CurrentUser>> getMe() async {
    final index = getMeCalls < users.length ? getMeCalls : users.length - 1;
    getMeCalls += 1;
    return Right(users[index]);
  }
}

class _FakeBusinessRepository implements BusinessRepository {
  int createBusinessCalls = 0;

  @override
  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
  }) async {
    createBusinessCalls += 1;
    return const Right(_createdBusiness);
  }

  @override
  Future<Either<Failure, Business>> getMyBusiness() async {
    return const Right(_createdBusiness);
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
  }) async {
    return const Right(_createdBusiness);
  }
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String businessId,
  ) async {
    return Right(
      DashboardSummary(
        business: _createdBusiness,
        currentUser: const DashboardCurrentUser(
          role: 'OWNER',
          permissions: BusinessPermissions.owner(),
        ),
        counts: const DashboardCounts(),
        publicMenu: const DashboardPublicMenu(
          path: '/m/tavrix-cafe',
          url: 'https://menu.example.test/m/tavrix-cafe',
          qrPayload: 'https://menu.example.test/m/tavrix-cafe',
        ),
        onboardingHints: const DashboardOnboardingHints(),
      ),
    );
  }
}
