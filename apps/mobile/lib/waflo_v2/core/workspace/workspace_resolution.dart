import 'workspace_models.dart';

enum WorkspaceResolutionKind {
  ready,
  selectionRequired,
  noAccess,
  invalidSelection,
}

class WorkspaceResolution {
  const WorkspaceResolution._(this.kind, this.membership);

  const WorkspaceResolution.ready(WorkspaceMembershipContract membership)
    : this._(WorkspaceResolutionKind.ready, membership);

  const WorkspaceResolution.selectionRequired()
    : this._(WorkspaceResolutionKind.selectionRequired, null);

  const WorkspaceResolution.noAccess()
    : this._(WorkspaceResolutionKind.noAccess, null);

  const WorkspaceResolution.invalidSelection()
    : this._(WorkspaceResolutionKind.invalidSelection, null);

  final WorkspaceResolutionKind kind;
  final WorkspaceMembershipContract? membership;
}

/// Resolves an active business only from authoritative membership input.
///
/// There is no list-position fallback. Multiple memberships require an exact
/// selected business identifier supplied by a trusted session decision.
abstract final class WorkspaceResolver {
  static WorkspaceResolution resolve({
    required List<WorkspaceMembershipContract> memberships,
    String? selectedBusinessId,
  }) {
    if (memberships.isEmpty) {
      return const WorkspaceResolution.noAccess();
    }

    final selected = selectedBusinessId?.trim();
    if (selected != null && selected.isNotEmpty) {
      WorkspaceMembershipContract? match;
      for (final membership in memberships) {
        if (membership.businessId == selected) {
          if (match != null) {
            return const WorkspaceResolution.invalidSelection();
          }
          match = membership;
        }
      }
      return match == null
          ? const WorkspaceResolution.invalidSelection()
          : WorkspaceResolution.ready(match);
    }

    if (memberships.length == 1) {
      return WorkspaceResolution.ready(memberships.single);
    }

    return const WorkspaceResolution.selectionRequired();
  }
}
