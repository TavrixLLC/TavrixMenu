import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/localization/app_localizations_extension.dart';
import 'waflo_button.dart';
import 'waflo_card.dart';
import 'waflo_status_badge.dart';

class ScannerActionPanel extends StatelessWidget {
  const ScannerActionPanel({
    required this.onScan,
    super.key,
    this.isBusy = false,
    this.businessName,
  });

  final VoidCallback? onScan;
  final bool isBusy;
  final String? businessName;

  @override
  Widget build(BuildContext context) {
    return WafloCard(
      color: AppColors.ink,
      borderColor: AppColors.ink,
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.charcoalSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.primaryCoral,
                    size: 28,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WafloStatusBadge(
                      label: businessName?.trim().isNotEmpty == true
                          ? businessName!.trim()
                          : context.l10n.scannerReady,
                      icon: Icons.shield_outlined,
                      color: AppColors.charcoalSoft,
                      foregroundColor: AppColors.surfaceWhite,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.staffScannerTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.surfaceWhite,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.scannerPrivacy,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.surfaceWhite.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          WafloButton(
            key: ValueKey('walletOpenCameraButton'),
            label: isBusy
                ? context.l10n.scannerBusy
                : context.l10n.openWalletScanner,
            icon: Icons.qr_code_scanner,
            onPressed: isBusy ? null : onScan,
          ),
        ],
      ),
    );
  }
}
