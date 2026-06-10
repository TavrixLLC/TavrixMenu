import '../../domain/entities/menu_item.dart';

class MenuItemModel extends MenuItem {
  const MenuItemModel({
    required super.id,
    required super.businessId,
    required super.categoryId,
    required super.name,
    required super.description,
    required super.price,
    required super.isAvailable,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: _stringValue(json['id']) ?? '',
      businessId:
          _stringValue(json['business_id']) ??
          _stringValue(json['businessId']) ??
          '',
      categoryId:
          _stringValue(json['category_id']) ??
          _stringValue(json['categoryId']) ??
          '',
      name:
          _stringValue(json['nameAr']) ??
          _stringValue(json['name_ar']) ??
          _stringValue(json['name']) ??
          '',
      description:
          _stringValue(json['descriptionAr']) ??
          _stringValue(json['description_ar']) ??
          _stringValue(json['description']) ??
          '',
      price:
          _stringValue(json['price']) ??
          _stringValue(json['price_cents']) ??
          _stringValue(json['priceCents']) ??
          '0',
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
      price: price,
      isAvailable: isAvailable,
    );
  }

  static String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }
}
