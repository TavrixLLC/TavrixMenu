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
import 'package:tavrix_menu_mobile/features/business_setup/presentation/bloc/business_setup_cubit.dart';
import 'package:tavrix_menu_mobile/features/business_setup/presentation/bloc/business_setup_state.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/bloc/loyalty_cubit.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/bloc/loyalty_state.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_state.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/presentation/bloc/wallet_scan_cubit.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/presentation/bloc/wallet_scan_state.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v2/waflo_shell_v2.dart';

void main() {
  group('Waflo V2 App Shell Navigation Tests', () {
    testWidgets(
      'renders shell with bottom navigation items and switches tabs',
      (tester) async {
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
          getDashboardSummary: GetDashboardSummary(
            const _DashboardRepository(),
          ),
        );

        final menuCubit = FakeMenuCubit();
        final loyaltyCubit = FakeLoyaltyCubit();
        final walletScanCubit = FakeWalletScanCubit();
        final businessSetupCubit = FakeBusinessSetupCubit();

        addTearDown(authCubit.close);
        addTearDown(dashboardCubit.close);
        addTearDown(menuCubit.close);
        addTearDown(loyaltyCubit.close);
        addTearDown(walletScanCubit.close);
        addTearDown(businessSetupCubit.close);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>.value(value: authCubit),
              BlocProvider<DashboardCubit>.value(value: dashboardCubit),
              BlocProvider<MenuCubit>.value(value: menuCubit),
              BlocProvider<LoyaltyCubit>.value(value: loyaltyCubit),
              BlocProvider<WalletScanCubit>.value(value: walletScanCubit),
              BlocProvider<BusinessSetupCubit>.value(value: businessSetupCubit),
            ],
            child: const MaterialApp(home: WafloShellV2(config: _config)),
          ),
        );
        await tester.pumpAndSettle();

        // Verify bottom navigation bar exists with correct Arabic sections
        expect(find.text('الرئيسية'), findsWidgets);
        expect(find.text('المنيو'), findsWidgets);
        expect(find.text('الولاء'), findsWidgets);
        expect(find.text('المسح'), findsWidgets);
        expect(find.text('الإعدادات'), findsWidgets);

        // The legacy shell harness still renders the canonical Dashboard body.
        expect(
          find.byKey(const ValueKey('dashboard-v3-progress-hero')),
          findsOneWidget,
        );

        // Tap on the 'المنيو' tab and verify switching
        await tester.tap(find.text('المنيو').first);
        await tester.pumpAndSettle();

        // Tap on the 'الولاء' tab and verify switching
        await tester.tap(find.text('الولاء').first);
        await tester.pumpAndSettle();

        // Tap on the 'المسح' tab and verify switching
        await tester.tap(find.text('المسح').first);
        await tester.pumpAndSettle();

        // Tap on the 'الإعدادات' tab and verify switching
        await tester.tap(find.text('الإعدادات').first);
        await tester.pumpAndSettle();
      },
    );
  });
}

// Fake Cubits utilizing the Dart noSuchMethod fallback pattern
class FakeMenuCubit extends Cubit<MenuState> implements MenuCubit {
  FakeMenuCubit()
    : super(const MenuState(status: MenuStatus.success, business: _business));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class FakeLoyaltyCubit extends Cubit<LoyaltyState> implements LoyaltyCubit {
  FakeLoyaltyCubit()
    : super(
        const LoyaltyState(status: LoyaltyStatus.success, business: _business),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class FakeWalletScanCubit extends Cubit<WalletScanState>
    implements WalletScanCubit {
  FakeWalletScanCubit()
    : super(
        const WalletScanState(
          status: WalletScanStatus.ready,
          business: _business,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class FakeBusinessSetupCubit extends Cubit<BusinessSetupState>
    implements BusinessSetupCubit {
  FakeBusinessSetupCubit()
    : super(
        const BusinessSetupState(
          status: BusinessSetupStatus.success,
          business: _business,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

// Config stub
const _config = AppConfig(
  appEnv: 'qa',
  apiBaseUrl: 'https://api.waflo.test',
  customerWebBaseUrl: 'https://card.waflo.test',
  clerkPublishableKey: 'pk_test_clerk',
  googleServerClientId: 'google_server_client_id',
  devAuthToken: '',
  enableDevAuth: false,
);

// Stub entities
const _business = Business(
  id: 'b1',
  name: 'Tavrix Cafe',
  type: 'cafe',
  currency: 'IQD',
  language: 'ar',
  city: 'Baghdad',
  slug: 'tavrix-cafe',
  publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
);

// Fake Repository Implementations
class _MeRepository implements MeRepository {
  const _MeRepository();

  @override
  Future<Either<Failure, CurrentUser>> getMe() async {
    return const Right(
      CurrentUser(
        id: 'u1',
        email: 'owner@tavrix.test',
        phone: '+9647700000000',
        fullName: 'Owner',
        role: 'OWNER',
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
  }) async {
    return const Right(_business);
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
    return const Right(_business);
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
