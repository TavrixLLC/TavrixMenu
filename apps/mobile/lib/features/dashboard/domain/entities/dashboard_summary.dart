import 'package:equatable/equatable.dart';

import '../../../business_setup/domain/entities/business.dart';

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.business,
    required this.currentUser,
    required this.counts,
    required this.publicMenu,
    required this.onboardingHints,
  });

  final Business business;
  final DashboardCurrentUser currentUser;
  final DashboardCounts counts;
  final DashboardPublicMenu publicMenu;
  final DashboardOnboardingHints onboardingHints;

  BusinessPermissions get permissions => currentUser.permissions;

  @override
  List<Object?> get props => [
    business,
    currentUser,
    counts,
    publicMenu,
    onboardingHints,
  ];
}

class DashboardCurrentUser extends Equatable {
  const DashboardCurrentUser({required this.role, required this.permissions});

  final String role;
  final BusinessPermissions permissions;

  @override
  List<Object?> get props => [role, permissions];
}

class DashboardCounts extends Equatable {
  const DashboardCounts({
    this.activeCategories = 0,
    this.inactiveCategories = 0,
    this.activeItems = 0,
    this.inactiveItems = 0,
    this.availableItems = 0,
    this.unavailableItems = 0,
    this.activeMembers = 0,
  });

  final int activeCategories;
  final int inactiveCategories;
  final int activeItems;
  final int inactiveItems;
  final int availableItems;
  final int unavailableItems;
  final int activeMembers;

  @override
  List<Object?> get props => [
    activeCategories,
    inactiveCategories,
    activeItems,
    inactiveItems,
    availableItems,
    unavailableItems,
    activeMembers,
  ];
}

class DashboardPublicMenu extends Equatable {
  const DashboardPublicMenu({
    required this.path,
    required this.url,
    required this.qrPayload,
  });

  final String path;
  final String url;
  final String qrPayload;

  @override
  List<Object?> get props => [path, url, qrPayload];
}

class DashboardOnboardingHints extends Equatable {
  const DashboardOnboardingHints({
    this.hasCategories = false,
    this.hasItems = false,
    this.hasPublicMenuReady = false,
    this.recommendedNextStep,
  });

  final bool hasCategories;
  final bool hasItems;
  final bool hasPublicMenuReady;
  final String? recommendedNextStep;

  @override
  List<Object?> get props => [
    hasCategories,
    hasItems,
    hasPublicMenuReady,
    recommendedNextStep,
  ];
}
