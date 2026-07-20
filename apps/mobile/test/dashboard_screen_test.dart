import 'dart:async';
import 'dart:io';

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
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_bottom_navigation.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_inline_error.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_skeleton.dart';

void main() {
  testWidgets('approved one-category zero-product hierarchy is honest', (
    tester,
  ) async {
    await _pumpDashboard(
      tester,
      dashboardRepository: const _ZeroProductsDashboardRepository(),
    );

    expect(find.text('خلّ منيوك جاهز للزبائن'), findsOneWidget);
    expect(find.text('إضافة منتج'), findsOneWidget);
    expect(find.text('2 من 4 خطوات جاهزة'), findsWidgets);
    expect(find.text('المنتجات'), findsOneWidget);
    expect(find.text('الأقسام'), findsOneWidget);
    expect(find.text('غير متاح'), findsNWidgets(2));
    expect(find.text(_business.name), findsNothing);
    expect(find.text('الطلبات'), findsNothing);
    expect(find.text('المبيعات'), findsNothing);
    expect(find.text('Subscription'), findsNothing);
    expect(find.byKey(const ValueKey('dashboard-v3-content')), findsOneWidget);
  });

  testWidgets('real category and product values come from dashboard summary', (
    tester,
  ) async {
    await _pumpDashboard(
      tester,
      dashboardRepository: const _DashboardRepository(),
    );

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('dashboard-v3-products-metric')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('dashboard-v3-categories-metric')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('loading never renders fabricated zero metrics', (tester) async {
    final pending = _PendingDashboardRepository();
    await _pumpDashboard(tester, dashboardRepository: pending, settle: false);
    await tester.pump();

    expect(find.byType(WafloSkeleton), findsWidgets);
    expect(
      find.byKey(const ValueKey('dashboard-v3-products-metric')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('dashboard-v3-categories-metric')),
      findsNothing,
    );
    pending.complete(const Left(ServerFailure()));
  });

  testWidgets('summary failure renders an honest retry error', (tester) async {
    await _pumpDashboard(
      tester,
      dashboardRepository: const _FailingDashboardRepository(),
    );

    expect(find.byType(WafloInlineError), findsOneWidget);
    expect(
      find.byKey(const ValueKey('dashboard-v3-summary-error')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('dashboard-v3-products-metric')),
      findsNothing,
    );
  });

  testWidgets('dashboard actions request only canonical shell destinations', (
    tester,
  ) async {
    final selected = <WafloWorkspaceDestination>[];
    await _pumpDashboard(
      tester,
      dashboardRepository: const _ZeroProductsDashboardRepository(),
      onDestinationSelected: selected.add,
    );

    final primaryButton = tester.widget<ElevatedButton>(
      find.descendant(
        of: find.byKey(const ValueKey('dashboard-v3-primary-menu-action')),
        matching: find.byType(ElevatedButton),
      ),
    );
    primaryButton.onPressed!();
    await tester.pump();
    expect(selected.last, WafloWorkspaceDestination.menu);

    for (final entry in <Key, WafloWorkspaceDestination>{
      const ValueKey('dashboard-v3-categories-action'):
          WafloWorkspaceDestination.menu,
      const ValueKey('dashboard-v3-scanner-action'):
          WafloWorkspaceDestination.scanner,
      const ValueKey('dashboard-v3-loyalty-action'):
          WafloWorkspaceDestination.loyalty,
    }.entries) {
      final ink = tester.widget<InkWell>(
        find.descendant(
          of: find.byKey(entry.key),
          matching: find.byType(InkWell),
        ),
      );
      ink.onTap!();
      await tester.pump();
      expect(selected.last, entry.value);
    }
  });

  testWidgets('unsupported notification and unready public menu are disabled', (
    tester,
  ) async {
    var publicMenuOpened = false;
    await _pumpDashboard(
      tester,
      dashboardRepository: const _ZeroProductsDashboardRepository(),
      onOpenPublicMenu: () => publicMenuOpened = true,
    );

    final notificationInk = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const ValueKey('dashboard-v3-notification-action')),
        matching: find.byType(InkWell),
      ),
    );
    expect(notificationInk.onTap, isNull);
    expect(find.text('يتفعّل عند توفر إشعارات العملاء'), findsOneWidget);

    final openMenuButton = tester.widget<OutlinedButton>(
      find.descendant(
        of: find.byKey(const ValueKey('dashboard-v3-open-menu-action')),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(openMenuButton.onPressed, isNull);
    expect(publicMenuOpened, isFalse);
    expect(
      find.byKey(const ValueKey('dashboard-v3-open-menu-helper')),
      findsOneWidget,
    );
  });

  testWidgets('ready public menu uses the supplied real-route callback', (
    tester,
  ) async {
    var publicMenuOpened = false;
    await _pumpDashboard(
      tester,
      dashboardRepository: const _DashboardRepository(),
      onOpenPublicMenu: () => publicMenuOpened = true,
    );

    final openMenuButton = tester.widget<OutlinedButton>(
      find.descendant(
        of: find.byKey(const ValueKey('dashboard-v3-open-menu-action')),
        matching: find.byType(OutlinedButton),
      ),
    );
    openMenuButton.onPressed!();
    expect(publicMenuOpened, isTrue);
  });

  testWidgets('recent activity uses an honest unavailable state', (
    tester,
  ) async {
    await _pumpDashboard(
      tester,
      dashboardRepository: const _ZeroProductsDashboardRepository(),
    );

    expect(
      find.byKey(const ValueKey('dashboard-v3-activity-unavailable')),
      findsOneWidget,
    );
    expect(find.text('النشاط الأخير غير متاح حالياً'), findsOneWidget);
  });

  testWidgets('Arabic RTL content does not overflow at 360px', (tester) async {
    await _pumpDashboard(
      tester,
      dashboardRepository: const _ZeroProductsDashboardRepository(),
      width: 360,
      textScale: 1.3,
    );

    expect(tester.takeException(), isNull);
  });

  test(
    'dashboard source has no legacy top-level navigation or identity card',
    () {
      final source = File(
        'lib/features/dashboard/presentation/pages/dashboard_screen.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('BusinessHeaderCard')));
      expect(source, isNot(contains('_DashboardActionCard')));
      expect(source, isNot(contains('WafloShellV2')));
      expect(source, isNot(contains('AppRouteNames.menu')));
      expect(source, isNot(contains('AppRouteNames.walletScan')));
      expect(source, isNot(contains('AppRouteNames.loyalty')));
      expect(source, isNot(contains('Navigator.of')));
      expect(source, isNot(contains('Image.network')));
    },
  );
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required DashboardRepository dashboardRepository,
  ValueChanged<WafloWorkspaceDestination>? onDestinationSelected,
  VoidCallback? onOpenPublicMenu,
  bool settle = true,
  double width = 390,
  double textScale = 1,
}) async {
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
    getDashboardSummary: GetDashboardSummary(dashboardRepository),
  );
  addTearDown(authCubit.close);
  addTearDown(dashboardCubit.close);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<DashboardCubit>.value(value: dashboardCubit),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 800),
            textScaler: TextScaler.linear(textScale),
          ),
          child: SizedBox(
            width: width,
            child: DashboardScreen(
              embeddedInWorkspaceShell: true,
              onDestinationSelected: onDestinationSelected,
              onOpenPublicMenu: onOpenPublicMenu,
            ),
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
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
          hasCategories: true,
          hasItems: true,
          hasPublicMenuReady: true,
          recommendedNextStep: 'OPEN_DASHBOARD',
        ),
      ),
    );
  }
}

class _ZeroProductsDashboardRepository implements DashboardRepository {
  const _ZeroProductsDashboardRepository();

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
        counts: DashboardCounts(activeCategories: 1),
        publicMenu: DashboardPublicMenu(
          path: '/m/tavrix-cafe',
          url: 'https://menu.example.test/m/tavrix-cafe',
          qrPayload: 'https://menu.example.test/m/tavrix-cafe',
        ),
        onboardingHints: DashboardOnboardingHints(
          hasCategories: true,
          recommendedNextStep: 'CREATE_ITEM',
        ),
      ),
    );
  }
}

class _FailingDashboardRepository implements DashboardRepository {
  const _FailingDashboardRepository();

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String businessId,
  ) async {
    return const Left(ServerFailure());
  }
}

class _PendingDashboardRepository implements DashboardRepository {
  final _completer = Completer<Either<Failure, DashboardSummary>>();

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String businessId,
  ) {
    return _completer.future;
  }

  void complete(Either<Failure, DashboardSummary> result) {
    if (!_completer.isCompleted) {
      _completer.complete(result);
    }
  }
}
