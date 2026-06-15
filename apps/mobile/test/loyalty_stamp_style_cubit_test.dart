import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/repositories/business_repository.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/get_my_business.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_action_result.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_enroll_result.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_membership.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_program.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_requests.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_stamp_style.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_transaction.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/repositories/loyalty_repository.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/add_loyalty_stamps.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/create_loyalty_program.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/enroll_loyalty_customer.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/get_active_loyalty_program.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/get_loyalty_membership.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/get_loyalty_stamp_presets.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/get_loyalty_stamp_style.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/list_loyalty_memberships.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/list_loyalty_transactions.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/redeem_loyalty_reward.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/update_loyalty_program.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/update_loyalty_stamp_style.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/bloc/loyalty_cubit.dart';

void main() {
  test('load presets success stores options', () async {
    final loyaltyRepository = _FakeLoyaltyRepository();
    final cubit = _cubit(loyaltyRepository: loyaltyRepository);

    await cubit.loadStampPresets();

    expect(cubit.state.stampPresets?.presets, hasLength(2));
    expect(cubit.state.stampPresets?.layoutVariants, ['MODERN', 'COMPACT']);

    await cubit.close();
  });

  test('load stamp style success stores active business style', () async {
    final loyaltyRepository = _FakeLoyaltyRepository();
    final cubit = _cubit(loyaltyRepository: loyaltyRepository);

    await cubit.load();

    expect(cubit.state.stampStyle?.presetKey, 'COFFEE');
    expect(cubit.state.stampStyle?.layoutVariant, 'MODERN');
    expect(cubit.state.stampStyleError, isNull);

    await cubit.close();
  });

  test('update stamp style success updates local state', () async {
    final loyaltyRepository = _FakeLoyaltyRepository();
    final cubit = _cubit(loyaltyRepository: loyaltyRepository);

    await cubit.load();
    await cubit.updateStampStyle(
      const UpdateLoyaltyStampStyleRequest(
        presetKey: 'HEART',
        themePreset: 'CUSTOM',
        colorMode: 'CUSTOM',
        backgroundColor: '#111827',
        accentColor: '#f59e0b',
        textColor: '#ffffff',
        stampFilledColor: '#facc15',
        stampEmptyColor: '#d6d3d1',
        rewardBannerColor: '#a16207',
        layoutVariant: 'COMPACT',
      ),
    );

    expect(loyaltyRepository.updateStampStyleCalls, 1);
    expect(cubit.state.stampStyle?.presetKey, 'HEART');
    expect(cubit.state.stampStyle?.layoutVariant, 'COMPACT');
    expect(cubit.state.stampStyleSaveSuccess, isTrue);

    await cubit.close();
  });

  test('STAFF cannot trigger stamp style update', () async {
    final loyaltyRepository = _FakeLoyaltyRepository();
    final cubit = _cubit(loyaltyRepository: loyaltyRepository, role: 'STAFF');

    await cubit.load();
    await cubit.updateStampStyle(
      const UpdateLoyaltyStampStyleRequest(presetKey: 'HEART'),
    );

    expect(loyaltyRepository.updateStampStyleCalls, 0);
    expect(
      cubit.state.stampStyleError,
      'Only owners and managers can edit the card style.',
    );

    await cubit.close();
  });

  test('stamp style 404 falls back without a visible section error', () async {
    final loyaltyRepository = _FakeLoyaltyRepository()
      ..stampStyleFailure = const NotFoundFailure();
    final cubit = _cubit(loyaltyRepository: loyaltyRepository);

    await cubit.load();

    expect(cubit.state.stampStyle, isNull);
    expect(cubit.state.stampStyleError, isNull);

    await cubit.close();
  });

  test(
    'stamp style server failure falls back without a visible section error',
    () async {
      final loyaltyRepository = _FakeLoyaltyRepository()
        ..stampStyleFailure = const ServerFailure();
      final cubit = _cubit(loyaltyRepository: loyaltyRepository);

      await cubit.load();

      expect(cubit.state.stampStyle, isNull);
      expect(cubit.state.stampStyleError, isNull);
      expect(cubit.state.errorMessage, isNull);

      await cubit.close();
    },
  );

  test('membership load failure stays out of global error card', () async {
    final loyaltyRepository = _FakeLoyaltyRepository()
      ..membershipFailure = const ServerFailure();
    final cubit = _cubit(loyaltyRepository: loyaltyRepository);

    await cubit.load();

    expect(cubit.state.errorMessage, isNull);
    expect(
      cubit.state.summaryErrorMessage,
      'Customer memberships could not load right now.',
    );

    await cubit.close();
  });
}

LoyaltyCubit _cubit({
  required _FakeLoyaltyRepository loyaltyRepository,
  String role = 'OWNER',
}) {
  final businessRepository = _FakeBusinessRepository(role);
  final dashboardRepository = _FakeDashboardRepository(role);

  return LoyaltyCubit(
    getMyBusiness: GetMyBusiness(businessRepository),
    getDashboardSummary: GetDashboardSummary(dashboardRepository),
    getActiveProgram: GetActiveLoyaltyProgram(loyaltyRepository),
    createProgram: CreateLoyaltyProgram(loyaltyRepository),
    updateProgram: UpdateLoyaltyProgram(loyaltyRepository),
    enrollCustomer: EnrollLoyaltyCustomer(loyaltyRepository),
    listMemberships: ListLoyaltyMemberships(loyaltyRepository),
    getMembership: GetLoyaltyMembership(loyaltyRepository),
    addStamps: AddLoyaltyStamps(loyaltyRepository),
    redeemReward: RedeemLoyaltyReward(loyaltyRepository),
    listTransactions: ListLoyaltyTransactions(loyaltyRepository),
    getStampPresets: GetLoyaltyStampPresets(loyaltyRepository),
    getStampStyle: GetLoyaltyStampStyle(loyaltyRepository),
    updateStampStyle: UpdateLoyaltyStampStyle(loyaltyRepository),
  );
}

