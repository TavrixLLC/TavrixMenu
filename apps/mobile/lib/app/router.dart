import 'package:flutter/material.dart';

import '../features/auth/login_screen.dart';
import '../features/business_setup/business_setup_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/menu/menu_screen.dart';
import '../features/qr/qr_screen.dart';
import '../features/staff_scanner/staff_scanner_screen.dart';
import '../features/subscription/subscription_screen.dart';

class AppRoutes {
  static const login = '/';
  static const dashboard = '/dashboard';
  static const businessSetup = '/business-setup';
  static const menu = '/menu';
  static const qr = '/qr';
  static const subscription = '/subscription';
  static const staffScanner = '/staff-scanner';
}

class AppRouter {
  static Map<String, WidgetBuilder> get routes {
    return {
      AppRoutes.login: (_) => const LoginScreen(),
      AppRoutes.dashboard: (_) => const DashboardScreen(),
      AppRoutes.businessSetup: (_) => const BusinessSetupScreen(),
      AppRoutes.menu: (_) => const MenuScreen(),
      AppRoutes.qr: (_) => const QRScreen(),
      AppRoutes.subscription: (_) => const SubscriptionScreen(),
      AppRoutes.staffScanner: (_) => const StaffScannerScreen(),
    };
  }
}
