import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  const MenuItem({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.nameAr,
    required this.price,
    required this.isAvailable,
    this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.imageUrl,
    this.sortOrder = 0,
  });

  final String id;
  final String businessId;
  final String categoryId;
  final String nameAr;
  final String? nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String price;
  final String? imageUrl;
  final bool isAvailable;
  final int sortOrder;

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn ?? '';

  String get displayDescription => (descriptionAr?.isNotEmpty ?? false)
      ? descriptionAr!
      : descriptionEn ?? '';

  @override
  List<Object?> get props => [
    id,
    businessId,
    categoryId,
    nameAr,
    nameEn,
    descriptionAr,
    descriptionEn,
    price,
    imageUrl,
    isAvailable,
    sortOrder,
  ];
}
