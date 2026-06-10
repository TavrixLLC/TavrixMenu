import '../../domain/entities/menu_category.dart';

class MenuCategoryModel extends MenuCategory {
  const MenuCategoryModel({
    required super.id,
    required super.businessId,
    required super.nameAr,
    required super.sortOrder,
    super.nameEn,
    super.isActive,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] as String? ?? '',
      businessId:
          json['business_id'] as String? ?? json['businessId'] as String? ?? '',
      nameAr:
          json['nameAr'] as String? ??
          json['name_ar'] as String? ??
          json['name'] as String? ??
          '',
      nameEn: json['nameEn'] as String? ?? json['name_en'] as String?,
      sortOrder: json['sortOrder'] as int? ?? json['sort_order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
    );
  }

  MenuCategory toEntity() {
    return MenuCategory(
      id: id,
      businessId: businessId,
      nameAr: nameAr,
      nameEn: nameEn,
      sortOrder: sortOrder,
      isActive: isActive,
    );
  }
}
