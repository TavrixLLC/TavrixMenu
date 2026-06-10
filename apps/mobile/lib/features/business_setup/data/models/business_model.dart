import '../../domain/entities/business.dart';

class BusinessModel extends Business {
  const BusinessModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.type,
    required super.role,
    required super.publicMenuUrl,
    super.city,
    super.currency,
    super.language,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    final slug = json['slug'] as String? ?? '';

    return BusinessModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: slug,
      type: json['type'] as String? ?? 'cafe',
      role: json['role'] as String? ?? '',
      publicMenuUrl:
          json['public_menu_url'] as String? ??
          json['publicMenuUrl'] as String? ??
          '',
      city: json['city'] as String?,
      currency: json['currency'] as String? ?? 'IQD',
      language: json['language'] as String? ?? 'ar',
    );
  }

  Business toEntity() {
    return Business(
      id: id,
      name: name,
      slug: slug,
      type: type,
      role: role,
      publicMenuUrl: publicMenuUrl,
      city: city,
      currency: currency,
      language: language,
    );
  }
}
