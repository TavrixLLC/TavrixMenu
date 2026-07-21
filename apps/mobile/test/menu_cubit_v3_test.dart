import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/repositories/business_repository.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/get_my_business.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/usecases/get_dashboard_summary.dart';
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

void main() {
  group('MenuCubit V3', () {
    late MenuTestHarness harness;

    setUp(() {
      harness = MenuTestHarness();
    });

    tearDown(() async {
      await harness.cubit.close();
    });

    test(
      'loads real records, includes unavailable items, and scopes tenant',
      () async {
        harness.menuRepository
          ..categories = [
            category(id: 'later', sortOrder: 8),
            category(id: 'first', sortOrder: 1),
            category(id: 'foreign', businessId: 'business-b'),
          ]
          ..items = [
            item(id: 'available', categoryId: 'first'),
            item(id: 'unavailable', categoryId: 'first', isAvailable: false),
            item(id: 'foreign-item', businessId: 'business-b'),
          ];

        await harness.cubit.load();

        expect(harness.cubit.state.status, MenuStatus.success);
        expect(harness.cubit.state.selectedCategoryId, 'first');
        expect(
          harness.cubit.state.selectedCategoryItems.map((value) => value.id),
          ['available', 'unavailable'],
        );
        expect(harness.menuRepository.getItemsIncludeInactive, isTrue);
        expect(
          harness.cubit.state.categories.every(
            (value) => value.businessId == testBusiness.id,
          ),
          isTrue,
        );
      },
    );

    test('load failure is not represented as an empty menu', () async {
      harness.menuRepository.categoriesResult = const Left(ServerFailure());

      await harness.cubit.load();

      expect(harness.cubit.state.status, MenuStatus.failure);
      expect(harness.cubit.state.errorMessage, isNotEmpty);
    });

    test('missing permissions fail closed for category creation', () async {
      harness.dashboardRepository.permissionsAvailable = false;
      harness.businessRepository.business = const Business(
        id: 'business-a',
        name: 'Waflo QA Restaurant',
        slug: 'waflo-qa',
        publicMenuUrl: '',
      );
      await harness.cubit.load();

      final result = await harness.cubit.addCategory('المشروبات');

      expect(result, isNull);
      expect(harness.menuRepository.createCategoryCalls, 0);
      expect(harness.cubit.state.errorMessage, isNotEmpty);
    });

    test(
      'category appears and becomes selected only after confirmation',
      () async {
        await harness.cubit.load();
        final pending = harness.menuRepository.delayNextCategoryCreate();

        final future = harness.cubit.addCategory('المشروبات');
        await Future<void>.delayed(Duration.zero);

        expect(harness.cubit.state.status, MenuStatus.mutating);
        expect(harness.cubit.state.categories, isEmpty);
        pending.complete(
          Right(category(id: 'created-category', name: 'المشروبات')),
        );
        final created = await future;

        expect(created?.id, 'created-category');
        expect(harness.cubit.state.selectedCategoryId, 'created-category');
        expect(harness.cubit.state.categories.single.id, 'created-category');
      },
    );

    test('duplicate category taps result in one request', () async {
      await harness.cubit.load();
      final pending = harness.menuRepository.delayNextCategoryCreate();

      final first = harness.cubit.addCategory('المشروبات');
      final second = await harness.cubit.addCategory('المشروبات');

      expect(second, isNull);
      expect(harness.menuRepository.createCategoryCalls, 1);
      pending.complete(Right(category(id: 'created-category')));
      await first;
    });

    test('category failure keeps confirmed list unchanged', () async {
      await harness.cubit.load();
      harness.menuRepository.createCategoryResult = const Left(ServerFailure());

      final created = await harness.cubit.addCategory('المشروبات');

      expect(created, isNull);
      expect(harness.cubit.state.categories, isEmpty);
      expect(harness.cubit.state.errorMessage, isNotEmpty);
    });

    test(
      'product create sends explicit availability and exact IQD value',
      () async {
        harness.menuRepository.categories = [category(id: 'drinks')];
        await harness.cubit.load();

        final created = await harness.cubit.addItem(
          categoryId: 'drinks',
          name: 'قهوة',
          description: 'ثقيلة',
          priceCents: 6500,
          isAvailable: false,
        );

        expect(created, isNotNull);
        expect(harness.menuRepository.lastCreatedPrice, 6500);
        expect(harness.menuRepository.lastCreatedAvailability, isFalse);
        expect(harness.cubit.state.items.single.isAvailable, isFalse);
      },
    );

    test('product cannot be created for another workspace category', () async {
      harness.menuRepository.categories = [
        category(id: 'foreign', businessId: 'business-b'),
      ];
      await harness.cubit.load();

      final result = await harness.cubit.addItem(
        categoryId: 'foreign',
        name: 'منتج',
        description: '',
        priceCents: 1000,
      );

      expect(result, isNull);
      expect(harness.menuRepository.createItemCalls, 0);
    });

    test('late product result is discarded after workspace reset', () async {
      harness.menuRepository.categories = [category(id: 'drinks')];
      await harness.cubit.load();
      final pending = harness.menuRepository.delayNextItemCreate();

      final future = harness.cubit.addItem(
        categoryId: 'drinks',
        name: 'قهوة',
        description: '',
        priceCents: 6500,
      );
      await Future<void>.delayed(Duration.zero);
      harness.cubit.reset();
      pending.complete(Right(item(id: 'late', categoryId: 'drinks')));
      expect(await future, isNull);

      expect(harness.cubit.state, const MenuState.initial());
    });

    test(
      'availability is not optimistic and duplicate taps are blocked',
      () async {
        final product = item(id: 'coffee', categoryId: 'drinks');
        harness.menuRepository
          ..categories = [category(id: 'drinks')]
          ..items = [product];
        await harness.cubit.load();
        final pending = harness.menuRepository.delayNextDelete();

        final first = harness.cubit.setItemAvailability(product, false);
        final second = harness.cubit.setItemAvailability(product, false);
        await Future<void>.delayed(Duration.zero);

        expect(harness.cubit.state.items.single.isAvailable, isTrue);
        expect(harness.menuRepository.deleteItemCalls, 1);
        pending.complete(const Right(unit));
        await Future.wait([first, second]);
        expect(harness.cubit.state.items.single.isAvailable, isFalse);
      },
    );

    test('failed availability write preserves last confirmed value', () async {
      final product = item(id: 'coffee', categoryId: 'drinks');
      harness.menuRepository
        ..categories = [category(id: 'drinks')]
        ..items = [product]
        ..deleteItemResult = const Left(ServerFailure());
      await harness.cubit.load();

      await harness.cubit.setItemAvailability(product, false);

      expect(harness.cubit.state.items.single.isAvailable, isTrue);
      expect(harness.cubit.state.errorMessage, isNotEmpty);
    });

    test(
      'reload preserves selected category by id, never list position',
      () async {
        harness.menuRepository.categories = [
          category(id: 'second', sortOrder: 2),
          category(id: 'first', sortOrder: 1),
        ];
        await harness.cubit.load();
        harness.cubit.selectCategory('second');
        harness.menuRepository.categories = [
          category(id: 'first', sortOrder: 1),
          category(id: 'second', sortOrder: 2),
        ];

        await harness.cubit.load();

        expect(harness.cubit.state.selectedCategoryId, 'second');
      },
    );
  });
}

