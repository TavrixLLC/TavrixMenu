import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import 'app_card.dart';

class QRPreviewCard extends StatelessWidget {
  const QRPreviewCard({
    required this.publicUrl,
    super.key,
    this.publicMenuPath,
    this.qrPayload,
  });

  final String publicUrl;
  final String? publicMenuPath;
  final String? qrPayload;

  static Future<void> copyUrl(String publicUrl) {
    return Clipboard.setData(ClipboardData(text: publicUrl));
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.ceramic,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const SizedBox(
              height: 180,
              width: double.infinity,
              child: Center(
                child: Icon(
                  Icons.qr_code_2,
                  size: 88,
                  color: AppColors.houseGreen,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Public menu URL',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(publicUrl),
          if (publicMenuPath?.isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Public menu path',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(publicMenuPath!),
          ],
          if (qrPayload?.isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.md),
            Text('QR payload', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(qrPayload!),
          ],
        ],
      ),
    );
  }
}
