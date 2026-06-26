import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
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
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/get_my_business.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/pages/dashboard_screen.dart';

void main() {
  testWidgets('dashboard is workspace-first and shows wallet scan action', (
    tester,
  ) async {
    final authCubit = AuthCubit(
      getCurrentUser: GetCurrentUser(const _MeRepository()),
      authSessionController: AuthSessionController(
        config: _config,
        clerkTokenProvider: ClerkTokenProvider(),
        devTokenProvider: const DevTokenProvider(''),
      ),
    );
    final dashboardCubit = DashboardCubit(
      getCurrentUser: GetCurrentUser(const _MeRepository()),
      getMyBusiness: GetMyBusiness(const _BusinessRepository()),
      getDashboardSummary: GetDashboardSummary(const _DashboardRepository()),
    );
    addTearDown(authCubit.close);
    addTearDown(dashboardCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<DashboardCubit>.value(value: dashboardCubit),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Waflo Workspace'), findsOneWidget);
    expect(find.text('Scan customer wallet'), findsOneWidget);
    expect(find.text('Business Workspace'), findsWidgets);
    expect(find.text('Staff Dashboard'), findsNothing);
    expect(find.text('Staff loyalty scan'), findsNothing);
    expect(
      find.textContaining(RegExp('customer signup', caseSensitive: false)),
      findsNothing,
    );
    expect(
      find.textContaining(RegExp('staff invite', caseSensitive: false)),
      findsNothing,
    );
  });
}

const _config = AppConfig(
  apiBaseUrl: 'https://api.example.test',
  customerWebBaseUrl: 'https://menu.example.test',
  devAuthToken: '',
  appEnv: 'development',
  enableDevAuth: false,
  clerkPublishableKey: 'pk_test_example',
);

const _business = Business(
  id: 'bus_123',
  name: 'Tavrix Cafe',
  slug: 'tavrix-cafe',
  publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
  permissions: BusinessPermissions.owner(),
);

class _MeRepository implements MeRepository {
  const _MeRepository();

  @override
  Future<Either<Failure, CurrentUser>> getMe() async {
    return const Right(
      CurrentUser(
        id: 'usr_owner',
        email: '',
        fullName: 'Owner',
        role: 'OWNER',
        onboarding: CurrentUserOnboarding(
          hasBusiness: true,
          activeBusinessCount: 1,
          recommendedNextStep: 'OPEN_DASHBOARD',
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
          role: 'OWNER',
          permissions: BusinessPermissions.owner(),
          permissionsAvailable: true,
        ),
        counts: DashboardCounts(activeCategories: 1, availableItems: 1),
        publicMenu: DashboardPublicMenu(
          path: '/m/tavrix-cafe',
          url: 'https://menu.example.test/m/tavrix-cafe',
          qrPayload: 'https://menu.example.test/m/tavrix-cafe',
        ),
        onboardingHints: DashboardOnboardingHints(
          recommendedNextStep: 'OPEN_DASHBOARD',
        ),
      ),
    );
  }
}
