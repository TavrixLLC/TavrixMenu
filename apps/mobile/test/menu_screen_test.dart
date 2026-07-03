import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/entities/current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/repositories/me_repository.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/repositories/business_repository.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/get_my_business.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_cubit.dart';
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
import 'package:tavrix_menu_mobile/features/menu/domain/usecases/update_menu_item.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/pages/menu_screen.dart';

void main() {
  testWidgets('menu management is Arabic-first and upload copy is honest', (
    tester,
  ) async {
    await _pumpMenuScreen(tester);

    expect(find.text('إدارة المنيو'), findsOneWidget);
    expect(find.text('إضافة منتج'), findsWidgets);
    expect(find.text('المنتجات'), findsOneWidget);
    expect(find.text('تعديل'), findsWidgets);
    expect(find.text('إخفاء'), findsWidgets);
    expect(find.text('Add item'), findsNothing);
    expect(find.text('Menu management'), findsNothing);
    expect(find.text('Archive'), findsNothing);

    await tester.ensureVisible(_fieldWithLabel(_priceLabel));
    await tester.pumpAndSettle();

    final priceField = tester.widget<TextField>(_fieldWithLabel(_priceLabel));
    expect(priceField.keyboardType, TextInputType.text);
    expect(find.text('د.ع'), findsWidgets);
    expect(find.text('اكتب رقماً كاملاً فقط. مثال: ٦٬٥٠٠'), findsOneWidget);
    expect(
      find.text(
        'إضافة صور المنتجات غير متاحة حالياً من التطبيق. يمكنك حفظ بيانات المنتج الآن بدون صورة.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(RegExp('upload|image url', caseSensitive: false)),
      findsNothing,
    );
  });

  testWidgets(
    'price validation rejects empty decimal negative and non-positive values',
    (tester) async {
      final harness = await _pumpMenuScreen(tester);

      await tester.enterText(_fieldWithLabel('اسم المنتج'), 'قهوة عربية');
      await tester.enterText(_fieldWithLabel(_priceLabel), '');
      await _tapPrimaryItemSubmit(tester);

      expect(find.text(_iqdPriceValidationMessage), findsOneWidget);
      expect(harness.menuRepository.createItemCalls, 0);

      await tester.enterText(_fieldWithLabel(_priceLabel), '0');
      await _tapPrimaryItemSubmit(tester);

      expect(find.text(_iqdPriceValidationMessage), findsOneWidget);
      expect(harness.menuRepository.createItemCalls, 0);

      await tester.enterText(_fieldWithLabel(_priceLabel), '-1');
      await _tapPrimaryItemSubmit(tester);

      expect(find.text(_iqdPriceValidationMessage), findsOneWidget);
      expect(harness.menuRepository.createItemCalls, 0);

      await tester.enterText(_fieldWithLabel(_priceLabel), '6500.5');
      await _tapPrimaryItemSubmit(tester);

      expect(find.text(_iqdPriceValidationMessage), findsOneWidget);
      expect(harness.menuRepository.createItemCalls, 0);

      await tester.enterText(_fieldWithLabel(_priceLabel), '٦٥٠٠٫٥');
      await _tapPrimaryItemSubmit(tester);

      expect(find.text(_iqdPriceValidationMessage), findsOneWidget);
      expect(harness.menuRepository.createItemCalls, 0);
    },
  );

  testWidgets('Arabic and Persian grouped IQD input saves whole dinars', (
    tester,
  ) async {
    final harness = await _pumpMenuScreen(tester);

    await _createItemWithPrice(tester, '٦٬٥٠٠');
    expect(harness.menuRepository.lastCreatedPriceCents, 6500);

    await _createItemWithPrice(tester, '۶٬۵۰۰');
    expect(harness.menuRepository.lastCreatedPriceCents, 6500);

    await _createItemWithPrice(tester, '6,500');
    expect(harness.menuRepository.lastCreatedPriceCents, 6500);

    await _createItemWithPrice(tester, '6 500');
    expect(harness.menuRepository.lastCreatedPriceCents, 6500);
  });

  testWidgets(
    'existing item has a clear edit path and updates through usecase',
    (tester) async {
      final harness = await _pumpMenuScreen(tester);

      await tester.scrollUntilVisible(
        find.text('QA Existing 6500'),
        80,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'تعديل').first);
      await tester.pumpAndSettle();

      expect(find.text('تعديل منتج'), findsOneWidget);
      expect(find.text('حفظ التعديل'), findsOneWidget);

      await tester.enterText(_fieldWithLabel(_priceLabel), '٣٬٥٠٠');
      await _tapPrimaryItemSubmit(tester);

      expect(harness.menuRepository.updateItemCalls, 1);
      expect(harness.menuRepository.lastUpdatedId, 'item_existing');
      expect(harness.menuRepository.lastUpdatedPriceCents, 3500);
    },
  );
}

