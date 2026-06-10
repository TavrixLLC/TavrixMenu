import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import '../../features/business_setup/domain/entities/business.dart';
import 'status_badge.dart';

class BusinessHeaderCard extends StatelessWidget {
  const BusinessHeaderCard({required this.business, super.key});

  final Business? business;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.houseGreen,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.header,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusBadge(label: 'Business app'),
            const SizedBox(height: AppSpacing.lg),
            Text(
              business?.name ?? 'Set up your business',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              business?.publicMenuUrl ??
                  'Create your business profile before publishing a menu.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.greenLight),
            ),
          ],
        ),
      ),
    );
  }
}
