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
import '../../features/business_setup/presentation/bloc/business_setup_cubit.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../features/menu/data/datasources/menu_remote_data_source.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/usecases/create_menu_category.dart';
import '../../features/menu/domain/usecases/create_menu_item.dart';
import '../../features/menu/domain/usecases/get_menu_categories.dart';
import '../../features/menu/domain/usecases/get_menu_items.dart';
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

    return AppDependencies._(
      config: resolvedConfig,
      authSessionController: authSessionController,
      authCubit: AuthCubit(
        getCurrentUser: getCurrentUser,
        authSessionController: authSessionController,
      ),
      businessSetupCubit: BusinessSetupCubit(createBusiness: createBusiness),
      dashboardCubit: DashboardCubit(
        getCurrentUser: getCurrentUser,
        getMyBusiness: getMyBusiness,
      ),
      menuCubit: MenuCubit(
        getMyBusiness: getMyBusiness,
        getMenuCategories: getMenuCategories,
        getMenuItems: getMenuItems,
        createMenuCategory: createMenuCategory,
        createMenuItem: createMenuItem,
      ),
    );
  }

  final AppConfig config;
  final AuthSessionController authSessionController;
  final AuthCubit authCubit;
  final BusinessSetupCubit businessSetupCubit;
  final DashboardCubit dashboardCubit;
  final MenuCubit menuCubit;

  Future<void> dispose() async {
    await authCubit.close();
    await businessSetupCubit.close();
    await dashboardCubit.close();
    await menuCubit.close();
  }
}
