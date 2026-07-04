import 'package:flutter/material.dart';
import '../../../../core/theme/v2/waflo_tokens_v2.dart';

/// Waflo Card V2 Component
///
/// A rounded surface container built using Waflo V2 radius, colors, and shadows.
/// Supports clicking with an ink splash effect, custom paddings, and borders.
class WafloCardV2 extends StatelessWidget {
  const WafloCardV2({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.showBorder = true,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool showBorder;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final finalBorderRadius = borderRadius ?? WafloRadiusV2.xlBorder;
    final finalPadding = padding ?? const EdgeInsets.all(WafloSpacingV2.md);

    Widget content = Padding(padding: finalPadding, child: child);

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: finalBorderRadius,
        child: content,
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? WafloColorsV2.surfaceWhite,
        borderRadius: finalBorderRadius,
        border: showBorder ? Border.all(color: WafloColorsV2.borderSoft) : null,
        boxShadow: showShadow ? WafloShadowV2.soft : null,
      ),
      child: ClipRRect(borderRadius: finalBorderRadius, child: content),
    );
  }
}
