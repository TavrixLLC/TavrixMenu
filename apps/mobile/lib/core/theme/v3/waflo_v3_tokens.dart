import 'package:flutter/material.dart';

/// Canonical color roles for Waflo Mobile UI V3.
abstract final class WafloV3Colors {
  static const Color primary = Color(0xFFAE3115);
  static const Color accent = Color(0xFFFF6B4A);
  static const Color background = Color(0xFFF7F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF181C20);
  static const Color error = Color(0xFFBA1A1A);
}

/// Spacing values derived from the locked 4px grid.
abstract final class WafloV3Spacing {
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;

  static const double standardPageMargin = space16;
  static const double commonCardPadding = space24;
  static const double minimumTouchTarget = space48;
}

/// Radius roles within the locked 16-24px hierarchy.
abstract final class WafloV3Radius {
  static const double inputControl = 16;
  static const double standardCard = 20;
  static const double largeCard = 24;
  static const double pill = 24;
}

/// Reference widths for responsive mobile decisions, not layout constraints.
abstract final class WafloV3Responsive {
  static const double compactReferenceWidth = 360;
  static const double expandedMobileReferenceWidth = 430;
}
