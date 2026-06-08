import '../../domain/entities/business.dart';

class BusinessModel extends Business {
  const BusinessModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.publicMenuUrl,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    final slug = json['slug'] as String? ?? '';

    return BusinessModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: slug,
      publicMenuUrl:
          json['public_menu_url'] as String? ??
          json['publicMenuUrl'] as String? ??
          'https://menu.tavrix.com/$slug',
    );
  }

  Business toEntity() {
    return Business(
      id: id,
      name: name,
      slug: slug,
      publicMenuUrl: publicMenuUrl,
    );
  }
}
