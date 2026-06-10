import 'package:equatable/equatable.dart';

import 'business.dart';
import 'public_link.dart';

class BusinessAppContext extends Equatable {
  const BusinessAppContext({
    required this.business,
    required this.currentMembership,
    required this.permissions,
    required this.publicMenu,
  });

  final Business business;
  final BusinessMembership currentMembership;
  final BusinessPermissions permissions;
  final PublicLink publicMenu;

  @override
  List<Object?> get props => [
    business,
    currentMembership,
    permissions,
    publicMenu,
  ];
}

class BusinessMembership extends Equatable {
  const BusinessMembership({
    required this.id,
    required this.role,
    required this.isActive,
  });

  final String id;
  final String role;
  final bool isActive;

  @override
  List<Object?> get props => [id, role, isActive];
}

class BusinessPermissions extends Equatable {
  const BusinessPermissions({
    required this.canManageBusiness,
    required this.canManageMenu,
    required this.canManageMembers,
    required this.canViewMembers,
    required this.canViewPublicLink,
  });

  const BusinessPermissions.all()
    : canManageBusiness = true,
      canManageMenu = true,
      canManageMembers = true,
      canViewMembers = true,
      canViewPublicLink = true;

  final bool canManageBusiness;
  final bool canManageMenu;
  final bool canManageMembers;
  final bool canViewMembers;
  final bool canViewPublicLink;

  @override
  List<Object?> get props => [
    canManageBusiness,
    canManageMenu,
    canManageMembers,
    canViewMembers,
    canViewPublicLink,
  ];
}
