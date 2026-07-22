import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/app/router/app_router.dart';
import 'package:tavrix_menu_mobile/app/router/route_names.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/entities/current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/presentation/bloc/business_setup_cubit.dart';
import 'package:tavrix_menu_mobile/features/business_setup/presentation/bloc/business_setup_state.dart';
import 'package:tavrix_menu_mobile/features/business_setup/presentation/pages/business_profile_screen.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/bloc/loyalty_cubit.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/bloc/loyalty_state.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/pages/loyalty_screen.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_state.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/pages/menu_screen.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/presentation/bloc/wallet_scan_cubit.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/presentation/bloc/wallet_scan_state.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/presentation/pages/staff_scanner_screen.dart';
import 'package:tavrix_menu_mobile/shared/widgets/app_text_field.dart';
import 'package:tavrix_menu_mobile/shared/widgets/business_header_card.dart';
import 'package:tavrix_menu_mobile/shared/widgets/scanner_action_panel.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_bottom_navigation.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_inline_error.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_shell_v3.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_skeleton.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_workspace_header.dart';

void main() {
  testWidgets('dashboard route composes all five real embedded destinations', (
    tester,
  ) async {
    final harness = _BlocHarness.ready();
    addTearDown(harness.close);

    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();

    expect(find.byType(WafloShellV3), findsOneWidget);
    expect(
      tester
          .widget<DashboardScreen>(
            find.byType(DashboardScreen, skipOffstage: false),
          )
          .embeddedInWorkspaceShell,
      isTrue,
    );
    expect(
      tester
          .widget<MenuScreen>(find.byType(MenuScreen, skipOffstage: false))
          .embeddedInWorkspaceShell,
      isTrue,
    );
    expect(
      tester
          .widget<StaffScannerScreen>(
            find.byType(StaffScannerScreen, skipOffstage: false),
          )
          .embeddedInWorkspaceShell,
      isTrue,
    );
    expect(
      tester
          .widget<LoyaltyScreen>(
            find.byType(LoyaltyScreen, skipOffstage: false),
          )
          .embeddedInWorkspaceShell,
      isTrue,
    );
    expect(
      tester
          .widget<BusinessProfileScreen>(
            find.byType(BusinessProfileScreen, skipOffstage: false),
          )
          .embeddedInWorkspaceShell,
      isTrue,
    );

    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(BusinessHeaderCard), findsNothing);
    expect(find.text(_businessA.name), findsOneWidget);
  });

  testWidgets('real scanner and settings content remains available', (
    tester,
  ) async {
    final harness = _BlocHarness.ready();
    addTearDown(harness.close);
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();

    await tester.tap(_destination(WafloWorkspaceDestination.scanner));
    await tester.pump();
    expect(find.byType(ScannerActionPanel), findsOneWidget);
    expect(find.byKey(const ValueKey('walletScanTokenField')), findsOneWidget);

    await tester.tap(_destination(WafloWorkspaceDestination.settings));
    await tester.pump();
    expect(find.byType(AppTextField), findsNWidgets(3));
  });

  testWidgets('dashboard actions switch canonical shell destinations', (
    tester,
  ) async {
    final harness = _BlocHarness.ready();
    addTearDown(harness.close);
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();

    tester
        .widget<ElevatedButton>(
          find.descendant(
            of: find.byKey(const ValueKey('dashboard-v3-primary-menu-action')),
            matching: find.byType(ElevatedButton),
          ),
        )
        .onPressed!();
    await tester.pump();
    expect(find.byType(MenuScreen), findsOneWidget);
    expect(find.text(_businessA.name), findsOneWidget);

    await tester.tap(_destination(WafloWorkspaceDestination.home));
    await tester.pump();
    _quickActionInk(tester, 'dashboard-v3-scanner-action').onTap!();
    await tester.pump();
    expect(find.byType(StaffScannerScreen), findsOneWidget);

    await tester.tap(_destination(WafloWorkspaceDestination.home));
    await tester.pump();
    _quickActionInk(tester, 'dashboard-v3-loyalty-action').onTap!();
    await tester.pump();
    expect(find.byType(LoyaltyScreen), findsOneWidget);
    expect(find.text(_businessA.name), findsOneWidget);
  });

  testWidgets('loading and failure never display stale workspace identity', (
    tester,
  ) async {
    final harness = _BlocHarness.loading();
    addTearDown(harness.close);
    await tester.pumpWidget(harness.app());
    await tester.pump();

    expect(find.byType(WafloWorkspaceHeader), findsNothing);
    expect(find.byType(WafloSkeleton), findsWidgets);
    expect(find.text(_businessA.name), findsNothing);

    harness.dashboard.setState(
      const DashboardState(
        status: DashboardStatus.failure,
        errorMessage: 'Workspace unavailable.',
      ),
    );
    await tester.pump();

    expect(find.byType(WafloWorkspaceHeader), findsNothing);
    expect(find.byType(WafloInlineError), findsWidgets);
    expect(find.text(_businessA.name), findsNothing);
  });

  testWidgets(
    'principal change clears identity and resets Home before B loads',
    (tester) async {
      final harness = _BlocHarness.ready();
      addTearDown(harness.close);
      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();

      await tester.tap(_destination(WafloWorkspaceDestination.menu));
      await tester.pump();
      expect(find.byType(MenuScreen), findsOneWidget);

      harness.auth.setState(_authenticated(_userB));
      await tester.pump();

      expect(find.text(_businessA.name), findsNothing);
      expect(find.byType(WafloWorkspaceHeader), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);

      harness.dashboard.setState(
        const DashboardState(
          status: DashboardStatus.success,
          user: _userB,
          business: _businessB,
        ),
      );
      await tester.pump();

      expect(find.text(_businessA.name), findsNothing);
      expect(find.text(_businessB.name), findsOneWidget);
      expect(find.byType(DashboardScreen), findsOneWidget);

      harness.auth.setState(
        const AuthState(status: AuthStatus.unauthenticated),
      );
      await tester.pump();
      expect(find.text(_businessB.name), findsNothing);
      expect(find.byType(WafloWorkspaceHeader), findsNothing);
    },
  );

  test('router preserves guided setup and fail-closed business resolution', () {
    final routerSource = File(
      'lib/app/router/app_router.dart',
    ).readAsStringSync();
    final resolverSource = File(
      'lib/features/business_setup/data/datasources/business_remote_data_source.dart',
    ).readAsStringSync();

    expect(routerSource, contains('AppRouteNames.businessSetup'));
    expect(routerSource, contains('WafloFirstRunWizardScreen'));
    expect(resolverSource, contains('businesses.length > 1'));
    expect(resolverSource, contains('businesses.single'));
    expect(routerSource, isNot(contains('businesses.first')));
  });

  test(
    'composition adds no network avatar or fake notification capability',
    () {
      final source = File('lib/app/router/app_router.dart').readAsStringSync();

      expect(source, isNot(contains('Image.network')));
      expect(source, isNot(contains('NetworkImage')));
      expect(source, isNot(contains('onNotificationPressed:')));
      expect(source, isNot(contains('unreadCount:')));
    },
  );

  test('scanner and settings sources use the localization foundation', () {
    const paths = [
      'apps/mobile/lib/features/staff_scanner/presentation/pages/staff_scanner_screen.dart',
      'apps/mobile/lib/features/business_setup/presentation/pages/business_profile_screen.dart',
    ];

    for (final path in paths) {
      final source = File('../../$path').readAsStringSync();
      expect(source, contains('context.l10n'));
      expect(source, isNot(contains('textDirection: TextDirection.rtl')));
    }
  });
}

