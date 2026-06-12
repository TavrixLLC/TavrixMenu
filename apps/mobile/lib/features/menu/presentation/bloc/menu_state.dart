import 'package:equatable/equatable.dart';

import '../../../business_setup/domain/entities/business.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/entities/menu_item.dart';

enum MenuStatus { initial, loading, success, failure }

class MenuState extends Equatable {
  const MenuState({
    required this.status,
    this.business,
    this.categories = const [],
    this.items = const [],
    this.permissions,
    this.showArchived = false,
    this.errorMessage,
    this.summaryErrorMessage,
  });

  const MenuState.initial() : this(status: MenuStatus.initial);

  final MenuStatus status;
  final Business? business;
  final List<MenuCategory> categories;
  final List<MenuItem> items;
  final BusinessPermissions? permissions;
  final bool showArchived;
  final String? errorMessage;
  final String? summaryErrorMessage;

  bool get canManageMenu => permissions?.canManageMenu ?? true;

  List<MenuCategory> get visibleCategories {
    final filtered = showArchived
        ? categories.where((category) => !category.isActive)
        : categories.where((category) => category.isActive);
    return filtered.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<MenuItem> get visibleItems {
    final filtered = showArchived
        ? items.where((item) => !item.isAvailable)
        : items.where((item) => item.isAvailable);
    return filtered.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  MenuState copyWith({
    MenuStatus? status,
    Business? business,
    List<MenuCategory>? categories,
    List<MenuItem>? items,
    BusinessPermissions? permissions,
    bool? showArchived,
    String? errorMessage,
    String? summaryErrorMessage,
    bool clearError = false,
    bool clearSummaryError = false,
  }) {
    return MenuState(
      status: status ?? this.status,
      business: business ?? this.business,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      permissions: permissions ?? this.permissions,
      showArchived: showArchived ?? this.showArchived,
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
    showArchived,
    errorMessage,
    summaryErrorMessage,
  ];
}
