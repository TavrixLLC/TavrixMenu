import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../features/business_setup/presentation/pages/business_profile_screen.dart';
import '../../../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../../../features/loyalty/presentation/pages/loyalty_screen.dart';
import '../../../../features/menu/presentation/pages/menu_screen.dart';
import '../../../../features/staff_scanner/presentation/pages/staff_scanner_screen.dart';
import 'waflo_bottom_nav_v2.dart';

/// Waflo V2 App Shell Widget
///
/// Serves as the main visual frame for the authenticated owner experience.
/// Hosts the 5 core tabs (الرئيسية, المنيو, الولاء, المسح, الإعدادات) in an
/// IndexedStack with a persistent WafloBottomNavV2 bar.
class WafloShellV2 extends StatefulWidget {
  const WafloShellV2({required this.config, super.key});

  final AppConfig config;

  static WafloShellV2State? of(BuildContext context) {
    return context.findAncestorStateOfType<WafloShellV2State>();
  }

  @override
  State<WafloShellV2> createState() => WafloShellV2State();
}

class WafloShellV2State extends State<WafloShellV2> {
  int _currentIndex = 0;

  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F0), // Warm background
      bottomNavigationBar: WafloBottomNavV2(
        currentIndex: _currentIndex,
        onTap: setTab,
        items: const [
          WafloBottomNavItemV2(
            icon: Icons.dashboard_outlined,
            label: 'الرئيسية',
          ),
          WafloBottomNavItemV2(
            icon: Icons.restaurant_menu_outlined,
            label: 'المنيو',
          ),
          WafloBottomNavItemV2(icon: Icons.loyalty_outlined, label: 'الولاء'),
          WafloBottomNavItemV2(
            icon: Icons.qr_code_scanner_outlined,
            label: 'المسح',
          ),
          WafloBottomNavItemV2(
            icon: Icons.settings_outlined,
            label: 'الإعدادات',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const DashboardScreen(),
          const MenuScreen(),
          LoyaltyScreen(
            customerWebBaseUrl: widget.config.normalizedCustomerWebBaseUrl,
          ),
          const StaffScannerScreen(),
          const BusinessProfileScreen(),
        ],
      ),
    );
  }
}
