import 'package:flutter/material.dart';

import '../../../core/theme/v3/waflo_v3_tokens.dart';

class WafloSectionHeader extends StatelessWidget {
  const WafloSectionHeader({
    required this.title,
    super.key,
    this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: WafloV3Colors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                  softWrap: true,
                ),
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: WafloV3Spacing.space8),
              TextButton(
                onPressed: onActionPressed,
                style: TextButton.styleFrom(
                  minimumSize: const Size(
                    WafloV3Spacing.minimumTouchTarget,
                    WafloV3Spacing.minimumTouchTarget,
                  ),
                  foregroundColor: WafloV3Colors.primary,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: WafloV3Spacing.space12,
                  ),
                ),
                child: Text(actionLabel!, textAlign: TextAlign.center),
              ),
            ],
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: WafloV3Spacing.space4),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: WafloV3Colors.primaryText.withValues(alpha: 0.72),
            ),
            softWrap: true,
          ),
        ],
      ],
    );
  }
}
