import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';

class StaffScannerScreen extends StatelessWidget {
  const StaffScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Staff scanner',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Scanner placeholder',
            subtitle: 'Camera scanning is intentionally outside Sprint 1.',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatusBadge(label: 'Later'),
                const SizedBox(height: AppSpacing.lg),
                Icon(
                  Icons.document_scanner_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Staff scanner shell',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'This screen reserves the staff workflow without adding camera or QR scanner packages yet.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
