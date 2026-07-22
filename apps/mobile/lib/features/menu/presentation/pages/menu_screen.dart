import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/localization/localized_runtime_message.dart';
import '../../../../core/theme/v3/waflo_v3_tokens.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/v3/waflo_empty_state.dart';
import '../../../../shared/widgets/v3/waflo_inline_error.dart';
import '../../../../shared/widgets/v3/waflo_secondary_button.dart';
import '../../../../shared/widgets/v3/waflo_skeleton.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/entities/menu_item.dart';
import '../bloc/menu_cubit.dart';
import '../bloc/menu_state.dart';
import 'product_editor_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, this.embeddedInWorkspaceShell = false});

  final bool embeddedInWorkspaceShell;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<MenuCubit>();
      if (cubit.state.status == MenuStatus.initial) {
        unawaited(cubit.load());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: AppScaffold(
        key: const ValueKey('menu-management-v3'),
        title: context.l10n.menuManagementTitle,
        embeddedInWorkspaceShell: widget.embeddedInWorkspaceShell,
        scrollable: true,
        padding: const EdgeInsets.all(WafloV3Spacing.standardPageMargin),
        child: BlocBuilder<MenuCubit, MenuState>(
          builder: (context, state) {
            return switch (state.status) {
              MenuStatus.initial ||
              MenuStatus.loading => const _MenuLoadingState(),
              MenuStatus.failure => _MenuLoadError(
                message: localizedRuntimeMessage(
                  context.l10n,
                  state.errorMessage,
                  fallback: context.l10n.menuLoadFailed,
                ),
                onRetry: () => context.read<MenuCubit>().load(),
              ),
              MenuStatus.mutating || MenuStatus.success => _MenuContent(
                state: state,
                searchController: _searchController,
                onAddCategory: _openAddCategoryDialog,
                onAddProduct: _openProductEditor,
                onPreview: state.canPreviewPublicMenu
                    ? () => Navigator.of(context).pushNamed(AppRouteNames.qr)
                    : null,
              ),
            };
          },
        ),
      ),
    );
  }

  Future<void> _openAddCategoryDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<MenuCubit>(),
        child: const _AddCategoryDialog(),
      ),
    );
  }

  Future<void> _openProductEditor() async {
    final cubit = context.read<MenuCubit>();
    final category = cubit.state.selectedCategory;
    if (category == null || !cubit.state.canManageMenu) return;

    final result = await Navigator.of(context).push<ProductEditorResult>(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/menu/products/create'),
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ProductEditorScreen(initialCategoryId: category.id),
        ),
      ),
    );
    if (!mounted || result == null) return;
    await cubit.load(preferredCategoryId: result.categoryId);
  }
}

class _MenuContent extends StatelessWidget {
  const _MenuContent({
    required this.state,
    required this.searchController,
    required this.onAddCategory,
    required this.onAddProduct,
    required this.onPreview,
  });

  final MenuState state;
  final TextEditingController searchController;
  final VoidCallback onAddCategory;
  final VoidCallback onAddProduct;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final categories = state.visibleCategories;
    final selectedItems = state.selectedCategoryItems;
    final filteredItems = state.filteredSelectedCategoryItems;

