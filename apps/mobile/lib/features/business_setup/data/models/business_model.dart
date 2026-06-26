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
    super.permissions,
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
          _fallbackPublicMenuUrl(slug),
      type: _string(business['type']) ?? 'cafe',
      city: _string(business['city']),
      currency: _string(business['currency']) ?? 'IQD',
      language: _string(business['language']) ?? 'ar',
      logoUrl: _string(business['logoUrl']) ?? _string(business['logo_url']),
      coverUrl: _string(business['coverUrl']) ?? _string(business['cover_url']),
      status: _string(business['status']),
      permissions: _permissionsFromJson(_asObject(json['permissions'])),
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
          _fallbackPublicMenuUrl(slug),
      type: _string(business['type']) ?? 'cafe',
      city: _string(business['city']),
      currency: _string(business['currency']) ?? 'IQD',
      language: _string(business['language']) ?? 'ar',
      logoUrl: _string(business['logoUrl']) ?? _string(business['logo_url']),
      coverUrl: _string(business['coverUrl']) ?? _string(business['cover_url']),
      status: _string(business['status']),
      permissions: _permissionsFromJson(_asObject(json['permissions'])),
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
      permissions: permissions,
    );
  }
}

BusinessPermissions? _permissionsFromJson(Map<String, dynamic>? json) {
  if (json == null) {
    return null;
  }

  return BusinessPermissions(
    canManageBusiness:
        _bool(json['canManageBusiness']) ??
        _bool(json['can_manage_business']) ??
        false,
    canManageMenu:
        _bool(json['canManageMenu']) ?? _bool(json['can_manage_menu']) ?? false,
    canManageMembers:
        _bool(json['canManageMembers']) ??
        _bool(json['can_manage_members']) ??
        false,
    canViewMembers:
        _bool(json['canViewMembers']) ??
        _bool(json['can_view_members']) ??
        false,
    canViewPublicLink:
        _bool(json['canViewPublicLink']) ??
        _bool(json['can_view_public_link']) ??
        false,
  );
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

bool? _bool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return bool.tryParse(value);
  }
  return null;
}

String _fallbackPublicMenuUrl(String slug) {
  return slug.trim().isEmpty ? '' : 'https://menu.tavrix.com/m/$slug';
}
