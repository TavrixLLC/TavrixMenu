import 'package:flutter/material.dart';

import '../../../../core/localization/waflo_v2_strings.dart';
import '../../../../core/theme/waflo_colors.dart';
import '../../../../core/theme/waflo_radii.dart';
import '../../../../core/theme/waflo_spacing.dart';
import '../../domain/card_design.dart';

class JoinPagePreview extends StatelessWidget {
  const JoinPagePreview({required this.design, super.key});

  final CardDesignDraft design;

  @override
  Widget build(BuildContext context) {
    final background = Color(0xFF000000 | design.backgroundColor.rgb);
    final text = Color(0xFF000000 | design.textColor.rgb);
    final primary = Color(0xFF000000 | design.primaryColor.rgb);
    return Semantics(
      container: true,
      label: context.wafloV2.joinPage,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.all(
            Radius.circular(WafloRadii.card),
          ),
          border: Border.all(color: WafloColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(WafloSpacing.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.loyalty_rounded, color: primary, size: 32),
              const SizedBox(height: WafloSpacing.x2),
              Text(
                design.copy.joinHeadline,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: text),
              ),
              Text(
                design.copy.joinBody,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: text),
              ),
              const SizedBox(height: WafloSpacing.x3),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(WafloRadii.compact),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QrPosterPreview extends StatelessWidget {
  const QrPosterPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    return Semantics(
      container: true,
      label: '${strings.qrUnavailable}. ${strings.qrUnavailableBody}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WafloColors.surfaceMuted,
          borderRadius: const BorderRadius.all(
            Radius.circular(WafloRadii.card),
          ),
          border: Border.all(color: WafloColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(WafloSpacing.x4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: WafloColors.textMuted,
                size: 32,
              ),
              const SizedBox(height: WafloSpacing.x2),
              Text(
                strings.qrUnavailable,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: WafloSpacing.x1),
              Text(
                strings.qrUnavailableBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
