import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/config/app_config.dart';
import '../constants/app_spacing.dart';
import '../../features/auth/domain/entities/current_user.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/dashboard/presentation/bloc/dashboard_state.dart';

const _showDebugQaContextPanel = bool.fromEnvironment(
  'WAFLO_SHOW_DEBUG_QA_CONTEXT',
  defaultValue: false,
);

Map<String, Object?>? buildDebugQaContextSnapshot({
  required AuthState authState,
  required DashboardState dashboardState,
  required String selectedRoute,
  AppConfig? config,
  int? meStatusCode,
}) {
  if (!kDebugMode) {
    return null;
  }

  final user = authState.user;
  final roles = _rolesReturned(user);
  final permissions = dashboardState.permissions;

  return {
    'meStatus': meStatusCode ?? _meStatus(authState.status),
    'membershipsCount': user?.memberships.length ?? 0,
    'rolesReturned': roles,
    'hasBusiness': user?.onboarding.hasBusiness ?? false,
    'activeBusinessCount': user?.onboarding.activeBusinessCount ?? 0,
    'recommendedNextStep': user?.onboarding.recommendedNextStep,
    'selectedBusinessAppContextRole': dashboardState.backendRole,
    'permissions': {
      'canManageAppearance': permissions?.canManageAppearance ?? false,
      'canManageBusiness': permissions?.canManageBusiness ?? false,
      'canManageMenu': permissions?.canManageMenu ?? false,
      'canManageMembers': permissions?.canManageMembers ?? false,
      'canViewMembers': permissions?.canViewMembers ?? false,
      'canViewPublicLink': permissions?.canViewPublicLink ?? false,
      'canScanCustomerWallet': permissions?.canScanCustomerWallet ?? false,
    },
    'selectedRoute': _safeRoute(selectedRoute),
    if (config != null) 'authConfig': config.sanitizedAuthConfigStatus,
  };
}

class DebugQaContextPanel extends StatelessWidget {
  const DebugQaContextPanel({required this.snapshot, super.key});

  final Map<String, Object?>? snapshot;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || !_showDebugQaContextPanel || snapshot == null) {
      return const SizedBox.shrink();
    }

    final data = snapshot!;
    final authConfig = data['authConfig'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug QA context',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            _DebugLine(label: '/me status', value: data['meStatus']),
            _DebugLine(
              label: 'memberships count',
              value: data['membershipsCount'],
            ),
            _DebugLine(label: 'roles returned', value: data['rolesReturned']),
            _DebugLine(label: 'hasBusiness', value: data['hasBusiness']),
            _DebugLine(
              label: 'activeBusinessCount',
              value: data['activeBusinessCount'],
            ),
            _DebugLine(
              label: 'recommendedNextStep',
              value: data['recommendedNextStep'],
            ),
            _DebugLine(
              label: 'app-context role',
              value: data['selectedBusinessAppContextRole'],
            ),
            _DebugLine(label: 'permissions', value: data['permissions']),
            _DebugLine(label: 'selected route', value: data['selectedRoute']),
            if (authConfig != null)
              _DebugLine(label: 'auth config', value: authConfig),
          ],
        ),
      ),
    );
  }
}

class _DebugLine extends StatelessWidget {
  const _DebugLine({required this.label, required this.value});

  final String label;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text('$label: ${value ?? 'none'}'),
    );
  }
}

Object _meStatus(AuthStatus status) {
  return switch (status) {
    AuthStatus.authenticated => 200,
    AuthStatus.failure => 'error',
    AuthStatus.loading => 'loading',
    AuthStatus.unauthenticated => 'not checked',
    AuthStatus.initial => 'not checked',
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
