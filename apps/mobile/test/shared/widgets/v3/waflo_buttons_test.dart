import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/theme/v3/waflo_v3_theme.dart';
import 'package:tavrix_menu_mobile/core/theme/v3/waflo_v3_tokens.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_primary_button.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_secondary_button.dart';

const _primaryLabel = 'حفظ التغييرات';
const _secondaryLabel = 'إلغاء';
const _loadingLabel = 'جارٍ التنفيذ';

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
  group('WafloPrimaryButton', () {
    testWidgets('renders an Arabic label under RTL', (tester) async {
      await tester.pumpWidget(
        _harness(
          child: WafloPrimaryButton(label: _primaryLabel, onPressed: () {}),
        ),
      );

      expect(find.text(_primaryLabel), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text(_primaryLabel))),
        TextDirection.rtl,
      );
    });

    testWidgets('enabled invokes once while disabled and loading do not', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _harness(
          child: WafloPrimaryButton(
            label: _primaryLabel,
            onPressed: () => calls += 1,
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(calls, 1);

      await tester.pumpWidget(
        _harness(
          child: const WafloPrimaryButton(
            label: _primaryLabel,
            onPressed: null,
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(calls, 1);

      await tester.pumpWidget(
        _harness(
          child: WafloPrimaryButton(
            label: _primaryLabel,
            onPressed: () => calls += 1,
            isLoading: true,
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(calls, 1);
    });

    testWidgets('loading exposes progress semantics and blocks rapid taps', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        _harness(
          child: WafloPrimaryButton(
            label: _primaryLabel,
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final loadingSemantics = tester
          .getSemantics(find.bySemanticsLabel(_primaryLabel))
          .getSemanticsData();
      expect(loadingSemantics.label, _primaryLabel);
      expect(loadingSemantics.value, _loadingLabel);
      expect(loadingSemantics.flagsCollection.isButton, isTrue);
      expect(loadingSemantics.flagsCollection.isLiveRegion, isTrue);
      expect(loadingSemantics.hasAction(SemanticsAction.tap), isFalse);
      semantics.dispose();

      var calls = 0;
      await tester.pumpWidget(
        _harness(
          child: WafloPrimaryButton(
            label: _primaryLabel,
            onPressed: () => calls += 1,
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      expect(calls, 1);
    });
  });

  group('WafloSecondaryButton', () {
    testWidgets('renders under RTL and invokes once when enabled', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _harness(
          child: WafloSecondaryButton(
            label: _secondaryLabel,
            onPressed: () => calls += 1,
          ),
        ),
      );

      expect(find.text(_secondaryLabel), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text(_secondaryLabel))),
        TextDirection.rtl,
      );
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      expect(calls, 1);
    });

    testWidgets('disabled and loading states do not invoke callbacks', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _harness(
          child: const WafloSecondaryButton(
            label: _secondaryLabel,
            onPressed: null,
          ),
        ),
      );
      await tester.tap(find.byType(OutlinedButton));
      expect(calls, 0);

      await tester.pumpWidget(
        _harness(
          child: WafloSecondaryButton(
            label: _secondaryLabel,
            onPressed: () => calls += 1,
            isLoading: true,
          ),
        ),
      );
      await tester.tap(find.byType(OutlinedButton));
      expect(calls, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  testWidgets('both buttons meet the minimum touch target', (tester) async {
    await tester.pumpWidget(
      _harness(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WafloPrimaryButton(label: _primaryLabel, onPressed: () {}),
            const SizedBox(height: WafloV3Spacing.space8),
            WafloSecondaryButton(label: _secondaryLabel, onPressed: () {}),
          ],
        ),
      ),
    );

    final primarySize = tester.getSize(find.byType(ElevatedButton));
    final secondarySize = tester.getSize(find.byType(OutlinedButton));
    expect(primarySize.width, greaterThanOrEqualTo(48));
    expect(primarySize.height, greaterThanOrEqualTo(48));
    expect(secondarySize.width, greaterThanOrEqualTo(48));
    expect(secondarySize.height, greaterThanOrEqualTo(48));
  });

  testWidgets('long Arabic labels wrap safely on a narrow surface', (
    tester,
  ) async {
    const longLabel = 'حفظ جميع التغييرات والمتابعة إلى الخطوة التالية';
    await tester.pumpWidget(
      _harness(
        width: 180,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WafloPrimaryButton(label: longLabel, onPressed: () {}),
            const SizedBox(height: WafloV3Spacing.space8),
            WafloSecondaryButton(label: longLabel, onPressed: () {}),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(longLabel), findsNWidgets(2));
  });

  test('button sources contain no domain or sample data', () {
    final sources = <String>[
      'lib/shared/widgets/v3/waflo_primary_button.dart',
      'lib/shared/widgets/v3/waflo_secondary_button.dart',
    ].map((path) => File(path).readAsStringSync()).join('\n');

    expect(
      sources,
      isNot(
        contains(
          RegExp(
            r'\b(business|category|product|customer|restaurant)\b',
            caseSensitive: false,
          ),
        ),
      ),
    );
  });
}
