import '../../../../core/utils/business_role.dart';
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
    super.role,
    super.permissions,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    final business = _asObject(json['business']) ?? json;
    final appContext =
        _asObject(json['appContext']) ?? _asObject(json['app_context']);
    if (appContext != null) {
      final currentMembership =
          _asObject(json['currentMembership']) ??
          _asObject(json['current_membership']);
      final mergedAppContext = Map<String, dynamic>.of(appContext);
      if (currentMembership != null) {
        mergedAppContext['currentMembership'] = currentMembership;
      }
      return BusinessModel.fromAppContext(mergedAppContext);
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
      role: _roleFrom(
        _string(_asObject(json['currentMembership'])?['role']) ??
            _string(_asObject(json['current_membership'])?['role']) ??
            _string(business['role']) ??
            _string(json['role']),
      ),
      permissions: _permissionsFromJson(_asObject(json['permissions'])),
    );
  }

  factory BusinessModel.fromAppContext(Map<String, dynamic> json) {
    final business = _asObject(json['business']) ?? const <String, dynamic>{};
    final publicMenu =
        _asObject(json['publicMenu']) ?? _asObject(json['public_menu']);
    final currentMembership =
        _asObject(json['currentMembership']) ??
        _asObject(json['current_membership']);
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
      role: _roleFrom(
        _string(currentMembership?['role']) ??
            _string(json['role']) ??
            _string(business['role']),
      ),
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
      role: role,
      permissions: permissions,
    );
  }
}

BusinessPermissions? _permissionsFromJson(Map<String, dynamic>? json) {
  if (json == null) {
    return null;
  }

  return BusinessPermissions(
    canManageAppearance:
        _bool(json['canManageAppearance']) ??
        _bool(json['can_manage_appearance']) ??
        _bool(json['canManageMenu']) ??
        _bool(json['can_manage_menu']) ??
        false,
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
    canScanCustomerWallet:
        _bool(json['canScanCustomerWallet']) ??
        _bool(json['can_scan_customer_wallet']) ??
        _bool(json['canScanWallet']) ??
        _bool(json['can_scan_wallet']) ??
        true,
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

String? _roleFrom(String? role) {
  final normalized = BusinessRole.normalize(role);
  return normalized == BusinessRole.operator ? null : normalized;
}
