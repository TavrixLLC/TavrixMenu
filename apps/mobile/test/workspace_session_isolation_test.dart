import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/session/workspace_session_coordinator.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/entities/current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/repositories/me_repository.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/repositories/business_repository.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/create_business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/get_my_business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/update_business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/presentation/bloc/business_setup_cubit.dart';
import 'package:tavrix_menu_mobile/features/business_setup/presentation/bloc/business_setup_state.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_action_result.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_card_state.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_customer.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_enroll_result.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_membership.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_program.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_requests.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_transaction.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/repositories/loyalty_repository.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/add_loyalty_stamps.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/create_loyalty_program.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/enroll_loyalty_customer.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/get_active_loyalty_program.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/get_loyalty_membership.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/list_loyalty_memberships.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/list_loyalty_transactions.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/redeem_loyalty_reward.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/update_loyalty_program.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/bloc/loyalty_cubit.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/bloc/loyalty_state.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/entities/menu_category.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/entities/menu_item.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/entities/reorder_menu_record.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/repositories/menu_repository.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/create_menu_category.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/create_menu_item.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/delete_menu_category.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/delete_menu_item.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/get_menu_categories.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/get_menu_items.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/reorder_menu_categories.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/reorder_menu_items.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/restore_menu_category.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/restore_menu_item.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_state.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/domain/entities/business_appearance.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/domain/entities/menu_template.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/domain/repositories/menu_appearance_repository.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/domain/usecases/get_business_appearance.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/domain/usecases/get_menu_template_catalog.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/domain/usecases/update_business_appearance.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/presentation/bloc/menu_appearance_cubit.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/presentation/bloc/menu_appearance_state.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/domain/entities/wallet_scan_result.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/domain/repositories/wallet_scan_repository.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/domain/usecases/scan_wallet_pass.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/presentation/bloc/wallet_scan_cubit.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/presentation/bloc/wallet_scan_state.dart';

