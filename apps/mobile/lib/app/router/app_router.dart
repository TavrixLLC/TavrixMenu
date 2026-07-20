import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/config/app_config.dart';
import '../../features/auth/domain/entities/current_user.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/business_setup/presentation/pages/business_profile_screen.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../features/dashboard/presentation/bloc/dashboard_state.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/onboarding/presentation/pages/waflo_first_run_wizard_screen.dart';
import '../../features/loyalty/presentation/pages/loyalty_screen.dart';
import '../../features/menu/presentation/pages/menu_screen.dart';
import '../../features/menu_appearance/presentation/pages/menu_appearance_screen.dart';
import '../../features/qr/presentation/pages/qr_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/staff_scanner/presentation/pages/staff_scanner_screen.dart';
import '../../shared/widgets/v3/waflo_shell_v3.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static Map<String, WidgetBuilder> routes({required AppConfig config}) {
    return {
      AppRouteNames.splash: (_) => const SplashScreen(),
      AppRouteNames.login: (_) => LoginScreen(config: config),
      AppRouteNames.dashboard: (_) => _OwnerWorkspaceShell(config: config),
      AppRouteNames.businessSetup: (_) => const WafloFirstRunWizardScreen(),
      AppRouteNames.businessProfile: (_) => const BusinessProfileScreen(),
      AppRouteNames.menu: (_) => const MenuScreen(),
      AppRouteNames.menuAppearance: (_) => MenuAppearanceScreen(
        customerWebBaseUrl: config.normalizedCustomerWebBaseUrl,
      ),
      AppRouteNames.loyalty: (_) => LoyaltyScreen(
        customerWebBaseUrl: config.normalizedCustomerWebBaseUrl,
      ),
      AppRouteNames.qr: (_) => const QRScreen(),
      AppRouteNames.walletScan: (_) => const StaffScannerScreen(),
    };
  }
}

class _OwnerWorkspaceShell extends StatelessWidget {
  const _OwnerWorkspaceShell({required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final principalIdentity = _principalIdentity(authState.user);

        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, dashboardState) {
            final identity = _workspaceIdentity(
              authState: authState,
              dashboardState: dashboardState,
              principalIdentity: principalIdentity,
            );
            final lifecycleIdentity = Object.hash(
              principalIdentity ?? authState.status,
              identity.businessId,
            );

            return WafloShellV3(
              workspaceLifecycleIdentity: lifecycleIdentity,
              workspaceIdentityState: identity.state,
              workspaceName: identity.workspaceName,
              home: DashboardScreen(
                embeddedInWorkspaceShell: true,
                onOpenPublicMenu: () =>
                    Navigator.of(context).pushNamed(AppRouteNames.qr),
              ),
              menu: const MenuScreen(embeddedInWorkspaceShell: true),
              scanner: const StaffScannerScreen(embeddedInWorkspaceShell: true),
              loyalty: LoyaltyScreen(
                customerWebBaseUrl: config.normalizedCustomerWebBaseUrl,
                embeddedInWorkspaceShell: true,
              ),
              settings: const BusinessProfileScreen(
                embeddedInWorkspaceShell: true,
              ),
            );
          },
        );
      },
    );
  }
}

class _WorkspaceIdentity {
  const _WorkspaceIdentity({
    required this.state,
    this.businessId,
    this.workspaceName,
  });

  final WafloWorkspaceIdentityState state;
  final String? businessId;
  final String? workspaceName;
}

_WorkspaceIdentity _workspaceIdentity({
  required AuthState authState,
  required DashboardState dashboardState,
  required String? principalIdentity,
}) {
  if (authState.status != AuthStatus.authenticated ||
      principalIdentity == null) {
    return const _WorkspaceIdentity(
      state: WafloWorkspaceIdentityState.unavailable,
    );
  }

  if (dashboardState.status == DashboardStatus.failure) {
    return const _WorkspaceIdentity(
      state: WafloWorkspaceIdentityState.unavailable,
    );
  }

  final dashboardPrincipal = _principalIdentity(dashboardState.user);
  final business = dashboardState.business;
  final matchingBusinessId =
      dashboardPrincipal == principalIdentity &&
          business != null &&
          business.id.trim().isNotEmpty
      ? business.id
      : null;
  if (dashboardState.status != DashboardStatus.success ||
      dashboardPrincipal != principalIdentity ||
      business == null ||
      business.id.trim().isEmpty ||
      business.name.trim().isEmpty) {
    return _WorkspaceIdentity(
      state: WafloWorkspaceIdentityState.loading,
      businessId: matchingBusinessId,
    );
  }

  return _WorkspaceIdentity(
    state: WafloWorkspaceIdentityState.ready,
    businessId: business.id,
    workspaceName: business.name.trim(),
  );
}

String? _principalIdentity(CurrentUser? user) {
  if (user == null) {
    return null;
  }

  final clerkUserId = user.clerkUserId?.trim();
  if (clerkUserId != null && clerkUserId.isNotEmpty) {
    return 'clerk:$clerkUserId';
  }

  final userId = user.id.trim();
  if (userId.isEmpty) {
    return null;
  }
  return 'user:$userId';
}
