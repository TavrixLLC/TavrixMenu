import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/workspace/branch_visibility_policy.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/workspace/workspace_models.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/workspace/workspace_resolution.dart';

import '../../test_fixtures.dart';

void main() {
  test('no membership fails closed', () {
    final result = WorkspaceResolver.resolve(memberships: const []);
    expect(result.kind, WorkspaceResolutionKind.noAccess);
  });

  test('one authoritative membership resolves without list-order guessing', () {
    final membership = ownerMembership();
    final result = WorkspaceResolver.resolve(memberships: [membership]);
    expect(result.kind, WorkspaceResolutionKind.ready);
    expect(result.membership, same(membership));
  });

  test('multiple memberships require an explicit business selection', () {
    final result = WorkspaceResolver.resolve(
      memberships: [ownerMembership(), managerMembership()],
    );
    expect(result.kind, WorkspaceResolutionKind.selectionRequired);
    expect(result.membership, isNull);
  });

  test(
    'exact selected business resolves and unknown selection fails closed',
    () {
      final memberships = [
        ownerMembership(),
        WorkspaceMembershipContract(
          businessId: 'business-review-b',
          businessDisplayName: 'Second business',
          role: WafloMembershipRole.manager,
          branchAccess: const BranchAccessScope.all(),
          capabilities: const {WafloCapability.viewHome},
        ),
      ];
      final selected = WorkspaceResolver.resolve(
        memberships: memberships,
        selectedBusinessId: 'business-review-b',
      );
      final invalid = WorkspaceResolver.resolve(
        memberships: memberships,
        selectedBusinessId: 'business-unknown',
      );
      expect(selected.kind, WorkspaceResolutionKind.ready);
      expect(selected.membership!.businessId, 'business-review-b');
      expect(invalid.kind, WorkspaceResolutionKind.invalidSelection);
    },
  );

  test(
    'Owner sees every authoritative branch regardless of assignment input',
    () {
      final visible = BranchVisibilityPolicy.visibleBranches(
        membership: ownerMembership(),
        authoritativeBranches: reviewBranches,
      );
      expect(visible, reviewBranches);
    },
  );

  test('Manager sees one, several, or all assigned branches only', () {
    final visible = BranchVisibilityPolicy.visibleBranches(
      membership: managerMembership(),
      authoritativeBranches: reviewBranches,
    );
    expect(visible.map((branch) => branch.id), [
      'branch-karrada',
      'branch-mansour',
    ]);
    expect(visible.map((branch) => branch.id), isNot(contains('branch-basra')));
  });

  test('Staff defaults safely only when exactly one visible branch exists', () {
    final visible = BranchVisibilityPolicy.visibleBranches(
      membership: staffMembership(),
      authoritativeBranches: reviewBranches,
    );
    final active = BranchVisibilityPolicy.resolveActiveBranch(
      membership: staffMembership(),
      visibleBranches: visible,
    );
    expect(visible, hasLength(1));
    expect(active!.id, 'branch-karrada');
  });

  test('source contains no businesses.first fallback', () {
    final source = File(
      'lib/waflo_v2/core/workspace/workspace_resolution.dart',
    ).readAsStringSync();
    expect(source, isNot(contains('businesses.first')));
    expect(source, isNot(contains('memberships.first')));
  });
}