void main() {
  test(
    'workspace scoped state clears between Owner A and Owner B in one process',
    () async {
      final harness = _WorkspaceHarness();
      addTearDown(harness.close);

      harness.authenticate(_ownerA);
      harness.businessRepository.currentBusiness = _businessA;
      await harness.walletScanCubit.load();
      await harness.walletScanCubit.scan('scan-input');
      harness.dashboardCubit.primeBusiness(_businessA);
      await harness.menuCubit.load();
      await harness.loyaltyCubit.load();
      await harness.menuAppearanceCubit.load();
      await harness.businessSetupCubit.submit(name: 'Business A', type: 'cafe');

      expect(harness.walletScanCubit.state.business?.id, _businessA.id);
      expect(harness.walletScanCubit.state.result, isNotNull);
      expect(harness.dashboardCubit.state.business?.id, _businessA.id);
      expect(harness.menuCubit.state.categories, isNotEmpty);
      expect(harness.loyaltyCubit.state.program, isNotNull);
      expect(harness.menuAppearanceCubit.state.templates, isNotEmpty);
      expect(
        harness.businessSetupCubit.state.status,
        BusinessSetupStatus.success,
      );

      harness.logout();

      expect(harness.walletScanCubit.state, const WalletScanState.initial());
      expect(harness.dashboardCubit.state, const DashboardState.initial());
      expect(harness.menuCubit.state, const MenuState.initial());
      expect(harness.loyaltyCubit.state, const LoyaltyState.initial());
      expect(
        harness.menuAppearanceCubit.state,
        const MenuAppearanceState.initial(),
      );
      expect(
        harness.businessSetupCubit.state,
        const BusinessSetupState.initial(),
      );

      harness.authenticate(_ownerB);
      harness.businessRepository.currentBusiness = _businessB;
      await harness.walletScanCubit.load();

      expect(harness.walletScanCubit.state.business?.id, _businessB.id);
      expect(harness.walletScanCubit.state.business?.name, _businessB.name);
      expect(harness.walletScanCubit.state.business?.id, isNot(_businessA.id));
      expect(harness.walletScanCubit.state.result, isNull);
      expect(harness.businessRepository.getMyBusinessCalls, 5);
    },
  );

  test('late Owner A scanner load is discarded after Owner B login', () async {
    final harness = _WorkspaceHarness();
    addTearDown(harness.close);

    harness.authenticate(_ownerA);
    final ownerALoad = harness.businessRepository.delayNextGetMyBusiness();
    final loadA = harness.walletScanCubit.load();
    expect(harness.walletScanCubit.state.status, WalletScanStatus.loading);

    harness.logout();
    expect(harness.walletScanCubit.state, const WalletScanState.initial());

    harness.authenticate(_ownerB);
    final ownerBLoad = harness.businessRepository.delayNextGetMyBusiness();
    final loadB = harness.walletScanCubit.load();

    ownerALoad.complete(Right(_businessA));
    await loadA;
    expect(harness.walletScanCubit.state.business?.id, isNot(_businessA.id));
    expect(harness.walletScanCubit.state.status, WalletScanStatus.loading);

    ownerBLoad.complete(Right(_businessB));
    await loadB;
    expect(harness.walletScanCubit.state.status, WalletScanStatus.ready);
    expect(harness.walletScanCubit.state.business?.id, _businessB.id);
  });

  test(
    'scanner load after reset performs a fresh business resolution',
    () async {
      final harness = _WorkspaceHarness();
      addTearDown(harness.close);

      harness.authenticate(_ownerA);
      harness.businessRepository.currentBusiness = _businessA;
      await harness.walletScanCubit.load();
      expect(harness.walletScanCubit.state.business?.id, _businessA.id);

      harness.logout();
      harness.authenticate(_ownerB);
      harness.businessRepository.currentBusiness = _businessB;
      await harness.walletScanCubit.load();

      expect(harness.businessRepository.getMyBusinessCalls, 2);
      expect(harness.walletScanCubit.state.business?.id, _businessB.id);
    },
  );

  test('old scanner error and result clear on account change', () async {
    final harness = _WorkspaceHarness();
    addTearDown(harness.close);

    harness.authenticate(_ownerA);
    harness.businessRepository.currentBusiness = _businessA;
    await harness.walletScanCubit.load();
    await harness.walletScanCubit.scan('scan-input');
    expect(harness.walletScanCubit.state.result, isNotNull);

    harness.walletScanRepository.nextScanFailure = const ServerFailure();
    await harness.walletScanCubit.scan('scan-input');
    expect(harness.walletScanCubit.state.errorMessage, isNotNull);

    harness.logout();

    expect(harness.walletScanCubit.state.result, isNull);
    expect(harness.walletScanCubit.state.errorMessage, isNull);
    expect(harness.walletScanCubit.state.business, isNull);
  });

  test('same principal auth event does not reset workspace state', () async {
    final harness = _WorkspaceHarness();
    addTearDown(harness.close);

    harness.authenticate(_ownerA);
    harness.businessRepository.currentBusiness = _businessA;
    await harness.walletScanCubit.load();

    harness.authenticate(_ownerA);

    expect(harness.walletScanCubit.state.business?.id, _businessA.id);
    expect(harness.businessRepository.getMyBusinessCalls, 1);
  });
}

