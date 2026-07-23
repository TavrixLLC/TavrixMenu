import 'package:flutter/material.dart';

import 'waflo_colors.dart';
import 'waflo_radii.dart';
import 'waflo_shadows.dart';

/// Component-level aliases. Shared primitives use these before features do.
abstract final class WafloComponentTokens {
  static const Color primaryButtonBackground = WafloColors.actionPrimary;
  static const Color primaryButtonForeground = WafloColors.onActionPrimary;
  static const Color focusRing = WafloColors.actionPrimary;
  static const double controlRadius = WafloRadii.control;
  static const double cardRadius = WafloRadii.card;
  static const List<BoxShadow> elevatedSurfaceShadow = WafloShadows.elevated;
}
