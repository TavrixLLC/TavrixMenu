import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/waflo_scaffold.dart';
import '../../../../shared/widgets/waflo_card.dart';
import '../../../../shared/widgets/waflo_button.dart';
import '../../../../shared/widgets/waflo_text_field.dart';
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
  final _searchController = TextEditingController();
  final _itemFormKey = GlobalKey();

  String? _selectedCategoryId;
  String? _selectedCategoryIdFilter;
  String _searchQuery = '';
  String? _itemPriceError;
  MenuItem? _editingItem;

  // Local state to track which item is being archived/restored/edited
  String? _processingItemId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WafloScaffold(
      title: 'إدارة المنيو',
      subtitle: 'قم بإدارة الأقسام والمنتجات الخاصة بمطعمك بسهولة.',
      scrollable: true,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<MenuCubit, MenuState>(
          builder: (context, state) {
            if (state.status == MenuStatus.initial) {
              return const LoadingView(message: 'نحضّر المنيو');
            }

            // If loading but we have no data, show the full page loading spinner
            if (state.status == MenuStatus.loading &&
                state.categories.isEmpty &&
                state.items.isEmpty) {
              return const LoadingView(message: 'نحضّر المنيو');
            }

            if (state.status == MenuStatus.failure &&
                state.categories.isEmpty &&
                state.items.isEmpty) {
              return ErrorView(
                message: state.errorMessage ?? 'تعذر تحميل المنيو حالياً.',
                onRetry: () => context.read<MenuCubit>().load(),
              );
            }

            if (state.business == null) {
              return const EmptyState(
                title: 'أكمل بيانات المطعم أولاً',
                message:
                    'أنشئ مساحة المطعم قبل إضافة الأقسام والمنتجات للمنيو.',
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

            // Filter logic for category tabs
            final activeTabId = _selectedCategoryTabId(activeCategories);
            final displayedGridItems = visibleItems.where((item) {
              final matchesCategory = item.categoryId == activeTabId;
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  item.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  item.description.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
              return matchesCategory && matchesSearch;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thin linear loading bar when reloading/processing in the background
                if (state.status == MenuStatus.loading) ...[
                  const LinearProgressIndicator(
                    minHeight: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryCoral,
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 4),
                ],
                _MenuHero(
                  businessName: state.business!.name,
                  archivedMode: state.showArchived,
                  onAppearancePressed: () => Navigator.of(
                    context,
                  ).pushNamed(AppRouteNames.menuAppearance),
                ),
                const SizedBox(height: AppSpacing.md),
                if (state.summaryErrorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  const _MenuNotice(
                    title: 'تعذر تحديث الصلاحيات',
                    message:
                        'تم تحميل المنيو، لكن لم نتمكن من تحديث ملخص الصلاحيات الآن.',
                  ),
                ],
                if (!canManageMenu) ...[
                  const SizedBox(height: AppSpacing.md),
                  const _MenuNotice(
                    title: 'عرض فقط',
                    message:
                        'صلاحيتك الحالية تسمح بمشاهدة المنيو فقط. اطلب من صاحب المطعم صلاحية التعديل.',
                  ),
                ],
                if (state.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  ErrorView(message: state.errorMessage!),
                ],
                const SizedBox(height: AppSpacing.lg),
                _ViewToggle(
                  showArchived: state.showArchived,
                  onChanged: (val) {
                    context.read<MenuCubit>().setArchivedView(val);
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Search Bar and Add Category Button Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(23),
                          border: Border.all(color: AppColors.softBorder),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: AppColors.mutedText,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'بحث عن منتج...',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (canManageMenu && !state.showArchived) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          // Scroll to Add Category Card
                          final context = _itemFormKey.currentContext;
                          if (context != null) {
                            Scrollable.ensureVisible(
                              context,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(23),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'إضافة قسم',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Horizontal Category Selection Tabs
                if (activeCategories.isNotEmpty) ...[
                  _CategoryTabs(
                    categories: activeCategories,
                    activeTabId: activeTabId,
                    onTabSelected: (categoryId) {
                      setState(() {
                        _selectedCategoryIdFilter = categoryId;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Grid View of Products
                if (activeCategories.isNotEmpty) ...[
                  SectionHeader(
                    title: state.showArchived ? 'المنتجات المخفية' : 'المنتجات',
                    subtitle: state.showArchived
                        ? 'هذه المنتجات لا تظهر للزبائن حالياً.'
                        : 'اضغط على أي منتج أو زر تعديل لتحديث بياناته.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                    itemCount:
                        displayedGridItems.length +
                        (canManageMenu && !state.showArchived ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < displayedGridItems.length) {
                        final item = displayedGridItems[index];
                        return _ProductGridItem(
                          key: ValueKey('grid-item-${item.id}'),
                          item: item,
                          categories: state.categories,
                          canManageMenu: canManageMenu,
                          showArchived: state.showArchived,
                          isProcessing: item.id == _processingItemId,
                          onArchive: (id) => _runMenuMutationWithCardLoading(
                            item.id,
                            (cubit) => cubit.archiveItem(id),
                          ),
                          onRestore: (id) => _runMenuMutationWithCardLoading(
                            item.id,
                            (cubit) => cubit.restoreItem(id),
                          ),
                          onEdit: _startEditingItem,
                        );
                      } else {
                        return _AddGridCard(
                          onTap: () {
                            final context = _itemFormKey.currentContext;
                            if (context != null) {
                              Scrollable.ensureVisible(
                                context,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                alignment: 0.08,
                              );
                            }
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                if (canManageMenu && !state.showArchived) ...[
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
                    key: _itemFormKey,
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
                    priceErrorText: _itemPriceError,
                    editingItem: _editingItem,
                    onPriceChanged: (_) {
                      if (_itemPriceError != null) {
                        setState(() {
                          _itemPriceError = null;
                        });
                      }
                    },
                    enabled: activeCategories.isNotEmpty,
                    onCancelEdit: _editingItem == null ? null : _resetItemForm,
                    onSubmit: () async {
                      final priceCents = _parseIqdAmount(
                        _itemPriceController.text,
                      );
                      if (priceCents == null) {
                        setState(() {
                          _itemPriceError = _iqdPriceValidationMessage;
                        });
                        return;
                      }

                      final categoryId = _selectedCategoryIdFor(
                        activeCategories,
                      );
                      if (categoryId == null) {
                        return;
                      }
                      final editingItem = _editingItem;
                      if (editingItem == null) {
                        await _runMenuMutation(
                          (cubit) => cubit.addItem(
                            categoryId: categoryId,
                            name: _itemNameController.text,
                            description: _itemDescriptionController.text,
                            priceCents: priceCents,
                          ),
                        );
                      } else {
                        await _runMenuMutation(
                          (cubit) => cubit.updateItem(
                            id: editingItem.id,
                            name: _itemNameController.text,
                            description: _itemDescriptionController.text,
                            priceCents: priceCents,
                            isAvailable: editingItem.isAvailable,
                          ),
                        );
                      }
                      _resetItemForm();
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
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
                if (activeCategories.isEmpty)
                  _ItemList(
                    items: visibleItems,
                    categories: state.categories,
                    canManageMenu: canManageMenu,
                    showArchived: state.showArchived,
                    onArchive: (id) =>
                        _runMenuMutation((cubit) => cubit.archiveItem(id)),
                    onRestore: (id) =>
                        _runMenuMutation((cubit) => cubit.restoreItem(id)),
                    onReorder: (items) =>
                        _runMenuMutation((cubit) => cubit.reorderItems(items)),
                    onEdit: _startEditingItem,
                  ),
              ],
            );
          },
        ),
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

  Future<void> _runMenuMutationWithCardLoading(
    String itemId,
    Future<void> Function(MenuCubit cubit) action,
  ) async {
    setState(() {
      _processingItemId = itemId;
    });
    try {
      await _runMenuMutation(action);
    } finally {
      if (mounted) {
        setState(() {
          _processingItemId = null;
        });
      }
    }
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

  String? _selectedCategoryTabId(List<MenuCategory> categories) {
    if (categories.isEmpty) {
      return null;
    }
    final currentFilter = _selectedCategoryIdFilter;
    if (currentFilter != null && categories.any((c) => c.id == currentFilter)) {
      return currentFilter;
    }
    return categories.first.id;
  }

  void _startEditingItem(MenuItem item) {
    setState(() {
      _editingItem = item;
      _selectedCategoryId = item.categoryId;
      _selectedCategoryIdFilter =
          item.categoryId; // Switch category tab to show the editing item
      _itemNameController.text = item.name;
      _itemDescriptionController.text = item.description;
      _itemPriceController.text = item.priceCents.toString();
      _itemPriceError = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _itemFormKey.currentContext;
      if (context == null || !mounted) {
        return;
      }

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: 0.08,
      );
    });
  }

  void _resetItemForm() {
    setState(() {
      _editingItem = null;
      _itemNameController.clear();
      _itemDescriptionController.clear();
      _itemPriceController.text = '3000';
      _itemPriceError = null;
    });
  }
}

class _MenuHero extends StatelessWidget {
  const _MenuHero({
    required this.businessName,
    required this.archivedMode,
    required this.onAppearancePressed,
  });

  final String businessName;
  final bool archivedMode;
  final VoidCallback onAppearancePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WafloCard(
      color: AppColors.warmCream,
      borderColor: AppColors.softBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.restaurant_menu,
                color: AppColors.primaryCoral,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'منيو $businessName',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            archivedMode
                ? 'راجع العناصر المخفية وأعد ما تحتاجه للمنيو العام.'
                : 'أضف الأقسام والمنتجات التي سيشاهدها الزبائن عند مسح رمز الـ QR.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          WafloButton(
            label: 'مظهر المنيو',
            icon: Icons.palette_outlined,
            variant: WafloButtonVariant.secondary,
            expand: false,
            onPressed: onAppearancePressed,
          ),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.showArchived, required this.onChanged});

  final bool showArchived;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutralCanvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'المنيو الظاهر',
              isActive: !showArchived,
              icon: Icons.visibility_outlined,
              onTap: () => onChanged(false),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ToggleButton(
              label: 'العناصر المخفية',
              isActive: showArchived,
              icon: Icons.archive_outlined,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surfaceWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.primaryCoral : AppColors.mutedText,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                color: isActive ? AppColors.textDark : AppColors.mutedText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCategoryCard extends StatelessWidget {
  const _AddCategoryCard({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return WafloCard(
      borderColor: AppColors.softBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إضافة قسم جديد',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          WafloTextField(
            label: 'اسم القسم',
            controller: controller,
            hint: 'مثال: وجبات رئيسية، حلويات، مشروبات',
            prefixIcon: Icons.folder_open_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          WafloButton(label: 'إضافة قسم', icon: Icons.add, onPressed: onSubmit),
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
    required this.priceErrorText,
    required this.editingItem,
    required this.onPriceChanged,
    required this.enabled,
    required this.onCancelEdit,
    required this.onSubmit,
    super.key,
  });

  final List<MenuCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final String? priceErrorText;
  final MenuItem? editingItem;
  final ValueChanged<String> onPriceChanged;
  final bool enabled;
  final VoidCallback? onCancelEdit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final editingItem = this.editingItem;
    final selectedCategory = categories
        .where((category) => category.id == selectedCategoryId)
        .firstOrNull;
    final theme = Theme.of(context);

    return WafloCard(
      borderColor: editingItem == null
          ? AppColors.softBorder
          : AppColors.primaryCoral,
      accentColor: editingItem == null ? null : AppColors.primaryCoral,
      color: editingItem == null ? AppColors.surfaceWhite : AppColors.coralTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                editingItem == null
                    ? Icons.add_circle_outline
                    : Icons.edit_outlined,
                color: AppColors.primaryCoralDark,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  editingItem == null ? 'إضافة منتج' : 'تعديل منتج',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              if (onCancelEdit != null)
                TextButton(
                  onPressed: onCancelEdit,
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            editingItem == null
                ? 'اختر القسم ثم أضف اسم المنتج والسعر بالدينار العراقي.'
                : 'عدّل بيانات المنتج ثم احفظ التغييرات.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (categories.isEmpty)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'أضف قسماً ظاهراً أولاً حتى يعرف الزبون أين يظهر المنتج.',
                  ),
                ),
              ],
            )
          else if (editingItem != null)
            _ReadonlyCategoryLine(categoryName: selectedCategory?.name)
          else
            DropdownButtonFormField<String>(
              initialValue: selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'القسم الرئيسي',
                prefixIcon: Icon(Icons.folder_open_outlined),
              ),
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
          WafloTextField(
            label: 'اسم المنتج',
            controller: nameController,
            hint: 'مثال: لاتيه حار، كريب شوكولاتة',
            prefixIcon: Icons.restaurant_menu_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          WafloTextField(
            label: 'وصف مختصر',
            controller: descriptionController,
            maxLines: 2,
            hint: 'اكتب مكونات الوجبة أو تفاصيل إضافية للزبون',
          ),
          const SizedBox(height: AppSpacing.md),
          _IqdPriceField(
            controller: priceController,
            errorText: priceErrorText,
            onChanged: onPriceChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          const _ImagePlaceholderWidget(),
          const SizedBox(height: AppSpacing.md),
          WafloButton(
            label: editingItem == null ? 'إضافة منتج' : 'حفظ التعديل',
            icon: editingItem == null
                ? Icons.add_circle_outline
                : Icons.check_circle_outline,
            onPressed: enabled ? onSubmit : null,
          ),
        ],
      ),
    );
  }
}

class _ReadonlyCategoryLine extends StatelessWidget {
  const _ReadonlyCategoryLine({required this.categoryName});

  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(Icons.folder_open_outlined, color: AppColors.mutedText),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'القسم: ${categoryName ?? 'القسم الحالي'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
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
        title: showArchived ? 'لا توجد أقسام مؤرشفة' : 'لا توجد أقسام بعد',
        message: showArchived
            ? 'الأقسام التي تخفيها من المنيو ستظهر هنا.'
            : 'ابدأ بقسم واحد مثل مشروبات أو وجبات رئيسية.',
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
            key: ValueKey('category-card-${category.id}'),
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
    super.key,
  });

  final MenuCategory category;
  final bool canManageMenu;
  final bool showArchived;
  final Future<void> Function(String id) onArchive;
  final Future<void> Function(String id) onRestore;

  @override
  Widget build(BuildContext context) {
    return WafloCard(
      borderColor: AppColors.softBorder,
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, color: AppColors.mutedText),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              category.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          StatusBadge(
            label: category.isActive ? 'ظاهر' : 'مؤرشف',
            color: category.isActive ? AppColors.greenTint : AppColors.goldTint,
            foregroundColor: category.isActive
                ? AppColors.freshGreenDark
                : AppColors.rewardGold,
          ),
          if (canManageMenu) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.mutedText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => showArchived
                  ? onRestore(category.id)
                  : onArchive(category.id),
              icon: Icon(
                showArchived ? Icons.restore_outlined : Icons.archive_outlined,
                size: 18,
              ),
              label: Text(showArchived ? 'إرجاع' : 'إخفاء'),
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
    required this.categories,
    required this.canManageMenu,
    required this.showArchived,
    required this.onArchive,
    required this.onRestore,
    required this.onReorder,
    required this.onEdit,
  });

  final List<MenuItem> items;
  final List<MenuCategory> categories;
  final bool canManageMenu;
  final bool showArchived;
  final Future<void> Function(String id) onArchive;
  final Future<void> Function(String id) onRestore;
  final Future<void> Function(List<MenuItem> items) onReorder;
  final ValueChanged<MenuItem> onEdit;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        title: showArchived ? 'لا توجد منتجات مخفية' : 'لا توجد منتجات بعد',
        message: showArchived
            ? 'المنتجات التي تخفيها من المنيو ستظهر هنا.'
            : 'أضف أول منتج للمنيو. صور المنتجات غير متاحة حالياً من التطبيق.',
      );
    }

    if (!canManageMenu || items.length < 2) {
      return Column(
        children: [
          for (final item in items) ...[
            _ItemCard(
              item: item,
              categories: categories,
              canManageMenu: canManageMenu,
              showArchived: showArchived,
              onArchive: onArchive,
              onRestore: onRestore,
              onEdit: onEdit,
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
            key: ValueKey('item-card-${item.id}'),
            item: item,
            categories: categories,
            canManageMenu: canManageMenu,
            showArchived: showArchived,
            onArchive: onArchive,
            onRestore: onRestore,
            onEdit: onEdit,
          ),
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.categories,
    required this.canManageMenu,
    required this.showArchived,
    required this.onArchive,
    required this.onRestore,
    required this.onEdit,
    super.key,
  });

  final MenuItem item;
  final List<MenuCategory> categories;
  final bool canManageMenu;
  final bool showArchived;
  final Future<void> Function(String id) onArchive;
  final Future<void> Function(String id) onRestore;
  final ValueChanged<MenuItem> onEdit;

  @override
  Widget build(BuildContext context) {
    final category = categories
        .where((c) => c.id == item.categoryId)
        .firstOrNull;

    return WafloCard(
      onTap: canManageMenu && !showArchived ? () => onEdit(item) : null,
      borderColor: AppColors.softBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.drag_indicator, color: AppColors.mutedText),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedText,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (category != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neutralCanvas,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.softBorder),
                        ),
                        child: Text(
                          'القسم: ${category.name}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(
                label: item.isAvailable ? 'ظاهر' : 'مخفي',
                color: item.isAvailable
                    ? AppColors.greenTint
                    : AppColors.dangerTint,
                foregroundColor: item.isAvailable
                    ? AppColors.freshGreenDark
                    : AppColors.dangerRed,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.coralTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: AppColors.primaryCoralDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      MoneyFormatter.formatCents(item.priceCents),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryCoralDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (canManageMenu) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (!showArchived) ...[
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryCoral,
                        foregroundColor: AppColors.surfaceWhite,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => onEdit(item),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text(
                        'تعديل',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(color: AppColors.softBorder),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () =>
                        showArchived ? onRestore(item.id) : onArchive(item.id),
                    icon: Icon(
                      showArchived
                          ? Icons.restore_outlined
                          : Icons.visibility_off_outlined,
                      size: 16,
                      color: AppColors.mutedText,
                    ),
                    label: Text(
                      showArchived ? 'إرجاع' : 'إخفاء',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
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
    return WafloCard(
      borderColor: AppColors.softBorder,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
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

class _IqdPriceField extends StatelessWidget {
  const _IqdPriceField({
    required this.controller,
    required this.errorText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      textDirection: TextDirection.ltr,
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: const [_IqdPriceInputFormatter()],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'السعر بالدينار العراقي',
        helperText: 'اكتب رقماً كاملاً فقط. مثال: ٦٬٥٠٠',
        suffixText: 'د.ع',
        prefixIcon: const Icon(Icons.payments_outlined),
        errorText: errorText,
      ),
    );
  }
}

class _ImagePlaceholderWidget extends StatelessWidget {
  const _ImagePlaceholderWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.neutralCanvas,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.add_a_photo_outlined,
            size: 32,
            color: AppColors.mutedText,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'صور المنتجات غير متاحة حالياً',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          const Text(
            'إضافة صور المنتجات غير متاحة حالياً من التطبيق. يمكنك حفظ بيانات المنتج الآن بدون صورة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _IqdPriceInputFormatter extends TextInputFormatter {
  const _IqdPriceInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.contains('.') || text.contains('٫')) {
      return oldValue;
    }

    for (final rune in text.runes) {
      final isAsciiDigit = rune >= 0x30 && rune <= 0x39;
      final isArabicIndicDigit = rune >= 0x0660 && rune <= 0x0669;
      final isEasternArabicDigit = rune >= 0x06F0 && rune <= 0x06F9;
      final isSeparator =
          rune == 0x2C ||
          rune == 0x060C ||
          rune == 0x066C ||
          rune == 0x20 ||
          rune == 0x00A0 ||
          rune == 0x202F;
      if (!isAsciiDigit &&
          !isArabicIndicDigit &&
          !isEasternArabicDigit &&
          !isSeparator) {
        return oldValue;
      }
    }

    return newValue;
  }
}

class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
  });

  final Color color;
  final double strokeWidth;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ),
    );

    final dashWidth = gap;
    final dashSpace = gap;
    double distance = 0.0;

    for (final PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AddGridCard extends StatelessWidget {
  const _AddGridCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: AppColors.primaryCoral.withValues(alpha: 0.5),
          strokeWidth: 1.5,
          gap: 5,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.neutralCanvas.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.coralTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_circle,
                  color: AppColors.primaryCoral,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'إضافة منتج جديد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryCoralDark,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              const Text(
                'انقر هنا لإضافة وجبة أو مشروب للقسم الحالي',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 9,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryCoral,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'إضافة منتج +',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  const _ProductGridItem({
    required this.item,
    required this.categories,
    required this.canManageMenu,
    required this.showArchived,
    required this.isProcessing,
    required this.onArchive,
    required this.onRestore,
    required this.onEdit,
    super.key,
  });

  final MenuItem item;
  final List<MenuCategory> categories;
  final bool canManageMenu;
  final bool showArchived;
  final bool isProcessing;
  final Future<void> Function(String id) onArchive;
  final Future<void> Function(String id) onRestore;
  final ValueChanged<MenuItem> onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Honest premium neutral placeholder instead of mock Unsplash images
    Widget image = const _ItemImagePlaceholder();

    if (!item.isAvailable) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: image,
      );
    }

    return WafloCard(
      borderColor: AppColors.softBorder,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Stack
                Stack(
                  children: [
                    image,
                    // Status Badge overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.isAvailable
                              ? Colors.white
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: item.isAvailable
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.isAvailable ? 'متوفر' : 'نفد الكمية',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: item.isAvailable
                                    ? const Color(0xFF047857)
                                    : const Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.mutedText,
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Switch Toggle
                          SizedBox(
                            height: 24,
                            width: 40,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Switch(
                                value: item.isAvailable,
                                activeThumbColor: AppColors.primaryCoral,
                                onChanged: canManageMenu
                                    ? (val) {
                                        if (val) {
                                          onRestore(item.id);
                                        } else {
                                          onArchive(item.id);
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          ),
                          // Price
                          Text(
                            'IQD ${MoneyFormatter.formatCents(item.priceCents).replaceAll(' د.ع', '')}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryCoralDark,
                            ),
                          ),
                        ],
                      ),
                      if (canManageMenu) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 28,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primaryCoral,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () => onEdit(item),
                                  child: const Text(
                                    'تعديل',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: SizedBox(
                                height: 28,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textDark,
                                    side: const BorderSide(
                                      color: AppColors.softBorder,
                                    ),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () => showArchived
                                      ? onRestore(item.id)
                                      : onArchive(item.id),
                                  child: Text(
                                    showArchived ? 'إرجاع' : 'إخفاء',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            // Premium Card-level loading overlay during item mutation
            if (isProcessing)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.7),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryCoral,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemImagePlaceholder extends StatelessWidget {
  const _ItemImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      color: AppColors.neutralCanvas,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.mutedText,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            'لا توجد صورة للمنتج',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.mutedText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.categories,
    required this.activeTabId,
    required this.onTabSelected,
  });

  final List<MenuCategory> categories;
  final String? activeTabId;
  final ValueChanged<String> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            for (final category in categories) ...[
              GestureDetector(
                onTap: () => onTabSelected(category.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: category.id == activeTabId
                        ? const Color(0xFFB23B1E) // Selected brand coral/red
                        : const Color(0xFFF1F5F9), // Soft neutral unselected
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: category.id == activeTabId
                          ? const Color(0xFFB23B1E)
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    boxShadow: category.id == activeTabId
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFB23B1E,
                              ).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (category.id == activeTabId) ...[
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        category.name,
                        style: TextStyle(
                          color: category.id == activeTabId
                              ? Colors.white
                              : const Color(0xFF334155),
                          fontWeight: category.id == activeTabId
                              ? FontWeight.w900
                              : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

List<T> _reordered<T>(List<T> items, int oldIndex, int newIndex) {
  final next = [...items];
  final moved = next.removeAt(oldIndex);
  next.insert(newIndex, moved);
  return next;
}

const _iqdPriceValidationMessage =
    'اكتب سعراً صحيحاً بالدينار العراقي بدون كسور وبقيمة أكبر من صفر.';

int? _parseIqdAmount(String value) {
  if (value.contains('.') || value.contains('٫')) {
    return null;
  }

  final normalized = _normalizeIqdDigits(value)
      .replaceAll(',', '')
      .replaceAll('،', '')
      .replaceAll('٬', '')
      .replaceAll(' ', '')
      .replaceAll(' ', '')
      .replaceAll(' ', '')
      .trim();
  if (normalized.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(normalized)) {
    return null;
  }

  final amount = int.tryParse(normalized);
  if (amount == null || amount <= 0) {
    return null;
  }

  return amount;
}

String _normalizeIqdDigits(String value) {
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.writeCharCode(0x30 + rune - 0x0660);
    } else if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.writeCharCode(0x30 + rune - 0x06F0);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}
