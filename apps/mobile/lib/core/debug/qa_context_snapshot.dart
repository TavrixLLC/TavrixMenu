import 'package:flutter/foundation.dart';

import '../../features/auth/domain/entities/current_user.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/dashboard/presentation/bloc/dashboard_state.dart';

Map<String, Object?>? buildDebugQaContextSnapshot({
  required AuthState authState,
  required DashboardState dashboardState,
  required String selectedRoute,
  int? meStatusCode,
}) {
  if (!kDebugMode) {
    return null;
  }

  final user = authState.user;
  final roles = _rolesReturned(user);
  final permissions = dashboardState.permissions;

  return {
    'meStatus': meStatusCode ?? authState.status.name,
    'membershipsCount': user?.memberships.length ?? 0,
    'rolesReturned': roles,
    'hasBusiness': user?.onboarding.hasBusiness ?? false,
    'activeBusinessCount': user?.onboarding.activeBusinessCount ?? 0,
    'recommendedNextStep': user?.onboarding.recommendedNextStep,
    'selectedBusinessAppContextRole': dashboardState.backendRole,
    'permissions': {
      'canManageBusiness': permissions?.canManageBusiness ?? false,
      'canManageMenu': permissions?.canManageMenu ?? false,
      'canManageMembers': permissions?.canManageMembers ?? false,
      'canViewMembers': permissions?.canViewMembers ?? false,
      'canViewPublicLink': permissions?.canViewPublicLink ?? false,
    },
    'selectedRoute': _safeRoute(selectedRoute),
  };
}

List<String> _rolesReturned(CurrentUser? user) {
  final roles = <String>{};
  final topLevelRole = user?.role.trim();
  if (topLevelRole != null && topLevelRole.isNotEmpty) {
    roles.add(topLevelRole);
  }
  for (final membership
      in user?.memberships ?? const <CurrentUserMembership>[]) {
    final role = membership.role.trim();
    if (role.isNotEmpty) {
      roles.add(role);
    }
  }
  for (final business in user?.businesses ?? const <CurrentUserBusiness>[]) {
    final role = business.role.trim();
    if (role.isNotEmpty) {
      roles.add(role);
    }
  }
  final sorted = roles.toList()..sort();
  return sorted;
}

String _safeRoute(String selectedRoute) {
  return switch (selectedRoute.trim().toLowerCase()) {
    'dashboard' || '/dashboard' => 'dashboard',
    'business setup' ||
    'business_setup' ||
    '/business-setup' => 'business setup',
    'error' => 'error',
    _ => 'error',
  };
}
