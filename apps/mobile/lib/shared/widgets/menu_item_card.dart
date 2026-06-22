import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/utils/money_formatter.dart';
import '../../features/menu/domain/entities/menu_item.dart';
import 'app_card.dart';
import 'status_badge.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({required this.item, super.key});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(item.description),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(MoneyFormatter.formatCents(item.priceCents)),
              ],
            ),
          ),
          StatusBadge(label: item.isAvailable ? 'Active' : 'Hidden'),
        ],
      ),
    );
  }
}
