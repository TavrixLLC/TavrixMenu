import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../features/menu/domain/entities/menu_item.dart';
import 'app_card.dart';
import 'status_badge.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    required this.item,
    super.key,
    this.onEdit,
    this.onDelete,
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
                Text(
                  item.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (item.nameEn?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(item.nameEn!),
                ],
                if (item.displayDescription.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(item.displayDescription),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(item.price),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(label: item.isAvailable ? 'Available' : 'Hidden'),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  IconButton(
                    tooltip: 'Edit item',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: 'Delete item',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
