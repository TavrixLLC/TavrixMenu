import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/theme/v3/waflo_v3_tokens.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_bottom_navigation.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_inline_error.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_shell_v3.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_skeleton.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v3/waflo_workspace_header.dart';

const _workspaceName = 'مساحة العمل التجريبية';

void main() {
  testWidgets('accepts exactly five typed destinations and starts at Home', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(shell: _shell()));

    expect(WafloWorkspaceDestination.values, hasLength(5));
    for (final destination in WafloWorkspaceDestination.values) {
      expect(_destination(destination), findsOneWidget);
    }
    expect(find.text('home-body'), findsOneWidget);
    expect(find.text('menu-body'), findsNothing);
  });

  testWidgets('each tab displays its supplied destination without Navigator', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(shell: _shell()));

    const cases = <WafloWorkspaceDestination, String>{
      WafloWorkspaceDestination.menu: 'menu-body',
      WafloWorkspaceDestination.scanner: 'scanner-body',
      WafloWorkspaceDestination.loyalty: 'loyalty-body',
      WafloWorkspaceDestination.settings: 'settings-body',
      WafloWorkspaceDestination.home: 'home-body',
    };
    for (final entry in cases.entries) {
      await tester.tap(_destination(entry.key));
      await tester.pump();
      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('typed shell controller selects a canonical destination', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        shell: _shell(
          home: Builder(
            builder: (context) => TextButton(
              key: const ValueKey('select-scanner-from-home'),
              onPressed: () => WafloShellV3.maybeControllerOf(
                context,
              )!.selectDestination(WafloWorkspaceDestination.scanner),
              child: const Text('select scanner'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('select-scanner-from-home')));
    await tester.pump();

    expect(find.text('scanner-body'), findsOneWidget);
    expect(
      tester
          .widget<Semantics>(_destination(WafloWorkspaceDestination.scanner))
          .properties
          .selected,
      isTrue,
    );
  });

  testWidgets('selected retap is ignored and body state is preserved', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(shell: _shell(menu: const _StatefulDestination())),
    );

    await tester.tap(_destination(WafloWorkspaceDestination.menu));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('increment-menu-state')));
    await tester.pump();
    expect(find.text('menu-state:1'), findsOneWidget);

    await tester.tap(_destination(WafloWorkspaceDestination.menu));
    await tester.pump();
    expect(find.text('menu-state:1'), findsOneWidget);

    await tester.tap(_destination(WafloWorkspaceDestination.home));
    await tester.pump();
    await tester.tap(_destination(WafloWorkspaceDestination.menu));
    await tester.pump();
    expect(find.text('menu-state:1'), findsOneWidget);
  });

  testWidgets('lifecycle identity change resets selection to Home', (
    tester,
  ) async {
    var lifecycleIdentity = 'principal-a:workspace-a';
    late StateSetter updateHarness;

    await tester.pumpWidget(
      _harness(
        shell: StatefulBuilder(
          builder: (context, setState) {
            updateHarness = setState;
            return _shell(
              lifecycleIdentity: lifecycleIdentity,
              menu: const _StatefulDestination(),
            );
          },
        ),
      ),
    );
    await tester.tap(_destination(WafloWorkspaceDestination.menu));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('increment-menu-state')));
    await tester.pump();
    expect(find.text('menu-state:1'), findsOneWidget);

    updateHarness(() => lifecycleIdentity = 'principal-b:workspace-b');
    await tester.pump();

    expect(find.text('home-body'), findsOneWidget);

    await tester.tap(_destination(WafloWorkspaceDestination.menu));
    await tester.pump();
    expect(find.text('menu-state:0'), findsOneWidget);
  });

  testWidgets('loading and unavailable identity never fabricate a name', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        shell: _shell(
          identityState: WafloWorkspaceIdentityState.loading,
          workspaceName: null,
        ),
      ),
    );
    expect(find.byType(WafloWorkspaceHeader), findsNothing);
    expect(find.byType(WafloSkeleton), findsWidgets);
    expect(find.text(_workspaceName), findsNothing);

    await tester.pumpWidget(
      _harness(
        shell: _shell(
          identityState: WafloWorkspaceIdentityState.unavailable,
          workspaceName: null,
        ),
      ),
    );
    expect(find.byType(WafloWorkspaceHeader), findsNothing);
    expect(find.byType(WafloInlineError), findsOneWidget);
    expect(find.text(_workspaceName), findsNothing);
  });

  testWidgets(
    'scanner is equal-sized, non-floating, and navigation is below body',
    (tester) async {
      await tester.pumpWidget(_harness(shell: _shell()));

      final scannerSize = tester.getSize(
        _destination(WafloWorkspaceDestination.scanner),
      );
      for (final destination in WafloWorkspaceDestination.values) {
        expect(tester.getSize(_destination(destination)), scannerSize);
      }
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(BottomAppBar), findsNothing);

      final bodyBottom = tester
          .getBottomLeft(find.byKey(const ValueKey('waflo-shell-v3-body')))
          .dy;
      final navigationTop = tester
          .getTopLeft(find.byType(WafloBottomNavigation))
          .dy;
      expect(bodyBottom, lessThanOrEqualTo(navigationTop));
    },
  );

  testWidgets(
    'shell consumes device SafeAreas without duplicating body padding',
    (tester) async {
      await tester.pumpWidget(
        _harness(shell: _shell(), topInset: 28, bottomInset: 24),
      );

      expect(
        tester
            .getTopLeft(
              find.byKey(const ValueKey('waflo-workspace-avatar-fallback')),
            )
            .dy,
        greaterThanOrEqualTo(28),
      );
      expect(
        tester.getSize(find.byType(WafloBottomNavigation)).height,
        greaterThan(48 + 24),
      );
      final bodyMediaQuery = MediaQuery.of(
        tester.element(find.byKey(const ValueKey('home-body'))),
      );
      expect(bodyMediaQuery.padding.top, 0);
      expect(bodyMediaQuery.padding.bottom, 0);
    },
  );

  testWidgets('V3 theme is scoped to the shell subtree', (tester) async {
    await tester.pumpWidget(
      _harness(
        shell: _shell(
          home: Builder(
            builder: (context) => Text(
              'theme:${Theme.of(context).colorScheme.primary.toARGB32()}',
              key: const ValueKey('theme-probe'),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('theme:${WafloV3Colors.primary.toARGB32()}'),
      findsOneWidget,
    );
  });

  testWidgets('long Arabic identity is safe at 360px and moderate text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        width: 360,
        textScale: 1.4,
        shell: _shell(
          workspaceName:
              'اسم مساحة عمل مطعم عربي طويل للاختبار على شاشة هاتف ضيقة',
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'notification action and count are absent without real callback',
    (tester) async {
      await tester.pumpWidget(_harness(shell: _shell()));

      expect(
        find.byKey(const ValueKey('waflo-workspace-notification-action')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('waflo-workspace-notification-count')),
        findsNothing,
      );
    },
  );

  test(
    'source owns no navigation, repository, network, or sample identity',
    () {
      final source = File(
        'lib/shared/widgets/v3/waflo_shell_v3.dart',
      ).readAsStringSync();

      expect(source, isNot(contains(RegExp(r'\bNavigator\b|pushNamed'))));
      expect(
        source,
        isNot(contains(RegExp(r'\bRepository\b|businesses\.first'))),
      );
      expect(source, isNot(contains('Image.network')));
      expect(source, isNot(contains('NetworkImage')));
      expect(source, isNot(contains('مطعم وفلو المميز')));
      expect(source, isNot(contains('unreadCount: 0')));
      expect(source, isNot(contains('ProductEditor')));
    },
  );
}

Finder _destination(WafloWorkspaceDestination destination) {
  return find.byKey(ValueKey('waflo-bottom-navigation-${destination.name}'));
}

Widget _harness({
  required Widget shell,
  double width = 390,
  double textScale = 1,
  double topInset = 0,
  double bottomInset = 0,
}) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 800),
        padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
        textScaler: TextScaler.linear(textScale),
      ),
      child: SizedBox(width: width, child: shell),
    ),
  );
}

WafloShellV3 _shell({
  Object lifecycleIdentity = 'principal:workspace',
  WafloWorkspaceIdentityState identityState = WafloWorkspaceIdentityState.ready,
  String? workspaceName = _workspaceName,
  Widget home = const Text('home-body', key: ValueKey('home-body')),
  Widget menu = const Text('menu-body', key: ValueKey('menu-body')),
}) {
  return WafloShellV3(
    workspaceLifecycleIdentity: lifecycleIdentity,
    workspaceIdentityState: identityState,
    workspaceName: workspaceName,
    home: home,
    menu: menu,
    scanner: const Text('scanner-body', key: ValueKey('scanner-body')),
    loyalty: const Text('loyalty-body', key: ValueKey('loyalty-body')),
    settings: const Text('settings-body', key: ValueKey('settings-body')),
  );
}

class _StatefulDestination extends StatefulWidget {
  const _StatefulDestination();

  @override
  State<_StatefulDestination> createState() => _StatefulDestinationState();
}

class _StatefulDestinationState extends State<_StatefulDestination> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('menu-state:$_count'),
        TextButton(
          key: const ValueKey('increment-menu-state'),
          onPressed: () => setState(() => _count += 1),
          child: const Text('increment'),
        ),
      ],
    );
  }
}
