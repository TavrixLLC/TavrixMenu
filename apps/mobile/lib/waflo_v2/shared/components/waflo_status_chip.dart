import 'package:flutter/material.dart';

import '../../core/theme/waflo_colors.dart';
import '../../core/theme/waflo_radii.dart';
import '../../core/theme/waflo_spacing.dart';

enum WafloStatusTone { neutral, information, success, warning, error }

class WafloStatusChip extends StatelessWidget {
  const WafloStatusChip({
    required this.label,
    required this.tone,
    super.key,
    this.icon,
  });

  final String label;
  final WafloStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      WafloStatusTone.neutral => (
        WafloColors.surfaceMuted,
        WafloColors.textMuted,
      ),
      WafloStatusTone.information => (
        WafloColors.informationContainer,
        WafloColors.onInformationContainer,
      ),
      WafloStatusTone.success => (
        WafloColors.successContainer,
        WafloColors.onSuccessContainer,
      ),
      WafloStatusTone.warning => (
        WafloColors.warningContainer,
        WafloColors.onWarningContainer,
      ),
      WafloStatusTone.error => (
        WafloColors.dangerContainer,
        WafloColors.onDangerContainer,
      ),
    };

    return Semantics(
      label: label,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.$1,
          borderRadius: const BorderRadius.all(
            Radius.circular(WafloRadii.pill),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: WafloSpacing.x3,
            vertical: WafloSpacing.x2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: colors.$2),
                const SizedBox(width: WafloSpacing.x1),
              ],
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.$2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
