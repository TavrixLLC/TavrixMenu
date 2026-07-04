import 'package:flutter/material.dart';
import 'waflo_tokens_v2.dart';

/// Waflo UI V2 Theme Definition
///
/// Exposes the premium light theme configuration for Waflo V2.
class WafloThemeV2 {
  const WafloThemeV2._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: WafloColorsV2.primaryCoral,
        onPrimary: WafloColorsV2.surfaceWhite,
        secondary: WafloColorsV2.accentCrimson,
        onSecondary: WafloColorsV2.surfaceWhite,
        error: WafloColorsV2.danger,
        onError: WafloColorsV2.surfaceWhite,
        surface: WafloColorsV2.surfaceWhite,
        onSurface: WafloColorsV2.textDark,
        surfaceContainerLowest: WafloColorsV2.surfaceWhite,
        surfaceContainer: WafloColorsV2.backgroundCanvas,
        outline: WafloColorsV2.borderSoft,
        outlineVariant: WafloColorsV2.borderExtraSoft,
      ),
      scaffoldBackgroundColor: WafloColorsV2.backgroundCanvas,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: WafloColorsV2.textDark,
        elevation: 0,
        titleTextStyle: WafloTypographyV2.h2,
      ),
      cardTheme: const CardThemeData(
        color: WafloColorsV2.surfaceWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      textTheme: const TextTheme(
        displayLarge: WafloTypographyV2.display,
        headlineMedium: WafloTypographyV2.h1,
        headlineSmall: WafloTypographyV2.h2,
        titleLarge: WafloTypographyV2.title,
        bodyLarge: WafloTypographyV2.bodyBold,
        bodyMedium: WafloTypographyV2.body,
        bodySmall: WafloTypographyV2.caption,
      ),
      dividerTheme: const DividerThemeData(
        color: WafloColorsV2.borderExtraSoft,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
