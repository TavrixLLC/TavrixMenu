import 'package:equatable/equatable.dart';

class MenuCategory extends Equatable {
  const MenuCategory({
    required this.id,
    required this.businessId,
    required this.name,
    required this.sortOrder,
  });

  final String id;
  final String businessId;
  final String name;
  final int sortOrder;

  @override
  List<Object?> get props => [id, businessId, name, sortOrder];
}
