import 'package:flutter/material.dart';

import '../theme/waflo_spacing.dart';

abstract final class WafloAccessibility {
  static const double minimumTouchTarget = WafloSpacing.minimumTouchTarget;

  static bool reducedMotionOf(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    return media?.disableAnimations ?? false;
  }

  static Duration motionDurationOf(BuildContext context) {
    return reducedMotionOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
  }
}

class WafloTouchTarget extends StatelessWidget {
  const WafloTouchTarget({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: WafloAccessibility.minimumTouchTarget,
        minHeight: WafloAccessibility.minimumTouchTarget,
      ),
      child: child,
    );
  }
}

class WafloFocusOrder extends StatelessWidget {
  const WafloFocusOrder({required this.order, required this.child, super.key});

  final double order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalOrder(order: NumericFocusOrder(order), child: child);
  }
}
