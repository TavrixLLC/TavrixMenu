import '../../domain/entities/current_user.dart';
import '../../../../core/utils/business_role.dart';

class CurrentUserModel extends CurrentUser {
  const CurrentUserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.clerkUserId,
    super.phone,
    super.status,
    super.createdAt,
    super.updatedAt,
    super.memberships,
    super.onboarding,
    super.businesses,
  });

  factory CurrentUserModel.fromJson(Map<String, dynamic> json) {
    final user = _asObject(json['user']) ?? json;
    final memberships = _asObjectList(
      json['memberships'],
    ).map(_membershipFromJson).toList(growable: false);
    final businesses = _asObjectList(
      json['businesses'],
    ).map(_businessFromJson).toList(growable: false);
    final onboarding = _onboardingFromJson(
      _asObject(json['onboarding']),
      businesses: businesses,
      memberships: memberships,
    );
    final role =
        _string(json['role']) ??
        _string(user['role']) ??
        memberships
            .where((membership) => membership.isActive)
            .firstOrNull
            ?.role ??
        businesses.firstOrNull?.role ??
        BusinessRole.operator;

    return CurrentUserModel(
      id: _string(user['id']) ?? '',
      clerkUserId:
          _string(user['clerkUserId']) ?? _string(user['clerk_user_id']),
      email: _string(user['email']) ?? '',
      fullName:
          _string(user['name']) ??
          _string(user['full_name']) ??
          _string(user['fullName']) ??
          '',
      role: BusinessRole.normalize(role),
      phone: _string(user['phone']),
      status: _string(user['status']),
      createdAt: _dateString(user['createdAt'] ?? user['created_at']),
      updatedAt: _dateString(user['updatedAt'] ?? user['updated_at']),
      memberships: memberships,
      onboarding: onboarding,
      businesses: businesses,
    );
  }

  CurrentUser toEntity() {
    return CurrentUser(
      id: id,
      clerkUserId: clerkUserId,
      email: email,
      fullName: fullName,
      role: role,
      phone: phone,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      memberships: memberships,
      onboarding: onboarding,
      businesses: businesses,
    );
  }
}

CurrentUserOnboarding _onboardingFromJson(
  Map<String, dynamic>? json, {
  required List<CurrentUserBusiness> businesses,
  required List<CurrentUserMembership> memberships,
}) {
  final activeMembershipCount = memberships
      .where((membership) => membership.isActive)
      .length;

  return CurrentUserOnboarding(
    hasBusiness:
        _bool(json?['hasBusiness']) ??
        _bool(json?['has_business']) ??
        activeMembershipCount > 0 ||
            businesses.any((business) => business.id.trim().isNotEmpty),
    activeBusinessCount:
        _int(json?['activeBusinessCount']) ??
        _int(json?['active_business_count']) ??
        activeMembershipCount,
    recommendedNextStep:
        _string(json?['recommendedNextStep']) ??
        _string(json?['recommended_next_step']),
  );
}

CurrentUserMembership _membershipFromJson(Map<String, dynamic> json) {
  final business = _asObject(json['business']) ?? const <String, dynamic>{};

  return CurrentUserMembership(
    id: _string(json['id']) ?? '',
    role: BusinessRole.normalize(_string(json['role'])),
    isActive: _bool(json['isActive']) ?? _bool(json['is_active']) ?? false,
    business: CurrentUserMembershipBusiness(
      id: _string(business['id']) ?? '',
      name: _string(business['name']) ?? '',
      slug: _string(business['slug']) ?? '',
      type: _string(business['type']) ?? '',
      city: _string(business['city']),
      currency: _string(business['currency']),
      language: _string(business['language']),
      logoUrl: _string(business['logoUrl']) ?? _string(business['logo_url']),
      coverUrl: _string(business['coverUrl']) ?? _string(business['cover_url']),
    ),
  );
}

CurrentUserBusiness _businessFromJson(Map<String, dynamic> json) {
  return CurrentUserBusiness(
    id: _string(json['id']) ?? '',
    name: _string(json['name']) ?? '',
    slug: _string(json['slug']) ?? '',
    type: _string(json['type']) ?? '',
    role: BusinessRole.normalize(_string(json['role'])),
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

List<Map<String, dynamic>> _asObjectList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map(_asObject)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
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

String? _dateString(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value.toIso8601String();
  }
  return _string(value);
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
