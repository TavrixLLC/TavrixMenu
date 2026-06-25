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
}
