import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/core/debug/qa_context_snapshot.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/entities/current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:tavrix_menu_mobile/features/dashboard/presentation/bloc/dashboard_state.dart';

void main() {
  testWidgets('debug QA context panel is hidden by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DebugQaContextPanel(snapshot: {'meStatus': 200})),
      ),
    );

    expect(find.text('Debug QA context'), findsNothing);
  });

  test('debug QA context contains only sanitized route and count fields', () {
    final snapshot = buildDebugQaContextSnapshot(
      authState: const AuthState(
        status: AuthStatus.authenticated,
        user: CurrentUser(
          id: 'usr_secret',
          email: 'owner@example.test',
          fullName: 'Owner Name',
          role: 'OWNER',
          memberships: [
            CurrentUserMembership(
              id: 'mem_secret',
              role: 'OWNER',
              isActive: true,
              business: CurrentUserMembershipBusiness(
                id: 'bus_secret',
                name: 'Tavrix Cafe',
                slug: 'tavrix-cafe',
                type: 'cafe',
              ),
            ),
          ],
          onboarding: CurrentUserOnboarding(
            hasBusiness: true,
            activeBusinessCount: 1,
            recommendedNextStep: 'OPEN_DASHBOARD',
          ),
        ),
      ),
      dashboardState: const DashboardState(
        status: DashboardStatus.success,
        summary: DashboardSummary(
          business: Business(
            id: 'bus_secret',
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
            qrPayload: 'https://menu.example.test/m/tavrix-cafe',
          ),
          onboardingHints: DashboardOnboardingHints(),
        ),
      ),
      selectedRoute: '/dashboard',
      config: const AppConfig(
        apiBaseUrl: '',
        customerWebBaseUrl: '',
        devAuthToken: '',
        appEnv: 'development',
        enableDevAuth: false,
        clerkPublishableKey: '',
      ),
      meStatusCode: 200,
    );

    expect(snapshot?['meStatus'], 200);
    expect(snapshot?['membershipsCount'], 1);
    expect(snapshot?['rolesReturned'], ['OWNER']);
    expect(snapshot?['selectedRoute'], 'dashboard');
    expect(snapshot?['authConfigStatus'], 'needs review');
    expect(snapshot.toString(), isNot(contains('API_BASE_URL')));
    expect(snapshot.toString(), isNot(contains('APP_ENV')));
    expect(snapshot.toString(), isNot(contains('ENABLE_DEV_AUTH')));
    expect(snapshot.toString(), isNot(contains('CLERK_PUBLISHABLE_KEY')));
    expect(snapshot.toString(), isNot(contains('CUSTOMER_WEB_BASE_URL')));
    expect(snapshot.toString(), isNot(contains('owner@example.test')));
    expect(snapshot.toString(), isNot(contains('usr_secret')));
    expect(snapshot.toString(), isNot(contains('bus_secret')));
  });
}