const testBusiness = Business(
  id: 'business-a',
  name: 'Waflo QA Restaurant',
  slug: 'waflo-qa',
  publicMenuUrl: 'https://card.example.test/m/waflo-qa',
  currency: 'IQD',
  language: 'ar',
  role: 'OWNER',
  permissions: BusinessPermissions.owner(),
);

MenuCategory category({
  String id = 'category-a',
  String businessId = 'business-a',
  String name = 'المشروبات',
  int sortOrder = 0,
  bool isActive = true,
}) {
  return MenuCategory(
    id: id,
    businessId: businessId,
    name: name,
    sortOrder: sortOrder,
    isActive: isActive,
  );
}

MenuItem item({
  String id = 'item-a',
  String businessId = 'business-a',
  String categoryId = 'category-a',
  String name = 'قهوة',
  String description = '',
  int priceCents = 6500,
  bool isAvailable = true,
  int sortOrder = 0,
}) {
  return MenuItem(
    id: id,
    businessId: businessId,
    categoryId: categoryId,
    name: name,
    description: description,
    priceCents: priceCents,
    isAvailable: isAvailable,
    sortOrder: sortOrder,
  );
}

class MenuTestHarness {
  MenuTestHarness({
    List<MenuCategory> categories = const [],
    List<MenuItem> items = const [],
  }) : businessRepository = FakeBusinessRepository(),
       dashboardRepository = FakeDashboardRepository(),
       menuRepository = FakeMenuRepository(
         categories: categories,
         items: items,
       ) {
    cubit = MenuCubit(
      getMyBusiness: GetMyBusiness(businessRepository),
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
      getDashboardSummary: GetDashboardSummary(dashboardRepository),
    );
  }

  final FakeBusinessRepository businessRepository;
  final FakeDashboardRepository dashboardRepository;
  final FakeMenuRepository menuRepository;
  late final MenuCubit cubit;
}

class FakeBusinessRepository implements BusinessRepository {
  Business business = testBusiness;
  Either<Failure, Business>? getResult;
  Completer<Either<Failure, Business>>? delayedGet;

  @override
  Future<Either<Failure, Business>> getMyBusiness() async {
    final delayed = delayedGet;
    if (delayed != null) {
      delayedGet = null;
      return delayed.future;
    }
    return getResult ?? Right(business);
  }

  @override
  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
  }) async => Right(business);

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
  }) async => Right(business);
}

