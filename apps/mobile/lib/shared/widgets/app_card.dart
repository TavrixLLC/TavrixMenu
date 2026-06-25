import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'waflo_card.dart';

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
    return WafloCard(
      onTap: onTap,
      padding: padding,
      color: color,
      elevated: true,
      child: child,
    );
  }
}
