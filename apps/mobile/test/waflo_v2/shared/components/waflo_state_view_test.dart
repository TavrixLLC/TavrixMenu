import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/state/waflo_view_state.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_buttons.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_state_view.dart';

import '../../test_fixtures.dart';

void main() {
  for (final kind in WafloViewStateKind.values) {
    testWidgets('$kind renders a distinct truthful state without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        foundationHarness(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: WafloStateView(state: WafloViewState(kind: kind)),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(WafloStateView), findsOneWidget);
    });
  }

  testWidgets('loading exposes progress while empty and error do not', (
    tester,
  ) async {
    await tester.pumpWidget(
      foundationHarness(
        home: const Scaffold(
          body: WafloStateView(
            state: WafloViewState(kind: WafloViewStateKind.loading),
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('waflo-state-progress')), findsOneWidget);

    await tester.pumpWidget(
      foundationHarness(
        home: const Scaffold(
          body: WafloStateView(
            state: WafloViewState(kind: WafloViewStateKind.empty),
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('waflo-state-progress')), findsNothing);

    await tester.pumpWidget(
      foundationHarness(
        home: const Scaffold(
          body: WafloStateView(
            state: WafloViewState(kind: WafloViewStateKind.error),
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('waflo-state-progress')), findsNothing);
  });

  test('offline and disabled states never permit value mutation', () {
    expect(
      const WafloViewState(
        kind: WafloViewStateKind.offline,
      ).permitsValueMutation,
      isFalse,
    );
    expect(
      const WafloViewState(
        kind: WafloViewStateKind.disabled,
      ).permitsValueMutation,
      isFalse,
    );
  });

  testWidgets('disabled primary action is inert and explains why', (
    tester,
  ) async {
    var calls = 0;
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      foundationHarness(
        home: Scaffold(
          body: WafloPrimaryButton(
            label: 'غير متاح',
            onPressed: null,
            disabledReason: 'يحتاج اتصالاً مؤكداً بالخادم',
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FilledButton));
    expect(calls, 0);
    expect(find.text('يحتاج اتصالاً مؤكداً بالخادم'), findsOneWidget);
    final data = tester.getSemantics(find.bySemanticsLabel('غير متاح'));
    expect(data.getSemanticsData().flagsCollection.isButton, isTrue);
    expect(data.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(48),
    );
    semantics.dispose();
  });
}