Finder _destination(WafloWorkspaceDestination destination) {
  return find.byKey(ValueKey('waflo-bottom-navigation-${destination.name}'));
}

InkWell _quickActionInk(WidgetTester tester, String key) {
  return tester.widget<InkWell>(
    find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(InkWell),
    ),
  );
}

AuthState _authenticated(CurrentUser user) {
  return AuthState(status: AuthStatus.authenticated, user: user);
}

class _BlocHarness {
  _BlocHarness._({
    required this.auth,
    required this.dashboard,
    required this.menu,
    required this.loyalty,
    required this.walletScan,
    required this.businessSetup,
  });

  factory _BlocHarness.ready() {
    return _BlocHarness._(
      auth: _FakeAuthCubit(_authenticated(_userA)),
      dashboard: _FakeDashboardCubit(
        const DashboardState(
          status: DashboardStatus.success,
          user: _userA,
          business: _businessA,
          summary: _summaryA,
        ),
      ),
      menu: _FakeMenuCubit(
        const MenuState(
          status: MenuStatus.success,
          business: _businessA,
          permissions: BusinessPermissions.owner(),
        ),
      ),
      loyalty: _FakeLoyaltyCubit(
        const LoyaltyState(
          status: LoyaltyStatus.success,
          business: _businessA,
          currentRole: 'OWNER',
          permissions: BusinessPermissions.owner(),
        ),
      ),
      walletScan: _FakeWalletScanCubit(
        const WalletScanState(
          status: WalletScanStatus.ready,
          business: _businessA,
        ),
      ),
      businessSetup: _FakeBusinessSetupCubit(
        const BusinessSetupState(
          status: BusinessSetupStatus.success,
          business: _businessA,
        ),
      ),
    );
  }

