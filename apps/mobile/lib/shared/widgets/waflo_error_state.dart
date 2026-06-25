import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'waflo_button.dart';
import 'waflo_card.dart';

class WafloErrorState extends StatelessWidget {
  const WafloErrorState({required this.message, super.key, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return WafloCard(
      accentColor: AppColors.dangerRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.dangerRed),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Something needs attention',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(message),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            WafloButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: onRetry,
              variant: WafloButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }
}
