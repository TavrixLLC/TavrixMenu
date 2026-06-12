import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import 'app_card.dart';

class QRPreviewCard extends StatelessWidget {
  const QRPreviewCard({required this.publicUrl, super.key, this.qrPayload});

  final String publicUrl;
  final String? qrPayload;

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
          const SizedBox(height: AppSpacing.md),
          Text('QR payload', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(qrPayload?.isNotEmpty == true ? qrPayload! : publicUrl),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => _copy(context, publicUrl, 'Public URL copied'),
                icon: const Icon(Icons.copy),
                label: const Text('Copy URL'),
              ),
              OutlinedButton.icon(
                onPressed: () => _copy(
                  context,
                  qrPayload?.isNotEmpty == true ? qrPayload! : publicUrl,
                  'QR payload copied',
                ),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Copy payload'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
