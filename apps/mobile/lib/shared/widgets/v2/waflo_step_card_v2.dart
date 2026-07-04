import 'package:flutter/material.dart';
import '../../../../core/theme/v2/waflo_tokens_v2.dart';
import 'waflo_card_v2.dart';

/// Waflo Step Card V2 Component
///
/// Used for guided onboarding and dashboard task checklist elements.
/// Features clean typography, status badge circles, and state-specific styling.
enum WafloStepState { completed, active, inactive }

class WafloStepCardV2 extends StatelessWidget {
  const WafloStepCardV2({
    required this.title,
    required this.description,
    required this.stepNumber,
    required this.state,
    super.key,
    this.onTap,
    this.actionLabel,
  });

  final String title;
  final String description;
  final int stepNumber;
  final WafloStepState state;
  final VoidCallback? onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final isCompleted = state == WafloStepState.completed;
    final isActive = state == WafloStepState.active;

    final stepBgColor = isCompleted
        ? WafloColorsV2.successBg
        : (isActive
              ? WafloColorsV2.surfaceWhite
              : WafloColorsV2.borderExtraSoft);

    return WafloCardV2(
      backgroundColor: stepBgColor,
      borderRadius: WafloRadiusV2.lgBorder,
      showShadow: isActive,
      onTap: isActive ? onTap : null,
      padding: const EdgeInsets.all(WafloSpacingV2.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number or Status Indicator Badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted
                  ? WafloColorsV2.success
                  : (isActive
                        ? WafloColorsV2.primaryCoral
                        : WafloColorsV2.textLight),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
          const SizedBox(width: WafloSpacingV2.md),
          // Text & Action details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: WafloTypographyV2.title.copyWith(
                    color: isActive
                        ? WafloColorsV2.textDark
                        : WafloColorsV2.textMedium,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: WafloSpacingV2.xs),
                Text(
                  description,
                  style: WafloTypographyV2.body.copyWith(
                    color: isCompleted
                        ? WafloColorsV2.textLight
                        : WafloColorsV2.textMedium,
                  ),
                ),
                if (isActive && actionLabel != null && onTap != null) ...[
                  const SizedBox(height: WafloSpacingV2.sm),
                  Row(
                    children: [
                      Text(
                        actionLabel!,
                        style: WafloTypographyV2.bodyBold.copyWith(
                          color: WafloColorsV2.accentCrimson,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: WafloColorsV2.accentCrimson,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
