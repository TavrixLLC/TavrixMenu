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
  testWidgets('dashboard is business workspace first, not staff first', (
    tester,
  ) async {
    final authCubit = AuthCubit(
      getCurrentUser: const GetCurrentUser(_FakeMeRepository()),
      authSessionController: AuthSessionController(
        config: _config,
        clerkTokenProvider: ClerkTokenProvider(),
        devTokenProvider: const DevTokenProvider(''),
      ),
    );
    final dashboardCubit = DashboardCubit(
      getCurrentUser: const GetCurrentUser(_FakeMeRepository()),
      getMyBusiness: GetMyBusiness(_FakeBusinessRepository()),
      getDashboardSummary: GetDashboardSummary(_FakeDashboardRepository()),
    )..primeBusiness(_business);
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

    expect(find.text('Business Workspace'), findsOneWidget);
    expect(find.text('Business tools'), findsOneWidget);
    expect(find.text('Scan customer wallet'), findsOneWidget);
    expect(find.text('Menu Appearance'), findsNothing);
    expect(find.text('Customize menu design'), findsOneWidget);
    expect(find.text('Loyalty tools'), findsOneWidget);
    expect(find.textContaining('Staff dashboard'), findsNothing);
    expect(find.textContaining('Staff account'), findsNothing);
    expect(find.textContaining('Invite staff'), findsNothing);
    expect(find.textContaining('Create staff'), findsNothing);
  });
}

const _business = Business(
  id: 'bus_123',
  name: 'Tavrix Cafe',
  slug: 'tavrix-cafe',
  publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
);

const _config = AppConfig(
  apiBaseUrl: 'https://api.example.test',
  customerWebBaseUrl: 'https://menu.example.test',
  devAuthToken: '',
  appEnv: 'development',
  enableDevAuth: false,
  clerkPublishableKey: 'pk_test_example',
);

const _user = CurrentUser(
  id: 'usr_owner',
  email: 'owner@tavrix.local',
  fullName: 'Business Owner',
  role: 'OWNER',
  onboarding: CurrentUserOnboarding(hasBusiness: true, activeBusinessCount: 1),
);

class _FakeMeRepository implements MeRepository {
  const _FakeMeRepository();

  @override
  Future<Either<Failure, CurrentUser>> getMe() async => const Right(_user);
}

class _FakeBusinessRepository implements BusinessRepository {
  @override
  Future<Either<Failure, Business>> getMyBusiness() async =>
      const Right(_business);

  @override
  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
  }) async => const Right(_business);

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
  }) async => const Right(_business);
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String businessId,
  ) async => const Left(ServerFailure());
}
