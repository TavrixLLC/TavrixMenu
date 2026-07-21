import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/theme/v3/waflo_v3_theme.dart';
import 'package:tavrix_menu_mobile/core/theme/v3/waflo_v3_tokens.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_bottom_navigation.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_status_badge.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_workspace_header.dart';

const _workspaceName = 'مساحة المطعم التجريبية';
const _statusLabel = 'نشط الآن';

final _transparentPixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);

Widget _harness({
  required Widget child,
  double width = 360,
  double textScale = 1,
  double bottomInset = 0,
  bool useV3Theme = true,
}) {
  return MaterialApp(
    theme: useV3Theme ? WafloV3Theme.light() : ThemeData(useMaterial3: true),
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 800),
        padding: EdgeInsets.only(bottom: bottomInset),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  );
}

Finder _destination(WafloWorkspaceDestination destination) {
  return find.byKey(ValueKey('waflo-bottom-navigation-${destination.name}'));
}

WafloBottomNavigation _navigation({
  WafloWorkspaceDestination selected = WafloWorkspaceDestination.home,
  ValueChanged<WafloWorkspaceDestination>? onSelected,
}) {
  return WafloBottomNavigation(
    selectedDestination: selected,
    onDestinationSelected: onSelected ?? (_) {},
  );
}

