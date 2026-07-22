import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/localization/app_localizations_extension.dart';
import 'app_card.dart';

class QRPreviewCard extends StatelessWidget {
  const QRPreviewCard({required this.publicUrl, super.key});

  final String publicUrl;

  @override
  Widget build(BuildContext context) {
    final confirmedUrl = confirmedPublicMenuUrl(publicUrl);
    if (confirmedUrl == null) {
      return AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.qr_code_2_outlined),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.publicMenuQrUnavailableTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(context.l10n.publicMenuQrUnavailableBody),
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
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.ceramic,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: SizedBox(
              height: 212,
              width: double.infinity,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: QrImageView(
                    key: const ValueKey('confirmed-public-menu-qr'),
                    data: confirmedUrl,
                    version: QrVersions.auto,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                    size: 180,
                    backgroundColor: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.previewCustomerMenu,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(confirmedUrl),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => _copy(context, confirmedUrl),
                icon: const Icon(Icons.copy),
                label: Text(context.l10n.copyPublicMenuLink),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.publicMenuLinkCopied)));
  }
}

String? confirmedPublicMenuUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null ||
      uri.scheme.toLowerCase() != 'https' ||
      uri.host.trim().isEmpty ||
      uri.host.toLowerCase() == 'localhost') {
    return null;
  }
  return uri.toString();
}
