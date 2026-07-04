import 'package:flutter/material.dart';
import '../../../../core/theme/v2/waflo_tokens_v2.dart';

/// Waflo Section Header V2 Component
///
/// Renders standard section title, optional subtitle, and trailing CTAs
/// using Waflo V2 typography and color system.
class WafloSectionHeaderV2 extends StatelessWidget {
  const WafloSectionHeaderV2({
    required this.title,
    super.key,
    this.subtitle,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(title, style: WafloTypographyV2.h2)),
            if (actionLabel != null && onActionPressed != null)
              GestureDetector(
                onTap: onActionPressed,
                child: Text(
                  actionLabel!,
                  style: WafloTypographyV2.bodyBold.copyWith(
                    color: WafloColorsV2.accentCrimson,
                  ),
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: WafloSpacingV2.xs),
          Text(
            subtitle!,
            style: WafloTypographyV2.body.copyWith(
              color: WafloColorsV2.textMedium,
            ),
          ),
        ],
      ],
    );
  }
}
