import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/app.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/app/di/injection.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/entities/current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/repositories/me_repository.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/repositories/business_repository.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/create_business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/get_my_business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/presentation/bloc/business_setup_cubit.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/entities/menu_category.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/entities/menu_item.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/repositories/menu_repository.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/create_menu_category.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/create_menu_item.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/delete_menu_item.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/get_menu_categories.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/get_menu_items.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/update_menu_item.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_cubit.dart';

void main() {
  testWidgets('dev login loads backend user and business before dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(TavrixMenuApp(dependencies: _dependencies()));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue in dev mode'));
    await tester.pumpAndSettle();

    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Tavrix Demo Cafe'), findsOneWidget);
    expect(find.text('Slug: tavrix-demo-cafe'), findsOneWidget);
    expect(find.text('Public menu: /m/tavrix-demo-cafe'), findsOneWidget);
    expect(find.text('Manage Menu'), findsOneWidget);
  });

  testWidgets(
    'dev login opens business setup when backend returns empty list',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        TavrixMenuApp(
          dependencies: _dependencies(
            user: _userWithoutBusinesses,
            businessResult: const Right([]),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue in dev mode'));
      await tester.pumpAndSettle();

      expect(find.text('Business setup'), findsOneWidget);
      expect(find.text('Create your business profile'), findsOneWidget);
    },
  );
}

const _user = CurrentUser(
  id: 'user-1',
  email: 'owner@tavrix.test',
  fullName: 'Tavrix Owner',
  role: 'Owner',
  businesses: [_business],
);

const _userWithoutBusinesses = CurrentUser(
  id: 'user-1',
  email: 'owner@tavrix.test',
  fullName: 'Tavrix Owner',
  role: 'Owner',
);

const _business = Business(
  id: 'business-1',
  name: 'Tavrix Demo Cafe',
  slug: 'tavrix-demo-cafe',
  publicMenuUrl: 'http://localhost:3000/m/tavrix-demo-cafe',
);

AppDependencies _dependencies({
  CurrentUser user = _user,
  Either<Failure, List<Business>> businessResult = const Right([_business]),
}) {
  final meRepository = _FakeMeRepository(user);
  final businessRepository = _FakeBusinessRepository(businessResult);
  final menuRepository = _FakeMenuRepository();
  final getCurrentUser = GetCurrentUser(meRepository);
  final getMyBusinesses = GetMyBusinesses(businessRepository);

  return AppDependencies(
    config: const AppConfig(
      apiBaseUrl: 'http://localhost:3000',
      customerWebBaseUrl: 'http://localhost:3000',
      clerkPublishableKey: '',
      devFallbackEnabled: false,
    ),
    authCubit: AuthCubit(getCurrentUser: getCurrentUser),
    businessSetupCubit: BusinessSetupCubit(
      createBusiness: CreateBusiness(businessRepository),
    ),
    dashboardCubit: DashboardCubit(
      getCurrentUser: getCurrentUser,
      getMyBusinesses: getMyBusinesses,
    ),
    menuCubit: MenuCubit(
      getMyBusinesses: getMyBusinesses,
      getMenuCategories: GetMenuCategories(menuRepository),
      getMenuItems: GetMenuItems(menuRepository),
      createMenuCategory: CreateMenuCategory(menuRepository),
      createMenuItem: CreateMenuItem(menuRepository),
      updateMenuItem: UpdateMenuItem(menuRepository),
      deleteMenuItem: DeleteMenuItem(menuRepository),
    ),
  );
}

class _FakeMeRepository implements MeRepository {
  const _FakeMeRepository(this._user);

  final CurrentUser _user;

  @override
  Future<Either<Failure, CurrentUser>> getMe() async {
    return Right(_user);
  }
}

class _FakeBusinessRepository implements BusinessRepository {
  _FakeBusinessRepository(this._businessResult);

  Either<Failure, List<Business>> _businessResult;

  @override
  Future<Either<Failure, List<Business>>> getMyBusinesses() async {
    return _businessResult;
  }

  @override
  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String type,
    String? city,
    String currency = 'IQD',
    String language = 'ar',
  }) async {
    final slug = name.toLowerCase().replaceAll(' ', '-');
    final business = Business(
      id: 'business-created',
      name: name,
      slug: slug,
      publicMenuUrl: 'http://localhost:3000/m/$slug',
      type: type,
      city: city,
      currency: currency,
      language: language,
    );
    _businessResult = Right([business]);
    return Right(business);
  }

  @override
  Future<Either<Failure, Business>> updateBusiness({
    required String id,
    required String name,
    required String type,
    String? city,
    String currency = 'IQD',
    String language = 'ar',
  }) async {
    final slug = name.toLowerCase().replaceAll(' ', '-');
    final business = Business(
      id: id,
      name: name,
      slug: slug,
      publicMenuUrl: 'http://localhost:3000/m/$slug',
      type: type,
      city: city,
      currency: currency,
      language: language,
    );
    _businessResult = Right([business]);
    return Right(business);
  }
}

class _FakeMenuRepository implements MenuRepository {
  @override
  Future<Either<Failure, MenuCategory>> createCategory({
    required String businessId,
    required String name,
  }) async {
    return Right(
      MenuCategory(
        id: 'category-1',
        businessId: businessId,
        name: name,
        sortOrder: 1,
      ),
    );
  }

  @override
  Future<Either<Failure, MenuItem>> createItem({
    required String businessId,
    required String categoryId,
    required String name,
    required String description,
    required String price,
  }) async {
    return Right(
      MenuItem(
        id: 'item-1',
        businessId: businessId,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        isAvailable: true,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteItem(String id) async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<MenuCategory>>> getCategories(
    String businessId,
  ) async {
    return Right([
      MenuCategory(
        id: 'category-1',
        businessId: businessId,
        name: 'Drinks',
        sortOrder: 1,
      ),
    ]);
  }

  @override
  Future<Either<Failure, List<MenuItem>>> getItems(String businessId) async {
    return Right([
      MenuItem(
        id: 'item-1',
        businessId: businessId,
        categoryId: 'category-1',
        name: 'House Latte',
        description: 'Warm espresso drink managed by staff.',
        price: '450',
        isAvailable: true,
      ),
    ]);
  }

  @override
  Future<Either<Failure, Unit>> updateItem({
    required String id,
    required String name,
    required String description,
    required String price,
    required bool isAvailable,
  }) async {
    return const Right(unit);
  }
}
