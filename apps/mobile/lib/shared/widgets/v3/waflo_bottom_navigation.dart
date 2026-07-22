import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations_extension.dart';
import '../../../core/theme/v3/waflo_v3_tokens.dart';

enum WafloWorkspaceDestination {
  home(
    label: 'الرئيسية',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
  ),
  menu(
    label: 'المنيو',
    icon: Icons.restaurant_menu_outlined,
    selectedIcon: Icons.restaurant_menu_rounded,
  ),
  scanner(
    label: 'المسح',
    icon: Icons.qr_code_scanner_outlined,
    selectedIcon: Icons.qr_code_scanner_rounded,
  ),
  loyalty(
    label: 'الولاء',
    icon: Icons.loyalty_outlined,
    selectedIcon: Icons.loyalty_rounded,
  ),
  settings(
    label: 'الإعدادات',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
  );

  const WafloWorkspaceDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  String localizedLabel(BuildContext context) => switch (this) {
    WafloWorkspaceDestination.home => context.l10n.navHome,
    WafloWorkspaceDestination.menu => context.l10n.navMenu,
    WafloWorkspaceDestination.scanner => context.l10n.navScan,
    WafloWorkspaceDestination.loyalty => context.l10n.navLoyalty,
    WafloWorkspaceDestination.settings => context.l10n.navSettings,
  };
}

/// Presentation-only navigation for the five canonical workspace destinations.
///
/// Taps on the selected destination are ignored so a parent does not create a
/// duplicate navigation entry. This widget never owns routes or selection.
class WafloBottomNavigation extends StatelessWidget {
  const WafloBottomNavigation({
    required this.selectedDestination,
    required this.onDestinationSelected,
    super.key,
    this.disabledDestinations = const {},
  });

  final WafloWorkspaceDestination selectedDestination;
  final ValueChanged<WafloWorkspaceDestination> onDestinationSelected;
  final Set<WafloWorkspaceDestination> disabledDestinations;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Material(
        color: WafloV3Colors.surface,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: WafloV3Colors.primaryText.withValues(alpha: 0.08),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: WafloV3Colors.primaryText.withValues(alpha: 0.06),
                blurRadius: WafloV3Spacing.space12,
                offset: const Offset(0, -WafloV3Spacing.space4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: WafloV3Spacing.space4),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: WafloWorkspaceDestination.values
                    .map((destination) {
                      final isSelected = destination == selectedDestination;
                      final isEnabled = !disabledDestinations.contains(
                        destination,
                      );

                      return Expanded(
                        child: _DestinationItem(
                          destination: destination,
                          isSelected: isSelected,
                          isEnabled: isEnabled,
                          onTap: isEnabled && !isSelected
                              ? () => onDestinationSelected(destination)
                              : null,
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DestinationItem extends StatelessWidget {
  const _DestinationItem({
    required this.destination,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final WafloWorkspaceDestination destination;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = destination.localizedLabel(context);
    final color = isSelected
        ? WafloV3Colors.primary
        : isEnabled
        ? WafloV3Colors.primaryText.withValues(alpha: 0.68)
        : WafloV3Colors.primaryText.withValues(alpha: 0.32);

    return Semantics(
      key: ValueKey('waflo-bottom-navigation-${destination.name}'),
      container: true,
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: WafloV3Spacing.minimumTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: WafloV3Spacing.space4,
              vertical: WafloV3Spacing.space4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: WafloV3Spacing.space4,
                  child: isSelected
                      ? DecoratedBox(
                          key: ValueKey(
                            'waflo-bottom-navigation-indicator-${destination.name}',
                          ),
                          decoration: const BoxDecoration(
                            color: WafloV3Colors.primary,
                            borderRadius: BorderRadius.all(
                              Radius.circular(WafloV3Radius.pill),
                            ),
                          ),
                          child: const SizedBox(width: WafloV3Spacing.space24),
                        )
                      : const SizedBox(width: WafloV3Spacing.space24),
                ),
                const SizedBox(height: WafloV3Spacing.space4),
                Icon(
                  isSelected ? destination.selectedIcon : destination.icon,
                  key: ValueKey(
                    'waflo-bottom-navigation-icon-${destination.name}',
                  ),
                  color: color,
                  size: WafloV3Spacing.space24,
                ),
                const SizedBox(height: WafloV3Spacing.space4),
                Text(
                  label,
                  key: ValueKey(
                    'waflo-bottom-navigation-label-${destination.name}',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
