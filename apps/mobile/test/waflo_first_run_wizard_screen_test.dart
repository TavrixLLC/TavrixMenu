import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/app/router/route_names.dart';
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
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/create_business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/get_my_business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/update_business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/presentation/bloc/business_setup_cubit.dart';
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
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:tavrix_menu_mobile/features/onboarding/presentation/pages/waflo_first_run_wizard_screen.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v2/waflo_button_v2.dart';

void main() {
  late AuthCubit authCubit;
  late BusinessSetupCubit businessSetupCubit;
  late DashboardCubit dashboardCubit;
  late MenuCubit menuCubit;

  late _MockNewOwnerMeRepository meRepository;
  late _MockBusinessRepository businessRepository;
  late _MockMenuRepository menuRepository;
  late _MockDashboardRepository dashboardRepository;

  setUp(() {
    meRepository = _MockNewOwnerMeRepository();
    businessRepository = _MockBusinessRepository(meRepository);
    menuRepository = _MockMenuRepository();
    dashboardRepository = const _MockDashboardRepository();

    authCubit = AuthCubit(
      getCurrentUser: GetCurrentUser(meRepository),
      authSessionController: AuthSessionController(
        config: _config,
        clerkTokenProvider: ClerkTokenProvider(),
        devTokenProvider: const DevTokenProvider(''),
      ),
    );

    businessSetupCubit = BusinessSetupCubit(
      createBusiness: CreateBusiness(businessRepository),
      updateBusiness: UpdateBusiness(businessRepository),
    );

    dashboardCubit = DashboardCubit(
      getCurrentUser: GetCurrentUser(meRepository),
      getMyBusiness: GetMyBusiness(businessRepository),
      getDashboardSummary: GetDashboardSummary(dashboardRepository),
    );

    menuCubit = MenuCubit(
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
  });

  tearDown(() {
    authCubit.close();
    businessSetupCubit.close();
    dashboardCubit.close();
    menuCubit.close();
  });

  Widget makeTestableWidget(Widget body) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<BusinessSetupCubit>.value(value: businessSetupCubit),
        BlocProvider<DashboardCubit>.value(value: dashboardCubit),
        BlocProvider<MenuCubit>.value(value: menuCubit),
      ],
      child: MaterialApp(
        routes: {
          AppRouteNames.dashboard: (_) =>
              const Scaffold(body: Text('لوحة التحكم الرئيسية')),
        },
        home: body,
      ),
    );
  }

  Future<void> pumpWizardToProductStep(WidgetTester tester) async {
    await tester.pumpWidget(
      makeTestableWidget(const WafloFirstRunWizardScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Royal Cafe');
    await tester.pumpAndSettle();
    meRepository.hasBusiness = true;
    await tester.tap(find.text('حفظ ومتابعة'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'المشاريب');
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ ومتابعة'));
    await tester.pumpAndSettle();

    expect(find.text('أضف أول منتج'), findsOneWidget);
  }

  testWidgets('renders welcome step first and navigates through the wizard steps', (
    tester,
  ) async {
    // Set a large enough test physical size for widget layout checks
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      makeTestableWidget(const WafloFirstRunWizardScreen()),
    );
    await tester.pumpAndSettle();

    // 1. Welcome Step
    expect(find.text('أهلاً بك في وافلو 🎉'), findsOneWidget);
    expect(
      find.text('خلينا نجهز مطعمك ونخلي منيو QR جاهز للزبائن'),
      findsOneWidget,
    );

    final startBtn = find.text('ابدأ الآن');
    expect(startBtn, findsOneWidget);
    await tester.tap(startBtn);
    await tester.pumpAndSettle();

    // 2. Restaurant workspace step
    expect(find.text('معلومات المطعم'), findsOneWidget);
    expect(
      find.text('أضف اسم المطعم ونوعه حتى يظهر للزبائن بشكل احترافي'),
      findsOneWidget,
    );

    // Save button disabled initially because text field is empty
    final saveWorkspaceBtn = find.text('حفظ ومتابعة');
    expect(saveWorkspaceBtn, findsOneWidget);

    // Enter name
    await tester.enterText(find.byType(TextFormField).first, 'Royal Cafe');
    await tester.pumpAndSettle();

    // Simulate Workspace Save trigger
    meRepository.hasBusiness = true;
    await tester.tap(saveWorkspaceBtn);
    await tester.pumpAndSettle();

    // 3. Choose appearance step
    expect(find.text('استعرض أشكال المنيو'), findsOneWidget);
    expect(
      find.text(
        'هاي أمثلة على أشكال ممكنة، وتكدر تضبط الشكل الحقيقي لاحقاً من شكل المنيو.',
      ),
      findsOneWidget,
    );
    expect(find.text('كلاسيك الدافئ (معاينة)'), findsOneWidget);
    expect(find.text('الأنيق العصري (معاينة)'), findsOneWidget);

    final saveAppearanceBtn = find.text('متابعة');
    await tester.tap(saveAppearanceBtn);
    await tester.pumpAndSettle();

    // 4. First category step
    expect(find.text('أضف أول قسم للمنيو'), findsOneWidget);
    // Let's test the skip option
    final skipCategoryBtn = find.text('لاحقاً (تخطي)');
    expect(skipCategoryBtn, findsOneWidget);
    await tester.tap(skipCategoryBtn);
    await tester.pumpAndSettle();

    // Skipped category moves directly to Step 6: Product Image honest notice step
    expect(find.text('صور المنتجات غير مفعّلة حالياً'), findsOneWidget);
    expect(find.text('رفع الصور غير مربوط حالياً'), findsOneWidget);

    final proceedImageBtn = find.text('متابعة');
    await tester.tap(proceedImageBtn);
    await tester.pumpAndSettle();

    // 7. Customer Preview Step
    expect(find.text('معاينة منيو الزبائن'), findsOneWidget);
    expect(
      find.text(
        'بعد توفر رابط المنيو الحقيقي، تگدر تراجع شكل المنيو كما يراه الزبائن. حالياً كمل خطوات التجهيز الباقية.',
      ),
      findsOneWidget,
    );

    final proceedPreviewBtn = find.text('متابعة');
    await tester.tap(proceedPreviewBtn);
    await tester.pumpAndSettle();

    // 8. QR Publish/Share Step
    expect(find.text('مشاركة QR غير مفعّلة حالياً'), findsOneWidget);
    expect(find.text('مشاركة QR غير مربوطة حالياً'), findsOneWidget);

    final proceedQrBtn = find.text('متابعة');
    await tester.tap(proceedQrBtn);
    await tester.pumpAndSettle();

    // 9. Finish step
    expect(find.text('رائع! بدأت تجهيز مطعمك 🎉'), findsOneWidget);
    final finishBtn = find.text('الانتقال إلى الرئيسية');
    await tester.tap(finishBtn);
    await tester.pumpAndSettle();

    // Verify redirect to main dashboard
    expect(find.text('لوحة التحكم الرئيسية'), findsOneWidget);
  });

  testWidgets('runs non-skipped flow and verifies product price validations', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      makeTestableWidget(const WafloFirstRunWizardScreen()),
    );
    await tester.pumpAndSettle();

    // 1. Welcome Step -> Start
    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();

    // 2. Restaurant workspace -> Enter name & save
    await tester.enterText(find.byType(TextFormField).first, 'Royal Cafe');
    await tester.pumpAndSettle();
    meRepository.hasBusiness = true;
    await tester.tap(find.text('حفظ ومتابعة'));
    await tester.pumpAndSettle();

    // 3. Choose appearance -> Continue
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();

    // 4. First category -> Enter name & save
    expect(find.text('أضف أول قسم للمنيو'), findsOneWidget);
    final categoryInput = find.byType(TextFormField).first;
    await tester.enterText(categoryInput, 'المشاريب');
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ ومتابعة'));
    await tester.pumpAndSettle();

    // 5. First product step
    expect(find.text('أضف أول منتج'), findsOneWidget);

    final nameFinder = find.byType(TextFormField).first;
    final priceFinder = find.byType(TextFormField).last;

    // Verify initial empty state
    final nameField = tester.widget<TextFormField>(nameFinder);
    final priceField = tester.widget<TextFormField>(priceFinder);
    expect(nameField.controller?.text, isEmpty);
    expect(priceField.controller?.text, isEmpty);

    // Button disabled initially
    final saveProductBtn = find.text('حفظ ومتابعة');
    expect(saveProductBtn, findsOneWidget);
    final saveButtonWidget = tester.widget<WafloButtonV2>(
      find.widgetWithText(WafloButtonV2, 'حفظ ومتابعة'),
    );
    expect(saveButtonWidget.onPressed, isNull);

    // Enter name only -> remains disabled
    await tester.enterText(nameFinder, 'شاي');
    await tester.pumpAndSettle();
    final saveButtonWidget2 = tester.widget<WafloButtonV2>(
      find.widgetWithText(WafloButtonV2, 'حفظ ومتابعة'),
    );
    expect(saveButtonWidget2.onPressed, isNull);

    // Enter price only -> remains disabled
    await tester.enterText(nameFinder, '');
    await tester.enterText(priceFinder, '3000');
    await tester.pumpAndSettle();
    final saveButtonWidget3 = tester.widget<WafloButtonV2>(
      find.widgetWithText(WafloButtonV2, 'حفظ ومتابعة'),
    );
    expect(saveButtonWidget3.onPressed, isNull);

    // Enter name + invalid price -> enabled but fails validation on press
    await tester.enterText(nameFinder, 'شاي');
    await tester.enterText(priceFinder, 'abc');
    await tester.pumpAndSettle();
    final saveButtonWidget4 = tester.widget<WafloButtonV2>(
      find.widgetWithText(WafloButtonV2, 'حفظ ومتابعة'),
    );
    expect(saveButtonWidget4.onPressed, isNotNull);

    await tester.tap(saveProductBtn);
    await tester.pumpAndSettle();
    expect(find.text('أدخل سعر صحيح بالدينار العراقي'), findsOneWidget);
    expect(find.text('أضف أول منتج'), findsOneWidget); // still on step 5

    // Zero price -> fails validation
    await tester.enterText(priceFinder, '0');
    await tester.pumpAndSettle();
    await tester.tap(saveProductBtn);
    await tester.pumpAndSettle();
    expect(find.text('أدخل سعر صحيح بالدينار العراقي'), findsOneWidget);

    // Negative price -> fails validation
    await tester.enterText(priceFinder, '-1000');
    await tester.pumpAndSettle();
    await tester.tap(saveProductBtn);
    await tester.pumpAndSettle();
    expect(find.text('أدخل سعر صحيح بالدينار العراقي'), findsOneWidget);

    // Decimals price -> fails validation
    await tester.enterText(priceFinder, '3000.5');
    await tester.pumpAndSettle();
    await tester.tap(saveProductBtn);
    await tester.pumpAndSettle();
    expect(find.text('أدخل سعر صحيح بالدينار العراقي'), findsOneWidget);

    for (final invalidPrice in <String>[
      ' 3500 ',
      '3500 ',
      ' 3500',
      ' ',
      '\t3500',
      '3500\n',
      '3,500',
      '٣٥٠٠ د.ع',
    ]) {
      priceField.controller!.text = invalidPrice;
      await tester.pumpAndSettle();
      await tester.tap(saveProductBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('أدخل سعر صحيح بالدينار العراقي'),
        findsOneWidget,
        reason: 'Invalid price should show validation error: $invalidPrice',
      );
      expect(find.text('أضف أول منتج'), findsOneWidget);
      expect(
        menuRepository.items,
        isEmpty,
        reason: 'Invalid price should not create product: $invalidPrice',
      );
    }

    // Enter valid ASCII price -> succeeds
    await tester.enterText(priceFinder, '3500');
    await tester.pumpAndSettle();
    await tester.tap(saveProductBtn);
    await tester.pumpAndSettle();

    expect(menuRepository.items, hasLength(1));
    expect(menuRepository.items.single.description, isEmpty);
    expect(menuRepository.items.single.priceCents, 3500);

    // Successfully transitioned to Step 6
    expect(find.text('صور المنتجات غير مفعّلة حالياً'), findsOneWidget);
  });

  testWidgets(
    'accepts Arabic digit product price and keeps description empty',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpWizardToProductStep(tester);

      final nameFinder = find.byType(TextFormField).first;
      final priceFinder = find.byType(TextFormField).last;

      await tester.enterText(nameFinder, 'شاي');
      await tester.enterText(priceFinder, '٣٥٠٠');
      await tester.pumpAndSettle();
      await tester.tap(find.text('حفظ ومتابعة'));
      await tester.pumpAndSettle();

      expect(menuRepository.items, hasLength(1));
      expect(menuRepository.items.single.description, isEmpty);
      expect(menuRepository.items.single.priceCents, 3500);
      expect(find.text('صور المنتجات غير مفعّلة حالياً'), findsOneWidget);
    },
  );
}

