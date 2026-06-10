import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/menu_item_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
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
  final _categoryNameArController = TextEditingController();
  final _categoryNameEnController = TextEditingController();
  final _categorySortController = TextEditingController(text: '0');
  final _itemNameArController = TextEditingController();
  final _itemNameEnController = TextEditingController();
  final _itemDescriptionArController = TextEditingController();
  final _itemDescriptionEnController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _itemImageUrlController = TextEditingController();
  final _itemSortController = TextEditingController(text: '0');
  bool _categoryIsActive = true;
  bool _itemIsAvailable = true;
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
    _categoryNameArController.dispose();
    _categoryNameEnController.dispose();
    _categorySortController.dispose();
    _itemNameArController.dispose();
    _itemNameEnController.dispose();
    _itemDescriptionArController.dispose();
    _itemDescriptionEnController.dispose();
    _itemPriceController.dispose();
    _itemImageUrlController.dispose();
    _itemSortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Menu management',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<MenuCubit>().load(),
        ),
      ],
      scrollable: true,
      child: BlocConsumer<MenuCubit, MenuState>(
        listenWhen: (previous, current) =>
            previous.successMessage != current.successMessage ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.successMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ScaffoldMessenger.maybeOf(
                context,
              )?.showSnackBar(SnackBar(content: Text(state.successMessage!)));
            });
          }
        },
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

          final effectiveCategoryId = _effectiveCategoryId(state.categories);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: state.business!.name,
                subtitle:
                    'Manage categories and menu items for staff operations.',
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                ErrorView(message: state.errorMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              _buildCategoryForm(context, state),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Categories'),
              const SizedBox(height: AppSpacing.md),
              if (state.categories.isEmpty)
                const EmptyState(
                  title: 'No categories yet',
                  message: 'Add your first category to organize the menu.',
                )
              else
                Column(
                  children: [
                    for (final category in state.categories) ...[
                      _CategoryCard(
                        category: category,
                        isSubmitting: state.isSubmitting,
                        onEdit: () => _showCategorySheet(context, category),
                        onDelete: () =>
                            _confirmDeleteCategory(context, category),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              const SizedBox(height: AppSpacing.lg),
              _buildItemForm(context, state, effectiveCategoryId),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Menu items'),
              const SizedBox(height: AppSpacing.md),
              if (state.items.isEmpty)
                const EmptyState(
                  title: 'No menu items yet',
                  message:
                      'Add items after creating at least one category. Images remain URL-only for now.',
                )
              else
                Column(
                  children: [
                    for (final item in state.items) ...[
                      MenuItemCard(
                        item: item,
                        onEdit: state.isSubmitting
                            ? null
                            : () => _showItemSheet(context, state, item),
                        onDelete: state.isSubmitting
                            ? null
                            : () => _confirmDeleteItem(context, item),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryForm(BuildContext context, MenuState state) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Arabic name',
            controller: _categoryNameArController,
            hint: 'Hot Drinks',
            enabled: !state.isSubmitting,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'English name',
            controller: _categoryNameEnController,
            hint: 'Hot Drinks',
            enabled: !state.isSubmitting,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Sort order',
            controller: _categorySortController,
            keyboardType: TextInputType.number,
            enabled: !state.isSubmitting,
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Active'),
            value: _categoryIsActive,
            onChanged: state.isSubmitting
                ? null
                : (value) => setState(() => _categoryIsActive = value),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: state.isSubmitting ? 'Saving' : 'Add category',
            icon: Icons.add,
            onPressed: state.isSubmitting ? null : _submitCategory,
          ),
        ],
      ),
    );
  }

  Widget _buildItemForm(
    BuildContext context,
    MenuState state,
    String? effectiveCategoryId,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add menu item', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            key: ValueKey(effectiveCategoryId),
            initialValue: effectiveCategoryId,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final category in state.categories)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.displayName),
                ),
            ],
            onChanged: state.isSubmitting || state.categories.isEmpty
                ? null
                : (value) => setState(() => _selectedCategoryId = value),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Arabic name',
            controller: _itemNameArController,
            hint: 'Turkish Coffee',
            enabled: !state.isSubmitting,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'English name',
            controller: _itemNameEnController,
            enabled: !state.isSubmitting,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Arabic description',
            controller: _itemDescriptionArController,
            maxLines: 2,
            enabled: !state.isSubmitting,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'English description',
            controller: _itemDescriptionEnController,
            maxLines: 2,
            enabled: !state.isSubmitting,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Price',
            controller: _itemPriceController,
            hint: '2500',
            keyboardType: TextInputType.number,
            enabled: !state.isSubmitting,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Image URL',
            controller: _itemImageUrlController,
            keyboardType: TextInputType.url,
            enabled: !state.isSubmitting,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Sort order',
            controller: _itemSortController,
            keyboardType: TextInputType.number,
            enabled: !state.isSubmitting,
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Available'),
            value: _itemIsAvailable,
            onChanged: state.isSubmitting
                ? null
                : (value) => setState(() => _itemIsAvailable = value),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: state.isSubmitting ? 'Saving' : 'Add item',
            icon: Icons.add_circle_outline,
            onPressed: state.isSubmitting || state.categories.isEmpty
                ? null
                : _submitItem,
          ),
        ],
      ),
    );
  }

  Future<void> _submitCategory() async {
    final cubit = context.read<MenuCubit>();
    await cubit.addCategory(
      nameAr: _categoryNameArController.text,
      nameEn: _categoryNameEnController.text,
      sortOrder: _parseSortOrder(_categorySortController.text),
      isActive: _categoryIsActive,
    );
    if (!mounted || cubit.state.errorMessage != null) {
      return;
    }
    _categoryNameArController.clear();
    _categoryNameEnController.clear();
    _categorySortController.text = '0';
    setState(() => _categoryIsActive = true);
  }

  Future<void> _submitItem() async {
    final cubit = context.read<MenuCubit>();
    final categoryId = _effectiveCategoryId(cubit.state.categories) ?? '';
    await cubit.addItem(
      categoryId: categoryId,
      nameAr: _itemNameArController.text,
      nameEn: _itemNameEnController.text,
      descriptionAr: _itemDescriptionArController.text,
      descriptionEn: _itemDescriptionEnController.text,
      price: _itemPriceController.text,
      imageUrl: _itemImageUrlController.text,
      sortOrder: _parseSortOrder(_itemSortController.text),
      isAvailable: _itemIsAvailable,
    );
    if (!mounted || cubit.state.errorMessage != null) {
      return;
    }
    _itemNameArController.clear();
    _itemNameEnController.clear();
    _itemDescriptionArController.clear();
    _itemDescriptionEnController.clear();
    _itemPriceController.clear();
    _itemImageUrlController.clear();
    _itemSortController.text = '0';
    setState(() => _itemIsAvailable = true);
  }

  Future<void> _showCategorySheet(
    BuildContext context,
    MenuCategory category,
  ) async {
    final cubit = context.read<MenuCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: _CategoryEditSheet(category: category),
      ),
    );
  }

  Future<void> _showItemSheet(
    BuildContext context,
    MenuState state,
    MenuItem item,
  ) async {
    final cubit = context.read<MenuCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: _ItemEditSheet(item: item, categories: state.categories),
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    MenuCategory category,
  ) async {
    final cubit = context.read<MenuCubit>();
    final confirmed = await _confirmDelete(
      context,
      title: 'Delete category?',
      message: 'This removes the category from menu management.',
    );
    if (!mounted || !confirmed) {
      return;
    }
    await cubit.deleteCategory(category.id);
  }

  Future<void> _confirmDeleteItem(BuildContext context, MenuItem item) async {
    final cubit = context.read<MenuCubit>();
    final confirmed = await _confirmDelete(
      context,
      title: 'Delete item?',
      message: 'This removes the item from menu management.',
    );
    if (!mounted || !confirmed) {
      return;
    }
    await cubit.deleteItem(item.id);
  }

  Future<bool> _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String? _effectiveCategoryId(List<MenuCategory> categories) {
    if (_selectedCategoryId != null &&
        categories.any((category) => category.id == _selectedCategoryId)) {
      return _selectedCategoryId;
    }
    return categories.isEmpty ? null : categories.first.id;
  }

  int _parseSortOrder(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }
}

