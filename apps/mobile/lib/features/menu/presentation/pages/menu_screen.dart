import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/entities/menu_item.dart';
import '../bloc/menu_cubit.dart';
import '../bloc/menu_state.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _categoryController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemPriceController = TextEditingController(text: '3000');
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuCubit>().load();
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Menu management',
      scrollable: true,
      child: BlocBuilder<MenuCubit, MenuState>(
        builder: (context, state) {
          if (state.status == MenuStatus.loading ||
              state.status == MenuStatus.initial) {
            return const LoadingView(message: 'Loading menu');
          }

          if (state.status == MenuStatus.failure) {
            return ErrorView(
              message: state.errorMessage ?? 'Menu could not load.',
              onRetry: () => context.read<MenuCubit>().load(),
            );
          }

          if (state.business == null) {
            return const EmptyState(
              title: 'Business setup needed',
              message:
                  'Create a business profile before managing categories and menu items.',
              icon: Icons.storefront,
            );
          }

          final visibleCategories = state.visibleCategories;
          final visibleItems = state.visibleItems;
          final canManageMenu = state.canManageMenu;
          final activeCategories =
              state.categories.where((category) => category.isActive).toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          final selectedCategoryId = _selectedCategoryIdFor(activeCategories);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: state.business!.name,
                subtitle: state.showArchived
                    ? 'Restore archived categories and unavailable menu items.'
                    : 'Manage active categories and available menu items.',
              ),
              if (state.summaryErrorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                _MenuNotice(
                  title: 'Permissions summary unavailable',
                  message:
                      'Menu data loaded, but latest dashboard permissions could not be refreshed. ${state.summaryErrorMessage}',
                ),
              ],
              if (!canManageMenu) ...[
                const SizedBox(height: AppSpacing.md),
                const _MenuNotice(
                  title: 'Restricted access',
                  message:
                      'You can view this menu, but your business permissions do not allow menu changes.',
                ),
              ],
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                ErrorView(message: state.errorMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    icon: Icon(Icons.visibility_outlined),
                    label: Text('Active'),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    icon: Icon(Icons.archive_outlined),
                    label: Text('Archived'),
                  ),
                ],
                selected: {state.showArchived},
                onSelectionChanged: (selection) {
                  context.read<MenuCubit>().setArchivedView(selection.first);
                },
              ),
              if (canManageMenu && !state.showArchived) ...[
                const SizedBox(height: AppSpacing.lg),
                _AddCategoryCard(
                  controller: _categoryController,
                  onSubmit: () async {
                    await _runMenuMutation(
                      (cubit) => cubit.addCategory(_categoryController.text),
                    );
                    _categoryController.clear();
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _AddItemCard(
                  categories: activeCategories,
                  selectedCategoryId: selectedCategoryId,
                  onCategoryChanged: (categoryId) {
                    setState(() {
                      _selectedCategoryId = categoryId;
                    });
                  },
                  nameController: _itemNameController,
                  descriptionController: _itemDescriptionController,
                  priceController: _itemPriceController,
                  enabled: activeCategories.isNotEmpty,
                  onSubmit: () async {
                    final priceCents =
                        int.tryParse(_itemPriceController.text) ?? 0;
                    final categoryId = _selectedCategoryIdFor(activeCategories);
                    if (categoryId == null) {
                      return;
                    }
                    await _runMenuMutation(
                      (cubit) => cubit.addItem(
                        categoryId: categoryId,
                        name: _itemNameController.text,
                        description: _itemDescriptionController.text,
                        priceCents: priceCents,
                      ),
                    );
                    _itemNameController.clear();
                    _itemDescriptionController.clear();
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: state.showArchived
                    ? 'Archived categories'
                    : 'Active categories',
              ),
              const SizedBox(height: AppSpacing.md),
              _CategoryList(
                categories: visibleCategories,
                canManageMenu: canManageMenu,
                showArchived: state.showArchived,
                onArchive: (id) =>
                    _runMenuMutation((cubit) => cubit.archiveCategory(id)),
                onRestore: (id) =>
                    _runMenuMutation((cubit) => cubit.restoreCategory(id)),
                onReorder: (categories) => _runMenuMutation(
                  (cubit) => cubit.reorderCategories(categories),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: state.showArchived ? 'Unavailable items' : 'Menu items',
              ),
              const SizedBox(height: AppSpacing.md),
              _ItemList(
                items: visibleItems,
                canManageMenu: canManageMenu,
                showArchived: state.showArchived,
                onArchive: (id) =>
                    _runMenuMutation((cubit) => cubit.archiveItem(id)),
                onRestore: (id) =>
                    _runMenuMutation((cubit) => cubit.restoreItem(id)),
                onReorder: (items) =>
                    _runMenuMutation((cubit) => cubit.reorderItems(items)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _runMenuMutation(
    Future<void> Function(MenuCubit cubit) action,
  ) async {
    final menuCubit = context.read<MenuCubit>();
    await action(menuCubit);
    if (!mounted) {
      return;
    }

    final businessId = menuCubit.state.business?.id;
    if (businessId == null || businessId.trim().isEmpty) {
      return;
    }

    await context.read<DashboardCubit>().refreshSummary(businessId);
  }

  String? _selectedCategoryIdFor(List<MenuCategory> categories) {
    if (categories.isEmpty) {
      return null;
    }

    final selectedCategoryId = _selectedCategoryId;
    if (selectedCategoryId != null &&
        categories.any((category) => category.id == selectedCategoryId)) {
      return selectedCategoryId;
    }

    return categories.first.id;
  }
}

class _AddCategoryCard extends StatelessWidget {
  const _AddCategoryCard({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Category name',
            controller: controller,
            hint: 'Breakfast',
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Add category',
            icon: Icons.add,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _AddItemCard extends StatelessWidget {
  const _AddItemCard({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.enabled,
    required this.onSubmit,
  });

  final List<MenuCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add menu item', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (categories.isEmpty)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Add an active category first so this item has a place in the menu.',
                  ),
                ),
              ],
            )
          else
            DropdownButtonFormField<String>(
              initialValue: selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final category in categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
              ],
              onChanged: enabled ? onCategoryChanged : null,
            ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Item name',
            controller: nameController,
            hint: 'Cardamom latte',
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Description',
            controller: descriptionController,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Price',
            controller: priceController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Add item',
            icon: Icons.add_circle_outline,
            onPressed: enabled ? onSubmit : null,
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.categories,
    required this.canManageMenu,
    required this.showArchived,
    required this.onArchive,
    required this.onRestore,
    required this.onReorder,
  });

  final List<MenuCategory> categories;
  final bool canManageMenu;
  final bool showArchived;
  final Future<void> Function(String id) onArchive;
  final Future<void> Function(String id) onRestore;
  final Future<void> Function(List<MenuCategory> categories) onReorder;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return EmptyState(
        title: showArchived ? 'No archived categories' : 'No categories yet',
        message: showArchived
            ? 'Archived categories will appear here after you archive them.'
            : 'Add your first category to organize the menu.',
      );
    }

    if (!canManageMenu || categories.length < 2) {
      return Column(
        children: [
          for (final category in categories) ...[
            _CategoryCard(
              category: category,
              canManageMenu: canManageMenu,
              showArchived: showArchived,
              onArchive: onArchive,
              onRestore: onRestore,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) {
        final reordered = _reordered(categories, oldIndex, newIndex);
        onReorder(reordered);
      },
      itemBuilder: (context, index) {
        final category = categories[index];
        return Padding(
          key: ValueKey('category-${category.id}'),
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _CategoryCard(
            category: category,
            canManageMenu: canManageMenu,
            showArchived: showArchived,
            onArchive: onArchive,
            onRestore: onRestore,
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.canManageMenu,
    required this.showArchived,
    required this.onArchive,
    required this.onRestore,
  });

  final MenuCategory category;
  final bool canManageMenu;
  final bool showArchived;
  final Future<void> Function(String id) onArchive;
  final Future<void> Function(String id) onRestore;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.drag_indicator),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              category.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          StatusBadge(label: category.isActive ? 'Active' : 'Archived'),
          if (canManageMenu) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton.icon(
              onPressed: () => showArchived
                  ? onRestore(category.id)
                  : onArchive(category.id),
              icon: Icon(showArchived ? Icons.restore : Icons.archive_outlined),
              label: Text(showArchived ? 'Restore' : 'Archive'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({
    required this.items,
    required this.canManageMenu,
    required this.showArchived,
    required this.onArchive,
    required this.onRestore,
    required this.onReorder,
  });

  final List<MenuItem> items;
  final bool canManageMenu;
  final bool showArchived;
  final Future<void> Function(String id) onArchive;
  final Future<void> Function(String id) onRestore;
  final Future<void> Function(List<MenuItem> items) onReorder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        title: showArchived ? 'No unavailable items' : 'No menu items yet',
        message: showArchived
            ? 'Archived or unavailable items will appear here.'
            : 'Add a simple item shell now. Images and advanced tools come later.',
      );
    }

    if (!canManageMenu || items.length < 2) {
      return Column(
        children: [
          for (final item in items) ...[
            _ItemCard(
              item: item,
              canManageMenu: canManageMenu,
              showArchived: showArchived,
              onArchive: onArchive,
              onRestore: onRestore,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) {
        final reordered = _reordered(items, oldIndex, newIndex);
        onReorder(reordered);
      },
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          key: ValueKey('item-${item.id}'),
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _ItemCard(
            item: item,
            canManageMenu: canManageMenu,
            showArchived: showArchived,
            onArchive: onArchive,
            onRestore: onRestore,
          ),
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.canManageMenu,
    required this.showArchived,
    required this.onArchive,
    required this.onRestore,
  });

  final MenuItem item;
  final bool canManageMenu;
  final bool showArchived;
  final Future<void> Function(String id) onArchive;
  final Future<void> Function(String id) onRestore;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.drag_indicator),
          const SizedBox(width: AppSpacing.sm),
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
          if (canManageMenu) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton.icon(
              onPressed: () =>
                  showArchived ? onRestore(item.id) : onArchive(item.id),
              icon: Icon(showArchived ? Icons.restore : Icons.archive_outlined),
              label: Text(showArchived ? 'Restore' : 'Archive'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuNotice extends StatelessWidget {
  const _MenuNotice({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<T> _reordered<T>(List<T> items, int oldIndex, int newIndex) {
  final next = [...items];
  var targetIndex = newIndex;
  if (targetIndex > oldIndex) {
    targetIndex -= 1;
  }
  final moved = next.removeAt(oldIndex);
  next.insert(targetIndex, moved);
  return next;
}
