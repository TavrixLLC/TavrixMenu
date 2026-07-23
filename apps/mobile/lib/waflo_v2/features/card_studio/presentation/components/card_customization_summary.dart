import 'package:flutter/material.dart';

import '../../../../core/localization/waflo_v2_strings.dart';
import '../../../../core/theme/waflo_spacing.dart';
import '../../../../shared/components/waflo_section_card.dart';
import '../../../../shared/components/waflo_status_chip.dart';
import '../../../../shared/components/waflo_text_field.dart';
import '../../domain/card_design.dart';

class CardBrandSummary extends StatelessWidget {
  const CardBrandSummary({required this.design, super.key});

  final CardDesignDraft design;

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    return WafloSectionCard(
      key: const ValueKey('waflo-studio-section-0'),
      title: strings.brand,
      leading: Icons.image_outlined,
      trailing: WafloStatusChip(
        label: strings.fieldPreviewOnly,
        tone: WafloStatusTone.information,
        icon: Icons.lock_outline_rounded,
      ),
      child: Column(
        children: [
          _MediaStateRow(
            label: strings.logo,
            media: design.logo,
            icon: Icons.account_circle_outlined,
          ),
          const SizedBox(height: WafloSpacing.x2),
          _MediaStateRow(
            label: strings.cover,
            media: design.cover,
            icon: Icons.panorama_outlined,
          ),
          const SizedBox(height: WafloSpacing.x3),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: WafloStatusChip(
              label:
                  '${strings.cardShape}: ${_cardShapeLabel(strings, design)}',
              tone: WafloStatusTone.neutral,
              icon: Icons.credit_card_rounded,
            ),
          ),
          const SizedBox(height: WafloSpacing.x4),
          WafloTextField(
            label: strings.joinHeadline,
            initialValue: design.copy.joinHeadline,
            readOnly: true,
            leading: Icons.title_rounded,
          ),
          const SizedBox(height: WafloSpacing.x3),
          WafloTextField(
            label: strings.joinDescription,
            initialValue: design.copy.joinBody,
            readOnly: true,
            maxLines: 2,
            leading: Icons.notes_rounded,
          ),
        ],
      ),
    );
  }
}

class CardEarningVisualSummary extends StatelessWidget {
  const CardEarningVisualSummary({required this.design, super.key});

  final CardDesignDraft design;

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    return WafloSectionCard(
      key: const ValueKey('waflo-studio-section-2'),
      title: strings.earningVisual,
      leading: Icons.loyalty_outlined,
      child: Wrap(
        spacing: WafloSpacing.x2,
        runSpacing: WafloSpacing.x2,
        children: [
          WafloStatusChip(
            label:
                '${strings.stampShape}: ${_stampShapeLabel(strings, design)}',
            tone: WafloStatusTone.neutral,
            icon: Icons.category_outlined,
          ),
          WafloStatusChip(
            label:
                '${strings.stampIcon}: ${_iconLabel(strings, design.stampIcon)}',
            tone: WafloStatusTone.neutral,
            icon: _iconData(design.stampIcon),
          ),
        ],
      ),
    );
  }
}

class CardRewardsSummary extends StatelessWidget {
  const CardRewardsSummary({required this.design, super.key});

  final CardDesignDraft design;

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    return WafloSectionCard(
      key: const ValueKey('waflo-studio-section-3'),
      title: strings.rewards,
      leading: Icons.redeem_outlined,
      trailing: WafloStatusChip(
        label:
            '${strings.rewardIcon}: ${_iconLabel(strings, design.rewardIcon)}',
        tone: WafloStatusTone.neutral,
        icon: _iconData(design.rewardIcon),
      ),
      child: Column(
        children: [
          _MediaStateRow(
            label: strings.rewardImage,
            media: design.rewardMedia,
            icon: Icons.card_giftcard_outlined,
          ),
          const SizedBox(height: WafloSpacing.x3),
          WafloTextField(
            label: strings.rewardLabel,
            initialValue: design.copy.rewardLabel,
            readOnly: true,
            leading: Icons.card_giftcard_outlined,
          ),
        ],
      ),
    );
  }
}

String _cardShapeLabel(WafloV2Strings strings, CardDesignDraft design) {
  return switch (design.cardShape) {
    CardVisualShape.roundedRectangle => strings.roundedCard,
    CardVisualShape.softRectangle => strings.softRounded,
  };
}

String _stampShapeLabel(WafloV2Strings strings, CardDesignDraft design) {
  return switch (design.stampShape) {
    StampVisualShape.circle => strings.circle,
    StampVisualShape.roundedSquare => strings.roundedSquare,
    StampVisualShape.star => strings.star,
    StampVisualShape.customIcon => strings.customIcon,
  };
}

String _iconLabel(WafloV2Strings strings, CardVisualIcon icon) {
  return switch (icon) {
    CardVisualIcon.coffee => strings.coffeeIcon,
    CardVisualIcon.star => strings.star,
    CardVisualIcon.gift => strings.giftIcon,
    CardVisualIcon.service => strings.serviceIcon,
    CardVisualIcon.custom => strings.customIcon,
  };
}

IconData _iconData(CardVisualIcon icon) {
  return switch (icon) {
    CardVisualIcon.coffee => Icons.local_cafe_outlined,
    CardVisualIcon.star => Icons.star_outline_rounded,
    CardVisualIcon.gift => Icons.card_giftcard_outlined,
    CardVisualIcon.service => Icons.room_service_outlined,
    CardVisualIcon.custom => Icons.image_outlined,
  };
}

class _MediaStateRow extends StatelessWidget {
  const _MediaStateRow({
    required this.label,
    required this.media,
    required this.icon,
  });

  final String label;
  final CardMediaReference media;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    final status = switch (media.state) {
      CardMediaState.empty => strings.notUploaded,
      CardMediaState.localPreview => strings.localMediaPreview,
      CardMediaState.serverConfirmed => strings.confirmedMedia,
    };
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: WafloSpacing.x2),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        const SizedBox(width: WafloSpacing.x2),
        Flexible(
          child: Text(
            status,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