const _config = AppConfig(
  apiBaseUrl: 'https://api.example.test',
  customerWebBaseUrl: 'https://menu.example.test',
  devAuthToken: '',
  appEnv: 'development',
  enableDevAuth: false,
  clerkPublishableKey: 'pk_test_example',
);

const _business = Business(
  id: 'bus_123',
  name: 'Tavrix Cafe',
  slug: 'tavrix-cafe',
  publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
  permissions: BusinessPermissions.owner(),
);

class _MockNewOwnerMeRepository implements MeRepository {
  _MockNewOwnerMeRepository();
  bool hasBusiness = false;

  @override
  Future<Either<Failure, CurrentUser>> getMe() async {
    return Right(
      CurrentUser(
        id: 'usr_new_owner',
        email: 'owner@test.com',
        fullName: 'New Owner',
        role: 'OWNER',
        onboarding: CurrentUserOnboarding(
          hasBusiness: hasBusiness,
          activeBusinessCount: hasBusiness ? 1 : 0,
          recommendedNextStep: hasBusiness
              ? 'OPEN_DASHBOARD'
              : 'CREATE_BUSINESS',
        ),
      ),
    );
  }
}

class _MockBusinessRepository implements BusinessRepository {
  const _MockBusinessRepository(this._meRepository);
  final _MockNewOwnerMeRepository _meRepository;

