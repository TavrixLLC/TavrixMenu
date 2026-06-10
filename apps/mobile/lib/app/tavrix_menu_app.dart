import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import 'config/app_config.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/business_setup/presentation/bloc/business_setup_cubit.dart';
import '../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../features/menu/presentation/bloc/menu_cubit.dart';
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
    return RepositoryProvider<AppConfig>.value(
      value: _dependencies.config,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: _dependencies.authCubit),
          BlocProvider<BusinessSetupCubit>.value(
            value: _dependencies.businessSetupCubit,
          ),
          BlocProvider<DashboardCubit>.value(
            value: _dependencies.dashboardCubit,
          ),
          BlocProvider<MenuCubit>.value(value: _dependencies.menuCubit),
        ],
        child: MaterialApp(
          title: 'Tavrix Menu',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: AppRouteNames.splash,
          routes: AppRouter.routes,
        ),
      ),
    );
  }
}
