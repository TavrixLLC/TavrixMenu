import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import '../../features/business_setup/domain/entities/business.dart';
import 'waflo_status_badge.dart';

class BusinessHeaderCard extends StatelessWidget {
  const BusinessHeaderCard({required this.business, super.key, this.role});

  final Business? business;
  final String? role;

  @override
  Widget build(BuildContext context) {
    final businessName = business?.name.trim();
    final publicMenu = business?.publicMenuUrl.trim();
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.header,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  const WafloStatusBadge(
                    label: 'Operator workspace',
                    icon: Icons.verified_user_outlined,
                    color: AppColors.charcoalSoft,
                    foregroundColor: AppColors.surfaceWhite,
                  ),
                  if (role != null)
                    WafloStatusBadge(
                      label: role!,
                      icon: Icons.admin_panel_settings_outlined,
                      color: AppColors.coralTint,
                      foregroundColor: AppColors.primaryCoralDark,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                businessName?.isNotEmpty == true
                    ? businessName!
                    : 'Set up your business',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.surfaceWhite,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                publicMenu?.isNotEmpty == true
                    ? 'Public menu is connected and ready to share.'
                    : 'Create your business profile before publishing a menu.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.surfaceWhite.withValues(alpha: 0.76),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
