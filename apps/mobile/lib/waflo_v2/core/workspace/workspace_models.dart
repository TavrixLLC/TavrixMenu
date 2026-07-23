enum WafloMembershipRole { owner, manager, staff }

enum WafloCapability {
  viewHome,
  viewPrograms,
  useScanner,
  viewCustomers,
  viewRewards,
  viewOwnActivity,
  viewAccount,
  viewMore,
  managePrograms,
  manageCardDesign,
}

enum BranchAccessKind { none, selected, all }

class BranchAccessScope {
  BranchAccessScope._(this.kind, Set<String> branchIds)
    : branchIds = Set.unmodifiable(branchIds);

  const BranchAccessScope.none()
    : kind = BranchAccessKind.none,
      branchIds = const {};

  const BranchAccessScope.all()
    : kind = BranchAccessKind.all,
      branchIds = const {};

  factory BranchAccessScope.selected(Iterable<String> branchIds) {
    final normalized = branchIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    if (normalized.isEmpty) {
      return const BranchAccessScope.none();
    }
    return BranchAccessScope._(BranchAccessKind.selected, normalized);
  }

  final BranchAccessKind kind;
  final Set<String> branchIds;

  bool allows(String branchId) {
    return kind == BranchAccessKind.all ||
        (kind == BranchAccessKind.selected && branchIds.contains(branchId));
  }

  String? get onlyBranchId {
    return kind == BranchAccessKind.selected && branchIds.length == 1
        ? branchIds.single
        : null;
  }
}

class WorkspaceMembershipContract {
  WorkspaceMembershipContract({
    required this.businessId,
    required this.businessDisplayName,
    required this.role,
    required this.branchAccess,
    required Set<WafloCapability> capabilities,
  }) : capabilities = Set.unmodifiable(capabilities);

  final String businessId;
  final String businessDisplayName;
  final WafloMembershipRole role;
  final BranchAccessScope branchAccess;
  final Set<WafloCapability> capabilities;

  bool can(WafloCapability capability) => capabilities.contains(capability);
}

class BranchSummaryContract {
  const BranchSummaryContract({required this.id, required this.displayName});

  final String id;
  final String displayName;
}

class ActiveWorkspaceContract {
  const ActiveWorkspaceContract({
    required this.membership,
    required this.visibleBranches,
    this.activeBranch,
  });

  final WorkspaceMembershipContract membership;
  final List<BranchSummaryContract> visibleBranches;
  final BranchSummaryContract? activeBranch;

  String get lifecycleIdentity {
    return '${membership.businessId}:${activeBranch?.id ?? 'no-branch'}';
  }
}
