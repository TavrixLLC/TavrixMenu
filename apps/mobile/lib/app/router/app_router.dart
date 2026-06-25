import 'package:flutter/material.dart';

import '../../app/config/app_config.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/business_setup/presentation/pages/business_profile_screen.dart';
import '../../features/business_setup/presentation/pages/business_setup_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/loyalty/presentation/pages/loyalty_screen.dart';
import '../../features/menu/presentation/pages/menu_screen.dart';
import '../../features/menu_appearance/presentation/pages/menu_appearance_screen.dart';
import '../../features/qr/presentation/pages/qr_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/staff_scanner/presentation/pages/staff_scanner_screen.dart';
import '../../features/subscription/presentation/pages/subscription_screen.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static Map<String, WidgetBuilder> routes({required AppConfig config}) {
    return {
      AppRouteNames.splash: (_) => const SplashScreen(),
      AppRouteNames.login: (_) => LoginScreen(config: config),
      AppRouteNames.dashboard: (_) => const DashboardScreen(),
      AppRouteNames.businessSetup: (_) => const BusinessSetupScreen(),
      AppRouteNames.businessProfile: (_) => const BusinessProfileScreen(),
      AppRouteNames.menu: (_) => const MenuScreen(),
      AppRouteNames.menuAppearance: (_) => MenuAppearanceScreen(
        customerWebBaseUrl: config.normalizedCustomerWebBaseUrl,
      ),
      AppRouteNames.loyalty: (_) => LoyaltyScreen(
        customerWebBaseUrl: config.normalizedCustomerWebBaseUrl,
      ),
      AppRouteNames.qr: (_) => const QRScreen(),
      AppRouteNames.subscription: (_) => const SubscriptionScreen(),
      AppRouteNames.walletScan: (_) => const StaffScannerScreen(),
    };
  }
}
