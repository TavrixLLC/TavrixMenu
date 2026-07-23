import 'workspace_models.dart';

/// Presentation filtering only. Every backend operation must independently
/// authorize both Business and Branch membership.
abstract final class BranchVisibilityPolicy {
  static List<BranchSummaryContract> visibleBranches({
    required WorkspaceMembershipContract membership,
    required List<BranchSummaryContract> authoritativeBranches,
  }) {
    if (membership.role == WafloMembershipRole.owner) {
      return List.unmodifiable(authoritativeBranches);
    }

    if (membership.branchAccess.kind == BranchAccessKind.none) {
      return const [];
    }

    if (membership.branchAccess.kind == BranchAccessKind.all) {
      return List.unmodifiable(authoritativeBranches);
    }

    return List.unmodifiable(
      authoritativeBranches.where(
        (branch) => membership.branchAccess.allows(branch.id),
      ),
    );
  }

  static BranchSummaryContract? resolveActiveBranch({
    required WorkspaceMembershipContract membership,
    required List<BranchSummaryContract> visibleBranches,
    String? selectedBranchId,
  }) {
    final selected = selectedBranchId?.trim();
    if (selected != null && selected.isNotEmpty) {
      for (final branch in visibleBranches) {
        if (branch.id == selected &&
            (membership.role == WafloMembershipRole.owner ||
                membership.branchAccess.allows(branch.id))) {
          return branch;
        }
      }
      return null;
    }

    if (visibleBranches.length == 1) {
      return visibleBranches.single;
    }
    return null;
  }
}
