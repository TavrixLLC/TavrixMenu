import 'package:equatable/equatable.dart';

class Business extends Equatable {
  const Business({
    required this.id,
    required this.name,
    required this.slug,
    required this.publicMenuUrl,
    this.type = 'cafe',
    this.city,
    this.currency = 'IQD',
    this.language = 'ar',
    this.logoUrl,
    this.coverUrl,
    this.status,
    this.role,
    this.permissions,
  });

  final String id;
  final String name;
  final String slug;
  final String publicMenuUrl;
  final String type;
  final String? city;
  final String currency;
  final String language;
  final String? logoUrl;
  final String? coverUrl;
  final String? status;
  final String? role;
  final BusinessPermissions? permissions;

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    publicMenuUrl,
    type,
    city,
    currency,
    language,
    logoUrl,
    coverUrl,
    status,
    role,
    permissions,
  ];
}

class BusinessPermissions extends Equatable {
  const BusinessPermissions({
    this.canManageAppearance = false,
    this.canManageBusiness = false,
    this.canManageMenu = false,
    this.canManageMembers = false,
    this.canViewMembers = false,
    this.canViewPublicLink = false,
    this.canScanCustomerWallet = true,
  });

  const BusinessPermissions.owner()
    : this(
        canManageAppearance: true,
        canManageBusiness: true,
        canManageMenu: true,
        canManageMembers: true,
        canViewMembers: true,
        canViewPublicLink: true,
        canScanCustomerWallet: true,
      );

  final bool canManageAppearance;
  final bool canManageBusiness;
  final bool canManageMenu;
  final bool canManageMembers;
  final bool canViewMembers;
  final bool canViewPublicLink;
  final bool canScanCustomerWallet;

  @override
  List<Object?> get props => [
    canManageAppearance,
    canManageBusiness,
    canManageMenu,
    canManageMembers,
    canViewMembers,
    canViewPublicLink,
    canScanCustomerWallet,
  ];
}
