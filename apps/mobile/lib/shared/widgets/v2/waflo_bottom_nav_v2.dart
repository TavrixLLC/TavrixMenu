import 'package:flutter/material.dart';
import '../../../../core/theme/v2/waflo_tokens_v2.dart';

/// Waflo Bottom Navigation V2 Component (Skeleton)
///
/// Renders a premium, RTL-first bottom navigation bar conforming to the
/// Waflo V2 design aesthetics.
class WafloBottomNavItemV2 {
  const WafloBottomNavItemV2({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class WafloBottomNavV2 extends StatelessWidget {
  const WafloBottomNavV2({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<WafloBottomNavItemV2> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: WafloColorsV2.surfaceWhite,
          border: const Border(
            top: BorderSide(color: WafloColorsV2.borderSoft),
          ),
          boxShadow: WafloShadowV2.soft,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == currentIndex;

                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? WafloColorsV2.primaryCoral
                              : WafloColorsV2.textLight,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: WafloTypographyV2.caption.copyWith(
                            color: isSelected
                                ? WafloColorsV2.primaryCoral
                                : WafloColorsV2.textMedium,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: WafloColorsV2.primaryCoral,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
