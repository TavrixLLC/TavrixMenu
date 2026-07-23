import 'package:flutter/material.dart';

import '../../core/theme/waflo_colors.dart';
import '../../core/theme/waflo_radii.dart';

/// A deterministic loading placeholder. Phase 1 keeps it static so reduced
/// motion is respected by default and widget/golden evidence stays stable.
class WafloSkeletonBlock extends StatelessWidget {
  const WafloSkeletonBlock({
    required this.semanticLabel,
    required this.height,
    super.key,
    this.width = double.infinity,
    this.radius = WafloRadii.compact,
  });

  final String semanticLabel;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: WafloColors.surfaceMuted,
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),
          ),
        ),
      ),
    );
  }
}
