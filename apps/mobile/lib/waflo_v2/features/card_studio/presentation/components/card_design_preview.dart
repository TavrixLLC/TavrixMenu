import 'package:flutter/material.dart';

import '../../../../core/localization/waflo_v2_strings.dart';
import '../../../../core/theme/waflo_radii.dart';
import '../../../../core/theme/waflo_shadows.dart';
import '../../../../core/theme/waflo_spacing.dart';
import '../../domain/card_design.dart';
import '../../domain/card_design_validator.dart';

class CardDesignPreview extends StatelessWidget {
  const CardDesignPreview({required this.design, super.key});

  final CardDesignDraft design;

  @override
  Widget build(BuildContext context) {
    final primary = Color(0xFF000000 | design.primaryColor.rgb);
    final secondary = Color(0xFF000000 | design.secondaryColor.rgb);
    final accent = Color(0xFF000000 | design.accentColor.rgb);
    final background = Color(0xFF000000 | design.backgroundColor.rgb);
    final textColor = Color(0xFF000000 | design.textColor.rgb);
    final primaryForeground = Color(
      0xFF000000 |
          CardDesignValidator.foregroundForSurface(
            design.primaryColor,
            preferred: design.textColor,
          ).foreground.rgb,
    );
    final cardRadius = design.cardShape == CardVisualShape.softRectangle
        ? WafloRadii.prominent
        : WafloRadii.card;

    return Semantics(
      container: true,
      label:
          '${context.wafloV2.baseDesign}: ${design.businessDisplayName}, ${design.programDisplayName}',
      child: AspectRatio(
        aspectRatio: 1.62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
            boxShadow: WafloShadows.elevated,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
            child: Stack(
              children: [
                PositionedDirectional(
                  top: -54,
                  end: -30,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: secondary.withValues(alpha: 0.34),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(dimension: 170),
                  ),
                ),
                PositionedDirectional(
                  bottom: -72,
                  start: -34,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(dimension: 180),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.all(WafloSpacing.x5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(WafloRadii.compact),
                              ),
                            ),
                            child: SizedBox.square(
                              dimension: 44,
                              child: Center(
                                child: Icon(
                                  design.logo.state == CardMediaState.empty
                                      ? Icons.storefront_outlined
                                      : Icons.image_outlined,
                                  color: primaryForeground,
                                  size: 23,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: WafloSpacing.x3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  design.businessDisplayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: textColor),
                                ),
                                Text(
                                  design.programDisplayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: textColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        context.wafloV2.earningVisual,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: textColor),
                      ),
                      const SizedBox(height: WafloSpacing.x2),
                      Wrap(
                        spacing: WafloSpacing.x2,
                        children: List.generate(
                          6,
                          (index) => _StampMark(
                            shape: design.stampShape,
                            icon: design.stampIcon,
                            color: switch (index) {
                              0 => primary,
                              1 => accent,
                              _ => textColor.withValues(alpha: 0.24),
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StampMark extends StatelessWidget {
  const _StampMark({
    required this.shape,
    required this.icon,
    required this.color,
  });

  final StampVisualShape shape;
  final CardVisualIcon icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (shape == StampVisualShape.star ||
        shape == StampVisualShape.customIcon) {
      return Icon(
        shape == StampVisualShape.star ? Icons.star_rounded : _iconData(icon),
        size: 25,
        color: color,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: shape == StampVisualShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: shape == StampVisualShape.roundedSquare
            ? const BorderRadius.all(Radius.circular(7))
            : null,
      ),
      child: const SizedBox.square(dimension: 24),
    );
  }

  IconData _iconData(CardVisualIcon value) {
    return switch (value) {
      CardVisualIcon.coffee => Icons.local_cafe_outlined,
      CardVisualIcon.star => Icons.star_outline_rounded,
      CardVisualIcon.gift => Icons.card_giftcard_outlined,
      CardVisualIcon.service => Icons.room_service_outlined,
      CardVisualIcon.custom => Icons.image_outlined,
    };
  }
}
