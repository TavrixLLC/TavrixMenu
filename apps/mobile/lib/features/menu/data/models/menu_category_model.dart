import '../../domain/entities/menu_category.dart';

class MenuCategoryModel extends MenuCategory {
  const MenuCategoryModel({
    required super.id,
    required super.businessId,
    required super.name,
    required super.sortOrder,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] as String? ?? '',
      businessId:
          json['business_id'] as String? ?? json['businessId'] as String? ?? '',
      name:
          json['nameAr'] as String? ??
          json['name_ar'] as String? ??
          json['name'] as String? ??
          '',
      sortOrder:
          (json['sort_order'] as num?)?.toInt() ??
          (json['sortOrder'] as num?)?.toInt() ??
          0,
    );
  }

  MenuCategory toEntity() {
    return MenuCategory(
      id: id,
      businessId: businessId,
      name: name,
      sortOrder: sortOrder,
    );
  }
}