void main() {
  group('WafloWorkspaceHeader', () {
    testWidgets('1. Arabic workspace name renders under RTL', (tester) async {
      await tester.pumpWidget(
        _harness(
          child: const WafloWorkspaceHeader(workspaceName: _workspaceName),
        ),
      );

      expect(find.text(_workspaceName), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text(_workspaceName))),
        TextDirection.rtl,
      );
    });

    testWidgets('2. optional status renders', (tester) async {
      await tester.pumpWidget(
        _harness(
          child: const WafloWorkspaceHeader(
            workspaceName: _workspaceName,
            statusLabel: _statusLabel,
            statusKind: WafloStatusKind.active,
          ),
        ),
      );

      expect(find.text(_statusLabel), findsOneWidget);
      expect(find.byType(WafloStatusBadge), findsOneWidget);
    });

    testWidgets('3. header renders safely without status', (tester) async {
      await tester.pumpWidget(
        _harness(
          child: const WafloWorkspaceHeader(workspaceName: _workspaceName),
        ),
      );

      expect(find.byType(WafloWorkspaceHeader), findsOneWidget);
      expect(find.byType(WafloStatusBadge), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. native avatar fallback renders without image bytes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          child: const WafloWorkspaceHeader(workspaceName: _workspaceName),
        ),
      );

      expect(
        find.byKey(const ValueKey('waflo-workspace-avatar-fallback')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
    });

    testWidgets('5. supplied local avatar renders without network fetching', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          child: WafloWorkspaceHeader(
            workspaceName: _workspaceName,
            avatarBytes: _transparentPixel,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(
        find.byKey(const ValueKey('waflo-workspace-avatar-fallback')),
        findsNothing,
      );
    });

    testWidgets('6. notification callback invokes once', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _harness(
          child: WafloWorkspaceHeader(
            workspaceName: _workspaceName,
            onNotificationPressed: () => calls += 1,
          ),
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey('waflo-workspace-notification-action')),
      );
      await tester.pump();
      expect(calls, 1);
    });

    testWidgets(
      '7. missing notification callback exposes no active-looking action',
      (tester) async {
        await tester.pumpWidget(
          _harness(
            child: const WafloWorkspaceHeader(workspaceName: _workspaceName),
          ),
        );

        expect(
          find.byKey(const ValueKey('waflo-workspace-notification-action')),
          findsNothing,
        );
        expect(find.byType(IconButton), findsNothing);
      },
    );

    testWidgets('8. unread count appears only when explicitly supplied', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          child: WafloWorkspaceHeader(
            workspaceName: _workspaceName,
            onNotificationPressed: () {},
          ),
        ),
      );
      expect(
        find.byKey(const ValueKey('waflo-workspace-notification-count')),
        findsNothing,
      );

      await tester.pumpWidget(
        _harness(
          child: WafloWorkspaceHeader(
            workspaceName: _workspaceName,
            onNotificationPressed: () {},
            unreadCount: 7,
          ),
        ),
      );
      expect(
        find.byKey(const ValueKey('waflo-workspace-notification-count')),
        findsOneWidget,
      );
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('9. long Arabic name does not overflow at 360px', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          child: WafloWorkspaceHeader(
            workspaceName:
                'اسم مساحة مطعم عربي طويل لا يصطدم بالحالة أو إجراء الإشعارات',
            statusLabel: _statusLabel,
            onNotificationPressed: () {},
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('10. header remains usable with increased text scaling', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          textScale: 1.4,
          child: WafloWorkspaceHeader(
            workspaceName: 'مساحة عمل عربية ذات اسم واضح وطويل',
            statusLabel: _statusLabel,
            onNotificationPressed: () {},
          ),
        ),
      );

      expect(find.text(_statusLabel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('11. notification target meets the 48px minimum', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          child: WafloWorkspaceHeader(
            workspaceName: _workspaceName,
            onNotificationPressed: () {},
          ),
        ),
      );

      final size = tester.getSize(
        find.byKey(const ValueKey('waflo-workspace-notification-action')),
      );
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('12. header stays compact without a fixed oversized height', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          width: 390,
          child: WafloWorkspaceHeader(
            workspaceName: _workspaceName,
            statusLabel: _statusLabel,
            onNotificationPressed: () {},
          ),
        ),
      );

      final size = tester.getSize(
        find.byKey(const ValueKey('waflo-workspace-header-surface')),
      );
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.height, lessThan(96));
    });

    test(
      '13. header performs no repository, Cubit, auth, or network lookup',
      () {
        final source = File(
          'lib/shared/widgets/v3/waflo_workspace_header.dart',
        ).readAsStringSync();

        expect(
          source,
          isNot(contains(RegExp(r'\b(Repository|Cubit|Bloc|Auth)\b'))),
        );
        expect(source, isNot(contains('Image.network')));
        expect(source, isNot(contains('NetworkImage')));
        expect(source, isNot(contains('http')));
        expect(source, isNot(contains('businesses.first')));
      },
    );
  });

  group('WafloBottomNavigation', () {
    testWidgets('14. exactly five destinations render', (tester) async {
      await tester.pumpWidget(_harness(child: _navigation()));

      for (final destination in WafloWorkspaceDestination.values) {
        expect(_destination(destination), findsOneWidget);
      }
      expect(WafloWorkspaceDestination.values, hasLength(5));
    });

    testWidgets('14. labels match the canonical Arabic order', (tester) async {
      await tester.pumpWidget(_harness(child: _navigation()));

      expect(
        WafloWorkspaceDestination.values.map((value) => value.label),
        const ['الرئيسية', 'المنيو', 'المسح', 'الولاء', 'الإعدادات'],
      );
      for (final label in WafloWorkspaceDestination.values.map(
        (value) => value.label,
      )) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('15. selected destination exposes selected semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _harness(child: _navigation(selected: WafloWorkspaceDestination.menu)),
      );

      final data = tester
          .getSemantics(_destination(WafloWorkspaceDestination.menu))
          .getSemanticsData();
      expect(data.flagsCollection.isSelected, Tristate.isTrue);
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.label, WafloWorkspaceDestination.menu.label);
      semantics.dispose();
    });

    testWidgets('16. selected icon and label use canonical primary', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          child: _navigation(selected: WafloWorkspaceDestination.loyalty),
        ),
      );

      final icon = tester.widget<Icon>(
        find.byKey(const ValueKey('waflo-bottom-navigation-icon-loyalty')),
      );
      final label = tester.widget<Text>(
        find.byKey(const ValueKey('waflo-bottom-navigation-label-loyalty')),
      );
      expect(icon.color, WafloV3Colors.primary);
      expect(label.style?.color, WafloV3Colors.primary);
    });

    testWidgets('17. selected destination has a non-color indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          child: _navigation(selected: WafloWorkspaceDestination.scanner),
        ),
      );

      final indicator = find.byKey(
        const ValueKey('waflo-bottom-navigation-indicator-scanner'),
      );
      expect(indicator, findsOneWidget);
      expect(tester.getSize(indicator).width, WafloV3Spacing.space24);
      expect(tester.getSize(indicator).height, WafloV3Spacing.space4);
    });

    testWidgets('18. tapping each destination reports the typed value', (
      tester,
    ) async {
      final received = <WafloWorkspaceDestination>[];
      var selected = WafloWorkspaceDestination.home;

      await tester.pumpWidget(
        _harness(
          child: StatefulBuilder(
            builder: (context, setState) {
              return WafloBottomNavigation(
                selectedDestination: selected,
                onDestinationSelected: (destination) {
                  received.add(destination);
                  setState(() => selected = destination);
                },
              );
            },
          ),
        ),
      );

      const tapOrder = [
        WafloWorkspaceDestination.menu,
        WafloWorkspaceDestination.scanner,
        WafloWorkspaceDestination.loyalty,
        WafloWorkspaceDestination.settings,
        WafloWorkspaceDestination.home,
      ];
      for (final destination in tapOrder) {
        await tester.tap(_destination(destination));
        await tester.pump();
      }
      expect(received, tapOrder);
    });

    testWidgets('19. scanner is not wider or taller than other destinations', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(child: _navigation()));

      final scannerSize = tester.getSize(
        _destination(WafloWorkspaceDestination.scanner),
      );
      for (final destination in WafloWorkspaceDestination.values) {
        expect(tester.getSize(_destination(destination)), scannerSize);
      }
    });

    testWidgets('20. scanner does not float', (tester) async {
      await tester.pumpWidget(
        _harness(
          child: _navigation(selected: WafloWorkspaceDestination.scanner),
        ),
      );

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(BottomAppBar), findsNothing);
      expect(
        tester.getTopLeft(_destination(WafloWorkspaceDestination.scanner)).dy,
        tester.getTopLeft(_destination(WafloWorkspaceDestination.home)).dy,
      );
    });

    testWidgets('21. every destination meets the 48px touch target', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(child: _navigation()));

      for (final destination in WafloWorkspaceDestination.values) {
        final size = tester.getSize(_destination(destination));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('22. component respects the bottom SafeArea', (tester) async {
      await tester.pumpWidget(_harness(bottomInset: 24, child: _navigation()));

      final safeArea = tester.widget<SafeArea>(
        find.descendant(
          of: find.byType(WafloBottomNavigation),
          matching: find.byType(SafeArea),
        ),
      );
      expect(safeArea.top, isFalse);
      expect(safeArea.bottom, isTrue);
      expect(
        tester.getSize(find.byType(WafloBottomNavigation)).height,
        greaterThan(48 + 24),
      );
    });

    testWidgets('23. labels do not overflow at 360px', (tester) async {
      await tester.pumpWidget(_harness(child: _navigation()));

      expect(tester.takeException(), isNull);
      for (final destination in WafloWorkspaceDestination.values) {
        expect(find.text(destination.label), findsOneWidget);
      }
    });

    testWidgets('24. moderate text scaling has no horizontal overflow', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(textScale: 1.4, child: _navigation()));

      expect(tester.takeException(), isNull);
      for (final destination in WafloWorkspaceDestination.values) {
        expect(find.text(destination.label), findsOneWidget);
      }
    });

    test('25. API contains no Navigator or hardcoded route behavior', () {
      final source = File(
        'lib/shared/widgets/v3/waflo_bottom_navigation.dart',
      ).readAsStringSync();

      expect(source, isNot(contains(RegExp(r'\b(Navigator|Router)\b'))));
      expect(source, isNot(contains('pushNamed')));
      expect(source, isNot(contains('/dashboard')));
    });

    test('26. component contains no sample runtime domain data', () {
      final source = File(
        'lib/shared/widgets/v3/waflo_bottom_navigation.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('مطعم وفلو المميز')));
      expect(source, isNot(contains('6500')));
      expect(source, isNot(contains('Customer')));
      expect(source, isNot(contains('Product')));
      expect(source, isNot(contains('businesses.first')));
    });
  });

  testWidgets('27. both components render with WafloV3Theme.light', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WafloWorkspaceHeader(workspaceName: _workspaceName),
            _navigation(),
          ],
        ),
      ),
    );

    final context = tester.element(find.byType(WafloWorkspaceHeader));
    expect(Theme.of(context).colorScheme.primary, WafloV3Colors.primary);
    expect(find.byType(WafloBottomNavigation), findsOneWidget);
  });

  testWidgets('28. both components work without global V3 theme wiring', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        useV3Theme: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WafloWorkspaceHeader(workspaceName: _workspaceName),
            _navigation(),
          ],
        ),
      ),
    );

    expect(find.byType(WafloWorkspaceHeader), findsOneWidget);
    expect(find.byType(WafloBottomNavigation), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('29. sources require no golden or network dependency', () {
    const paths = [
      'lib/shared/widgets/v3/waflo_workspace_header.dart',
      'lib/shared/widgets/v3/waflo_bottom_navigation.dart',
    ];
    final source = paths
        .map((path) => File(path).readAsStringSync())
        .join('\n');

    expect(source, isNot(contains('matchesGoldenFile')));
    expect(source, isNot(contains('golden')));
    expect(source, isNot(contains('Image.network')));
    expect(source, isNot(contains('NetworkImage')));
    expect(source, isNot(contains("package:http")));
  });
}
