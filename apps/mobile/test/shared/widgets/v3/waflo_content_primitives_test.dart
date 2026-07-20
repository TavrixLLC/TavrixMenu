import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/theme/v3/waflo_v3_theme.dart';
import 'package:tavrix_menu_mobile/core/theme/v3/waflo_v3_tokens.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_empty_state.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_inline_error.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_primary_button.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_secondary_button.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_section_header.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_skeleton.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_status_badge.dart';

const _sectionTitle = 'إدارة المحتوى';
const _description = 'راجع التفاصيل قبل المتابعة';
const _actionLabel = 'عرض الكل';

Widget _harness({required Widget child, double width = 360}) {
  return MaterialApp(
    theme: WafloV3Theme.light(),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        child: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('WafloSectionHeader', () {
    testWidgets('renders Arabic title and optional description under RTL', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          child: const WafloSectionHeader(
            title: _sectionTitle,
            description: _description,
          ),
        ),
      );

      expect(find.text(_sectionTitle), findsOneWidget);
      expect(find.text(_description), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text(_sectionTitle))),
        TextDirection.rtl,
      );
    });

    testWidgets('trailing action invokes once and meets the touch target', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _harness(
          child: WafloSectionHeader(
            title: _sectionTitle,
            actionLabel: _actionLabel,
            onActionPressed: () => calls += 1,
          ),
        ),
      );

      final action = find.widgetWithText(TextButton, _actionLabel);
      final size = tester.getSize(action);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      await tester.tap(action);
      expect(calls, 1);
    });

    testWidgets('long text wraps on a narrow surface without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          width: 220,
          child: const SingleChildScrollView(
            child: WafloSectionHeader(
              title: 'عنوان عربي طويل يلتف بشكل طبيعي داخل المساحة المتاحة',
              description:
                  'وصف توضيحي طويل يساعد القارئ من دون تجاوز عرض الهاتف الصغير',
              actionLabel: _actionLabel,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('WafloStatusBadge', () {
    testWidgets('renders every typed semantic status', (tester) async {
      await tester.pumpWidget(
        _harness(
          child: Wrap(
            children: WafloStatusKind.values
                .map(
                  (status) => WafloStatusBadge(
                    label: status.name,
                    status: status,
                    icon: Icons.circle,
                  ),
                )
                .toList(),
          ),
        ),
      );

      for (final status in WafloStatusKind.values) {
        expect(find.text(status.name), findsOneWidget);
      }
      expect(
        find.byIcon(Icons.circle),
        findsNWidgets(WafloStatusKind.values.length),
      );
    });

    testWidgets('error uses semantic error instead of brand primary', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          child: const WafloStatusBadge(
            label: 'تعذر الإكمال',
            status: WafloStatusKind.error,
          ),
        ),
      );

      final label = tester.widget<Text>(find.text('تعذر الإكمال'));
      expect(label.style?.color, WafloV3Colors.error);
      expect(label.style?.color, isNot(WafloV3Colors.primary));
    });

    testWidgets('exposes readable text semantics and a non-color label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _harness(
          child: const WafloStatusBadge(
            label: 'متاح',
            status: WafloStatusKind.active,
          ),
        ),
      );

      expect(find.text('متاح'), findsOneWidget);
      expect(find.bySemanticsLabel('متاح'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('WafloEmptyState', () {
    testWidgets('renders Arabic copy and both V3 action types', (tester) async {
      await tester.pumpWidget(
        _harness(
          child: WafloEmptyState(
            title: 'لا توجد نتائج',
            description: _description,
            icon: Icons.inbox_outlined,
            primaryActionLabel: 'إضافة',
            onPrimaryAction: () {},
            secondaryActionLabel: 'رجوع',
            onSecondaryAction: () {},
          ),
        ),
      );

      expect(find.text('لا توجد نتائج'), findsOneWidget);
      expect(find.text(_description), findsOneWidget);
      expect(find.byType(WafloPrimaryButton), findsOneWidget);
      expect(find.byType(WafloSecondaryButton), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('لا توجد نتائج'))),
        TextDirection.rtl,
      );
    });

    testWidgets('missing actions leave no interactive button space', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          child: const WafloEmptyState(
            title: 'لا توجد نتائج',
            description: _description,
          ),
        ),
      );

      expect(find.byType(WafloPrimaryButton), findsNothing);
      expect(find.byType(WafloSecondaryButton), findsNothing);
      expect(find.byType(ButtonStyleButton), findsNothing);
    });

    testWidgets('long Arabic copy wraps without horizontal overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          width: 220,
          child: const WafloEmptyState(
            title: 'لا يوجد محتوى متاح في هذه المساحة حتى الآن',
            description:
                'يمكنك العودة لاحقاً أو استخدام الإجراء الحقيقي المتاح عندما يظهر هنا',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('WafloInlineError', () {
    testWidgets('exposes error copy as a live semantic region', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _harness(
          child: const WafloInlineError(
            title: 'تعذر الإكمال',
            message: 'حاول مرة أخرى بعد قليل',
          ),
        ),
      );

      final data = tester
          .getSemantics(
            find.bySemanticsLabel('تعذر الإكمال، حاول مرة أخرى بعد قليل'),
          )
          .getSemanticsData();
      expect(data.flagsCollection.isLiveRegion, isTrue);
      expect(data.label, contains('تعذر الإكمال'));
      semantics.dispose();
    });

    testWidgets('retry invokes once and keeps a 48px target', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _harness(
          child: WafloInlineError(
            message: 'حاول مرة أخرى',
            onRetry: () => calls += 1,
          ),
        ),
      );

      final retry = find.byType(WafloSecondaryButton);
      final size = tester.getSize(find.byType(OutlinedButton));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      await tester.tap(retry);
      expect(calls, 1);
    });

    testWidgets('retrying prevents taps and exposes progress', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _harness(
          child: WafloInlineError(
            message: 'حاول مرة أخرى',
            onRetry: () => calls += 1,
            isRetrying: true,
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      expect(calls, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('long Arabic message wraps safely', (tester) async {
      await tester.pumpWidget(
        _harness(
          width: 220,
          child: const WafloInlineError(
            message:
                'تعذر إكمال العملية الآن، تحقق من الاتصال ثم حاول مرة أخرى بعد قليل',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('WafloSkeleton', () {
    testWidgets('uses configurable dimensions', (tester) async {
      await tester.pumpWidget(
        _harness(
          child: const Align(
            child: WafloSkeleton(width: 120, height: 32, radius: 20),
          ),
        ),
      );

      expect(tester.getSize(find.byType(WafloSkeleton)), const Size(120, 32));
    });

    testWidgets('defaults to token geometry with no visible fake content', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(child: const WafloSkeleton()));

      expect(
        tester.getSize(find.byType(WafloSkeleton)).height,
        WafloV3Spacing.minimumTouchTarget,
      );
      final decorated = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(WafloSkeleton),
          matching: find.byType(DecoratedBox),
        ),
      );
      final decoration = decorated.decoration as BoxDecoration;
      expect(
        decoration.borderRadius,
        const BorderRadius.all(Radius.circular(WafloV3Radius.inputControl)),
      );
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('settles deterministically without animation', (tester) async {
      await tester.pumpWidget(_harness(child: const WafloSkeleton()));

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('all supplied interactive controls respect 48px targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WafloSectionHeader(
              title: _sectionTitle,
              actionLabel: _actionLabel,
              onActionPressed: () {},
            ),
            WafloEmptyState(
              title: 'لا توجد نتائج',
              description: _description,
              primaryActionLabel: 'إضافة',
              onPrimaryAction: () {},
              secondaryActionLabel: 'رجوع',
              onSecondaryAction: () {},
            ),
          ],
        ),
      ),
    );

    for (final finder in <Finder>[
      find.byType(TextButton),
      find.byType(ElevatedButton),
      find.byType(OutlinedButton),
    ]) {
      final size = tester.getSize(finder);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
  });

  test(
    'sources contain no domain data, remote assets, or raw diagnostics API',
    () {
      const paths = <String>[
        'lib/shared/widgets/v3/waflo_section_header.dart',
        'lib/shared/widgets/v3/waflo_status_badge.dart',
        'lib/shared/widgets/v3/waflo_empty_state.dart',
        'lib/shared/widgets/v3/waflo_inline_error.dart',
        'lib/shared/widgets/v3/waflo_skeleton.dart',
      ];
      final source = paths
          .map((path) => File(path).readAsStringSync())
          .join('\n');

      expect(
        source,
        isNot(
          contains(
            RegExp(
              r'\b(business|product|customer|restaurant|StackTrace|Exception)\b',
              caseSensitive: false,
            ),
          ),
        ),
      );
      expect(source, isNot(contains('Image.network')));
      expect(source, isNot(contains('AssetImage')));
      expect(source, isNot(contains('AnimationController')));
    },
  );
}
