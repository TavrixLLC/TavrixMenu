import 'package:flutter/material.dart';

import '../core/localization/waflo_v2_strings.dart';
import '../core/state/waflo_view_state.dart';
import '../core/workspace/workspace_models.dart';
import '../core/workspace/workspace_resolution.dart';
import '../shared/components/waflo_state_view.dart';

class WafloWorkspaceGate extends StatelessWidget {
  const WafloWorkspaceGate({
    required this.resolution,
    required this.readyBuilder,
    super.key,
  });

  final WorkspaceResolution resolution;
  final Widget Function(
    BuildContext context,
    WorkspaceMembershipContract membership,
  )
  readyBuilder;

  @override
  Widget build(BuildContext context) {
    if (resolution.kind == WorkspaceResolutionKind.ready) {
      return readyBuilder(context, resolution.membership!);
    }

    final strings = context.wafloV2;
    final isSelection =
        resolution.kind == WorkspaceResolutionKind.selectionRequired;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: isSelection
                  ? WafloStateView(
                      key: const ValueKey('workspace-selection-required'),
                      state: const WafloViewState(
                        kind: WafloViewStateKind.disabled,
                      ),
                      actionLabel: strings.selectWorkspace,
                      onAction: null,
                    )
                  : const WafloStateView(
                      key: ValueKey('workspace-no-access'),
                      state: WafloViewState(kind: WafloViewStateKind.forbidden),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
