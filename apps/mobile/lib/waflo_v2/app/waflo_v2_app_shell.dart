import 'package:flutter/material.dart';

import '../core/localization/waflo_v2_strings.dart';
import '../core/navigation/waflo_destination.dart';
import '../core/navigation/waflo_navigation_policy.dart';
import '../core/theme/waflo_colors.dart';
import '../core/theme/waflo_spacing.dart';
import '../core/workspace/workspace_models.dart';
import '../shared/components/waflo_brand_mark.dart';
import '../shared/components/waflo_status_chip.dart';

typedef WafloDestinationBuilder =
    Widget Function(BuildContext context, WafloDestination destination);

class WafloV2AppShell extends StatefulWidget {
  const WafloV2AppShell({
    required this.workspace,
    required this.destinationBuilder,
    super.key,
    this.initialDestination,
  });

  final ActiveWorkspaceContract workspace;
  final WafloDestinationBuilder destinationBuilder;
  final WafloDestination? initialDestination;

  @override
  State<WafloV2AppShell> createState() => _WafloV2AppShellState();
}

class _WafloV2AppShellState extends State<WafloV2AppShell> {
  late WafloDestination _selectedDestination = _resolveInitialDestination();

  List<WafloDestination> get _destinations =>
      WafloNavigationPolicy.destinationsFor(widget.workspace.membership);

  WafloDestination _resolveInitialDestination() {
    final allowed = WafloNavigationPolicy.destinationsFor(
      widget.workspace.membership,
    );
    if (widget.initialDestination != null &&
        allowed.contains(widget.initialDestination)) {
      return widget.initialDestination!;
    }
    return WafloNavigationPolicy.initialDestinationFor(
      widget.workspace.membership,
    );
  }

  @override
  void didUpdateWidget(covariant WafloV2AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspace.lifecycleIdentity !=
        widget.workspace.lifecycleIdentity) {
      _selectedDestination = _resolveInitialDestination();
      return;
    }
    if (!_destinations.contains(_selectedDestination)) {
      _selectedDestination = _resolveInitialDestination();
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations;
    final selectedIndex = destinations.indexOf(_selectedDestination);
    return Scaffold(
      body: Column(
        children: [
          _WorkspaceHeader(workspace: widget.workspace),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey(
                '${widget.workspace.lifecycleIdentity}:${_selectedDestination.name}',
              ),
              child: widget.destinationBuilder(context, _selectedDestination),
            ),
          ),
        ],
      ),
      bottomNavigationBar: destinations.isEmpty
          ? null
          : NavigationBar(
              key: const ValueKey('waflo-v2-bottom-navigation'),
              selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
              onDestinationSelected: (index) {
                final destination = destinations[index];
                if (destination == _selectedDestination) {
                  return;
                }
                setState(() => _selectedDestination = destination);
              },
              destinations: destinations
                  .map(
                    (destination) => NavigationDestination(
                      key: ValueKey('waflo-v2-navigation-${destination.name}'),
                      icon: Icon(_iconFor(destination, selected: false)),
                      selectedIcon: Icon(_iconFor(destination, selected: true)),
                      label: _labelFor(context, destination),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }

  IconData _iconFor(WafloDestination destination, {required bool selected}) {
    return switch (destination) {
      WafloDestination.home =>
        selected ? Icons.home_rounded : Icons.home_outlined,
      WafloDestination.programs =>
        selected ? Icons.loyalty_rounded : Icons.loyalty_outlined,
      WafloDestination.scan =>
        selected
            ? Icons.qr_code_scanner_rounded
            : Icons.qr_code_scanner_outlined,
      WafloDestination.customers =>
        selected ? Icons.groups_rounded : Icons.groups_outlined,
      WafloDestination.rewards =>
        selected ? Icons.redeem_rounded : Icons.redeem_outlined,
      WafloDestination.myActivity =>
        selected ? Icons.history_rounded : Icons.history_outlined,
      WafloDestination.account =>
        selected ? Icons.account_circle_rounded : Icons.account_circle_outlined,
      WafloDestination.more =>
        selected ? Icons.more_horiz_rounded : Icons.more_horiz_outlined,
    };
  }

  String _labelFor(BuildContext context, WafloDestination destination) {
    final strings = context.wafloV2;
    return switch (destination) {
      WafloDestination.home => strings.home,
      WafloDestination.programs => strings.programs,
      WafloDestination.scan => strings.scan,
      WafloDestination.customers => strings.customers,
      WafloDestination.rewards => strings.rewards,
      WafloDestination.myActivity => strings.myActivity,
      WafloDestination.account => strings.account,
      WafloDestination.more => strings.more,
    };
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({required this.workspace});

  final ActiveWorkspaceContract workspace;

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    final membership = workspace.membership;
    final roleLabel = switch (membership.role) {
      WafloMembershipRole.owner => strings.owner,
      WafloMembershipRole.manager => strings.manager,
      WafloMembershipRole.staff => strings.staff,
    };

    return Material(
      color: WafloColors.surface,
      child: SafeArea(
        bottom: false,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: WafloColors.divider)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              WafloSpacing.x4,
              WafloSpacing.x3,
              WafloSpacing.x4,
              WafloSpacing.x3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const WafloBrandMark(),
                    const SizedBox(width: WafloSpacing.x3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.workspace,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            membership.businessDisplayName,
                            key: const ValueKey('waflo-v2-workspace-name'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: WafloSpacing.x2),
                    WafloStatusChip(
                      label: roleLabel,
                      tone: WafloStatusTone.information,
                      icon: Icons.verified_user_outlined,
                    ),
                  ],
                ),
                if (workspace.activeBranch != null) ...[
                  const SizedBox(height: WafloSpacing.x2),
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        size: 18,
                        color: WafloColors.textMuted,
                      ),
                      const SizedBox(width: WafloSpacing.x2),
                      Expanded(
                        child: Text(
                          '${strings.branch}: ${workspace.activeBranch!.displayName}',
                          key: const ValueKey('waflo-v2-branch-name'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
