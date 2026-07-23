import 'package:flutter/material.dart';

import '../../../core/localization/waflo_v2_strings.dart';
import '../../../core/theme/waflo_spacing.dart';
import '../../../core/workspace/workspace_models.dart';
import '../../../shared/components/waflo_buttons.dart';
import '../../../shared/components/waflo_info_banner.dart';
import '../../../shared/components/waflo_section_card.dart';
import '../../../shared/components/waflo_status_chip.dart';

class WafloFoundationOverview extends StatelessWidget {
  const WafloFoundationOverview({required this.workspace, super.key});

  final ActiveWorkspaceContract workspace;

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    return ListView(
      padding: const EdgeInsetsDirectional.all(WafloSpacing.screenInset),
      children: [
        WafloInfoBanner(
          title: strings.foundationPreview,
          body: strings.previewOnly,
          tone: WafloBannerTone.information,
        ),
        const SizedBox(height: WafloSpacing.x4),
        Text(
          strings.foundationReady,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: WafloSpacing.x2),
        Text(
          strings.foundationReadyBody,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: WafloSpacing.x6),
        WafloSectionCard(
          title: strings.activeProgram,
          leading: Icons.loyalty_outlined,
          trailing: WafloStatusChip(
            label: strings.oneActivePolicy,
            tone: WafloStatusTone.success,
            icon: Icons.check_rounded,
          ),
          child: Text(
            strings.activeProgramBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: WafloSpacing.x3),
        WafloSectionCard(
          title: strings.branchAccess,
          leading: Icons.account_tree_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.branchAccessBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (workspace.visibleBranches.isNotEmpty) ...[
                const SizedBox(height: WafloSpacing.x3),
                Wrap(
                  spacing: WafloSpacing.x2,
                  runSpacing: WafloSpacing.x2,
                  children: workspace.visibleBranches
                      .map(
                        (branch) => WafloStatusChip(
                          label: branch.displayName,
                          tone: WafloStatusTone.neutral,
                          icon: Icons.storefront_outlined,
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: WafloSpacing.x4),
        WafloPrimaryButton(
          label: strings.unavailableAction,
          onPressed: null,
          disabledReason: strings.disabledBody,
        ),
      ],
    );
  }
}
