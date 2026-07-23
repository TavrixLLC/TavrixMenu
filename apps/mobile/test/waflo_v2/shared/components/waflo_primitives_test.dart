import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/accessibility/waflo_accessibility.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_buttons.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_modal_frame.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_skeleton.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_text_field.dart';

import '../../test_fixtures.dart';

void main() {
  testWidgets('text field supports explicit LTR data inside RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      foundationHarness(
        home: const Scaffold(
          body: WafloTextField(
            label: 'رقم الهاتف',
            initialValue: '+964 770 000 0000',
            readOnly: true,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.textDirection, TextDirection.ltr);
    expect(field.readOnly, isTrue);
    expect(
      tester.getSize(find.byType(TextField)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('skeleton exposes loading semantics without animation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      foundationHarness(
        home: const Scaffold(
          body: WafloSkeletonBlock(
            semanticLabel: 'جارٍ تحميل البرنامج',
            height: 72,
          ),
        ),
      ),
    );
    final node = tester.getSemantics(
      find.bySemanticsLabel('جارٍ تحميل البرنامج'),
    );
    expect(node.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
    expect(find.byType(AnimatedWidget), findsNothing);
    semantics.dispose();
  });

  testWidgets('retry is a real 48dp action only when callback exists', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      foundationHarness(
        home: Scaffold(
          body: WafloRetryButton(
            label: 'إعادة المحاولة',
            onPressed: () => calls++,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(OutlinedButton));
    expect(calls, 1);
    expect(
      tester.getSize(find.byType(OutlinedButton)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('bottom-sheet frame handles large text and keyboard inset', (
    tester,
  ) async {
    await tester.pumpWidget(
      foundationHarness(
        home: const MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(1.5),
            viewInsets: EdgeInsets.only(bottom: 120),
          ),
          child: Scaffold(
            body: WafloBottomSheetFrame(
              title: 'عنوان إجراء واضح وطويل',
              child: Text('لا يعرض نجاحاً قبل تأكيد الخادم.'),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(SafeArea), findsWidgets);
  });

  testWidgets('dialog frame owns no implicit confirmation action', (
    tester,
  ) async {
    await tester.pumpWidget(
      foundationHarness(
        home: const Scaffold(
          body: WafloDialogFrame(
            title: 'تأكيد الإجراء',
            child: Text('يلزم قرار صريح من المستخدم.'),
          ),
        ),
      ),
    );
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('reduced motion and focus order are explicit primitives', (
    tester,
  ) async {
    await tester.pumpWidget(
      foundationHarness(
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: WafloFocusOrder(order: 2, child: SizedBox()),
        ),
      ),
    );
    final context = tester.element(find.byType(WafloFocusOrder));
    expect(WafloAccessibility.motionDurationOf(context), Duration.zero);
    final order = tester.widget<FocusTraversalOrder>(
      find.byType(FocusTraversalOrder),
    );
    expect((order.order as NumericFocusOrder).order, 2);
  });
}
