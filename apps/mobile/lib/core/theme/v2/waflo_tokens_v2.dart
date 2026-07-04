import 'package:flutter/material.dart';

/// Waflo UI V2 Design System Tokens
///
/// Contains Color, Radius, Shadow, Spacing, and Typography definitions for Waflo V2.
class WafloColorsV2 {
  const WafloColorsV2._();

  // Core Brand Colors
  static const Color primaryCoral = Color(0xFFFF6B4A);
  static const Color accentCrimson = Color(0xFFB23B1E);
  static const Color backgroundWarm = Color(0xFFFFF5F0);
  static const Color cardWarm = Color(0xFFFFFDFB);

  // Backgrounds & Surface
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundCanvas = Color(0xFFFFF5F0);

  // Text Colors
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMedium = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);

  // Borders
  static const Color borderSoft = Color(0xFFE2E8F0);
  static const Color borderExtraSoft = Color(0xFFF1F5F9);

  // Semantic Indicators
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFFEFF6FF);
}

class WafloRadiusV2 {
  const WafloRadiusV2._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;

  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get lgBorder => BorderRadius.circular(lg);
  static BorderRadius get xlBorder => BorderRadius.circular(xl);
  static BorderRadius get xxlBorder => BorderRadius.circular(xxl);
}

class WafloSpacingV2 {
  const WafloSpacingV2._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class WafloShadowV2 {
  const WafloShadowV2._();

  static List<BoxShadow> get soft => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get brand => [
    BoxShadow(
      color: const Color(0xFFB23B1E).withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

class WafloTypographyV2 {
  const WafloTypographyV2._();

  static const String primaryFont = 'Outfit';
  static const String fallbackFont = 'Inter';

  static const TextStyle display = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: [fallbackFont],
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: WafloColorsV2.textDark,
    height: 1.2,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: [fallbackFont],
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: WafloColorsV2.textDark,
    height: 1.25,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: [fallbackFont],
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: WafloColorsV2.textDark,
    height: 1.3,
  );

  static const TextStyle title = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: [fallbackFont],
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: WafloColorsV2.textDark,
    height: 1.35,
  );

  static const TextStyle body = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: [fallbackFont],
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: WafloColorsV2.textMedium,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: [fallbackFont],
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: WafloColorsV2.textDark,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: [fallbackFont],
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: WafloColorsV2.textLight,
    height: 1.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: [fallbackFont],
    fontSize: 15,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );
}
