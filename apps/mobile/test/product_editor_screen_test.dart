import 'package:dartz/dartz.dart' show Left, Right;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/pages/product_editor_screen.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_bottom_navigation.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_workspace_header.dart';

import 'menu_cubit_v3_test.dart';

void main() {
  group('ProductEditorScreen', () {
    late MenuTestHarness harness;

    setUp(() async {
      harness = MenuTestHarness(categories: [category(id: 'drinks')]);
      await harness.cubit.load();
    });

    tearDown(() async {
      await harness.cubit.close();
    });

    testWidgets('is a focused Arabic editor without workspace navigation', (
      tester,
    ) async {
      await _openEditor(tester, harness);

      expect(find.byKey(const ValueKey('product-editor-v3')), findsOneWidget);
      expect(find.text('إضافة منتج'), findsWidgets);
      expect(find.text('اسم المنتج'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.byType(WafloBottomNavigation), findsNothing);
      expect(find.byType(WafloWorkspaceHeader), findsNothing);
      expect(find.text('مسودة'), findsNothing);
      expect(find.text('رفع صورة'), findsNothing);
      expect(
        find.text('إضافة صورة للمنتج غير متاحة في هذه المرحلة.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('product-price-currency')),
        findsOneWidget,
      );
      expect(find.text('د.ع'), findsOneWidget);
    });

    testWidgets('validates required name, category, and positive whole IQD', (
      tester,
    ) async {
      await _openEditor(tester, harness);

      await tester.tap(find.byKey(const ValueKey('product-submit-action')));
      await tester.pump();

      expect(find.text('اكتب اسم المنتج.'), findsOneWidget);
      expect(find.text('أدخل سعراً صحيحاً أكبر من صفر.'), findsOneWidget);
      expect(harness.menuRepository.createItemCalls, 0);

      await tester.enterText(
        find.byKey(const ValueKey('product-name-field')),
        'قهوة',
      );
      await tester.enterText(
        find.byKey(const ValueKey('product-price-field')),
        '٦٥٠٠٫٥',
      );
      await tester.tap(find.byKey(const ValueKey('product-submit-action')));
      await tester.pump();
      expect(find.text('أدخل سعراً صحيحاً أكبر من صفر.'), findsOneWidget);
      expect(harness.menuRepository.createItemCalls, 0);
    });

    testWidgets('submits Arabic digits and explicit availability once', (
      tester,
    ) async {
      await _openEditor(tester, harness);
      final pending = harness.menuRepository.delayNextItemCreate();
      await tester.enterText(
        find.byKey(const ValueKey('product-name-field')),
        'قهوة عربية',
      );
      await tester.enterText(
        find.byKey(const ValueKey('product-description-field')),
        'ثقيلة',
      );
      await tester.enterText(
        find.byKey(const ValueKey('product-price-field')),
        '٦٬٥٠٠',
      );
      await tester.tap(
        find.byKey(const ValueKey('product-availability-field')),
      );

      await tester.tap(find.byKey(const ValueKey('product-submit-action')));
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('product-submit-action')),
        warnIfMissed: false,
      );

      expect(harness.menuRepository.createItemCalls, 1);
      expect(harness.menuRepository.lastCreatedPrice, 6500);
      expect(harness.menuRepository.lastCreatedAvailability, isFalse);
      pending.complete(
        Right(
          item(
            id: 'created-product',
            categoryId: 'drinks',
            name: 'قهوة عربية',
            priceCents: 6500,
            isAvailable: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('product-editor-v3')), findsNothing);
      expect(find.text('created-product'), findsOneWidget);
    });

    testWidgets('backend failure preserves user input for retry', (
      tester,
    ) async {
      harness.menuRepository.createItemResult = const Left(ServerFailure());
      await _openEditor(tester, harness);
      await tester.enterText(
        find.byKey(const ValueKey('product-name-field')),
        'شاي',
      );
      await tester.enterText(
        find.byKey(const ValueKey('product-price-field')),
        '3000',
      );

      await tester.tap(find.byKey(const ValueKey('product-submit-action')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('product-editor-v3')), findsOneWidget);
      expect(find.text('شاي'), findsOneWidget);
      expect(find.text('3000'), findsOneWidget);
      expect(find.textContaining('تعذّرت إضافة المنتج'), findsOneWidget);
    });

    testWidgets('back navigation protects unsaved input', (tester) async {
      await _openEditor(tester, harness);
      await tester.enterText(
        find.byKey(const ValueKey('product-name-field')),
        'شاي',
      );

      await tester.tap(find.byKey(const ValueKey('product-editor-back')));
      await tester.pumpAndSettle();

      expect(find.text('ترك التعديلات؟'), findsOneWidget);
      await tester.tap(find.text('البقاء'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('product-editor-v3')), findsOneWidget);
      expect(find.text('شاي'), findsOneWidget);
    });

    testWidgets('workspace reset dismisses the editor without stale state', (
      tester,
    ) async {
      await _openEditor(tester, harness);
      await tester.enterText(
        find.byKey(const ValueKey('product-name-field')),
        'قهوة',
      );

      harness.cubit.reset();
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('product-editor-v3')), findsNothing);
      expect(find.text('لم تتم الإضافة'), findsOneWidget);
    });

    testWidgets('renders without overflow at 390px', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _openEditor(tester, harness, tallViewport: false);

      expect(tester.takeException(), isNull);
    });

    testWidgets('compact one-line controls retain 48px touch geometry', (
      tester,
    ) async {
      await _openEditor(tester, harness);

      for (final key in const [
        'product-name-field',
        'product-category-field',
        'product-price-field',
        'product-availability-field',
      ]) {
        expect(
          tester.getSize(find.byKey(ValueKey(key))).height,
          greaterThanOrEqualTo(48),
        );
      }
    });

    testWidgets('primary action remains reachable with keyboard view insets', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _openEditor(tester, harness, tallViewport: false);

      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('product-submit-action')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('product-submit-action')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _openEditor(
  WidgetTester tester,
  MenuTestHarness harness, {
  bool tallViewport = true,
}) async {
  if (tallViewport) {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }
  await tester.pumpWidget(
    BlocProvider<MenuCubit>.value(
      value: harness.cubit,
      child: const MaterialApp(home: _EditorHost()),
    ),
  );
  await tester.tap(find.byKey(const ValueKey('open-product-editor')));
  await tester.pumpAndSettle();
}

class _EditorHost extends StatefulWidget {
  const _EditorHost();

  @override
  State<_EditorHost> createState() => _EditorHostState();
}

class _EditorHostState extends State<_EditorHost> {
  ProductEditorResult? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              key: const ValueKey('open-product-editor'),
              onPressed: () async {
                final result = await Navigator.of(context)
                    .push<ProductEditorResult>(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<MenuCubit>.value(
                          value: context.read<MenuCubit>(),
                          child: const ProductEditorScreen(
                            initialCategoryId: 'drinks',
                          ),
                        ),
                      ),
                    );
                if (mounted) setState(() => _result = result);
              },
              child: const Text('فتح'),
            ),
            Text(_result?.productId ?? 'لم تتم الإضافة'),
          ],
        ),
      ),
    );
  }
}
