import 'package:flutter/material.dart';

import '../../../../core/localization/waflo_v2_strings.dart';
import '../../../../core/theme/waflo_colors.dart';
import '../../../../core/theme/waflo_radii.dart';
import '../../../../core/theme/waflo_spacing.dart';
import '../../../../shared/components/waflo_info_banner.dart';
import '../../../../shared/components/waflo_status_chip.dart';
import '../../domain/card_design.dart';
import '../../domain/card_design_validator.dart';
import '../../domain/provider_preview.dart';

class ProviderPreviewPanel extends StatelessWidget {
  const ProviderPreviewPanel({
    required this.design,
    required this.capability,
    super.key,
  });

  final CardDesignDraft design;
  final ProviderPreviewCapability capability;

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    final providerLabel = _providerLabel(strings);
    final fidelityLabel = capability.isDeterministicPreview
        ? strings.exactWafloPreview
        : strings.platformApproximation;
    final semanticAvailability = capability.isAvailable
        ? fidelityLabel
        : strings.previewUnavailable;

    return Semantics(
      container: true,
      label: '$providerLabel. $semanticAvailability.',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WafloColors.surface,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_providerIcon(), color: WafloColors.textStrong),
                  const SizedBox(width: WafloSpacing.x2),
                  Expanded(
                    child: Text(
                      providerLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: WafloSpacing.x2),
                  Flexible(
                    child: WafloStatusChip(
                      label: capability.isAvailable
                          ? fidelityLabel
                          : strings.previewUnavailable,
                      tone: capability.isAvailable
                          ? capability.isDeterministicPreview
                                ? WafloStatusTone.information
                                : WafloStatusTone.warning
                          : WafloStatusTone.neutral,
                      icon: capability.isAvailable
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: WafloSpacing.x3),
              if (!capability.isAvailable)
                WafloInfoBanner(
                  title: strings.previewUnavailable,
                  body: strings.previewUnavailableBody,
                  tone: WafloBannerTone.warning,
                )
              else
                _providerPreview(context),
              if (capability.isAvailable &&
                  !capability.isDeterministicPreview &&
                  !capability.isRealDeviceVerified) ...[
                const SizedBox(height: WafloSpacing.x3),
                Text(
                  strings.notDeviceVerified,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              for (final limitation in capability.limitations) ...[
                const SizedBox(height: WafloSpacing.x1),
                Text(
                  '• $limitation',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _providerPreview(BuildContext context) {
    return switch (capability.provider) {
      CardPreviewProvider.web => _WafloProviderCard(design: design),
      CardPreviewProvider.appleWallet => _AppleWalletApproximation(
        design: design,
      ),
      CardPreviewProvider.googleWallet => _GoogleWalletApproximation(
        design: design,
      ),
    };
  }

  String _providerLabel(WafloV2Strings strings) {
    return switch (capability.provider) {
      CardPreviewProvider.web => strings.compactWafloCardPreview,
      CardPreviewProvider.appleWallet => strings.appleWallet,
      CardPreviewProvider.googleWallet => strings.googleWallet,
    };
  }

  IconData _providerIcon() {
    return switch (capability.provider) {
      CardPreviewProvider.web => Icons.loyalty_outlined,
      CardPreviewProvider.appleWallet => Icons.phone_iphone_rounded,
      CardPreviewProvider.googleWallet => Icons.account_balance_wallet_outlined,
    };
  }
}

class _WafloProviderCard extends StatelessWidget {
  const _WafloProviderCard({required this.design});

  final CardDesignDraft design;

  @override
  Widget build(BuildContext context) {
    final background = _color(design.backgroundColor);
    final text = _color(design.textColor);
    final primary = _color(design.primaryColor);
    final primaryForeground = _foreground(
      design.primaryColor,
      design.textColor,
    );
    final accent = _color(design.accentColor);
    return DecoratedBox(
      key: const ValueKey('waflo-deterministic-preview'),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(WafloRadii.card)),
        border: Border.all(color: text.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(WafloSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(WafloRadii.control),
                    ),
                  ),
                  child: SizedBox.square(
                    dimension: 44,
                    child: Icon(
                      design.logo.state == CardMediaState.empty
                          ? Icons.storefront_outlined
                          : Icons.image_outlined,
                      color: primaryForeground,
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
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: text),
                      ),
                      Text(
                        design.programDisplayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: WafloSpacing.x4),
            Wrap(
              spacing: WafloSpacing.x2,
              runSpacing: WafloSpacing.x2,
              children: List.generate(
                6,
                (index) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: index < 3
                        ? (index == 2 ? accent : primary)
                        : text.withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(WafloRadii.compact),
                    ),
                  ),
                  child: const SizedBox.square(dimension: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppleWalletApproximation extends StatelessWidget {
  const _AppleWalletApproximation({required this.design});

  final CardDesignDraft design;

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    final primary = _color(design.primaryColor);
    final foreground = _foreground(design.primaryColor, design.textColor);
    return DecoratedBox(
      key: const ValueKey('apple-platform-approximation'),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.all(
          Radius.circular(WafloRadii.control),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(WafloSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.apple, color: foreground, size: 20),
                const SizedBox(width: WafloSpacing.x2),
                Expanded(
                  child: Text(
                    design.businessDisplayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
            const SizedBox(height: WafloSpacing.x5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _WalletField(
                    label: strings.pointsBalance,
                    value: '240',
                    foreground: foreground,
                  ),
                ),
                const SizedBox(width: WafloSpacing.x3),
                Expanded(
                  child: _WalletField(
                    label: strings.nextReward,
                    value: design.copy.rewardLabel,
                    foreground: foreground,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: WafloSpacing.x4),
            DecoratedBox(
              decoration: BoxDecoration(
                color: foreground.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.all(
                  Radius.circular(WafloRadii.compact),
                ),
              ),
              child: SizedBox(
                height: 42,
                child: Center(
                  child: Icon(
                    Icons.view_week_outlined,
                    color: foreground,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleWalletApproximation extends StatelessWidget {
  const _GoogleWalletApproximation({required this.design});

  final CardDesignDraft design;

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    final accent = _color(design.accentColor);
    final accentForeground = _foreground(design.accentColor, design.textColor);
    return DecoratedBox(
      key: const ValueKey('google-platform-approximation'),
      decoration: BoxDecoration(
        color: WafloColors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(WafloRadii.card)),
        border: Border.all(color: WafloColors.outline),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(WafloRadii.card)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: accent,
              child: Padding(
                padding: const EdgeInsetsDirectional.all(WafloSpacing.x3),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: accentForeground,
                    ),
                    const SizedBox(width: WafloSpacing.x2),
                    Expanded(
                      child: Text(
                        design.programDisplayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: accentForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.all(WafloSpacing.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.pointsBalance,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '240',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: WafloSpacing.x3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${strings.memberId}: WF-2048',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      const Icon(Icons.view_week_outlined, size: 32),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletField extends StatelessWidget {
  const _WalletField({
    required this.label,
    required this.value,
    required this.foreground,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color foreground;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: foreground),
        ),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: foreground),
        ),
      ],
    );
  }
}

Color _color(HexColorValue value) => Color(0xFF000000 | value.rgb);

Color _foreground(HexColorValue surface, HexColorValue preferred) {
  final result = CardDesignValidator.foregroundForSurface(
    surface,
    preferred: preferred,
  );
  return _color(result.foreground);
}
