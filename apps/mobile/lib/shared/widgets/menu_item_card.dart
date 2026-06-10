import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/utils/money_formatter.dart';
import '../../features/menu/domain/entities/menu_item.dart';
import 'app_card.dart';
import 'status_badge.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    required this.item,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final MenuItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
                Text(MoneyFormatter.formatPrice(item.price)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(label: item.isAvailable ? 'Active' : 'Hidden'),
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        tooltip: 'Edit item',
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    if (onDelete != null)
                      IconButton(
                        tooltip: 'Delete item',
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
