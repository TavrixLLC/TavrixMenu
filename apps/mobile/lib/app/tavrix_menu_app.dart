import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/auth/auth_session_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/business_setup/presentation/bloc/business_setup_cubit.dart';
import '../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../features/loyalty/presentation/bloc/loyalty_cubit.dart';
import '../features/menu/presentation/bloc/menu_cubit.dart';
import '../features/staff_scanner/presentation/bloc/wallet_scan_cubit.dart';
import 'di/injection.dart';
import 'router/app_router.dart';
import 'router/route_names.dart';

class TavrixMenuApp extends StatefulWidget {
  const TavrixMenuApp({super.key, this.dependencies});

  final AppDependencies? dependencies;

  @override
  State<TavrixMenuApp> createState() => _TavrixMenuAppState();
}

class _TavrixMenuAppState extends State<TavrixMenuApp> {
  late final AppDependencies _dependencies =
      widget.dependencies ?? AppDependencies.create();

  @override
  void dispose() {
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _dependencies.authCubit),
        BlocProvider<BusinessSetupCubit>.value(
          value: _dependencies.businessSetupCubit,
        ),
        BlocProvider<DashboardCubit>.value(value: _dependencies.dashboardCubit),
        BlocProvider<MenuCubit>.value(value: _dependencies.menuCubit),
        BlocProvider<LoyaltyCubit>.value(value: _dependencies.loyaltyCubit),
        BlocProvider<WalletScanCubit>.value(
          value: _dependencies.walletScanCubit,
        ),
      ],
      child: MaterialApp(
        title: 'Tavrix Menu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRouteNames.splash,
        routes: AppRouter.routes(config: _dependencies.config),
        builder: (context, child) {
          final page = child ?? const SizedBox.shrink();
          if (!_dependencies.config.hasClerkPublishableKey) {
            return page;
          }

          return _ClerkAuthStateBinder(
            authSessionController: _dependencies.authSessionController,
            child: page,
          );
        },
      ),
    );

    if (!_dependencies.config.hasClerkPublishableKey) {
      return app;
    }

    return ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: _dependencies.config.clerkPublishableKey,
      ),
      child: app,
    );
  }
}

class _ClerkAuthStateBinder extends StatelessWidget {
  const _ClerkAuthStateBinder({
    required this.authSessionController,
    required this.child,
  });

  final AuthSessionController authSessionController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClerkAuthBuilder(
      builder: (context, authState) {
        authSessionController.bindClerkAuthState(authState);
        return child;
      },
      signedInBuilder: (context, authState) {
        authSessionController.bindClerkAuthState(authState);
        return child;
      },
      signedOutBuilder: (context, authState) {
        authSessionController.bindClerkAuthState(authState);
        return child;
      },
    );
  }
}
