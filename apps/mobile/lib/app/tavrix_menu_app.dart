import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/auth/auth_session_controller.dart';
import '../core/localization/app_locale.dart';
import '../core/localization/app_locale_controller.dart';
import '../core/localization/ckb_framework_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/localization/presentation/pages/language_selection_screen.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/business_setup/presentation/bloc/business_setup_cubit.dart';
import '../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../features/loyalty/presentation/bloc/loyalty_cubit.dart';
import '../features/menu/presentation/bloc/menu_cubit.dart';
import '../features/menu_appearance/presentation/bloc/menu_appearance_cubit.dart';
import '../features/staff_scanner/presentation/bloc/wallet_scan_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import 'di/injection.dart';
import 'router/app_router.dart';
import 'router/route_names.dart';
import 'session/workspace_session_coordinator.dart';

class TavrixMenuApp extends StatefulWidget {
  const TavrixMenuApp({super.key, this.dependencies});

  final AppDependencies? dependencies;

  @override
  State<TavrixMenuApp> createState() => _TavrixMenuAppState();
}

class _TavrixMenuAppState extends State<TavrixMenuApp> {
  late final AppDependencies _dependencies =
      widget.dependencies ?? AppDependencies.create();
  late final WorkspaceSessionCoordinator _workspaceSessionCoordinator =
      WorkspaceSessionCoordinator(
        dashboardCubit: _dependencies.dashboardCubit,
        walletScanCubit: _dependencies.walletScanCubit,
        menuCubit: _dependencies.menuCubit,
        loyaltyCubit: _dependencies.loyaltyCubit,
        menuAppearanceCubit: _dependencies.menuAppearanceCubit,
        businessSetupCubit: _dependencies.businessSetupCubit,
      );

  @override
  void initState() {
    super.initState();
    unawaited(_dependencies.appLocaleController.restore());
  }

  @override
  void dispose() {
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppLocaleController>.value(
      value: _dependencies.appLocaleController,
      child: BlocBuilder<AppLocaleController, AppLocaleState>(
        builder: (context, localeState) {
          if (!localeState.hasConfirmedChoice) {
            return _buildLocaleGate(localeState);
          }
          return _buildAuthenticatedApp(localeState.locale!);
        },
      ),
    );
  }

  Widget _buildLocaleGate(AppLocaleState localeState) {
    final restoring = localeState.status == AppLocaleStatus.restoring;
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: AppLocale.arabic.locale,
      localizationsDelegates: _localizationsDelegates,
      supportedLocales: AppLocale.supportedLocales,
      home: restoring
          ? const _LocaleRestoringScreen()
          : const LanguageSelectionScreen(),
    );
  }

  Widget _buildAuthenticatedApp(AppLocale locale) {
    final app = MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _dependencies.authCubit),
        BlocProvider<BusinessSetupCubit>.value(
          value: _dependencies.businessSetupCubit,
        ),
        BlocProvider<DashboardCubit>.value(value: _dependencies.dashboardCubit),
        BlocProvider<MenuCubit>.value(value: _dependencies.menuCubit),
        BlocProvider<MenuAppearanceCubit>.value(
          value: _dependencies.menuAppearanceCubit,
        ),
        BlocProvider<LoyaltyCubit>.value(value: _dependencies.loyaltyCubit),
        BlocProvider<WalletScanCubit>.value(
          value: _dependencies.walletScanCubit,
        ),
      ],
      child: _WorkspaceSessionResetter(
        coordinator: _workspaceSessionCoordinator,
        child: MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: locale.locale,
          localizationsDelegates: _localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
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

const _localizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  ckbMaterialLocalizationsDelegate,
  GlobalMaterialLocalizations.delegate,
  ckbCupertinoLocalizationsDelegate,
  GlobalCupertinoLocalizations.delegate,
  ckbWidgetsLocalizationsDelegate,
  GlobalWidgetsLocalizations.delegate,
];

class _LocaleRestoringScreen extends StatelessWidget {
  const _LocaleRestoringScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _WorkspaceSessionResetter extends StatelessWidget {
  const _WorkspaceSessionResetter({
    required this.coordinator,
    required this.child,
  });

  final WorkspaceSessionCoordinator coordinator;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (_, state) => coordinator.handleAuthStateChange(state),
      child: child,
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
