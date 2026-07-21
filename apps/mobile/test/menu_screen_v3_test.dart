import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/pages/menu_screen.dart';

import 'menu_cubit_v3_test.dart';

void main() {
  group('MenuScreen V3', () {
    late MenuTestHarness harness;

    tearDown(() async {
      await harness.cubit.close();
    });

    testWidgets('shows an honest loading skeleton', (tester) async {
      harness = MenuTestHarness();
      harness.businessRepository.delayedGet = Completer();

      await _pumpMenu(tester, harness);

      expect(find.byKey(const ValueKey('menu-loading-state')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('menu-no-categories-state')),
        findsNothing,
      );
    });

    testWidgets('shows a retryable load error instead of an empty state', (
      tester,
    ) async {
      harness = MenuTestHarness();
      harness.businessRepository.getResult = const Left(ServerFailure());

      await _pumpMenu(tester, harness, settle: true);

      expect(find.byKey(const ValueKey('menu-load-error')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('menu-no-categories-state')),
        findsNothing,
      );
    });

    testWidgets('zero-category state offers category creation only', (
      tester,
    ) async {
      harness = MenuTestHarness();

      await _pumpMenu(tester, harness, settle: true);

      expect(
        find.byKey(const ValueKey('menu-no-categories-state')),
        findsOneWidget,
      );
      expect(find.text('ابدأ بأول قسم في منيوك'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('menu-add-product-action')),
        findsNothing,
      );
      expect(find.text('Menu management'), findsNothing);
      expect(find.text('Active categories'), findsNothing);
    });

    testWidgets('category without products has the approved next action', (
      tester,
    ) async {
      harness = MenuTestHarness(categories: [category(id: 'drinks')]);

      await _pumpMenu(tester, harness, settle: true);

      expect(
        find.byKey(const ValueKey('menu-no-products-state')),
        findsOneWidget,
      );
      expect(find.text('هذا القسم بعده بدون منتجات'), findsOneWidget);
      expect(find.text('إضافة أول منتج'), findsOneWidget);
    });

    testWidgets('renders confirmed products and unavailable records', (
      tester,
    ) async {
      harness = MenuTestHarness(
        categories: [category(id: 'drinks')],
        items: [
          item(
            id: 'coffee',
            categoryId: 'drinks',
            name: 'قهوة عربية',
            description: 'ثقيلة',
          ),
          item(
            id: 'tea',
            categoryId: 'drinks',
            name: 'شاي',
            priceCents: 3000,
            isAvailable: false,
          ),
        ],
      );

      await _pumpMenu(tester, harness, settle: true);

      expect(
        find.byKey(const ValueKey('menu-populated-state')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('menu-product-coffee')), findsOneWidget);
      expect(find.byKey(const ValueKey('menu-product-tea')), findsOneWidget);
      expect(find.text('6,500 د.ع'), findsOneWidget);
      expect(find.text('3,000 د.ع'), findsOneWidget);
      expect(find.text('غير متوفر للزبائن'), findsOneWidget);
      final availability = find.byKey(
        const ValueKey('menu-availability-control-coffee'),
      );
      expect(
        find.descendant(of: availability, matching: find.text('متوفر للزبائن')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: availability,
          matching: find.byKey(const ValueKey('menu-availability-coffee')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('search-empty is distinct and clearing restores products', (
      tester,
    ) async {
      harness = MenuTestHarness(
        categories: [category(id: 'drinks')],
        items: [item(id: 'coffee', categoryId: 'drinks')],
      );
      await _pumpMenu(tester, harness, settle: true);

      await tester.enterText(
        find.byKey(const ValueKey('menu-product-search')),
        'غير موجود',
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('menu-search-empty-state')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('menu-no-products-state')),
        findsNothing,
      );
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('مسح البحث'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('menu-product-coffee')), findsOneWidget);
    });

    testWidgets('category creation closes only after backend confirmation', (
      tester,
    ) async {
      harness = MenuTestHarness();
      await _pumpMenu(tester, harness, settle: true);
      final pending = harness.menuRepository.delayNextCategoryCreate();

      await tester.tap(find.text('إضافة قسم').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('add-category-name-field')),
        'الحلويات',
      );
      await tester.tap(find.byKey(const ValueKey('add-category-submit')));
      await tester.pump();

      expect(find.byKey(const ValueKey('add-category-dialog')), findsOneWidget);
      expect(harness.menuRepository.createCategoryCalls, 1);
      pending.complete(Right(category(id: 'desserts', name: 'الحلويات')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('add-category-dialog')), findsNothing);
      expect(
        find.byKey(const ValueKey('menu-category-desserts')),
        findsOneWidget,
      );
    });

    testWidgets('preview stays disabled until real public readiness', (
      tester,
    ) async {
      harness = MenuTestHarness(categories: [category(id: 'drinks')]);
      harness.dashboardRepository.publicMenuReady = false;

      await _pumpMenu(tester, harness, settle: true);

      expect(
        find.text('تتفعّل المعاينة بعد جاهزية منيو الزبائن.'),
        findsOneWidget,
      );
      final button = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton).last,
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('fits a 390px screen without Flutter layout errors', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      harness = MenuTestHarness(
        categories: [category(id: 'drinks')],
        items: [item(id: 'coffee', categoryId: 'drinks')],
      );

      await _pumpMenu(tester, harness, settle: true);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('menu-product-coffee')), findsOneWidget);
    });

    testWidgets('product media stays bounded across compact mobile widths', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      harness = MenuTestHarness(
        categories: [category(id: 'drinks')],
        items: [item(id: 'coffee', categoryId: 'drinks')],
      );

      await _pumpMenu(tester, harness, settle: true);

      final size = tester.getSize(
        find.byKey(const ValueKey('menu-product-media-coffee')),
      );
      expect(size.height, inInclusiveRange(96, 112));
      expect(size.height, lessThan(size.width / 2));
    });

    testWidgets('menu keeps explicit clearance after its final action', (
      tester,
    ) async {
      harness = MenuTestHarness(
        categories: [category(id: 'drinks')],
        items: [item(id: 'coffee', categoryId: 'drinks')],
      );
      await _pumpMenu(tester, harness, settle: true);

      expect(
        tester
            .getSize(
              find.byKey(const ValueKey('menu-bottom-navigation-clearance')),
            )
            .height,
        greaterThanOrEqualTo(32),
      );
    });

    testWidgets('category dialog actions keep 48px targets at 360px', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      harness = MenuTestHarness();
      await _pumpMenu(tester, harness, settle: true);

      await tester.tap(find.text('إضافة قسم').first);
      await tester.pumpAndSettle();

      expect(
        tester
            .getSize(find.byKey(const ValueKey('add-category-submit')))
            .height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('add-category-cancel')))
            .height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _pumpMenu(
  WidgetTester tester,
  MenuTestHarness harness, {
  bool settle = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<MenuCubit>.value(
        value: harness.cubit,
        child: const MenuScreen(embeddedInWorkspaceShell: true),
      ),
    ),
  );
  await tester.pump();
  if (settle) await tester.pumpAndSettle();
}
