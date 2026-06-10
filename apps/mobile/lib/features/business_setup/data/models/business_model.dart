import '../../domain/entities/business.dart';

class BusinessModel extends Business {
  const BusinessModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.publicMenuUrl,
    super.type,
    super.city,
    super.currency,
    super.language,
    super.role,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    final slug = _stringValue(json['slug']) ?? '';

    return BusinessModel(
      id: _stringValue(json['id']) ?? '',
      name: _stringValue(json['name']) ?? '',
      slug: slug,
      publicMenuUrl:
          _stringValue(json['public_menu_url']) ??
          _stringValue(json['publicMenuUrl']) ??
          (slug.isEmpty ? '' : 'https://menu.tavrix.com/$slug'),
      type: _stringValue(json['type']) ?? 'cafe',
      city: _stringValue(json['city']),
      currency: _stringValue(json['currency']) ?? 'IQD',
      language: _stringValue(json['language']) ?? 'ar',
      role: _stringValue(json['role']),
    );
  }

  Business toEntity() {
    return Business(
      id: id,
      name: name,
      slug: slug,
      publicMenuUrl: publicMenuUrl,
      type: type,
      city: city,
      currency: currency,
      language: language,
      role: role,
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
