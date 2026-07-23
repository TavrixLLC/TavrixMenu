import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/waflo_v2/app/waflo_v2_app_shell.dart';
import 'package:tavrix_menu_mobile/waflo_v2/app/waflo_workspace_gate.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/navigation/waflo_destination.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/workspace/workspace_models.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/workspace/workspace_resolution.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/home/presentation/waflo_foundation_overview.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_brand_mark.dart';

import '../test_fixtures.dart';

void main() {
  testWidgets('Owner shell renders five equal top-level destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      foundationHarness(
        home: WafloV2AppShell(
          workspace: ownerWorkspace(),
          destinationBuilder: _destinationBuilder,
        ),
      ),
    );

    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(
      find.byKey(const ValueKey('waflo-v2-navigation-programs')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('waflo-v2-navigation-scan')),
      findsOneWidget,
    );
    expect(find.text('مقهى دجلة'), findsOneWidget);
    expect(find.textContaining('فرع الكرادة'), findsWidgets);
    expect(find.byType(WafloBrandMark), findsOneWidget);
  });

  testWidgets(
    'Staff shell starts at Scan and omits configuration destinations',
    (tester) async {
      await tester.pumpWidget(
        foundationHarness(
          locale: const Locale('ckb'),
          home: WafloV2AppShell(
            workspace: staffWorkspace(),
            destinationBuilder: _destinationBuilder,
          ),
        ),
      );

      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(
        find.byKey(const ValueKey('waflo-v2-navigation-scan')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('waflo-v2-navigation-programs')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('destination-scan')), findsOneWidget);
      expect(
        Directionality.of(
          tester.element(find.byKey(const ValueKey('destination-scan'))),
        ),
        TextDirection.rtl,
      );
    },
  );

  testWidgets('English shell is LTR and Manager sees permitted branches', (
    tester,
  ) async {
    await tester.pumpWidget(
      foundationHarness(
        locale: const Locale('en'),
        home: WafloV2AppShell(
          workspace: managerWorkspace(),
          destinationBuilder: _destinationBuilder,
        ),
      ),
    );
    expect(
      Directionality.of(tester.element(find.byType(WafloV2AppShell))),
      TextDirection.ltr,
    );
    expect(find.text('Dijla Café'), findsOneWidget);
    expect(find.textContaining('فرع المنصور'), findsWidgets);
  });

  testWidgets('workspace identity change resets the selected destination', (
    tester,
  ) async {
    late StateSetter update;
    var workspace = ownerWorkspace();
    await tester.pumpWidget(
      foundationHarness(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return WafloV2AppShell(
              workspace: workspace,
              destinationBuilder: _destinationBuilder,
            );
          },
        ),
      ),
    );
    await tester.tap(
      find.byKey(const ValueKey('waflo-v2-navigation-programs')),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('destination-programs')), findsOneWidget);

    final secondMembership = WorkspaceMembershipContract(
      businessId: 'business-review-b',
      businessDisplayName: 'نشاط ثانٍ',
      role: WafloMembershipRole.owner,
      branchAccess: const BranchAccessScope.all(),
      capabilities: WafloCapability.values.toSet(),
    );
    update(() {
      workspace = ActiveWorkspaceContract(
        membership: secondMembership,
        visibleBranches: const [
          BranchSummaryContract(id: 'branch-second', displayName: 'فرع ثانٍ'),
        ],
        activeBranch: const BranchSummaryContract(
          id: 'branch-second',
          displayName: 'فرع ثانٍ',
        ),
      );
    });
    await tester.pump();

    expect(find.byKey(const ValueKey('destination-home')), findsOneWidget);
    expect(find.text('نشاط ثانٍ'), findsOneWidget);
    expect(find.text('مقهى دجلة'), findsNothing);
  });

  testWidgets('ambiguous workspace state fails closed', (tester) async {
    await tester.pumpWidget(
      foundationHarness(
        home: WafloWorkspaceGate(
          resolution: const WorkspaceResolution.selectionRequired(),
          readyBuilder: (_, _) => const SizedBox.shrink(),
        ),
      ),
    );
    expect(
      find.byKey(const ValueKey('workspace-selection-required')),
      findsOneWidget,
    );
    expect(find.byType(WafloV2AppShell), findsNothing);
  });
}

Widget _destinationBuilder(BuildContext context, WafloDestination destination) {
  if (destination == WafloDestination.home) {
    return KeyedSubtree(
      key: const ValueKey('destination-home'),
      child: WafloFoundationOverview(workspace: ownerWorkspace()),
    );
  }
  return Center(
    child: Text(
      destination.name,
      key: ValueKey('destination-${destination.name}'),
    ),
  );
}
