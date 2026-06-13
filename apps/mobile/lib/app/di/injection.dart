import '../../core/auth/auth_session_controller.dart';
import '../../core/auth/clerk_token_provider.dart';
import '../../core/auth/dev_token_provider.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../features/auth/data/datasources/me_remote_data_source.dart';
import '../../features/auth/data/repositories/me_repository_impl.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/business_setup/data/datasources/business_remote_data_source.dart';
import '../../features/business_setup/data/repositories/business_repository_impl.dart';
import '../../features/business_setup/domain/usecases/create_business.dart';
import '../../features/business_setup/domain/usecases/get_my_business.dart';
import '../../features/business_setup/domain/usecases/update_business.dart';
import '../../features/business_setup/presentation/bloc/business_setup_cubit.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_summary.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../features/loyalty/data/datasources/loyalty_remote_data_source.dart';
import '../../features/loyalty/data/repositories/loyalty_repository_impl.dart';
import '../../features/loyalty/domain/usecases/add_loyalty_stamps.dart';
import '../../features/loyalty/domain/usecases/create_loyalty_program.dart';
import '../../features/loyalty/domain/usecases/enroll_loyalty_customer.dart';
import '../../features/loyalty/domain/usecases/get_active_loyalty_program.dart';
import '../../features/loyalty/domain/usecases/get_loyalty_membership.dart';
import '../../features/loyalty/domain/usecases/list_loyalty_memberships.dart';
import '../../features/loyalty/domain/usecases/list_loyalty_transactions.dart';
import '../../features/loyalty/domain/usecases/redeem_loyalty_reward.dart';
import '../../features/loyalty/domain/usecases/update_loyalty_program.dart';
import '../../features/loyalty/presentation/bloc/loyalty_cubit.dart';
import '../../features/menu/data/datasources/menu_remote_data_source.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/usecases/create_menu_category.dart';
import '../../features/menu/domain/usecases/create_menu_item.dart';
import '../../features/menu/domain/usecases/delete_menu_category.dart';
import '../../features/menu/domain/usecases/delete_menu_item.dart';
import '../../features/menu/domain/usecases/get_menu_categories.dart';
import '../../features/menu/domain/usecases/get_menu_items.dart';
import '../../features/menu/domain/usecases/reorder_menu_categories.dart';
import '../../features/menu/domain/usecases/reorder_menu_items.dart';
import '../../features/menu/domain/usecases/restore_menu_category.dart';
import '../../features/menu/domain/usecases/restore_menu_item.dart';
import '../../features/menu/presentation/bloc/menu_cubit.dart';
import '../config/app_config.dart';

class AppDependencies {
  AppDependencies._({
    required this.config,
    required this.authSessionController,
    required this.authCubit,
    required this.businessSetupCubit,
    required this.dashboardCubit,
    required this.menuCubit,
    required this.loyaltyCubit,
  });

  factory AppDependencies.create({AppConfig? config}) {
    final resolvedConfig = config ?? AppConfig.fromEnvironment();
    final clerkTokenProvider = ClerkTokenProvider();
    final devTokenProvider = DevTokenProvider(resolvedConfig.devAuthToken);
    final authSessionController = AuthSessionController(
      config: resolvedConfig,
      clerkTokenProvider: clerkTokenProvider,
      devTokenProvider: devTokenProvider,
    );
    final apiClient = ApiClient(
      config: resolvedConfig,
      tokenProvider: authSessionController,
    );
    const networkInfo = NetworkInfoImpl();

    final meRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);
    final meRepository = MeRepositoryImpl(
      remoteDataSource: meRemoteDataSource,
      networkInfo: networkInfo,
      devFallbackEnabled: resolvedConfig.isDevAuthEnabled,
    );
    final getCurrentUser = GetCurrentUser(meRepository);

    final businessRemoteDataSource = BusinessRemoteDataSourceImpl(apiClient);
    final businessRepository = BusinessRepositoryImpl(
      remoteDataSource: businessRemoteDataSource,
      networkInfo: networkInfo,
      devFallbackEnabled: resolvedConfig.isDevAuthEnabled,
    );
    final getMyBusiness = GetMyBusiness(businessRepository);
    final createBusiness = CreateBusiness(businessRepository);
    final updateBusiness = UpdateBusiness(businessRepository);

    final dashboardRemoteDataSource = DashboardRemoteDataSourceImpl(apiClient);
    final dashboardRepository = DashboardRepositoryImpl(
      remoteDataSource: dashboardRemoteDataSource,
      networkInfo: networkInfo,
      devFallbackEnabled: resolvedConfig.isDevAuthEnabled,
    );
    final getDashboardSummary = GetDashboardSummary(dashboardRepository);