class _WorkspaceHarness {
  _WorkspaceHarness()
    : businessRepository = _FakeBusinessRepository(),
      meRepository = _FakeMeRepository(),
      dashboardRepository = _FakeDashboardRepository(),
      menuRepository = _FakeMenuRepository(),
      menuAppearanceRepository = _FakeMenuAppearanceRepository(),
      loyaltyRepository = _FakeLoyaltyRepository(),
      walletScanRepository = _FakeWalletScanRepository() {
    final getMyBusiness = GetMyBusiness(businessRepository);
    final getDashboardSummary = GetDashboardSummary(dashboardRepository);

    businessSetupCubit = BusinessSetupCubit(
      createBusiness: CreateBusiness(businessRepository),
      updateBusiness: UpdateBusiness(businessRepository),
    );
    dashboardCubit = DashboardCubit(
      getCurrentUser: GetCurrentUser(meRepository),
      getMyBusiness: getMyBusiness,
      getDashboardSummary: getDashboardSummary,
    );
    menuCubit = MenuCubit(
      getMyBusiness: getMyBusiness,
      getMenuCategories: GetMenuCategories(menuRepository),
      getMenuItems: GetMenuItems(menuRepository),
      createMenuCategory: CreateMenuCategory(menuRepository),
      createMenuItem: CreateMenuItem(menuRepository),
      deleteMenuCategory: DeleteMenuCategory(menuRepository),
      restoreMenuCategory: RestoreMenuCategory(menuRepository),
      deleteMenuItem: DeleteMenuItem(menuRepository),
      restoreMenuItem: RestoreMenuItem(menuRepository),
      reorderMenuCategories: ReorderMenuCategories(menuRepository),
      reorderMenuItems: ReorderMenuItems(menuRepository),
      getDashboardSummary: getDashboardSummary,
    );
    menuAppearanceCubit = MenuAppearanceCubit(
      getMyBusiness: getMyBusiness,
      getMenuTemplateCatalog: GetMenuTemplateCatalog(menuAppearanceRepository),
      getBusinessAppearance: GetBusinessAppearance(menuAppearanceRepository),
      updateBusinessAppearance: UpdateBusinessAppearance(
        menuAppearanceRepository,
      ),
    );
    loyaltyCubit = LoyaltyCubit(
      getMyBusiness: getMyBusiness,
      getDashboardSummary: getDashboardSummary,
      getActiveProgram: GetActiveLoyaltyProgram(loyaltyRepository),
      createProgram: CreateLoyaltyProgram(loyaltyRepository),
      updateProgram: UpdateLoyaltyProgram(loyaltyRepository),
      enrollCustomer: EnrollLoyaltyCustomer(loyaltyRepository),
      listMemberships: ListLoyaltyMemberships(loyaltyRepository),
      getMembership: GetLoyaltyMembership(loyaltyRepository),
      addStamps: AddLoyaltyStamps(loyaltyRepository),
      redeemReward: RedeemLoyaltyReward(loyaltyRepository),
      listTransactions: ListLoyaltyTransactions(loyaltyRepository),
    );
    walletScanCubit = WalletScanCubit(
      getMyBusiness: getMyBusiness,
      scanWalletPass: ScanWalletPass(walletScanRepository),
      addLoyaltyStamps: AddLoyaltyStamps(loyaltyRepository),
    );
    coordinator = WorkspaceSessionCoordinator(
      dashboardCubit: dashboardCubit,
      walletScanCubit: walletScanCubit,
      menuCubit: menuCubit,
      loyaltyCubit: loyaltyCubit,
      menuAppearanceCubit: menuAppearanceCubit,
      businessSetupCubit: businessSetupCubit,
    );
  }

  final _FakeBusinessRepository businessRepository;
  final _FakeMeRepository meRepository;
  final _FakeDashboardRepository dashboardRepository;
  final _FakeMenuRepository menuRepository;
  final _FakeMenuAppearanceRepository menuAppearanceRepository;
  final _FakeLoyaltyRepository loyaltyRepository;
  final _FakeWalletScanRepository walletScanRepository;

  late final BusinessSetupCubit businessSetupCubit;
  late final DashboardCubit dashboardCubit;
  late final MenuCubit menuCubit;
  late final MenuAppearanceCubit menuAppearanceCubit;
  late final LoyaltyCubit loyaltyCubit;
  late final WalletScanCubit walletScanCubit;
  late final WorkspaceSessionCoordinator coordinator;