const _priceLabel = 'السعر بالدينار العراقي';
const _iqdPriceValidationMessage =
    'اكتب سعراً صحيحاً بالدينار العراقي بدون كسور وبقيمة أكبر من صفر.';

Finder _fieldWithLabel(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );
}

Future<void> _tapPrimaryItemSubmit(WidgetTester tester) async {
  final addButton = find.widgetWithText(TextButton, 'إضافة منتج');
  final saveButton = find.widgetWithText(TextButton, 'حفظ التعديل');
  final button = saveButton.evaluate().isNotEmpty ? saveButton : addButton;
  await tester.scrollUntilVisible(
    button.first,
    80,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(button.first);
  await tester.pumpAndSettle();
}

Future<void> _createItemWithPrice(WidgetTester tester, String price) async {
  await tester.enterText(_fieldWithLabel('اسم المنتج'), 'قهوة عربية');
  await tester.enterText(_fieldWithLabel('وصف مختصر'), 'بدون سكر');
  await tester.enterText(_fieldWithLabel(_priceLabel), price);
  await _tapPrimaryItemSubmit(tester);
}

Future<_MenuHarness> _pumpMenuScreen(WidgetTester tester) async {
  final business = _business();
  final businessRepository = _FakeBusinessRepository(business);
  final dashboardRepository = _FakeDashboardRepository(business);
  final menuRepository = _FakeMenuRepository();

  await tester.pumpWidget(
    MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MenuCubit(
              getMyBusiness: GetMyBusiness(businessRepository),
              getMenuCategories: GetMenuCategories(menuRepository),
              getMenuItems: GetMenuItems(menuRepository),
              createMenuCategory: CreateMenuCategory(menuRepository),
              createMenuItem: CreateMenuItem(menuRepository),
              updateMenuItem: UpdateMenuItem(menuRepository),
              deleteMenuCategory: DeleteMenuCategory(menuRepository),
              restoreMenuCategory: RestoreMenuCategory(menuRepository),
              deleteMenuItem: DeleteMenuItem(menuRepository),
              restoreMenuItem: RestoreMenuItem(menuRepository),
              reorderMenuCategories: ReorderMenuCategories(menuRepository),
              reorderMenuItems: ReorderMenuItems(menuRepository),
              getDashboardSummary: GetDashboardSummary(dashboardRepository),
            ),
          ),
          BlocProvider(
            create: (_) => DashboardCubit(
              getCurrentUser: const GetCurrentUser(_FakeMeRepository()),
              getMyBusiness: GetMyBusiness(businessRepository),
              getDashboardSummary: GetDashboardSummary(dashboardRepository),
            ),
          ),
        ],
        child: const MenuScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();

  return _MenuHarness(menuRepository: menuRepository);
}

Business _business() {
  return const Business(
    id: 'business_one',
    name: 'Waflo QA Restaurant',
    slug: 'waflo-qa-restaurant',
    publicMenuUrl: 'https://menu.example.test/waflo-qa-restaurant',
    role: 'OWNER',
    permissions: BusinessPermissions.owner(),
  );
}

