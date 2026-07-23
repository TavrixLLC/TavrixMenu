import 'package:flutter/material.dart';

import 'waflo_colors.dart';

abstract final class WafloTypography {
  static const String latinFamily = 'Manrope';
  static const String arabicFamily = 'Noto Sans Arabic';

  static String familyFor(Locale locale) {
    return _usesArabicScript(locale) ? arabicFamily : latinFamily;
  }

  static List<String> fallbackFor(Locale locale) {
    return _usesArabicScript(locale)
        ? const [latinFamily]
        : const [arabicFamily];
  }

  static TextTheme textThemeFor(Locale locale) {
    final family = familyFor(locale);
    final fallback = fallbackFor(locale);

    TextStyle style({
      required double size,
      required double lineHeight,
      required FontWeight weight,
      Color color = WafloColors.textStrong,
    }) {
      return TextStyle(
        color: color,
        fontFamily: family,
        fontFamilyFallback: fallback,
        fontSize: size,
        height: lineHeight / size,
        fontWeight: weight,
      );
    }

    final display = style(size: 48, lineHeight: 56, weight: FontWeight.w800);
    final h1 = style(size: 36, lineHeight: 44, weight: FontWeight.w800);
    final h2 = style(size: 28, lineHeight: 36, weight: FontWeight.w700);
    final body = style(size: 16, lineHeight: 26, weight: FontWeight.w400);
    final label = style(size: 14, lineHeight: 20, weight: FontWeight.w600);
    final caption = style(
      size: 12,
      lineHeight: 18,
      weight: FontWeight.w500,
      color: WafloColors.textMuted,
    );

    return TextTheme(
      displayLarge: display,
      displayMedium: h1,
      displaySmall: h1,
      headlineLarge: h1,
      headlineMedium: h2,
      headlineSmall: h2,
      titleLarge: h2,
      titleMedium: body.copyWith(fontWeight: FontWeight.w600),
      titleSmall: label,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: caption,
      labelLarge: label,
      labelMedium: caption,
      labelSmall: caption,
    );
  }

  static TextStyle numericEmphasis(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static bool _usesArabicScript(Locale locale) {
    return locale.languageCode == 'ar' || locale.languageCode == 'ckb';
  }
}