    return Column(
      key: const ValueKey('menu-v3-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.menuManagementTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: WafloV3Spacing.space8),
        Text(
          context.l10n.menuManagementBody,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: WafloV3Colors.primaryText.withValues(alpha: 0.68),
          ),
        ),
        const SizedBox(height: WafloV3Spacing.space16),
        _ReadinessCard(state: state),
        if (state.summaryErrorMessage != null) ...[
          const SizedBox(height: WafloV3Spacing.space12),
          Text(
            localizedRuntimeMessage(context.l10n, state.summaryErrorMessage),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: WafloV3Colors.primaryText.withValues(alpha: 0.68),
            ),
          ),
        ],
        if (state.errorMessage != null) ...[
          const SizedBox(height: WafloV3Spacing.space12),
          WafloInlineError(
            message: localizedRuntimeMessage(context.l10n, state.errorMessage),
          ),
        ],
        const SizedBox(height: WafloV3Spacing.space16),
        if (categories.isEmpty)
          _NoCategoriesState(
            canManage: state.canManageMenu,
            onAddCategory: onAddCategory,
          )
        else ...[
          _CategorySection(
            categories: categories,
            selectedCategoryId: state.selectedCategoryId,
            canManage: state.canManageMenu,
            isAdding: state.isCategoryMutationPending,
            onAddCategory: onAddCategory,
          ),
          const SizedBox(height: WafloV3Spacing.space16),
          TextField(
            key: const ValueKey('menu-product-search'),
            controller: searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: context.l10n.searchProducts,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: state.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: context.l10n.clearSearch,
                      onPressed: () {
                        searchController.clear();
                        context.read<MenuCubit>().setSearchQuery('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: WafloV3Colors.surface,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(WafloV3Radius.inputControl),
                ),
              ),
            ),
            onChanged: context.read<MenuCubit>().setSearchQuery,
          ),
          const SizedBox(height: WafloV3Spacing.space16),
          if (selectedItems.isEmpty)
            _NoProductsState(
              canManage: state.canManageMenu,
              onAddProduct: onAddProduct,
            )
          else if (filteredItems.isEmpty)
            _SearchEmptyState(
              onClear: () {
                searchController.clear();
                context.read<MenuCubit>().setSearchQuery('');
              },
            )
          else
            _ProductList(
              items: filteredItems,
              state: state,
              onAddProduct: onAddProduct,
            ),
          const SizedBox(height: WafloV3Spacing.space16),
          _PreviewCard(enabled: onPreview != null, onPressed: onPreview),
        ],
        const SizedBox(
          key: ValueKey('menu-bottom-navigation-clearance'),
          height: WafloV3Spacing.space32,
        ),
      ],
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.state});

  final MenuState state;

  @override
  Widget build(BuildContext context) {
    final categories = state.visibleCategories.length;
    final products = state.items.length;
    return _Surface(
      key: const ValueKey('menu-readiness-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: context.l10n.categories,
                  value: '$categories',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: context.l10n.products,
                  value: '$products',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: context.l10n.menuStatus,
                  value: state.canPreviewPublicMenu
                      ? context.l10n.genericReady
                      : context.l10n.genericNotReady,
                  emphasized: !state.canPreviewPublicMenu,
                ),
              ),
            ],
          ),
          const SizedBox(height: WafloV3Spacing.space16),
          Text(
            categories == 0
                ? context.l10n.menuAddCategoryHint
                : products == 0
                ? context.l10n.menuAddProductHint
                : context.l10n.menuLoadedHint,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, textAlign: TextAlign.center),
        const SizedBox(height: WafloV3Spacing.space4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: emphasized ? WafloV3Colors.error : WafloV3Colors.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _NoCategoriesState extends StatelessWidget {
  const _NoCategoriesState({
    required this.canManage,
    required this.onAddCategory,
  });

  final bool canManage;
  final VoidCallback onAddCategory;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      key: const ValueKey('menu-no-categories-state'),
      child: Column(
        children: [
          WafloEmptyState(
            icon: Icons.grid_view_rounded,
            title: context.l10n.noCategoriesTitle,
            description: context.l10n.noCategoriesBody,
            primaryActionLabel: context.l10n.addCategory,
            onPrimaryAction: canManage ? onAddCategory : null,
          ),
          if (!canManage)
            Padding(
              padding: const EdgeInsets.only(bottom: WafloV3Spacing.space16),
              child: Text(context.l10n.addCategoryPermissionDenied),
            ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.categories,
    required this.selectedCategoryId,
    required this.canManage,
    required this.isAdding,
    required this.onAddCategory,
  });

  final List<MenuCategory> categories;
  final String? selectedCategoryId;
  final bool canManage;
  final bool isAdding;
  final VoidCallback onAddCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.categories,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton.icon(
              key: const ValueKey('menu-add-category-action'),
              onPressed: canManage && !isAdding ? onAddCategory : null,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.addCategory),
            ),
          ],
        ),
        const SizedBox(height: WafloV3Spacing.space8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final category in categories) ...[
                ChoiceChip(
                  key: ValueKey('menu-category-${category.id}'),
                  label: Text(category.name),
                  selected: category.id == selectedCategoryId,
                  onSelected: (_) =>
                      context.read<MenuCubit>().selectCategory(category.id),
                ),
                const SizedBox(width: WafloV3Spacing.space8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NoProductsState extends StatelessWidget {
  const _NoProductsState({required this.canManage, required this.onAddProduct});

  final bool canManage;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      key: const ValueKey('menu-no-products-state'),
      child: Column(
        children: [
          WafloEmptyState(
            icon: Icons.restaurant_menu_rounded,
            title: context.l10n.noProductsTitle,
            description: context.l10n.noProductsBody,
            primaryActionLabel: context.l10n.addFirstProduct,
            onPrimaryAction: canManage ? onAddProduct : null,
          ),
          if (!canManage)
            Padding(
              padding: const EdgeInsets.only(bottom: WafloV3Spacing.space16),
              child: Text(context.l10n.addProductPermissionDenied),
            ),
        ],
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      key: const ValueKey('menu-search-empty-state'),
      child: WafloEmptyState(
        icon: Icons.search_off_rounded,
        title: context.l10n.noSearchResultsTitle,
        description: context.l10n.noSearchResultsBody,
        secondaryActionLabel: context.l10n.clearSearch,
        onSecondaryAction: onClear,
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.items,
    required this.state,
    required this.onAddProduct,
  });

  final List<MenuItem> items;
  final MenuState state;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    final available = state.selectedCategoryItems
        .where((item) => item.isAvailable)
        .length;
    return Column(
      key: const ValueKey('menu-populated-state'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.productsInCategory(
                  state.selectedCategoryItems.length,
                  available,
                ),
              ),
            ),
            TextButton.icon(
              key: const ValueKey('menu-add-product-action'),
              onPressed: state.canManageMenu ? onAddProduct : null,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: Text(context.l10n.addProduct),
            ),
          ],
        ),
        const SizedBox(height: WafloV3Spacing.space12),
        for (final item in items) ...[
          _ProductCard(item: item, state: state),
          const SizedBox(height: WafloV3Spacing.space12),
        ],
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.item, required this.state});

  final MenuItem item;
  final MenuState state;

  @override
  Widget build(BuildContext context) {
    final pending = state.pendingAvailabilityItemIds.contains(item.id);
    return _Surface(
      key: ValueKey('menu-product-${item.id}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final mediaHeight = (constraints.maxWidth / 3.2).clamp(
                96.0,
                112.0,
              );
              return SizedBox(
                key: ValueKey('menu-product-media-${item.id}'),
                height: mediaHeight,
                child: _ProductMedia(imageUrl: item.imageUrl),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(WafloV3Spacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (item.description.trim().isNotEmpty) ...[
                  const SizedBox(height: WafloV3Spacing.space8),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: WafloV3Spacing.space12),
                Text(
                  MoneyFormatter.formatMajorUnits(
                    item.priceCents,
                    currency: state.business?.currency ?? 'IQD',
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: WafloV3Colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: WafloV3Spacing.space12),
                _AvailabilityControl(
                  item: item,
                  pending: pending,
                  enabled: state.canManageMenu && !pending,
                  onChanged: (value) => context
                      .read<MenuCubit>()
                      .setItemAvailability(item, value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductMedia extends StatelessWidget {
  const _ProductMedia({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final uri = imageUrl == null ? null : Uri.tryParse(imageUrl!);
    final valid =
        uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
    if (!valid) return const _ProductMediaPlaceholder();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(WafloV3Radius.standardCard),
      ),
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ProductMediaPlaceholder(),
      ),
    );
  }
}

class _ProductMediaPlaceholder extends StatelessWidget {
  const _ProductMediaPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: WafloV3Colors.primary.withValues(alpha: 0.07),
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: WafloV3Spacing.space48,
          color: WafloV3Colors.primary,
        ),
      ),
    );
  }
}

class _AvailabilityControl extends StatelessWidget {
  const _AvailabilityControl({
    required this.item,
    required this.pending,
    required this.enabled,
    required this.onChanged,
  });

  final MenuItem item;
  final bool pending;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = item.isAvailable
        ? const Color(0xFF1B6E3C)
        : WafloV3Colors.error;
    return Container(
      key: ValueKey('menu-availability-control-${item.id}'),
      constraints: const BoxConstraints(
        minHeight: WafloV3Spacing.minimumTouchTarget,
      ),
      padding: const EdgeInsetsDirectional.only(start: WafloV3Spacing.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(
          Radius.circular(WafloV3Radius.inputControl),
        ),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(
            item.isAvailable
                ? Icons.check_circle_outline_rounded
                : Icons.visibility_off_outlined,
            size: WafloV3Spacing.space20,
            color: color,
          ),
          const SizedBox(width: WafloV3Spacing.space8),
          Expanded(
            child: Text(
              pending
                  ? context.l10n.availabilityUpdating
                  : item.isAvailable
                  ? context.l10n.productAvailable
                  : context.l10n.productUnavailable,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
          Switch(
            key: ValueKey('menu-availability-${item.id}'),
            value: item.isAvailable,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      key: const ValueKey('menu-preview-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.previewCustomerMenu,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: WafloV3Spacing.space4),
          Text(
            enabled
                ? context.l10n.previewMenuReadyBody
                : context.l10n.previewMenuUnavailableBody,
          ),
          const SizedBox(height: WafloV3Spacing.space12),
          WafloSecondaryButton(
            label: context.l10n.previewCustomerMenu,
            onPressed: enabled ? onPressed : null,
          ),
        ],
      ),
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: AlertDialog(
        key: const ValueKey('add-category-dialog'),
        scrollable: true,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: WafloV3Spacing.space16,
          vertical: WafloV3Spacing.space24,
        ),
        title: Text(context.l10n.addCategory),
        contentPadding: const EdgeInsetsDirectional.fromSTEB(
          WafloV3Spacing.space24,
          WafloV3Spacing.space8,
          WafloV3Spacing.space24,
          0,
        ),
        content: TextField(
          key: const ValueKey('add-category-name-field'),
          controller: _controller,
          autofocus: true,
          maxLength: 160,
          decoration: InputDecoration(
            labelText: context.l10n.categoryName,
            hintText: context.l10n.categoryNameHint,
            errorText: _error,
          ),
          onSubmitted: (_) => _submit(),
        ),
        actionsPadding: const EdgeInsetsDirectional.fromSTEB(
          WafloV3Spacing.space16,
          WafloV3Spacing.space8,
          WafloV3Spacing.space16,
          WafloV3Spacing.space16,
        ),
        actions: [
          TextButton(
            key: const ValueKey('add-category-cancel'),
            style: TextButton.styleFrom(
              minimumSize: const Size(96, WafloV3Spacing.minimumTouchTarget),
            ),
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            child: Text(context.l10n.genericCancel),
          ),
          FilledButton(
            key: const ValueKey('add-category-submit'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(96, WafloV3Spacing.minimumTouchTarget),
            ),
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.l10n.addCategory),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l10n.categoryRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final created = await context.read<MenuCubit>().addCategory(name);
    if (!mounted) return;
    if (created == null) {
      setState(() {
        _submitting = false;
        _error = context.l10n.categoryCreateFailed;
      });
      return;
    }
    Navigator.of(context).pop();
  }
}

class _MenuLoadingState extends StatelessWidget {
  const _MenuLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey('menu-loading-state'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WafloSkeleton(width: 180, height: 34),
        SizedBox(height: WafloV3Spacing.space12),
        WafloSkeleton(height: 120),
        SizedBox(height: WafloV3Spacing.space16),
        WafloSkeleton(height: 56),
        SizedBox(height: WafloV3Spacing.space16),
        WafloSkeleton(height: 220),
      ],
    );
  }
}

class _MenuLoadError extends StatelessWidget {
  const _MenuLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WafloInlineError(
      key: const ValueKey('menu-load-error'),
      title: context.l10n.menuLoadFailed,
      message: message,
      onRetry: onRetry,
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child, super.key, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: WafloV3Colors.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(WafloV3Radius.standardCard),
        ),
        border: Border.all(
          color: WafloV3Colors.primaryText.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: WafloV3Colors.primaryText.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding:
            padding ?? const EdgeInsets.all(WafloV3Spacing.commonCardPadding),
        child: child,
      ),
    );
  }
}
