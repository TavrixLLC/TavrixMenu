import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations_extension.dart';
import '../../../core/theme/v3/waflo_v3_tokens.dart';

class WafloSkeleton extends StatelessWidget {
  const WafloSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = WafloV3Spacing.minimumTouchTarget,
    this.radius = WafloV3Radius.inputControl,
    this.semanticLabel,
  });

  final double width;
  final double height;
  final double radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel ?? context.l10n.genericLoading,
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