  void authenticate(CurrentUser user) {
    meRepository.currentUser = user;
    coordinator.handleAuthStateChange(
      AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  void logout() {
    coordinator.handleAuthStateChange(
      const AuthState(status: AuthStatus.unauthenticated),
    );
  }

  Future<void> close() async {
    await businessSetupCubit.close();
    await dashboardCubit.close();
    await menuCubit.close();
    await menuAppearanceCubit.close();
    await loyaltyCubit.close();
    await walletScanCubit.close();
  }
}

const _businessA = Business(
  id: 'business-a',
  name: 'Business A',
  slug: 'business-a',
  publicMenuUrl: '',
  role: 'OWNER',
  permissions: BusinessPermissions.owner(),
);

const _businessB = Business(
  id: 'business-b',
  name: 'Business B',
  slug: 'business-b',
  publicMenuUrl: '',
  role: 'OWNER',
  permissions: BusinessPermissions.owner(),
);

const _ownerA = CurrentUser(
  id: 'owner-a',
  email: '',
  fullName: 'Owner A',
  role: 'OWNER',
  onboarding: CurrentUserOnboarding(hasBusiness: true, activeBusinessCount: 1),
);

const _ownerB = CurrentUser(
  id: 'owner-b',
  email: '',
  fullName: 'Owner B',
  role: 'OWNER',
  onboarding: CurrentUserOnboarding(hasBusiness: true, activeBusinessCount: 1),
);

class _FakeMeRepository implements MeRepository {
  CurrentUser currentUser = _ownerA;

  @override
  Future<Either<Failure, CurrentUser>> getMe() async => Right(currentUser);
}

class _FakeBusinessRepository implements BusinessRepository {
  Business currentBusiness = _businessA;
  int getMyBusinessCalls = 0;
  final List<Completer<Either<Failure, Business>>> _delayedGets = [];

  Completer<Either<Failure, Business>> delayNextGetMyBusiness() {
    final completer = Completer<Either<Failure, Business>>();
    _delayedGets.add(completer);
    return completer;
  }

  @override
  Future<Either<Failure, Business>> getMyBusiness() {
    getMyBusinessCalls++;
    if (_delayedGets.isNotEmpty) {
      return _delayedGets.removeAt(0).future;
    }
    return Future.value(Right(currentBusiness));
  }

  @override
  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
  }) async {
    return Right(currentBusiness);
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
    return Right(currentBusiness);
  }
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String businessId,
  ) async {
    final business = businessId == _businessB.id ? _businessB : _businessA;
    return Right(
      DashboardSummary(
        business: business,
        currentUser: const DashboardCurrentUser(
          role: 'OWNER',
          permissions: BusinessPermissions.owner(),
          permissionsAvailable: true,
        ),
        counts: const DashboardCounts(activeCategories: 1, activeItems: 1),
        publicMenu: const DashboardPublicMenu(path: '', url: '', qrPayload: ''),
        onboardingHints: const DashboardOnboardingHints(
          hasCategories: true,
          hasItems: true,
        ),
      ),
    );
  }
}

class _FakeMenuRepository implements MenuRepository {
  @override
  Future<Either<Failure, List<MenuCategory>>> getCategories(
    String businessId, {
    bool includeInactive = false,
  }) async {
    return Right([
      MenuCategory(
        id: 'category-$businessId',
        businessId: businessId,
        name: 'Category $businessId',
        sortOrder: 0,
      ),
    ]);
  }

  @override
  Future<Either<Failure, List<MenuItem>>> getItems(
    String businessId, {
    bool includeInactive = false,
  }) async {
    return Right([
      MenuItem(
        id: 'item-$businessId',
        businessId: businessId,
        categoryId: 'category-$businessId',
        name: 'Item $businessId',
        description: '',
        priceCents: 1,
        isAvailable: true,
        sortOrder: 0,
      ),
    ]);
  }

  @override
  Future<Either<Failure, MenuCategory>> createCategory({
    required String businessId,
    required String name,
  }) async {
    return Right(
      MenuCategory(
        id: 'category-$businessId',
        businessId: businessId,
        name: name,
        sortOrder: 0,
      ),
    );
  }

