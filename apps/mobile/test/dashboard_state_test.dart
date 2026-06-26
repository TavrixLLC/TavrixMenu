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

  test('admin role does not render staff', () {
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
          role: 'ADMIN',
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

    expect(state.roleDisplayLabel, 'Admin');
    expect(state.roleDisplayLabel, isNot('Staff'));
  });

  test('manager and staff labels follow server roles exactly', () {
    const managerState = DashboardState(
      status: DashboardStatus.success,
      business: Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: 'tavrix-cafe',
        publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
        role: 'MANAGER',
      ),
    );
    const staffState = DashboardState(
      status: DashboardStatus.success,
      business: Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: 'tavrix-cafe',
        publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
        role: 'STAFF',
      ),
    );

    expect(managerState.roleDisplayLabel, 'Manager');
    expect(managerState.workspaceRoleDisplayLabel, 'Manager');
    expect(staffState.roleDisplayLabel, 'Staff');
    expect(staffState.workspaceRoleDisplayLabel, 'Staff');
  });

  test('staff permissions keep owner tools disabled', () {
    const state = DashboardState(
      status: DashboardStatus.success,
      business: Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: 'tavrix-cafe',
        publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
        role: 'STAFF',
        permissions: BusinessPermissions(
          canManageAppearance: false,
          canManageBusiness: false,
          canManageMenu: false,
          canViewPublicLink: true,
        ),
      ),
    );

    expect(state.roleDisplayLabel, 'Staff');
    expect(state.permissions?.canManageAppearance, isFalse);
    expect(state.permissions?.canManageMenu, isFalse);
    expect(state.permissions?.canManageBusiness, isFalse);
  });

  test('workspace label follows explicit staff role', () {
    const state = DashboardState(
      status: DashboardStatus.success,
      business: Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: 'tavrix-cafe',
        publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
        role: 'STAFF',
      ),
    );

    expect(state.roleDisplayLabel, 'Staff');
    expect(state.workspaceRoleDisplayLabel, 'Staff');
  });

  test('business app-context role beats stale user role', () {
    const state = DashboardState(
      status: DashboardStatus.success,
      user: CurrentUser(
        id: 'usr_owner',
        email: '',
        fullName: 'Owner',
        role: 'STAFF',
        onboarding: CurrentUserOnboarding(hasBusiness: true),
      ),
      business: Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: 'tavrix-cafe',
        publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
        role: 'OWNER',
      ),
    );

    expect(state.roleDisplayLabel, 'Owner');
    expect(state.roleDisplayLabel, isNot('Staff'));
  });
}
