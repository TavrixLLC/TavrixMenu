import 'package:flutter/material.dart';

import '../../../core/theme/v3/waflo_v3_tokens.dart';

enum WafloStatusKind { active, inactive, warning, error, informational }

class WafloStatusBadge extends StatelessWidget {
  const WafloStatusBadge({
    required this.label,
    required this.status,
    super.key,
    this.icon,
  });

  final String label;
  final WafloStatusKind status;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(status);

    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.all(
            Radius.circular(WafloV3Radius.pill),
          ),
          border: Border.all(color: colors.foreground.withValues(alpha: 0.24)),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: WafloV3Spacing.space8,
            vertical: WafloV3Spacing.space4,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: WafloV3Spacing.space4,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: WafloV3Spacing.space16,
                  color: colors.foreground,
                ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _BadgeColors _colorsFor(WafloStatusKind value) {
    return switch (value) {
      WafloStatusKind.active => const _BadgeColors(
        background: Color(0xFFE7F4EA),
        foreground: Color(0xFF166534),
      ),
      WafloStatusKind.inactive => _BadgeColors(
        background: WafloV3Colors.primaryText.withValues(alpha: 0.08),
        foreground: WafloV3Colors.primaryText.withValues(alpha: 0.72),
      ),
      WafloStatusKind.warning => const _BadgeColors(
        background: Color(0xFFFFF4CC),
        foreground: Color(0xFF7A4B00),
      ),
      WafloStatusKind.error => _BadgeColors(
        background: WafloV3Colors.error.withValues(alpha: 0.10),
        foreground: WafloV3Colors.error,
      ),
      WafloStatusKind.informational => const _BadgeColors(
        background: Color(0xFFE8F1FF),
        foreground: Color(0xFF184E8A),
      ),
    };
  }
}

class _BadgeColors {
  const _BadgeColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
