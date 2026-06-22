import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'app_button.dart';
import 'app_card.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, super.key, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Something needs attention',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(message),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: onRetry,
              variant: AppButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }
}
