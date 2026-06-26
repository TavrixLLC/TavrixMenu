import '../../../business_setup/data/models/business_model.dart';
import '../../../business_setup/domain/entities/business.dart';
import '../../../../core/utils/business_role.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.business,
    required super.currentUser,
    required super.counts,
    required super.publicMenu,
    required super.onboardingHints,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final businessJson =
        _asObject(json['business']) ?? const <String, dynamic>{};
    final currentUserJson =
        _asObject(json['currentUser']) ??
        _asObject(json['current_user']) ??
        const <String, dynamic>{};
    final permissionsJson = _asObject(currentUserJson['permissions']);
    final publicMenu = _publicMenuFromJson(
      _asObject(json['publicMenu']) ?? _asObject(json['public_menu']),
      slug: _string(businessJson['slug']) ?? '',
    );

    return DashboardSummaryModel(
      business: BusinessModel.fromAppContext({
        'business': businessJson,
        ...permissionsJson == null
            ? const <String, dynamic>{}
            : {'permissions': permissionsJson},
        'publicMenu': {
          'path': publicMenu.path,
          'url': publicMenu.url,
          'qrPayload': publicMenu.qrPayload,
        },
      }).toEntity(),
      currentUser: DashboardCurrentUser(
        role: BusinessRole.normalize(_string(currentUserJson['role'])),
        permissions: _permissionsFromJson(permissionsJson),
        permissionsAvailable: permissionsJson != null,
      ),
      counts: _countsFromJson(_asObject(json['counts'])),
      publicMenu: publicMenu,
      onboardingHints: _hintsFromJson(
        _asObject(json['onboardingHints']) ??
            _asObject(json['onboarding_hints']),
      ),
    );
  }

  DashboardSummary toEntity() {
    return DashboardSummary(
      business: business,
      currentUser: currentUser,
      counts: counts,
      publicMenu: publicMenu,
      onboardingHints: onboardingHints,
    );
  }
}

DashboardCounts _countsFromJson(Map<String, dynamic>? json) {
  return DashboardCounts(
    activeCategories:
        _int(json?['activeCategories']) ??
        _int(json?['active_categories']) ??
        0,
    inactiveCategories:
        _int(json?['inactiveCategories']) ??
        _int(json?['inactive_categories']) ??
        0,
    activeItems: _int(json?['activeItems']) ?? _int(json?['active_items']) ?? 0,
    inactiveItems:
        _int(json?['inactiveItems']) ?? _int(json?['inactive_items']) ?? 0,
    availableItems:
        _int(json?['availableItems']) ?? _int(json?['available_items']) ?? 0,
    unavailableItems:
        _int(json?['unavailableItems']) ??
        _int(json?['unavailable_items']) ??
        0,
    activeMembers:
        _int(json?['activeMembers']) ?? _int(json?['active_members']) ?? 0,
  );
}

DashboardPublicMenu _publicMenuFromJson(
  Map<String, dynamic>? json, {
  required String slug,
}) {
  final path =
      _string(json?['path']) ??
      _string(json?['publicMenuPath']) ??
      _string(json?['public_menu_path']) ??
      (slug.isEmpty ? '' : '/m/$slug');
  final url =
      _string(json?['url']) ??
      _string(json?['publicMenuUrl']) ??
      _string(json?['public_menu_url']) ??
      (slug.isEmpty ? '' : 'https://menu.tavrix.com/m/$slug');
  final qrPayload =
      _string(json?['qrPayload']) ?? _string(json?['qr_payload']) ?? url;

  return DashboardPublicMenu(path: path, url: url, qrPayload: qrPayload);
}

DashboardOnboardingHints _hintsFromJson(Map<String, dynamic>? json) {
  return DashboardOnboardingHints(
    hasCategories:
        _bool(json?['hasCategories']) ??
        _bool(json?['has_categories']) ??
        false,
    hasItems: _bool(json?['hasItems']) ?? _bool(json?['has_items']) ?? false,
    hasPublicMenuReady:
        _bool(json?['hasPublicMenuReady']) ??
        _bool(json?['has_public_menu_ready']) ??
        false,
    recommendedNextStep:
        _string(json?['recommendedNextStep']) ??
        _string(json?['recommended_next_step']),
  );
}

BusinessPermissions _permissionsFromJson(Map<String, dynamic>? json) {
  return BusinessPermissions(
    canManageBusiness:
        _bool(json?['canManageBusiness']) ??
        _bool(json?['can_manage_business']) ??
        false,
    canManageMenu:
        _bool(json?['canManageMenu']) ??
        _bool(json?['can_manage_menu']) ??
        false,
    canManageMembers:
        _bool(json?['canManageMembers']) ??
        _bool(json?['can_manage_members']) ??
        false,
    canViewMembers:
        _bool(json?['canViewMembers']) ??
        _bool(json?['can_view_members']) ??
        false,
    canViewPublicLink:
        _bool(json?['canViewPublicLink']) ??
        _bool(json?['can_view_public_link']) ??
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

int? _int(Object? value) {
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
