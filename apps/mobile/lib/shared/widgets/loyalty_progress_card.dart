import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'waflo_card.dart';
import 'waflo_status_badge.dart';

class LoyaltyProgressCard extends StatelessWidget {
  const LoyaltyProgressCard({
    required this.customerName,
    required this.programName,
    required this.rewardText,
    required this.stamps,
    required this.goal,
    required this.canRedeem,
    super.key,
    this.customerHint,
  });

  final String customerName;
  final String? customerHint;
  final String programName;
  final String rewardText;
  final int stamps;
  final int goal;
  final bool canRedeem;

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (stamps / goal).clamp(0.0, 1.0) : 0.0;

    return WafloCard(
      accentColor: canRedeem ? AppColors.rewardGold : AppColors.freshGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WafloStatusBadge(
            label: canRedeem ? 'Reward ready' : 'In progress',
            icon: canRedeem ? Icons.workspace_premium : Icons.trending_up,
            color: canRedeem ? AppColors.goldTint : AppColors.greenTint,
            foregroundColor: canRedeem
                ? AppColors.rewardGold
                : AppColors.freshGreenDark,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(customerName, style: Theme.of(context).textTheme.titleLarge),
          if (customerHint != null && customerHint!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(customerHint!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(programName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              key: const ValueKey('walletStampProgressBar'),
              value: progress,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            key: const ValueKey('walletStampCount'),
            '$stamps of $goal stamps',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(rewardText),
        ],
      ),
    );
  }
}
