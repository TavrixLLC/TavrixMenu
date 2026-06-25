import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/utils/business_role.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/entities/current_user.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_state.dart';

void main() {
  test('unknown role stays neutral and does not render staff', () {
    const state = DashboardState(
      status: DashboardStatus.success,
      user: CurrentUser(
        id: 'usr_123',
        email: '',
        fullName: 'Operator',
        role: BusinessRole.operator,
        onboarding: CurrentUserOnboarding(hasBusiness: true),
      ),
      business: Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: 'tavrix-cafe',
        publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
      ),
    );

    expect(state.hasKnownRole, isFalse);
    expect(state.effectiveRole, BusinessRole.operator);
    expect(state.roleDisplayLabel, 'Business Operator');
    expect(state.roleDisplayLabel, isNot(contains('Staff')));
  });

  test('owner role and backend permissions stay authoritative', () {
    const state = DashboardState(
      status: DashboardStatus.success,
      summary: DashboardSummary(
        business: Business(
          id: 'bus_123',
          name: 'Tavrix Cafe',
          slug: 'tavrix-cafe',
          publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
        ),
        currentUser: DashboardCurrentUser(
          role: 'OWNER',
          permissions: BusinessPermissions.owner(),
          permissionsAvailable: true,
        ),
        counts: DashboardCounts(),
        publicMenu: DashboardPublicMenu(
          path: '/m/tavrix-cafe',
          url: 'https://menu.example.test/m/tavrix-cafe',
          qrPayload: '',
        ),
        onboardingHints: DashboardOnboardingHints(),
      ),
    );

    expect(state.hasKnownRole, isTrue);
    expect(state.roleDisplayLabel, 'Owner');
    expect(state.permissions?.canManageBusiness, isTrue);
  });

  test('admin role renders admin and never staff', () {
    final state = _stateForRole('ADMIN');

    expect(state.hasKnownRole, isTrue);
    expect(state.effectiveRole, BusinessRole.admin);
    expect(state.roleDisplayLabel, 'Admin');
    expect(state.roleDisplayLabel, isNot(contains('Staff')));
  });

  test('manager role renders manager and never staff', () {
    final state = _stateForRole('MANAGER');

    expect(state.hasKnownRole, isTrue);
    expect(state.effectiveRole, BusinessRole.manager);
    expect(state.roleDisplayLabel, 'Manager');
    expect(state.roleDisplayLabel, isNot(contains('Staff')));
  });

  test('staff role renders staff only when backend returns staff', () {
    final state = _stateForRole('STAFF');

    expect(state.hasKnownRole, isTrue);
    expect(state.effectiveRole, BusinessRole.staff);
    expect(state.roleDisplayLabel, 'Staff');
  });

  test('missing role renders business operator and never staff', () {
    const state = DashboardState(
      status: DashboardStatus.success,
      business: Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: 'tavrix-cafe',
        publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
      ),
    );

    expect(state.hasKnownRole, isFalse);
    expect(state.effectiveRole, BusinessRole.operator);
    expect(state.roleDisplayLabel, 'Business Operator');
    expect(state.roleDisplayLabel, isNot(contains('Staff')));
  });
}

DashboardState _stateForRole(String role) {
  return DashboardState(
    status: DashboardStatus.success,
    summary: DashboardSummary(
      business: const Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: 'tavrix-cafe',
        publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
      ),
      currentUser: DashboardCurrentUser(
        role: role,
        permissions: const BusinessPermissions(),
        permissionsAvailable: false,
      ),
      counts: const DashboardCounts(),
      publicMenu: const DashboardPublicMenu(
        path: '/m/tavrix-cafe',
        url: 'https://menu.example.test/m/tavrix-cafe',
        qrPayload: '',
      ),
      onboardingHints: const DashboardOnboardingHints(),
    ),
  );
}
