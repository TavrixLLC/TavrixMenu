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
    super.logoUrl,
    super.coverUrl,
    super.status,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    final business = _asObject(json['business']) ?? json;
    final appContext =
        _asObject(json['appContext']) ?? _asObject(json['app_context']);
    if (appContext != null) {
      return BusinessModel.fromAppContext(appContext);
    }

    final slug = _string(business['slug']) ?? '';

    return BusinessModel(
      id: _string(business['id']) ?? '',
      name: _string(business['name']) ?? '',
      slug: slug,
      publicMenuUrl:
          _string(business['publicMenuUrl']) ??
          _string(business['public_menu_url']) ??
          _string(business['publicMenuUrl']) ??
          'https://menu.tavrix.com/$slug',
      type: _string(business['type']) ?? 'cafe',
      city: _string(business['city']),
      currency: _string(business['currency']) ?? 'IQD',
      language: _string(business['language']) ?? 'ar',
      logoUrl: _string(business['logoUrl']) ?? _string(business['logo_url']),
      coverUrl: _string(business['coverUrl']) ?? _string(business['cover_url']),
      status: _string(business['status']),
    );
  }

  factory BusinessModel.fromAppContext(Map<String, dynamic> json) {
    final business = _asObject(json['business']) ?? const <String, dynamic>{};
    final publicMenu =
        _asObject(json['publicMenu']) ?? _asObject(json['public_menu']);
    final slug =
        _string(business['slug']) ?? _string(publicMenu?['slug']) ?? '';

    return BusinessModel(
      id: _string(business['id']) ?? '',
      name: _string(business['name']) ?? '',
      slug: slug,
      publicMenuUrl:
          _string(publicMenu?['url']) ??
          _string(publicMenu?['qrPayload']) ??
          _string(publicMenu?['qr_payload']) ??
          _string(business['publicMenuUrl']) ??
          _string(business['public_menu_url']) ??
          'https://menu.tavrix.com/$slug',
      type: _string(business['type']) ?? 'cafe',
      city: _string(business['city']),
      currency: _string(business['currency']) ?? 'IQD',
      language: _string(business['language']) ?? 'ar',
      logoUrl: _string(business['logoUrl']) ?? _string(business['logo_url']),
      coverUrl: _string(business['coverUrl']) ?? _string(business['cover_url']),
      status: _string(business['status']),
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
      logoUrl: logoUrl,
      coverUrl: coverUrl,
      status: status,
    );
  }
}

Map<String, dynamic>? _asObject(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

String? _string(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}
