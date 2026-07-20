import 'package:flutter/material.dart';

import '../../../core/theme/v3/waflo_v3_tokens.dart';
import 'waflo_primary_button.dart';
import 'waflo_secondary_button.dart';

class WafloEmptyState extends StatelessWidget {
  const WafloEmptyState({
    required this.title,
    required this.description,
    super.key,
    this.icon,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String title;
  final String description;
  final IconData? icon;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(WafloV3Spacing.commonCardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (icon != null) ...[
            Align(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: WafloV3Colors.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(WafloV3Spacing.space16),
                  child: Icon(
                    icon,
                    size: WafloV3Spacing.space32,
                    color: WafloV3Colors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: WafloV3Spacing.space16),
          ],
          Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: WafloV3Colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
          const SizedBox(height: WafloV3Spacing.space8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: WafloV3Colors.primaryText.withValues(alpha: 0.72),
            ),
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          if (primaryActionLabel != null) ...[
            const SizedBox(height: WafloV3Spacing.space24),
            WafloPrimaryButton(
              label: primaryActionLabel!,
              onPressed: onPrimaryAction,
            ),
          ],
          if (secondaryActionLabel != null) ...[
            const SizedBox(height: WafloV3Spacing.space8),
            WafloSecondaryButton(
              label: secondaryActionLabel!,
              onPressed: onSecondaryAction,
            ),
          ],
        ],
      ),
    );
  }
}
