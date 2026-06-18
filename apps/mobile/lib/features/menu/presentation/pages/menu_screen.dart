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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: state.business!.name,
                subtitle:
                    'Manage categories and menu items for staff operations.',
              ),
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
                              final priceCents =
                                  int.tryParse(_itemPriceController.text) ?? 0;
                              await context.read<MenuCubit>().addItem(
                                name: _itemNameController.text,
                                description: _itemDescriptionController.text,
                                priceCents: priceCents,
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
                      MenuItemCard(item: item),
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
