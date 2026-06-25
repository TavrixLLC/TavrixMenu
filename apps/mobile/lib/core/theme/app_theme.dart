import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryCoral,
        onPrimary: AppColors.surfaceWhite,
        secondary: AppColors.freshGreen,
        onSecondary: AppColors.surfaceWhite,
        tertiary: AppColors.rewardGold,
        onTertiary: AppColors.ink,
        error: AppColors.dangerRed,
        onError: AppColors.surfaceWhite,
        surface: AppColors.surfaceWhite,
        onSurface: AppColors.textDark,
        surfaceContainerLowest: AppColors.surfaceWhite,
        surfaceContainer: AppColors.neutralCanvas,
        outline: AppColors.softBorder,
        outlineVariant: AppColors.softBorder,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.neutralCanvas,
      fontFamilyFallback: const ['Inter', 'Arial'],
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.neutralCanvas,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: AppColors.primaryCoral,
          foregroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.softBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryCoralDark,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        labelStyle: TextStyle(color: AppColors.mutedText),
        hintStyle: TextStyle(color: AppColors.mutedText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          borderSide: BorderSide(color: AppColors.softBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          borderSide: BorderSide(color: AppColors.softBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          borderSide: BorderSide(color: AppColors.primaryCoral, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          borderSide: BorderSide(color: AppColors.dangerRed),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.textDark,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textDark,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        labelLarge: TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: TextStyle(color: AppColors.textDark, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.mutedText, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.softBorder),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.freshGreen,
        linearTrackColor: AppColors.softBorder,
      ),
    );
  }
}
