import '../../domain/entities/menu_item.dart';

class MenuItemModel extends MenuItem {
  const MenuItemModel({
    required super.id,
    required super.businessId,
    required super.categoryId,
    required super.name,
    required super.description,
    required super.priceCents,
    required super.isAvailable,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String? ?? '',
      businessId:
          json['business_id'] as String? ?? json['businessId'] as String? ?? '',
      categoryId:
          json['category_id'] as String? ?? json['categoryId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priceCents:
          json['price_cents'] as int? ?? json['priceCents'] as int? ?? 0,
      isAvailable:
          json['is_available'] as bool? ?? json['isAvailable'] as bool? ?? true,
    );
  }

  MenuItem toEntity() {
    return MenuItem(
      id: id,
      businessId: businessId,
      categoryId: categoryId,
      name: name,
      description: description,
      priceCents: priceCents,
      isAvailable: isAvailable,
    );
  }
}
