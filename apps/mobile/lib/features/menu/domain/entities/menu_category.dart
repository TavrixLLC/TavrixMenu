import 'package:equatable/equatable.dart';

class MenuCategory extends Equatable {
  const MenuCategory({
    required this.id,
    required this.businessId,
    required this.name,
    required this.sortOrder,
    this.isActive = true,
  });

  final String id;
  final String businessId;
  final String name;
  final int sortOrder;
  final bool isActive;

  MenuCategory copyWith({
    String? id,
    String? businessId,
    String? name,
    int? sortOrder,
    bool? isActive,
  }) {
    return MenuCategory(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, businessId, name, sortOrder, isActive];
}
