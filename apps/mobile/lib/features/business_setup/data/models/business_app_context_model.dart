import '../../../../core/utils/response_parser.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/business_app_context.dart';
import 'business_model.dart';
import 'public_link_model.dart';

class BusinessAppContextModel extends BusinessAppContext {
  const BusinessAppContextModel({
    required super.business,
    required super.currentMembership,
    required super.permissions,
    required super.publicMenu,
  });

  factory BusinessAppContextModel.fromResponse(dynamic data) {
    final json = asJsonObject(data, context: 'business app context response');
    final nested = json['data'];
    final contextJson = nested == null
        ? json
        : asJsonObject(nested, context: 'business app context response');

    final membership = BusinessMembershipModel.fromJson(
      asJsonObject(
        contextJson['currentMembership'],
        context: 'current membership response',
      ),
    );
    final businessModel = BusinessModel.fromJson(
      asJsonObject(contextJson['business'], context: 'app context business'),
    );
    final publicMenu = PublicLinkModel.fromPublicMenuJson(
      businessId: businessModel.id,
      json: asJsonObject(
        contextJson['publicMenu'],
        context: 'app context public menu',
      ),
    );

    return BusinessAppContextModel(
      business: Business(
        id: businessModel.id,
        name: businessModel.name,
        slug: businessModel.slug,
        type: businessModel.type,
        role: businessModel.role.isEmpty ? membership.role : businessModel.role,
        publicMenuUrl: publicMenu.publicMenuUrl,
        city: businessModel.city,
        currency: businessModel.currency,
        language: businessModel.language,
      ),
      currentMembership: membership,
      permissions: BusinessPermissionsModel.fromJson(
        asJsonObject(
          contextJson['permissions'],
          context: 'business permissions response',
        ),
      ),
      publicMenu: publicMenu,
    );
  }

  BusinessAppContext toEntity() {
    return BusinessAppContext(
      business: business,
      currentMembership: currentMembership,
      permissions: permissions,
      publicMenu: publicMenu,
    );
  }
}

class BusinessMembershipModel extends BusinessMembership {
  const BusinessMembershipModel({
    required super.id,
    required super.role,
    required super.isActive,
  });

  factory BusinessMembershipModel.fromJson(Map<String, dynamic> json) {
    return BusinessMembershipModel(
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class BusinessPermissionsModel extends BusinessPermissions {
  const BusinessPermissionsModel({
    required super.canManageBusiness,
    required super.canManageMenu,
    required super.canManageMembers,
    required super.canViewMembers,
    required super.canViewPublicLink,
  });

  factory BusinessPermissionsModel.fromJson(Map<String, dynamic> json) {
    return BusinessPermissionsModel(
      canManageBusiness: json['canManageBusiness'] as bool? ?? false,
      canManageMenu: json['canManageMenu'] as bool? ?? false,
      canManageMembers: json['canManageMembers'] as bool? ?? false,
      canViewMembers: json['canViewMembers'] as bool? ?? false,
      canViewPublicLink: json['canViewPublicLink'] as bool? ?? false,
    );
  }
}
