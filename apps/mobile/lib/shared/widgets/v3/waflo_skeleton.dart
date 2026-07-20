import 'package:flutter/material.dart';

import '../../../core/theme/v3/waflo_v3_tokens.dart';

class WafloSkeleton extends StatelessWidget {
  const WafloSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = WafloV3Spacing.minimumTouchTarget,
    this.radius = WafloV3Radius.inputControl,
    this.semanticLabel = 'جارٍ التحميل',
  });

  final double width;
  final double height;
  final double radius;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: WafloV3Colors.primaryText.withValues(alpha: 0.08),
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
        ),
      ),
    );
  }
}
