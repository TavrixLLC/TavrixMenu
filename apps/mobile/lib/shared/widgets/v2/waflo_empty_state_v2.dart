import 'package:flutter/material.dart';
import '../../../../core/theme/v2/waflo_tokens_v2.dart';
import 'waflo_button_v2.dart';

/// Waflo Empty State V2 Component
///
/// A clean visual container rendering friendly icons, titles, action items,
/// and detailed descriptions when no content or results exist.
class WafloEmptyStateV2 extends StatelessWidget {
  const WafloEmptyStateV2({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
    this.actionLabel,
    this.onActionPressed,
    this.actionIcon,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Rounded decorative icon slot
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: WafloColorsV2.backgroundWarm,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 40, color: WafloColorsV2.accentCrimson),
        ),
        const SizedBox(height: WafloSpacingV2.md),
        Text(title, style: WafloTypographyV2.h2, textAlign: TextAlign.center),
        const SizedBox(height: WafloSpacingV2.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: WafloSpacingV2.md),
          child: Text(
            description,
            style: WafloTypographyV2.body,
            textAlign: TextAlign.center,
          ),
        ),
        if (actionLabel != null && onActionPressed != null) ...[
          const SizedBox(height: WafloSpacingV2.lg),
          WafloButtonV2(
            label: actionLabel!,
            icon: actionIcon,
            expand: false,
            onPressed: onActionPressed,
          ),
        ],
      ],
    );
  }
}
