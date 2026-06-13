import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
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
                    'Customer Enrollment Link',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'A business slug is required before customers can join from a public loyalty link.',
                  ),
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
                      'Customer Enrollment Link',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Ask the customer to scan this QR or open this link to join the loyalty program.',
                    ),
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
          Text(
            'Enrollment URL',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(enrollmentUrl),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: 'Copy link',
                icon: Icons.copy_outlined,
                onPressed: () => _copyLink(context, enrollmentUrl),
                variant: AppButtonVariant.secondary,
                expand: false,
              ),
              AppButton(
                label: 'Share link',
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
    ).showSnackBar(const SnackBar(content: Text('Enrollment link copied')));
  }

  Future<void> _shareLink(BuildContext context, String enrollmentUrl) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'Join our loyalty program',
          subject: 'Join our loyalty program',
          text: 'Join our loyalty program: $enrollmentUrl',
        ),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: enrollmentUrl));
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sharing is unavailable. Enrollment link copied.'),
        ),
      );
    }
  }
}
