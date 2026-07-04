import 'package:flutter/material.dart';
import '../../../../core/theme/v2/waflo_tokens_v2.dart';

/// Waflo Status Badge V2 Component
///
/// A tiny colored pill container representing states (success, warning, error, info).
enum WafloStatusTypeV2 { success, warning, danger, info }

class WafloStatusBadgeV2 extends StatelessWidget {
  const WafloStatusBadgeV2({
    required this.label,
    required this.type,
    super.key,
    this.icon,
  });

  final String label;
  final WafloStatusTypeV2 type;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = _badgeColors(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: colors.foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: WafloTypographyV2.caption.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeColors _badgeColors(WafloStatusTypeV2 type) {
    return switch (type) {
      WafloStatusTypeV2.success => const _BadgeColors(
        background: WafloColorsV2.successBg,
        foreground: WafloColorsV2.success,
        border: Color(0xFFC6F6D5),
      ),
      WafloStatusTypeV2.warning => const _BadgeColors(
        background: WafloColorsV2.warningBg,
        foreground: WafloColorsV2.warning,
        border: Color(0xFFFEF3C7),
      ),
      WafloStatusTypeV2.danger => const _BadgeColors(
        background: WafloColorsV2.dangerBg,
        foreground: WafloColorsV2.danger,
        border: Color(0xFFFEE2E2),
      ),
      WafloStatusTypeV2.info => const _BadgeColors(
        background: WafloColorsV2.infoBg,
        foreground: WafloColorsV2.info,
        border: Color(0xFFDBEAFE),
      ),
    };
  }
}

class _BadgeColors {
  const _BadgeColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
