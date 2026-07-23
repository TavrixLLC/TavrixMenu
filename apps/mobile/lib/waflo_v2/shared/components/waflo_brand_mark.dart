import 'package:flutter/material.dart';

/// Official primary Waflo mark with enforced UI minimum size and clear space.
class WafloBrandMark extends StatelessWidget {
  const WafloBrandMark({
    super.key,
    this.markSize = recommendedUiSize,
    this.clearSpace = defaultClearSpace,
  }) : assert(markSize >= minimumRenderedSize),
       assert(clearSpace >= 0);

  static const String assetPath =
      'assets/waflo_v2/brand/waflo-mark-primary-256.png';
  static const double minimumRenderedSize = 24;
  static const double recommendedUiSize = 32;
  static const double defaultClearSpace = 4;

  final double markSize;
  final double clearSpace;

  @override
  Widget build(BuildContext context) {
    final totalSize = markSize + (clearSpace * 2);
    return Semantics(
      image: true,
      label: 'Waflo',
      child: SizedBox.square(
        dimension: totalSize,
        child: Padding(
          padding: EdgeInsets.all(clearSpace),
          child: Image.asset(
            assetPath,
            width: markSize,
            height: markSize,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
