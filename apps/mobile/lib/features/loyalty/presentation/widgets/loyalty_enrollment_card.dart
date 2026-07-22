import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/loyalty_enrollment_link.dart';

class LoyaltyEnrollmentCard extends StatelessWidget {
  const LoyaltyEnrollmentCard({
    required this.businessSlug,
    required this.customerWebBaseUrl,
    super.key,
    this.publicMenuUrl,
  });

  final String businessSlug;
  final String customerWebBaseUrl;
  final String? publicMenuUrl;

  @override
  Widget build(BuildContext context) {
    final enrollmentUrl = LoyaltyEnrollmentLink.build(
      businessSlug: businessSlug,
      customerWebBaseUrl: customerWebBaseUrl,
      publicMenuUrl: publicMenuUrl,
    );

    if (enrollmentUrl == null) {
      return AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.link_off_outlined),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.loyaltyEnrollmentUnavailableTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(context.l10n.loyaltyEnrollmentUnavailableBody),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.qr_code_2_outlined),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.loyaltyEnrollmentTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(context.l10n.loyaltyEnrollmentHelp),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.ceramic),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: QrImageView(
                  data: enrollmentUrl,
                  version: QrVersions.auto,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  size: 180,
                  backgroundColor: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SelectableText(enrollmentUrl),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: context.l10n.copyLink,
                icon: Icons.copy_outlined,
                onPressed: () => _copyLink(context, enrollmentUrl),
                variant: AppButtonVariant.secondary,
                expand: false,
              ),
              AppButton(
                label: context.l10n.shareLink,
                icon: Icons.ios_share_outlined,
                onPressed: () => _shareLink(context, enrollmentUrl),
                variant: AppButtonVariant.secondary,
                expand: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copyLink(BuildContext context, String enrollmentUrl) async {
    await Clipboard.setData(ClipboardData(text: enrollmentUrl));
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.linkCopied)));
  }

  Future<void> _shareLink(BuildContext context, String enrollmentUrl) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: context.l10n.loyaltyEnrollmentTitle,
          subject: context.l10n.loyaltyEnrollmentTitle,
          text: context.l10n.loyaltyEnrollmentShareText(enrollmentUrl),
        ),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: enrollmentUrl));
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.sharingUnavailableCopied)),
      );
    }
  }
}
