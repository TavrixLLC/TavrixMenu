import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  const MenuItem({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.isAvailable,
    required this.sortOrder,
  });

  final String id;
  final String businessId;
  final String categoryId;
  final String name;
  final String description;
  final int priceCents;
  final bool isAvailable;
  final int sortOrder;

  MenuItem copyWith({
    String? id,
    String? businessId,
    String? categoryId,
    String? name,
    String? description,
    int? priceCents,
    bool? isAvailable,
    int? sortOrder,
  }) {
    return MenuItem(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      priceCents: priceCents ?? this.priceCents,
      isAvailable: isAvailable ?? this.isAvailable,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
    id,
    businessId,
    categoryId,
    name,
    description,
    priceCents,
    isAvailable,
    sortOrder,
  ];
}
