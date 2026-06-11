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
    this.errorMessage,
  });

  const MenuState.initial() : this(status: MenuStatus.initial);

  final MenuStatus status;
  final Business? business;
  final List<MenuCategory> categories;
  final List<MenuItem> items;
  final String? errorMessage;

  MenuState copyWith({
    MenuStatus? status,
    Business? business,
    List<MenuCategory>? categories,
    List<MenuItem>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MenuState(
      status: status ?? this.status,
      business: business ?? this.business,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    business,
    categories,
    items,
    errorMessage,
  ];
}
