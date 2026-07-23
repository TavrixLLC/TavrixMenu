import 'package:flutter/material.dart';

import '../../core/localization/waflo_v2_strings.dart';
import '../../core/state/waflo_view_state.dart';
import '../../core/theme/waflo_colors.dart';
import '../../core/theme/waflo_spacing.dart';
import 'waflo_buttons.dart';
import 'waflo_section_card.dart';

class WafloStateView extends StatelessWidget {
  const WafloStateView({
    required this.state,
    super.key,
    this.compact = false,
    this.actionLabel,
    this.onAction,
  });

  final WafloViewState state;
  final bool compact;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    final visual = _visualFor(strings);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: visual.background,
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: compact ? 40 : 52,
              child: state.isBusy
                  ? Padding(
                      padding: const EdgeInsets.all(WafloSpacing.x3),
                      child: CircularProgressIndicator(
                        key: const ValueKey('waflo-state-progress'),
                        strokeWidth: 2.5,
                        color: visual.foreground,
                      ),
                    )
                  : Icon(visual.icon, color: visual.foreground, size: 26),
            ),
          ),
        ),
        SizedBox(height: compact ? WafloSpacing.x2 : WafloSpacing.x3),
        Text(visual.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: WafloSpacing.x1),
        Text(
          visual.body,
          style: compact
              ? Theme.of(context).textTheme.bodySmall
              : Theme.of(context).textTheme.bodyMedium,
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: WafloSpacing.x3),
          WafloPrimaryButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    );

    return Semantics(
      container: true,
      liveRegion: state.kind == WafloViewStateKind.error || state.isBusy,
      label: '${visual.title}. ${visual.body}',
      excludeSemantics: true,
      child: WafloSectionCard(child: content),
    );
  }

  _StateVisual _visualFor(WafloV2Strings strings) {
    return switch (state.kind) {
      WafloViewStateKind.initial ||
      WafloViewStateKind.loading ||
      WafloViewStateKind.refreshing ||
      WafloViewStateKind.submitting => _StateVisual(
        title: strings.loadingTitle,
        body: strings.loadingBody,
        icon: Icons.hourglass_top_rounded,
        background: WafloColors.informationContainer,
        foreground: WafloColors.onInformationContainer,
      ),
      WafloViewStateKind.empty => _StateVisual(
        title: strings.emptyTitle,
        body: strings.emptyBody,
        icon: Icons.inbox_outlined,
        background: WafloColors.surfaceMuted,
        foreground: WafloColors.textMuted,
      ),
      WafloViewStateKind.error => _StateVisual(
        title: strings.errorTitle,
        body: strings.errorBody,
        icon: Icons.error_outline_rounded,
        background: WafloColors.dangerContainer,
        foreground: WafloColors.onDangerContainer,
      ),
      WafloViewStateKind.offline => _StateVisual(
        title: strings.offlineTitle,
        body: strings.offlineBody,
        icon: Icons.cloud_off_outlined,
        background: WafloColors.warningContainer,
        foreground: WafloColors.onWarningContainer,
      ),
      WafloViewStateKind.forbidden => _StateVisual(
        title: strings.forbiddenTitle,
        body: strings.forbiddenBody,
        icon: Icons.lock_outline_rounded,
        background: WafloColors.dangerContainer,
        foreground: WafloColors.onDangerContainer,
      ),
      WafloViewStateKind.stale => _StateVisual(
        title: strings.staleTitle,
        body: strings.staleBody,
        icon: Icons.history_rounded,
        background: WafloColors.warningContainer,
        foreground: WafloColors.onWarningContainer,
      ),
      WafloViewStateKind.confirmed => _StateVisual(
        title: strings.confirmedTitle,
        body: strings.confirmedBody,
        icon: Icons.check_circle_outline_rounded,
        background: WafloColors.successContainer,
        foreground: WafloColors.onSuccessContainer,
      ),
      WafloViewStateKind.draft => _StateVisual(
        title: strings.draftTitle,
        body: strings.draftBody,
        icon: Icons.edit_note_rounded,
        background: WafloColors.informationContainer,
        foreground: WafloColors.onInformationContainer,
      ),
      WafloViewStateKind.disabled => _StateVisual(
        title: strings.disabledTitle,
        body: strings.disabledBody,
        icon: Icons.block_rounded,
        background: WafloColors.surfaceMuted,
        foreground: WafloColors.disabledForeground,
      ),
    };
  }
}

class _StateVisual {
  const _StateVisual({
    required this.title,
    required this.body,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color background;
  final Color foreground;
}
