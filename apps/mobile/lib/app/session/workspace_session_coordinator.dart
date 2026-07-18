import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/business_setup/presentation/bloc/business_setup_cubit.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../features/loyalty/presentation/bloc/loyalty_cubit.dart';
import '../../features/menu/presentation/bloc/menu_cubit.dart';
import '../../features/menu_appearance/presentation/bloc/menu_appearance_cubit.dart';
import '../../features/staff_scanner/presentation/bloc/wallet_scan_cubit.dart';

class WorkspaceSessionCoordinator {
  WorkspaceSessionCoordinator({
    required DashboardCubit dashboardCubit,
    required WalletScanCubit walletScanCubit,
    required MenuCubit menuCubit,
    required LoyaltyCubit loyaltyCubit,
    required MenuAppearanceCubit menuAppearanceCubit,
    required BusinessSetupCubit businessSetupCubit,
  }) : _dashboardCubit = dashboardCubit,
       _walletScanCubit = walletScanCubit,
       _menuCubit = menuCubit,
       _loyaltyCubit = loyaltyCubit,
       _menuAppearanceCubit = menuAppearanceCubit,
       _businessSetupCubit = businessSetupCubit;

  final DashboardCubit _dashboardCubit;
  final WalletScanCubit _walletScanCubit;
  final MenuCubit _menuCubit;
  final LoyaltyCubit _loyaltyCubit;
  final MenuAppearanceCubit _menuAppearanceCubit;
  final BusinessSetupCubit _businessSetupCubit;

  String? _activePrincipalKey;

  void handleAuthStateChange(AuthState state) {
    if (state.status == AuthStatus.authenticated) {
      final nextPrincipalKey = _principalKey(state);
      if (nextPrincipalKey != null && nextPrincipalKey != _activePrincipalKey) {
        _activePrincipalKey = nextPrincipalKey;
        resetWorkspaceState();
      }
      return;
    }

    if (state.status == AuthStatus.unauthenticated ||
        state.status == AuthStatus.failure) {
      _activePrincipalKey = null;
      resetWorkspaceState();
    }
  }

  void resetWorkspaceState() {
    _dashboardCubit.reset();
    _walletScanCubit.reset();
    _menuCubit.reset();
    _loyaltyCubit.reset();
    _menuAppearanceCubit.reset();
    _businessSetupCubit.reset();
  }

  String? _principalKey(AuthState state) {
    final user = state.user;
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
}