// ─── Edit Sheets ─────────────────────────────────────────────────────────────
// These are proper StatefulWidget classes. The key to avoiding the
// _dependents.isEmpty crash: each sheet is wrapped with BlocProvider.value()
// INSIDE the showModalBottomSheet builder. This creates a LOCAL InheritedWidget
// scoped to the modal route's lifetime, so BlocConsumer registers its dependency
// on that local widget — not the parent route's. When the modal closes, both
// are unmounted together cleanly.

class _CategoryEditSheet extends StatefulWidget {
  const _CategoryEditSheet({required this.category});

  final MenuCategory category;

  @override
  State<_CategoryEditSheet> createState() => _CategoryEditSheetState();
}

class _CategoryEditSheetState extends State<_CategoryEditSheet> {
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _sortController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController(text: widget.category.nameAr);
    _nameEnController = TextEditingController(
      text: widget.category.nameEn ?? '',
    );
    _sortController = TextEditingController(
      text: widget.category.sortOrder.toString(),
    );
    _isActive = widget.category.isActive;
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return BlocConsumer<MenuCubit, MenuState>(
      listenWhen: (prev, curr) =>
          prev.isSubmitting && !curr.isSubmitting && curr.errorMessage == null,
      listener: (_, state) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      buildWhen: (prev, curr) => prev.isSubmitting != curr.isSubmitting,
      builder: (ctx, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md + bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Arabic name',
                controller: _nameArController,
                enabled: !state.isSubmitting,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'English name',
                controller: _nameEnController,
                enabled: !state.isSubmitting,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Sort order',
                controller: _sortController,
                keyboardType: TextInputType.number,
                enabled: !state.isSubmitting,
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _isActive,
                onChanged: state.isSubmitting
                    ? null
                    : (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: state.isSubmitting ? 'Saving' : 'Save category',
                icon: Icons.check,
                onPressed: state.isSubmitting
                    ? null
                    : () => ctx.read<MenuCubit>().updateCategory(
                        id: widget.category.id,
                        nameAr: _nameArController.text,
                        nameEn: _nameEnController.text,
                        sortOrder:
                            int.tryParse(_sortController.text.trim()) ?? 0,
                        isActive: _isActive,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ItemEditSheet extends StatefulWidget {
  const _ItemEditSheet({required this.item, required this.categories});

  final MenuItem item;
  final List<MenuCategory> categories;

  @override
  State<_ItemEditSheet> createState() => _ItemEditSheetState();
}

class _ItemEditSheetState extends State<_ItemEditSheet> {
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _descArController;
  late final TextEditingController _descEnController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _sortController;
  late String _categoryId;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController(text: widget.item.nameAr);
    _nameEnController = TextEditingController(text: widget.item.nameEn ?? '');
    _descArController = TextEditingController(
      text: widget.item.descriptionAr ?? '',
    );
    _descEnController = TextEditingController(
      text: widget.item.descriptionEn ?? '',
    );
    _priceController = TextEditingController(text: widget.item.price);
    _imageUrlController = TextEditingController(
      text: widget.item.imageUrl ?? '',
    );
    _sortController = TextEditingController(
      text: widget.item.sortOrder.toString(),
    );
    _isAvailable = widget.item.isAvailable;
    _categoryId = widget.categories.any((c) => c.id == widget.item.categoryId)
        ? widget.item.categoryId
        : (widget.categories.isEmpty ? '' : widget.categories.first.id);
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return BlocConsumer<MenuCubit, MenuState>(
      listenWhen: (prev, curr) =>
          prev.isSubmitting && !curr.isSubmitting && curr.errorMessage == null,
      listener: (_, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) Navigator.of(context).pop();
        });
      },
      buildWhen: (prev, curr) => prev.isSubmitting != curr.isSubmitting,
      builder: (ctx, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md + bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit item',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  key: ValueKey(_categoryId),
                  initialValue: _categoryId.isEmpty ? null : _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final c in widget.categories)
                      DropdownMenuItem(value: c.id, child: Text(c.displayName)),
                  ],
                  onChanged: state.isSubmitting
                      ? null
                      : (v) => setState(() => _categoryId = v ?? ''),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Arabic name',
                  controller: _nameArController,
                  enabled: !state.isSubmitting,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'English name',
                  controller: _nameEnController,
                  enabled: !state.isSubmitting,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Arabic description',
                  controller: _descArController,
                  maxLines: 2,
                  enabled: !state.isSubmitting,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'English description',
                  controller: _descEnController,
                  maxLines: 2,
                  enabled: !state.isSubmitting,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Price',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  enabled: !state.isSubmitting,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Image URL',
                  controller: _imageUrlController,
                  keyboardType: TextInputType.url,
                  enabled: !state.isSubmitting,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Sort order',
                  controller: _sortController,
                  keyboardType: TextInputType.number,
                  enabled: !state.isSubmitting,
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Available'),
                  value: _isAvailable,
                  onChanged: state.isSubmitting
                      ? null
                      : (v) => setState(() => _isAvailable = v),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: state.isSubmitting ? 'Saving' : 'Save item',
                  icon: Icons.check,
                  onPressed: state.isSubmitting
                      ? null
                      : () => ctx.read<MenuCubit>().updateItem(
                          id: widget.item.id,
                          categoryId: _categoryId,
                          nameAr: _nameArController.text,
                          nameEn: _nameEnController.text,
                          descriptionAr: _descArController.text,
                          descriptionEn: _descEnController.text,
                          price: _priceController.text,
                          imageUrl: _imageUrlController.text,
                          sortOrder:
                              int.tryParse(_sortController.text.trim()) ?? 0,
                          isAvailable: _isAvailable,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.isSubmitting,
    required this.onEdit,
    required this.onDelete,
  });

  final MenuCategory category;
  final bool isSubmitting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                  category.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (category.nameEn?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(category.nameEn!),
                ],
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatusBadge(
                      label: category.isActive ? 'Active' : 'Archived',
                    ),
                    StatusBadge(label: 'Sort ${category.sortOrder}'),
                  ],
                ),
              ],
            ),
          ),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              IconButton(
                tooltip: 'Edit category',
                icon: const Icon(Icons.edit_outlined),
                onPressed: isSubmitting ? null : onEdit,
              ),
              IconButton(
                tooltip: 'Delete category',
                icon: const Icon(Icons.delete_outline),
                onPressed: isSubmitting ? null : onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
