import 'package:equatable/equatable.dart';

class CurrentUser extends Equatable {
  const CurrentUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.clerkUserId,
    this.phone,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.memberships = const [],
    this.onboarding = const CurrentUserOnboarding(),
    this.businesses = const [],
  });

  final String id;
  final String? clerkUserId;
  final String email;
  final String fullName;
  final String role;
  final String? phone;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final List<CurrentUserMembership> memberships;
  final CurrentUserOnboarding onboarding;
  final List<CurrentUserBusiness> businesses;

  bool get hasActiveMembershipBusiness {
    return memberships.any(
      (membership) =>
          membership.isActive && membership.business.id.trim().isNotEmpty,
    );
  }

  bool get hasAnyBusinessSummary {
    return businesses.any((business) => business.id.trim().isNotEmpty);
  }

  bool get hasBusiness {
    return onboarding.hasBusiness ||
        onboarding.activeBusinessCount > 0 ||
        hasActiveMembershipBusiness ||
        hasAnyBusinessSummary;
  }

  String? get primaryBusinessId {
    for (final membership in memberships) {
      if (membership.isActive && membership.business.id.trim().isNotEmpty) {
        return membership.business.id;
      }
    }

    for (final business in businesses) {
      if (business.id.trim().isNotEmpty) {
        return business.id;
      }
    }

    return null;
  }

  @override
  List<Object?> get props => [
    id,
    clerkUserId,
    email,
    fullName,
    role,
    phone,
    status,
    createdAt,
    updatedAt,
    memberships,
    onboarding,
    businesses,
  ];
}

class CurrentUserOnboarding extends Equatable {
  const CurrentUserOnboarding({
    this.hasBusiness = false,
    this.activeBusinessCount = 0,
    this.recommendedNextStep,
  });

  final bool hasBusiness;
  final int activeBusinessCount;
  final String? recommendedNextStep;

  @override
  List<Object?> get props => [
    hasBusiness,
    activeBusinessCount,
    recommendedNextStep,
  ];
}

class CurrentUserMembership extends Equatable {
  const CurrentUserMembership({
    required this.id,
    required this.role,
    required this.isActive,
    required this.business,
  });

  final String id;
  final String role;
  final bool isActive;
  final CurrentUserMembershipBusiness business;

  @override
  List<Object?> get props => [id, role, isActive, business];
}

class CurrentUserMembershipBusiness extends Equatable {
  const CurrentUserMembershipBusiness({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    this.city,
    this.currency,
    this.language,
    this.logoUrl,
    this.coverUrl,
  });

  final String id;
  final String name;
  final String slug;
  final String type;
  final String? city;
  final String? currency;
  final String? language;
  final String? logoUrl;
  final String? coverUrl;

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    type,
    city,
    currency,
    language,
    logoUrl,
    coverUrl,
  ];
}

class CurrentUserBusiness extends Equatable {
  const CurrentUserBusiness({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.role,
  });

  final String id;
  final String name;
  final String slug;
  final String type;
  final String role;

  @override
  List<Object?> get props => [id, name, slug, type, role];
}