class _FakeBusinessRepository implements BusinessRepository {
  const _FakeBusinessRepository(this.role);

  final String role;

  @override
  Future<Either<Failure, Business>> getMyBusiness() async {
    return Right(_business(role));
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

class _FakeDashboardRepository implements DashboardRepository {
  const _FakeDashboardRepository(this.role);

  final String role;

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String businessId,
  ) async {
    return Right(
      DashboardSummary(
        business: _business(role),
        currentUser: DashboardCurrentUser(
          role: role,
          permissions: _permissions(role),
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

class _FakeLoyaltyRepository implements LoyaltyRepository {
  int updateStampStyleCalls = 0;
  Failure? stampStyleFailure;
  Failure? membershipFailure;

  LoyaltyStampStyle stampStyle = const LoyaltyStampStyle(
    id: 'stamp_style_id',
    loyaltyProgramId: 'loyalty_program_id',
    styleType: 'PRESET',
    presetKey: 'COFFEE',
    themePreset: 'COFFEE',
    colorMode: 'PRESET',
    backgroundColor: '#111827',
    accentColor: '#f59e0b',
    textColor: '#ffffff',
    stampFilledColor: '#facc15',
    stampEmptyColor: '#d6d3d1',
    rewardBannerColor: '#a16207',
    layoutVariant: 'MODERN',
    isDefault: false,
  );

  @override
  Future<Either<Failure, LoyaltyProgram?>> getActiveProgram(
    String businessId,
  ) async {
    return const Right(
      LoyaltyProgram(
        id: 'loyalty_program_id',
        businessId: 'bus_123',
        name: 'Tavrix Cafe Stamp Card',
        stampGoal: 7,
        rewardName: 'Free coffee',
      ),
    );
  }

  @override
  Future<Either<Failure, LoyaltyStampPresets>> getStampPresets() async {
    return const Right(
      LoyaltyStampPresets(
        presets: [
          LoyaltyStampPreset(key: 'STAR', label: 'Star'),
          LoyaltyStampPreset(key: 'COFFEE', label: 'Coffee'),
        ],
        styleTypes: ['PRESET'],
        layoutVariants: ['MODERN', 'COMPACT'],
      ),
    );
  }

  @override
  Future<Either<Failure, LoyaltyStampStyle?>> getStampStyle(
    String businessId,
  ) async {
    final failure = stampStyleFailure;
    if (failure != null) {
      return Left(failure);
    }
    return Right(stampStyle);
  }

  @override
  Future<Either<Failure, LoyaltyStampStyle>> updateStampStyle({
    required String businessId,
    required UpdateLoyaltyStampStyleRequest request,
  }) async {
    updateStampStyleCalls += 1;
    stampStyle = LoyaltyStampStyle(
      id: 'stamp_style_id',
      loyaltyProgramId: 'loyalty_program_id',
      styleType: request.styleType,
      presetKey: request.presetKey ?? 'STAR',
      themePreset: request.themePreset,
      colorMode: request.colorMode,
      backgroundColor: request.backgroundColor,
      accentColor: request.accentColor,
      textColor: request.textColor,
      stampFilledColor: request.stampFilledColor,
      stampEmptyColor: request.stampEmptyColor,
      rewardBannerColor: request.rewardBannerColor,
      layoutVariant: request.layoutVariant ?? 'MODERN',
      isDefault: false,
    );
    return Right(stampStyle);
  }

  @override
  Future<Either<Failure, List<LoyaltyMembership>>> listMemberships({
    required String businessId,
    String? search,
    String? status,
    bool? rewardReady,
  }) async {
    final failure = membershipFailure;
    if (failure != null) {
      return Left(failure);
    }
    return const Right([]);
  }

  @override
  Future<Either<Failure, LoyaltyProgram>> createProgram({
    required String businessId,
    required LoyaltyProgramRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, LoyaltyProgram>> updateProgram({
    required String businessId,
    required String programId,
    required LoyaltyProgramRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, LoyaltyEnrollResult>> enrollCustomer({
    required String businessId,
    required EnrollLoyaltyCustomerRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, LoyaltyMembership>> getMembership({
    required String businessId,
    required String membershipId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, LoyaltyActionResult>> addStamps({
    required String businessId,
    required String membershipId,
    required AddStampsRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, LoyaltyActionResult>> redeemReward({
    required String businessId,
    required String membershipId,
    required RedeemRewardRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<LoyaltyTransaction>>> listTransactions({
    required String businessId,
    required String membershipId,
  }) {
    throw UnimplementedError();
  }
}

Business _business(String role) {
  return Business(
    id: 'bus_123',
    name: 'Tavrix Cafe',
    slug: 'tavrix-cafe',
    publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
    permissions: _permissions(role),
  );
}

BusinessPermissions _permissions(String role) {
  return switch (role) {
    'OWNER' => const BusinessPermissions.owner(),
    'MANAGER' => const BusinessPermissions(
      canManageMenu: true,
      canManageMembers: true,
      canViewMembers: true,
      canViewPublicLink: true,
    ),
    _ => const BusinessPermissions(
      canViewMembers: true,
      canViewPublicLink: true,
    ),
  };
}