  @override
  Future<Either<Failure, Business>> getMyBusiness() async {
    if (_meRepository.hasBusiness) {
      return const Right(_business);
    }
    return const Left(OfflineFailure());
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
    throw UnimplementedError();
  }
}

class _MockDashboardRepository implements DashboardRepository {
  const _MockDashboardRepository();

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
        counts: DashboardCounts(),
        publicMenu: DashboardPublicMenu(
          path: '/m/tavrix-cafe',
          url: 'https://menu.example.test/m/tavrix-cafe',
          qrPayload: 'https://menu.example.test/m/tavrix-cafe',
        ),
        onboardingHints: DashboardOnboardingHints(
          recommendedNextStep: 'CREATE_CATEGORY',
        ),
      ),
    );
  }
}

class _MockMenuRepository implements MenuRepository {
  _MockMenuRepository();

  final List<MenuCategory> categories = [];
  final List<MenuItem> items = [];

  @override
  Future<Either<Failure, List<MenuCategory>>> getCategories(
    String businessId, {
    bool includeInactive = false,
  }) async {
    return Right(categories);
  }

  @override
  Future<Either<Failure, MenuCategory>> createCategory({
    required String businessId,
    required String name,
  }) async {
    final cat = MenuCategory(
      id: 'cat_${categories.length + 1}',
      businessId: businessId,
      name: name,
      isActive: true,
      sortOrder: categories.length,
    );
    categories.add(cat);
    return Right(cat);
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
    final item = MenuItem(
      id: 'item_${items.length + 1}',
      businessId: businessId,
      categoryId: categoryId,
      name: name,
      description: description,
      priceCents: priceCents,
      isAvailable: isAvailable,
      sortOrder: items.length,
    );
    items.add(item);
    return Right(item);
  }

  @override
  Future<Either<Failure, List<MenuItem>>> getItems(
    String businessId, {
    bool includeInactive = false,
  }) async {
    return Right(items);
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
  Future<Either<Failure, Unit>> deleteItem(String id) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> restoreItem(String id) async =>
      const Right(unit);

  @override
  Future<Either<Failure, List<MenuItem>>> reorderItems({
    required String businessId,
    required List<ReorderMenuRecord> orders,
  }) async => Right(items);
}
