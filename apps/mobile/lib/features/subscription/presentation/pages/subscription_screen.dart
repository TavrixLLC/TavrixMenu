import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Subscription',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Waflo plans',
            subtitle:
                'Plan status is informational in the operator app. Checkout is not implemented here.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _PlanCard(
            title: 'Basic',
            price: 'Starter tools',
            badge: 'Current shell',
            features: const [
              'Business dashboard',
              'Menu management',
              'QR menu link',
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PlanCard(
            title: 'Pro',
            price: 'Advanced tools later',
            badge: 'Later',
            features: const [
              'Customer wallet scanning',
              'AI recommendations later',
              'Advanced loyalty management',
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.badge,
    required this.features,
  });

  final String title;
  final String price;
  final String badge;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              StatusBadge(
                label: badge,
                color: title == 'Pro' ? AppColors.gold : AppColors.greenLight,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(price),
          const SizedBox(height: AppSpacing.md),
          for (final feature in features) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, size: 18, color: AppColors.greenAccent),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(feature)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Plan changes unavailable in mobile',
            icon: Icons.lock_outline,
            onPressed: null,
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    );
  }
}
