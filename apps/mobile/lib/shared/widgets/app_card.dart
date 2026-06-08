import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsetsDirectional.all(AppSpacing.md),
    this.color = AppColors.white,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.soft,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: card,
    );
  }
}
