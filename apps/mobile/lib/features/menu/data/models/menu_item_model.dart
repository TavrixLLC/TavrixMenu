import '../../domain/entities/menu_item.dart';

class MenuItemModel extends MenuItem {
  const MenuItemModel({
    required super.id,
    required super.businessId,
    required super.categoryId,
    required super.nameAr,
    required super.price,
    required super.isAvailable,
    super.nameEn,
    super.descriptionAr,
    super.descriptionEn,
    super.imageUrl,
    super.sortOrder,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String? ?? '',
      businessId:
          json['business_id'] as String? ?? json['businessId'] as String? ?? '',
      categoryId:
          json['category_id'] as String? ?? json['categoryId'] as String? ?? '',
      nameAr:
          json['nameAr'] as String? ??
          json['name_ar'] as String? ??
          json['name'] as String? ??
          '',
      nameEn: json['nameEn'] as String? ?? json['name_en'] as String?,
      descriptionAr:
          json['descriptionAr'] as String? ??
          json['description_ar'] as String? ??
          json['description'] as String?,
      descriptionEn:
          json['descriptionEn'] as String? ?? json['description_en'] as String?,
      price:
          json['price']?.toString() ??
          json['price_cents']?.toString() ??
          json['priceCents']?.toString() ??
          '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      isAvailable:
          json['isAvailable'] as bool? ?? json['is_available'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? json['sort_order'] as int? ?? 0,
    );
  }

  MenuItem toEntity() {
    return MenuItem(
      id: id,
      businessId: businessId,
      categoryId: categoryId,
      nameAr: nameAr,
      nameEn: nameEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      price: price,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      sortOrder: sortOrder,
    );
  }
}