  factory _BlocHarness.loading() {
    final harness = _BlocHarness.ready();
    harness.dashboard.setState(
      const DashboardState(status: DashboardStatus.loading),
    );
    return harness;
  }

  final _FakeAuthCubit auth;
  final _FakeDashboardCubit dashboard;
  final _FakeMenuCubit menu;
  final _FakeLoyaltyCubit loyalty;
  final _FakeWalletScanCubit walletScan;
  final _FakeBusinessSetupCubit businessSetup;

  Widget app() {
    final routes = AppRouter.routes(config: _config)
      ..remove(Navigator.defaultRouteName);
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: auth),
        BlocProvider<DashboardCubit>.value(value: dashboard),
        BlocProvider<MenuCubit>.value(value: menu),
        BlocProvider<LoyaltyCubit>.value(value: loyalty),
        BlocProvider<WalletScanCubit>.value(value: walletScan),
        BlocProvider<BusinessSetupCubit>.value(value: businessSetup),
      ],
      child: MaterialApp(
        routes: routes,
        home: Builder(
          builder: (context) => AppRouter.routes(
            config: _config,
          )[AppRouteNames.dashboard]!(context),
        ),
      ),
    );
  }

  Future<void> close() async {
    await auth.close();
    await dashboard.close();
    await menu.close();
    await loyalty.close();
    await walletScan.close();
    await businessSetup.close();
  }
}

class _FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _FakeAuthCubit(super.state);

  void setState(AuthState state) => emit(state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeDashboardCubit extends Cubit<DashboardState>
    implements DashboardCubit {
  _FakeDashboardCubit(super.state);

  void setState(DashboardState state) => emit(state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeMenuCubit extends Cubit<MenuState> implements MenuCubit {
  _FakeMenuCubit(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeLoyaltyCubit extends Cubit<LoyaltyState> implements LoyaltyCubit {
  _FakeLoyaltyCubit(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeWalletScanCubit extends Cubit<WalletScanState>
    implements WalletScanCubit {
  _FakeWalletScanCubit(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeBusinessSetupCubit extends Cubit<BusinessSetupState>
    implements BusinessSetupCubit {
  _FakeBusinessSetupCubit(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

const _config = AppConfig(
  appEnv: 'qa',
  apiBaseUrl: 'https://api.example.test',
  customerWebBaseUrl: 'https://card.example.test',
  clerkPublishableKey: 'pk_test_example',
  devAuthToken: '',
  enableDevAuth: false,
);

const _userA = CurrentUser(
  id: 'principal-a',
  email: '',
  fullName: 'Owner A',
  role: 'OWNER',
);

const _userB = CurrentUser(
  id: 'principal-b',
  email: '',
  fullName: 'Owner B',
  role: 'OWNER',
);

const _businessA = Business(
  id: 'workspace-a',
  name: 'مساحة اختبار ألف',
  slug: 'workspace-a',
  publicMenuUrl: 'https://menu.example.test/m/workspace-a',
  permissions: BusinessPermissions.owner(),
);

const _businessB = Business(
  id: 'workspace-b',
  name: 'مساحة اختبار باء',
  slug: 'workspace-b',
  publicMenuUrl: 'https://menu.example.test/m/workspace-b',
  permissions: BusinessPermissions.owner(),
);

const _summaryA = DashboardSummary(
  business: _businessA,
  currentUser: DashboardCurrentUser(
    role: 'OWNER',
    permissions: BusinessPermissions.owner(),
    permissionsAvailable: true,
  ),
  counts: DashboardCounts(activeCategories: 1),
  publicMenu: DashboardPublicMenu(
    path: '/m/workspace-a',
    url: 'https://menu.example.test/m/workspace-a',
    qrPayload: 'https://menu.example.test/m/workspace-a',
  ),
  onboardingHints: DashboardOnboardingHints(
    hasCategories: true,
    recommendedNextStep: 'CREATE_ITEM',
  ),
);