    final menuRemoteDataSource = MenuRemoteDataSourceImpl(apiClient);
    final menuRepository = MenuRepositoryImpl(
      remoteDataSource: menuRemoteDataSource,
      networkInfo: networkInfo,
      devFallbackEnabled: resolvedConfig.isDevAuthEnabled,
    );
    final getMenuCategories = GetMenuCategories(menuRepository);
    final getMenuItems = GetMenuItems(menuRepository);
    final createMenuCategory = CreateMenuCategory(menuRepository);
    final createMenuItem = CreateMenuItem(menuRepository);
    final deleteMenuCategory = DeleteMenuCategory(menuRepository);
    final restoreMenuCategory = RestoreMenuCategory(menuRepository);
    final deleteMenuItem = DeleteMenuItem(menuRepository);
    final restoreMenuItem = RestoreMenuItem(menuRepository);
    final reorderMenuCategories = ReorderMenuCategories(menuRepository);
    final reorderMenuItems = ReorderMenuItems(menuRepository);

    final loyaltyRemoteDataSource = LoyaltyRemoteDataSourceImpl(apiClient);
    final loyaltyRepository = LoyaltyRepositoryImpl(
      remoteDataSource: loyaltyRemoteDataSource,
      networkInfo: networkInfo,
      devFallbackEnabled: resolvedConfig.isDevAuthEnabled,
    );
    final getActiveLoyaltyProgram = GetActiveLoyaltyProgram(loyaltyRepository);
    final createLoyaltyProgram = CreateLoyaltyProgram(loyaltyRepository);
    final updateLoyaltyProgram = UpdateLoyaltyProgram(loyaltyRepository);
    final enrollLoyaltyCustomer = EnrollLoyaltyCustomer(loyaltyRepository);
    final listLoyaltyMemberships = ListLoyaltyMemberships(loyaltyRepository);
    final getLoyaltyMembership = GetLoyaltyMembership(loyaltyRepository);
    final addLoyaltyStamps = AddLoyaltyStamps(loyaltyRepository);
    final redeemLoyaltyReward = RedeemLoyaltyReward(loyaltyRepository);
    final listLoyaltyTransactions = ListLoyaltyTransactions(loyaltyRepository);

    return AppDependencies._(
      config: resolvedConfig,
      authSessionController: authSessionController,
      authCubit: AuthCubit(
        getCurrentUser: getCurrentUser,
        authSessionController: authSessionController,
      ),
      businessSetupCubit: BusinessSetupCubit(
        createBusiness: createBusiness,
        updateBusiness: updateBusiness,
      ),
      dashboardCubit: DashboardCubit(
        getCurrentUser: getCurrentUser,
        getMyBusiness: getMyBusiness,
        getDashboardSummary: getDashboardSummary,
      ),
      menuCubit: MenuCubit(
        getMyBusiness: getMyBusiness,
        getMenuCategories: getMenuCategories,
        getMenuItems: getMenuItems,
        createMenuCategory: createMenuCategory,
        createMenuItem: createMenuItem,
        deleteMenuCategory: deleteMenuCategory,
        restoreMenuCategory: restoreMenuCategory,
        deleteMenuItem: deleteMenuItem,
        restoreMenuItem: restoreMenuItem,
        reorderMenuCategories: reorderMenuCategories,
        reorderMenuItems: reorderMenuItems,
        getDashboardSummary: getDashboardSummary,
      ),
      loyaltyCubit: LoyaltyCubit(
        getMyBusiness: getMyBusiness,
        getDashboardSummary: getDashboardSummary,
        getActiveProgram: getActiveLoyaltyProgram,
        createProgram: createLoyaltyProgram,
        updateProgram: updateLoyaltyProgram,
        enrollCustomer: enrollLoyaltyCustomer,
        listMemberships: listLoyaltyMemberships,
        getMembership: getLoyaltyMembership,
        addStamps: addLoyaltyStamps,
        redeemReward: redeemLoyaltyReward,
        listTransactions: listLoyaltyTransactions,
      ),
    );
  }

  final AppConfig config;
  final AuthSessionController authSessionController;
  final AuthCubit authCubit;
  final BusinessSetupCubit businessSetupCubit;
  final DashboardCubit dashboardCubit;
  final MenuCubit menuCubit;
  final LoyaltyCubit loyaltyCubit;

  Future<void> dispose() async {
    await authCubit.close();
    await businessSetupCubit.close();
    await dashboardCubit.close();
    await menuCubit.close();
    await loyaltyCubit.close();
  }
}
