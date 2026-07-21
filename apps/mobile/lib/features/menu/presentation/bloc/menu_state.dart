import 'package:equatable/equatable.dart';

import '../../../business_setup/domain/entities/business.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/entities/menu_item.dart';

enum MenuStatus { initial, loading, mutating, success, failure }

class MenuState extends Equatable {
  const MenuState({
    required this.status,
    this.business,
    this.categories = const [],
    this.items = const [],
    this.permissions,
    this.selectedCategoryId,
    this.searchQuery = '',
    this.publicMenuReady = false,
    this.showArchived = false,
    this.isCategoryMutationPending = false,
    this.isProductMutationPending = false,
    this.pendingAvailabilityItemIds = const {},
    this.errorMessage,
    this.summaryErrorMessage,
  });

  const MenuState.initial() : this(status: MenuStatus.initial);

  final MenuStatus status;
  final Business? business;
  final List<MenuCategory> categories;
  final List<MenuItem> items;
  final BusinessPermissions? permissions;
  final String? selectedCategoryId;
  final String searchQuery;
  final bool publicMenuReady;
  final bool showArchived;
  final bool isCategoryMutationPending;
  final bool isProductMutationPending;
  final Set<String> pendingAvailabilityItemIds;
  final String? errorMessage;
  final String? summaryErrorMessage;

  bool get canManageMenu => permissions?.canManageMenu ?? false;

  List<MenuCategory> get visibleCategories {
    final filtered = categories.where((category) => category.isActive).toList();
    filtered.sort(_compareCategories);
    return filtered;
  }

  MenuCategory? get selectedCategory {
    final selectedId = selectedCategoryId;
    if (selectedId == null) {
      return null;
    }
    return visibleCategories
        .where((category) => category.id == selectedId)
        .firstOrNull;
  }

  List<MenuItem> get selectedCategoryItems {
    final category = selectedCategory;
    final businessId = business?.id;
    if (category == null || businessId == null) {
      return const [];
    }
    final filtered = items
        .where(
          (item) =>
              item.businessId == businessId && item.categoryId == category.id,
        )
        .toList();
    filtered.sort(_compareItems);
    return filtered;
  }

  List<MenuItem> get filteredSelectedCategoryItems {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return selectedCategoryItems;
    }
    return selectedCategoryItems.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
    }).toList();
  }

  List<MenuItem> get visibleItems => selectedCategoryItems;

  bool get canPreviewPublicMenu {
    final business = this.business;
    return publicMenuReady &&
        business != null &&
        business.publicMenuUrl.trim().isNotEmpty;
  }

  MenuState copyWith({
    MenuStatus? status,
    Business? business,
    List<MenuCategory>? categories,
    List<MenuItem>? items,
    BusinessPermissions? permissions,
    String? selectedCategoryId,
    String? searchQuery,
    bool? publicMenuReady,
    bool? showArchived,
    bool? isCategoryMutationPending,
    bool? isProductMutationPending,
    Set<String>? pendingAvailabilityItemIds,
    String? errorMessage,
    String? summaryErrorMessage,
    bool clearSelectedCategory = false,
    bool clearError = false,
    bool clearSummaryError = false,
  }) {
    return MenuState(
      status: status ?? this.status,
      business: business ?? this.business,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      permissions: permissions ?? this.permissions,
      selectedCategoryId: clearSelectedCategory
          ? null
          : selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      publicMenuReady: publicMenuReady ?? this.publicMenuReady,
      showArchived: showArchived ?? this.showArchived,
      isCategoryMutationPending:
          isCategoryMutationPending ?? this.isCategoryMutationPending,
      isProductMutationPending:
          isProductMutationPending ?? this.isProductMutationPending,
      pendingAvailabilityItemIds:
          pendingAvailabilityItemIds ?? this.pendingAvailabilityItemIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      summaryErrorMessage: clearSummaryError
          ? null
          : summaryErrorMessage ?? this.summaryErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    business,
    categories,
    items,
    permissions,
    selectedCategoryId,
    searchQuery,
    publicMenuReady,
    showArchived,
    isCategoryMutationPending,
    isProductMutationPending,
    pendingAvailabilityItemIds,
    errorMessage,
    summaryErrorMessage,
  ];
}

int _compareCategories(MenuCategory left, MenuCategory right) {
  final order = left.sortOrder.compareTo(right.sortOrder);
  return order != 0 ? order : left.id.compareTo(right.id);
}

int _compareItems(MenuItem left, MenuItem right) {
  final order = left.sortOrder.compareTo(right.sortOrder);
  return order != 0 ? order : left.id.compareTo(right.id);
}
