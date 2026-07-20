import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/constants/app_spacing.dart';
import 'package:tavrix_menu_mobile/core/copy/pilot_arabic_copy.dart';
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
import 'package:tavrix_menu_mobile/shared/widgets/app_scaffold.dart';
import 'package:tavrix_menu_mobile/shared/widgets/app_text_field.dart';
import 'package:tavrix_menu_mobile/shared/widgets/business_header_card.dart';
import 'package:tavrix_menu_mobile/shared/widgets/error_view.dart';
import 'package:tavrix_menu_mobile/shared/widgets/loading_view.dart';
import 'package:tavrix_menu_mobile/shared/widgets/scanner_action_panel.dart';

void main() {
  testWidgets('AppScaffold keeps standalone chrome by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppScaffold(title: 'Workspace', child: Text('Content')),
      ),
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Workspace'), findsOneWidget);
  });

  testWidgets('AppScaffold embedded mode omits only local app bar', (
    tester,
  ) async {
    const contentKey = ValueKey('embeddedContent');

    await tester.pumpWidget(
      const MaterialApp(
        home: AppScaffold(
          title: 'Workspace',
          embeddedInWorkspaceShell: true,
          child: SizedBox(key: contentKey, height: 20),
        ),
      ),
    );

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Workspace'), findsNothing);
    expect(tester.getTopLeft(find.byKey(contentKey)).dy, AppSpacing.md);
  });

  testWidgets('all five destinations keep standalone app bars by default', (
    tester,
  ) async {
    for (final screen in const <Widget>[
      DashboardScreen(),
      MenuScreen(),
      StaffScannerScreen(),
      LoyaltyScreen(),
      BusinessProfileScreen(),
    ]) {
      await _pumpScreen(tester, screen);
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('dashboard embedded mode has V3 content without local identity', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      const DashboardScreen(embeddedInWorkspaceShell: true),
    );

    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(BusinessHeaderCard), findsNothing);
    expect(
      find.byKey(const ValueKey('dashboard-v3-progress-hero')),
      findsOneWidget,
    );

    await _pumpScreen(tester, const DashboardScreen());
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(BusinessHeaderCard), findsNothing);
  });

  testWidgets('menu and loyalty hide workspace identity only when embedded', (
    tester,
  ) async {
    await _pumpScreen(tester, const MenuScreen());
    expect(find.text(_business.name), findsOneWidget);

    await _pumpScreen(tester, const MenuScreen(embeddedInWorkspaceShell: true));
    expect(find.byType(AppBar), findsNothing);
    expect(find.text(_business.name), findsNothing);
    expect(find.text('Menu appearance'), findsOneWidget);

    await _pumpScreen(tester, const LoyaltyScreen());
    expect(find.text(_business.name), findsOneWidget);

    await _pumpScreen(
      tester,
      const LoyaltyScreen(embeddedInWorkspaceShell: true),
    );
    expect(find.byType(AppBar), findsNothing);
    expect(find.text(_business.name), findsNothing);
    expect(find.text(PilotArabicCopy.scanCustomerCard), findsOneWidget);
  });

  testWidgets('scanner and profile retain functional embedded content', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      const StaffScannerScreen(embeddedInWorkspaceShell: true),
    );
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(ScannerActionPanel), findsOneWidget);
    expect(find.byKey(const ValueKey('walletScanTokenField')), findsOneWidget);

    await _pumpScreen(
      tester,
      const BusinessProfileScreen(embeddedInWorkspaceShell: true),
    );
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(AppTextField), findsNWidgets(3));
    expect(find.text(PilotArabicCopy.saveChanges), findsOneWidget);
  });

  testWidgets('embedded screens preserve honest loading and error states', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      const MenuScreen(embeddedInWorkspaceShell: true),
      menuState: const MenuState(status: MenuStatus.loading),
      settle: false,
    );
    expect(find.byType(LoadingView), findsOneWidget);

    await _pumpScreen(
      tester,
      const LoyaltyScreen(embeddedInWorkspaceShell: true),
      loyaltyState: const LoyaltyState(
        status: LoyaltyStatus.failure,
        errorMessage: 'Could not load loyalty.',
      ),
    );
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Could not load loyalty.'), findsOneWidget);
  });

  testWidgets('embedded destinations retain RTL and fit narrow mobile width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpScreen(
      tester,
      const DashboardScreen(embeddedInWorkspaceShell: true),
    );

    final directions = tester.widgetList<Directionality>(
      find.descendant(
        of: find.byType(DashboardScreen),
        matching: find.byType(Directionality),
      ),
    );
    expect(
      directions.any(
        (direction) => direction.textDirection == TextDirection.rtl,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  Widget screen, {
  MenuState menuState = const MenuState(
    status: MenuStatus.success,
    business: _business,
  ),
  LoyaltyState loyaltyState = const LoyaltyState(
    status: LoyaltyStatus.success,
    business: _business,
  ),
  bool settle = true,
}) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => _FakeAuthCubit()),
        BlocProvider<DashboardCubit>(create: (_) => _FakeDashboardCubit()),
        BlocProvider<MenuCubit>(create: (_) => _FakeMenuCubit(menuState)),
        BlocProvider<LoyaltyCubit>(
          create: (_) => _FakeLoyaltyCubit(loyaltyState),
        ),
        BlocProvider<WalletScanCubit>(create: (_) => _FakeWalletScanCubit()),
        BlocProvider<BusinessSetupCubit>(
          create: (_) => _FakeBusinessSetupCubit(),
        ),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

class _FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _FakeAuthCubit() : super(const AuthState.initial());

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeDashboardCubit extends Cubit<DashboardState>
    implements DashboardCubit {
  _FakeDashboardCubit()
    : super(
        const DashboardState(
          status: DashboardStatus.success,
          business: _business,
          summary: _dashboardSummary,
        ),
      );

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
  _FakeWalletScanCubit()
    : super(
        const WalletScanState(
          status: WalletScanStatus.ready,
          business: _business,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeBusinessSetupCubit extends Cubit<BusinessSetupState>
    implements BusinessSetupCubit {
  _FakeBusinessSetupCubit()
    : super(
        const BusinessSetupState(
          status: BusinessSetupStatus.success,
          business: _business,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

const _business = Business(
  id: 'business-test',
  name: 'Fixture Workspace',
  type: 'restaurant',
  currency: 'IQD',
  language: 'ar',
  city: 'Baghdad',
  slug: 'fixture-workspace',
  publicMenuUrl: 'https://menu.example.test/m/fixture-workspace',
  permissions: BusinessPermissions.owner(),
);

const _dashboardSummary = DashboardSummary(
  business: _business,
  currentUser: DashboardCurrentUser(
    role: 'OWNER',
    permissions: BusinessPermissions.owner(),
    permissionsAvailable: true,
  ),
  counts: DashboardCounts(activeCategories: 1),
  publicMenu: DashboardPublicMenu(
    path: '/m/fixture-workspace',
    url: 'https://menu.example.test/m/fixture-workspace',
    qrPayload: 'https://menu.example.test/m/fixture-workspace',
  ),
  onboardingHints: DashboardOnboardingHints(
    hasCategories: true,
    recommendedNextStep: 'CREATE_ITEM',
  ),
);