  @override
  Future<Either<Failure, MenuItem>> createItem({
    required String businessId,
    required String categoryId,
    required String name,
    required String description,
    required int priceCents,
  }) async {
    return Right(
      MenuItem(
        id: 'item-$businessId',
        businessId: businessId,
        categoryId: categoryId,
        name: name,
        description: description,
        priceCents: priceCents,
        isAvailable: true,
        sortOrder: 0,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String id) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> deleteItem(String id) async =>
      const Right(unit);

  @override
  Future<Either<Failure, List<MenuCategory>>> reorderCategories({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) async {
    return getCategories(businessId);
  }

  @override
  Future<Either<Failure, List<MenuItem>>> reorderItems({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) async {
    return getItems(businessId);
  }

  @override
  Future<Either<Failure, Unit>> restoreCategory(String id) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> restoreItem(String id) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> updateCategory({
    required String id,
    String? name,
    int? sortOrder,
    bool? isActive,
  }) async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> updateItem({
    required String id,
    required String name,
    required String description,
    required int priceCents,
    required bool isAvailable,
  }) async {
    return const Right(unit);
  }
}

class _FakeMenuAppearanceRepository implements MenuAppearanceRepository {
  @override
  Future<Either<Failure, List<MenuTemplate>>> getTemplates() async {
    return const Right([
      MenuTemplate(
        id: 'waflo-warm',
        displayName: 'Warm',
        description: 'Warm template',
      ),
    ]);
  }

  @override
  Future<Either<Failure, BusinessAppearance>> getBusinessAppearance(
    String businessId,
  ) async {
    return Right(
      BusinessAppearance(businessId: businessId, menuTemplateId: 'waflo-warm'),
    );
  }

  @override
  Future<Either<Failure, BusinessAppearance>> updateBusinessAppearance({
    required String businessId,
    required String menuTemplateId,
  }) async {
    return Right(
      BusinessAppearance(
        businessId: businessId,
        menuTemplateId: menuTemplateId,
      ),
    );
  }
}

class _FakeLoyaltyRepository implements LoyaltyRepository {
  @override
  Future<Either<Failure, LoyaltyProgram?>> getActiveProgram(
    String businessId,
  ) async {
    return Right(_program(businessId));
  }

  @override
  Future<Either<Failure, List<LoyaltyMembership>>> listMemberships({
    required String businessId,
    String? search,
    String? status,
    bool? rewardReady,
  }) async {
    return Right([_membership(businessId)]);
  }

  @override
  Future<Either<Failure, LoyaltyMembership>> getMembership({
    required String businessId,
    required String membershipId,
  }) async {
    return Right(_membership(businessId));
  }

  @override
  Future<Either<Failure, List<LoyaltyTransaction>>> listTransactions({
    required String businessId,
    required String membershipId,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, LoyaltyActionResult>> addStamps({
    required String businessId,
    required String membershipId,
    required AddStampsRequest request,
  }) async {
    final cardState = _cardState(businessId).copyWith(stampCount: 2);
    return Right(
      LoyaltyActionResult(
        membership: _membership(businessId).copyWith(stampCount: 2),
        cardState: cardState,
      ),
    );
  }

  @override
  Future<Either<Failure, LoyaltyProgram>> createProgram({
    required String businessId,
    required LoyaltyProgramRequest request,
  }) async {
    return Right(_program(businessId));
  }

  @override
  Future<Either<Failure, LoyaltyEnrollResult>> enrollCustomer({
    required String businessId,
    required EnrollLoyaltyCustomerRequest request,
  }) async {
    return Right(
      LoyaltyEnrollResult(
        customer: const LoyaltyCustomer(id: 'customer'),
        membership: _membership(businessId),
        program: _program(businessId),
        cardState: _cardState(businessId),
      ),
    );
  }

  @override
  Future<Either<Failure, LoyaltyActionResult>> redeemReward({
    required String businessId,
    required String membershipId,
    required RedeemRewardRequest request,
  }) async {
    return Right(
      LoyaltyActionResult(
        membership: _membership(businessId),
        cardState: _cardState(businessId),
      ),
    );
  }

  @override
  Future<Either<Failure, LoyaltyProgram>> updateProgram({
    required String businessId,
    required String programId,
    required LoyaltyProgramRequest request,
  }) async {
    return Right(_program(businessId));
  }
}

class _FakeWalletScanRepository implements WalletScanRepository {
  Failure? nextScanFailure;

  @override
  Future<Either<Failure, WalletScanResult>> scan({
    required String businessId,
    required String token,
  }) async {
    final failure = nextScanFailure;
    nextScanFailure = null;
    if (failure != null) {
      return Left(failure);
    }
    return Right(
      WalletScanResult(
        membershipId: 'membership-$businessId',
        programName: 'Program $businessId',
        rewardName: 'Reward',
        stamps: 1,
        goal: 5,
        canRedeem: false,
      ),
    );
  }
}

LoyaltyProgram _program(String businessId) {
  return LoyaltyProgram(
    id: 'program-$businessId',
    businessId: businessId,
    name: 'Program $businessId',
    stampGoal: 5,
    rewardName: 'Reward',
  );
}

LoyaltyMembership _membership(String businessId) {
  return LoyaltyMembership(
    id: 'membership-$businessId',
    businessId: businessId,
    loyaltyProgramId: 'program-$businessId',
    customerId: 'customer',
    stampCount: 1,
    program: _program(businessId),
    cardState: _cardState(businessId),
  );
}

LoyaltyCardState _cardState(String businessId) {
  return LoyaltyCardState(
    stampCount: 1,
    stampGoal: 5,
    rewardReady: false,
    progressPercent: 20,
    rewardName: 'Reward',
    programName: 'Program $businessId',
  );
}
