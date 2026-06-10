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

  String? _selectedCategoryIdFor(List<MenuCategory> categories) {
    if (categories.isEmpty) {
      return null;
    }

    final current = _selectedCategoryId;
    if (current != null &&
        categories.any((category) => category.id == current)) {
      return current;
    }

    return categories.first.id;
  }

  Future<void> _showEditItemDialog(BuildContext context, MenuItem item) async {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final priceController = TextEditingController(text: item.price);
    var isAvailable = item.isAvailable;

    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Edit menu item'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item name',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isAvailable,
                        title: const Text('Available'),
                        onChanged: (value) {
                          setDialogState(() {
                            isAvailable = value ?? true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!context.mounted || saved != true) {
        return;
      }

      await context.read<MenuCubit>().updateItem(
        item: item,
        name: nameController.text,
        description: descriptionController.text,
        price: priceController.text,
        isAvailable: isAvailable,
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      priceController.dispose();
    }
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

          if (state.status == MenuStatus.failure && state.business == null) {
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

          final selectedCategoryId = _selectedCategoryIdFor(state.categories);

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
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Category name',
                      controller: _categoryController,
                      hint: 'Breakfast',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Add category',
                      icon: Icons.add,
                      onPressed: () async {
                        await context.read<MenuCubit>().addCategory(
                          _categoryController.text,
                        );
                        _categoryController.clear();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add menu item',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: [
                        for (final category in state.categories)
                          DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                      ],
                      onChanged: state.categories.isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Item name',
                      controller: _itemNameController,
                      hint: 'Cardamom latte',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Description',
                      controller: _itemDescriptionController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Price',
                      controller: _itemPriceController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Add item',
                      icon: Icons.add_circle_outline,
                      onPressed: state.categories.isEmpty
                          ? null
                          : () async {
                              await context.read<MenuCubit>().addItem(
                                categoryId: selectedCategoryId,
                                name: _itemNameController.text,
                                description: _itemDescriptionController.text,
                                price: _itemPriceController.text,
                              );
                              _itemNameController.clear();
                              _itemDescriptionController.clear();
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Categories'),
              const SizedBox(height: AppSpacing.md),
              if (state.categories.isEmpty)
                const EmptyState(
                  title: 'No categories yet',
                  message: 'Add your first category to organize the menu.',
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final category in state.categories)
                      StatusBadge(label: category.name),
                  ],
                ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Menu items'),
              const SizedBox(height: AppSpacing.md),
              if (state.items.isEmpty)
                const EmptyState(
                  title: 'No menu items yet',
                  message:
                      'Add a simple item shell now. Images and advanced tools come later.',
                )
              else
                Column(
                  children: [
                    for (final item in state.items) ...[
                      MenuItemCard(
                        item: item,
                        onEdit: () => _showEditItemDialog(context, item),
                        onDelete: () =>
                            context.read<MenuCubit>().deleteItem(item.id),
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
}
