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
    required super.sortOrder,
    super.imageUrl,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String? ?? '',
      businessId:
          json['business_id'] as String? ?? json['businessId'] as String? ?? '',
      categoryId:
          json['category_id'] as String? ?? json['categoryId'] as String? ?? '',
      name:
          json['nameAr'] as String? ??
          json['name_ar'] as String? ??
          json['name'] as String? ??
          '',
      description:
          json['descriptionAr'] as String? ??
          json['description_ar'] as String? ??
          json['description'] as String? ??
          '',
      priceCents:
          _priceToInt(json['price']) ??
          (json['price_cents'] as num?)?.toInt() ??
          (json['priceCents'] as num?)?.toInt() ??
          0,
      isAvailable:
          json['is_available'] as bool? ?? json['isAvailable'] as bool? ?? true,
      sortOrder:
          (json['sort_order'] as num?)?.toInt() ??
          (json['sortOrder'] as num?)?.toInt() ??
          0,
      imageUrl: _optionalString(json['imageUrl'] ?? json['image_url']),
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
      sortOrder: sortOrder,
      imageUrl: imageUrl,
    );
  }
}

String? _optionalString(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return value.trim();
}

int? _priceToInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