DashboardSummary _summary(Business business) {
  return DashboardSummary(
    business: business,
    currentUser: const DashboardCurrentUser(
      role: 'OWNER',
      permissions: BusinessPermissions.owner(),
      permissionsAvailable: true,
    ),
    counts: const DashboardCounts(activeCategories: 1),
    publicMenu: const DashboardPublicMenu(path: '', url: '', qrPayload: ''),
    onboardingHints: const DashboardOnboardingHints(hasCategories: true),
  );
}

class _MenuHarness {
  const _MenuHarness({required this.menuRepository});

  final _FakeMenuRepository menuRepository;
}

class _FakeMeRepository implements MeRepository {
  const _FakeMeRepository();

  @override
  Future<Either<Failure, CurrentUser>> getMe() async {
    return const Right(
      CurrentUser(id: 'user_one', email: '', fullName: 'Owner', role: 'OWNER'),
    );
  }
}

class _FakeBusinessRepository implements BusinessRepository {
  const _FakeBusinessRepository(this.business);

  final Business business;

  @override
  Future<Either<Failure, Business>> getMyBusiness() async => Right(business);

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
  const _FakeDashboardRepository(this.business);

  final Business business;

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String businessId,
  ) async {
    return Right(_summary(business));
  }
}

class _FakeMenuRepository implements MenuRepository {
  final _categories = const [
    MenuCategory(
      id: 'category_active',
      businessId: 'business_one',
      name: 'QA Active',
      sortOrder: 0,
    ),
  ];
  final _items = <MenuItem>[
    const MenuItem(
      id: 'item_existing',
      businessId: 'business_one',
      categoryId: 'category_active',
      name: 'QA Existing 6500',
      description: 'QA item',
      priceCents: 6500,
      isAvailable: true,
      sortOrder: 0,
    ),
  ];

  int createItemCalls = 0;
  int updateItemCalls = 0;
  int? lastCreatedPriceCents;
  int? lastUpdatedPriceCents;
  String? lastUpdatedId;

  @override
  Future<Either<Failure, List<MenuCategory>>> getCategories(
    String businessId, {
    bool includeInactive = false,
  }) async {
    return Right(_categories);
  }

  @override
  Future<Either<Failure, MenuCategory>> createCategory({
    required String businessId,
    required String name,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> updateCategory({
    required String id,
    String? name,
    int? sortOrder,
    bool? isActive,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String id) async => right(unit);

  @override
  Future<Either<Failure, Unit>> restoreCategory(String id) async => right(unit);

  @override
  Future<Either<Failure, List<MenuCategory>>> reorderCategories({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) async {
    return Right(_categories);
  }

  @override
  Future<Either<Failure, List<MenuItem>>> getItems(
    String businessId, {
    bool includeInactive = false,
  }) async {
    return Right(_items);
  }

  @override
  Future<Either<Failure, MenuItem>> createItem({
    required String businessId,
    required String categoryId,
    required String name,
    required String description,
    required int priceCents,
  }) async {
    createItemCalls++;
    lastCreatedPriceCents = priceCents;
    final item = MenuItem(
      id: 'item_$createItemCalls',
      businessId: businessId,
      categoryId: categoryId,
      name: name,
      description: description,
      priceCents: priceCents,
      isAvailable: true,
      sortOrder: _items.length,
    );
    _items.add(item);
    return Right(item);
  }

  @override
  Future<Either<Failure, Unit>> updateItem({
    required String id,
    required String name,
    required String description,
    required int priceCents,
    required bool isAvailable,
  }) async {
    updateItemCalls++;
    lastUpdatedId = id;
    lastUpdatedPriceCents = priceCents;
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        name: name,
        description: description,
        priceCents: priceCents,
        isAvailable: isAvailable,
      );
    }
    return right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteItem(String id) async => right(unit);

  @override
  Future<Either<Failure, Unit>> restoreItem(String id) async => right(unit);

  @override
  Future<Either<Failure, List<MenuItem>>> reorderItems({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) async {
    return Right(_items);
  }
}
