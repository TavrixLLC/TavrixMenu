import 'package:equatable/equatable.dart';

class MenuCategory extends Equatable {
  const MenuCategory({
    required this.id,
    required this.businessId,
    required this.nameAr,
    required this.sortOrder,
    this.nameEn,
    this.isActive = true,
  });

  final String id;
  final String businessId;
  final String nameAr;
  final String? nameEn;
  final int sortOrder;
  final bool isActive;

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn ?? '';

  @override
  List<Object?> get props => [
    id,
    businessId,
    nameAr,
    nameEn,
    sortOrder,
    isActive,
  ];
}
