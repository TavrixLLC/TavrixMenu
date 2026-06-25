import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'waflo_card.dart';
import 'waflo_status_badge.dart';

class WafloActionTile extends StatelessWidget {
  const WafloActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
    this.onTap,
    this.enabled = true,
    this.badge,
    this.accentColor = AppColors.primaryCoral,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final String? badge;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled ? AppColors.textDark : AppColors.mutedText;
    return WafloCard(
      onTap: enabled ? onTap : null,
      borderColor: enabled ? AppColors.softBorder : AppColors.softBorder,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: enabled ? 0.12 : 0.06),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                icon,
                color: enabled ? accentColor : AppColors.mutedText,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: foreground),
                      ),
                    ),
                    if (badge != null) WafloStatusBadge(label: badge!),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.chevron_right, color: foreground),
        ],
      ),
    );
  }
}
