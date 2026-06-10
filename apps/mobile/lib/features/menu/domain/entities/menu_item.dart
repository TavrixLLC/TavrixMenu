import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  const MenuItem({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.isAvailable,
  });

  final String id;
  final String businessId;
  final String categoryId;
  final String name;
  final String description;
  final String price;
  final bool isAvailable;

  @override
  List<Object?> get props => [
    id,
    businessId,
    categoryId,
    name,
    description,
    price,
    isAvailable,
  ];
}
