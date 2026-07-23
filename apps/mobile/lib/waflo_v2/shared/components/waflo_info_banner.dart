import 'package:flutter/material.dart';

import '../../core/theme/waflo_colors.dart';
import '../../core/theme/waflo_radii.dart';
import '../../core/theme/waflo_spacing.dart';

enum WafloBannerTone { information, warning, error, success }

class WafloInfoBanner extends StatelessWidget {
  const WafloInfoBanner({
    required this.title,
    required this.body,
    required this.tone,
    super.key,
  });

  final String title;
  final String body;
  final WafloBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final values = switch (tone) {
      WafloBannerTone.information => (
        WafloColors.informationContainer,
        WafloColors.onInformationContainer,
        Icons.info_outline_rounded,
      ),
      WafloBannerTone.warning => (
        WafloColors.warningContainer,
        WafloColors.onWarningContainer,
        Icons.warning_amber_rounded,
      ),
      WafloBannerTone.error => (
        WafloColors.dangerContainer,
        WafloColors.onDangerContainer,
        Icons.error_outline_rounded,
      ),
      WafloBannerTone.success => (
        WafloColors.successContainer,
        WafloColors.onSuccessContainer,
        Icons.check_circle_outline_rounded,
      ),
    };

    return Semantics(
      container: true,
      liveRegion: tone == WafloBannerTone.error,
      label: '$title. $body',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: values.$1,
          borderRadius: const BorderRadius.all(
            Radius.circular(WafloRadii.control),
          ),
          border: Border.all(color: values.$2.withValues(alpha: 0.24)),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(WafloSpacing.x3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(values.$3, color: values.$2, size: 22),
              const SizedBox(width: WafloSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: values.$2),
                    ),
                    const SizedBox(height: WafloSpacing.x1),
                    Text(
                      body,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: values.$2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
