import 'package:flutter/material.dart';

import '../../../../core/theme/waflo_colors.dart';
import '../../../../core/theme/waflo_radii.dart';
import '../../../../core/theme/waflo_spacing.dart';
import '../../domain/card_design.dart';

class ColorPreviewField extends StatelessWidget {
  const ColorPreviewField({
    required this.label,
    required this.color,
    super.key,
  });

  final String label;
  final HexColorValue color;

  @override
  Widget build(BuildContext context) {
    final flutterColor = Color(0xFF000000 | color.rgb);
    return Semantics(
      container: true,
      readOnly: true,
      label: '$label ${color.value}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WafloColors.surface,
          borderRadius: const BorderRadius.all(
            Radius.circular(WafloRadii.control),
          ),
          border: Border.all(color: WafloColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(WafloSpacing.x3),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: flutterColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: WafloColors.outline),
                ),
                child: const SizedBox.square(dimension: 32),
              ),
              const SizedBox(width: WafloSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      color.value,
                      textDirection: TextDirection.ltr,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: WafloColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
