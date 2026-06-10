import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/business_setup/presentation/pages/business_setup_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/menu/presentation/pages/menu_screen.dart';
import '../../features/qr/presentation/pages/qr_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/staff_scanner/presentation/pages/staff_scanner_screen.dart';
import '../../features/subscription/presentation/pages/subscription_screen.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static Map<String, WidgetBuilder> get routes {
    return {
      AppRouteNames.splash: (_) => const SplashScreen(),
      AppRouteNames.login: (_) => const LoginScreen(),
      AppRouteNames.dashboard: (_) => const DashboardScreen(),
      AppRouteNames.businessSetup: (_) => const BusinessSetupScreen(),
      AppRouteNames.menu: (_) => const MenuScreen(),
      AppRouteNames.qr: (_) => const QRScreen(),
      AppRouteNames.subscription: (_) => const SubscriptionScreen(),
      AppRouteNames.staffScanner: (_) => const StaffScannerScreen(),
    };
  }
}
