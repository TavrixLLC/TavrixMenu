import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';

class WafloCard extends StatelessWidget {
  const WafloCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsetsDirectional.all(AppSpacing.md),
    this.color = AppColors.surfaceWhite,
    this.borderColor = AppColors.softBorder,
    this.elevated = false,
    this.accentColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final bool elevated;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.md);
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        border: Border.all(color: borderColor),
        boxShadow: elevated ? AppShadows.soft : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            if (accentColor != null)
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: ColoredBox(
                  color: accentColor!,
                  child: const SizedBox(width: 4),
                ),
              ),
            Padding(
              padding: accentColor == null
                  ? padding
                  : padding.add(const EdgeInsetsDirectional.only(start: 4)),
              child: child,
            ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: SizedBox(width: double.infinity, child: card),
      ),
    );
  }
}
