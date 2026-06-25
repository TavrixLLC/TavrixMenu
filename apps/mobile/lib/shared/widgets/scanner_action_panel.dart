import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
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
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WafloStatusBadge(
                      label: businessName?.trim().isNotEmpty == true
                          ? businessName!.trim()
                          : 'Scanner ready',
                      icon: Icons.shield_outlined,
                      color: AppColors.charcoalSoft,
                      foregroundColor: AppColors.surfaceWhite,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Scan customer QR',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.surfaceWhite,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tokens stay hidden from staff screens.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.surfaceWhite.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          WafloButton(
            key: const ValueKey('walletOpenCameraButton'),
            label: isBusy ? 'Scanner busy' : 'Open camera scanner',
            icon: Icons.qr_code_scanner,
            onPressed: isBusy ? null : onScan,
          ),
        ],
      ),
    );
  }
}
