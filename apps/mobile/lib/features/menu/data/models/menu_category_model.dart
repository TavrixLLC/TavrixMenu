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
      id: _stringValue(json['id']) ?? '',
      businessId:
          _stringValue(json['business_id']) ??
          _stringValue(json['businessId']) ??
          '',
      name:
          _stringValue(json['nameAr']) ??
          _stringValue(json['name_ar']) ??
          _stringValue(json['name']) ??
          '',
      sortOrder:
          _intValue(json['sort_order']) ?? _intValue(json['sortOrder']) ?? 0,
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

  static String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  static int? _intValue(dynamic value) {
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
}