class FakeDashboardRepository implements DashboardRepository {
  bool permissionsAvailable = true;
  bool publicMenuReady = true;

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String businessId,
  ) async {
    return Right(
      DashboardSummary(
        business: testBusiness,
        currentUser: DashboardCurrentUser(
          role: 'OWNER',
          permissions: const BusinessPermissions.owner(),
          permissionsAvailable: permissionsAvailable,
        ),
        counts: const DashboardCounts(),
        publicMenu: const DashboardPublicMenu(
          path: '/m/waflo-qa',
          url: 'https://card.example.test/m/waflo-qa',
          qrPayload: '',
        ),
        onboardingHints: DashboardOnboardingHints(
          hasPublicMenuReady: publicMenuReady,
        ),
      ),
    );
  }
}

class FakeMenuRepository implements MenuRepository {
  FakeMenuRepository({
    List<MenuCategory> categories = const [],
    List<MenuItem> items = const [],
  }) : categories = [...categories],
       items = [...items];

  List<MenuCategory> categories;
  List<MenuItem> items;
  Either<Failure, List<MenuCategory>>? categoriesResult;
  Either<Failure, MenuCategory>? createCategoryResult;
  Either<Failure, MenuItem>? createItemResult;
  Either<Failure, Unit> deleteItemResult = const Right(unit);
  Either<Failure, Unit> restoreItemResult = const Right(unit);
  final List<Completer<Either<Failure, MenuCategory>>> _categoryCreates = [];
  final List<Completer<Either<Failure, MenuItem>>> _itemCreates = [];
  final List<Completer<Either<Failure, Unit>>> _deletes = [];
  int createCategoryCalls = 0;
  int createItemCalls = 0;
  int deleteItemCalls = 0;
  int restoreItemCalls = 0;
  bool getItemsIncludeInactive = false;
  int? lastCreatedPrice;
  bool? lastCreatedAvailability;

  Completer<Either<Failure, MenuCategory>> delayNextCategoryCreate() {
    final completer = Completer<Either<Failure, MenuCategory>>();
    _categoryCreates.add(completer);
    return completer;
  }

  Completer<Either<Failure, MenuItem>> delayNextItemCreate() {
    final completer = Completer<Either<Failure, MenuItem>>();
    _itemCreates.add(completer);
    return completer;
  }

  Completer<Either<Failure, Unit>> delayNextDelete() {
    final completer = Completer<Either<Failure, Unit>>();
    _deletes.add(completer);
    return completer;
  }

  @override
  Future<Either<Failure, List<MenuCategory>>> getCategories(
    String businessId, {
    bool includeInactive = false,
  }) async => categoriesResult ?? Right([...categories]);

  @override
  Future<Either<Failure, List<MenuItem>>> getItems(
    String businessId, {
    bool includeInactive = false,
  }) async {
    getItemsIncludeInactive = includeInactive;
    return Right([...items]);
  }

  @override
  Future<Either<Failure, MenuCategory>> createCategory({
    required String businessId,
    required String name,
  }) async {
    createCategoryCalls++;
    final result = _categoryCreates.isNotEmpty
        ? await _categoryCreates.removeAt(0).future
        : createCategoryResult ??
              Right(
                category(
                  id: 'created-category-$createCategoryCalls',
                  businessId: businessId,
                  name: name,
                ),
              );
    result.fold((_) {}, (value) => categories.add(value));
    return result;
  }

  @override
  Future<Either<Failure, MenuItem>> createItem({
    required String businessId,
    required String categoryId,
    required String name,
    required String description,
    required int priceCents,
    bool isAvailable = true,
  }) async {
    createItemCalls++;
    lastCreatedPrice = priceCents;
    lastCreatedAvailability = isAvailable;
    final result = _itemCreates.isNotEmpty
        ? await _itemCreates.removeAt(0).future
        : createItemResult ??
              Right(
                item(
                  id: 'created-item-$createItemCalls',
                  businessId: businessId,
                  categoryId: categoryId,
                  name: name,
                  description: description,
                  priceCents: priceCents,
                  isAvailable: isAvailable,
                ),
              );
    result.fold((_) {}, (value) => items.add(value));
    return result;
  }

  @override
  Future<Either<Failure, Unit>> deleteItem(String id) async {
    deleteItemCalls++;
    if (_deletes.isNotEmpty) return _deletes.removeAt(0).future;
    return deleteItemResult;
  }

  @override
  Future<Either<Failure, Unit>> restoreItem(String id) async {
    restoreItemCalls++;
    return restoreItemResult;
  }

  @override
  Future<Either<Failure, Unit>> updateCategory({
    required String id,
    String? name,
    int? sortOrder,
    bool? isActive,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> deleteCategory(String id) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> restoreCategory(String id) async =>
      const Right(unit);

  @override
  Future<Either<Failure, List<MenuCategory>>> reorderCategories({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) async => Right(categories);

  @override
  Future<Either<Failure, Unit>> updateItem({
    required String id,
    required String name,
    required String description,
    required int priceCents,
    required bool isAvailable,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, List<MenuItem>>> reorderItems({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) async => Right(items);
}
