import 'package:flutter/material.dart';

import 'waflo_colors.dart';
import 'waflo_component_tokens.dart';
import 'waflo_radii.dart';
import 'waflo_spacing.dart';
import 'waflo_typography.dart';

abstract final class WafloTheme {
  static ThemeData light(Locale locale) {
    final colorScheme = ColorScheme.light(
      primary: WafloColors.actionPrimary,
      onPrimary: WafloColors.onActionPrimary,
      secondary: WafloColors.actionSecondary,
      onSecondary: WafloColors.onActionSecondary,
      error: WafloColors.statusDanger,
      onError: WafloColors.onStatusDanger,
      errorContainer: WafloColors.dangerContainer,
      onErrorContainer: WafloColors.onDangerContainer,
      surface: WafloColors.surface,
      onSurface: WafloColors.onSurface,
      surfaceContainerLowest: WafloColors.surface,
      surfaceContainer: WafloColors.canvas,
      surfaceContainerHigh: WafloColors.surfaceMuted,
      outline: WafloColors.outline,
      outlineVariant: WafloColors.divider,
    );

    final textTheme = WafloTypography.textThemeFor(locale);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: WafloColors.canvas,
      textTheme: textTheme,
      disabledColor: WafloColors.disabledForeground,
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
      cardTheme: const CardThemeData(
        color: WafloColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(WafloRadii.card)),
          side: BorderSide(color: WafloColors.divider),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: WafloColors.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WafloColors.surface,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: WafloSpacing.x4,
          vertical: WafloSpacing.x3,
        ),
        border: _outlineBorder(WafloColors.outline),
        enabledBorder: _outlineBorder(WafloColors.outline),
        focusedBorder: _outlineBorder(WafloComponentTokens.focusRing, width: 2),
        errorBorder: _outlineBorder(WafloColors.statusDanger),
        focusedErrorBorder: _outlineBorder(WafloColors.statusDanger, width: 2),
        disabledBorder: _outlineBorder(WafloColors.divider),
        labelStyle: textTheme.bodyMedium,
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(
          color: WafloColors.statusDanger,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(
              WafloSpacing.minimumTouchTarget,
              WafloSpacing.minimumTouchTarget,
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsetsDirectional.symmetric(horizontal: WafloSpacing.x5),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return WafloColors.disabledSurface;
            }
            return WafloComponentTokens.primaryButtonBackground;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return WafloColors.disabledForeground;
            }
            return WafloComponentTokens.primaryButtonForeground;
          }),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(WafloRadii.control),
              ),
            ),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          animationDuration: const Duration(milliseconds: 160),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(
              WafloSpacing.minimumTouchTarget,
              WafloSpacing.minimumTouchTarget,
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsetsDirectional.symmetric(horizontal: WafloSpacing.x5),
          ),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return WafloColors.disabledForeground;
            }
            return WafloColors.actionPrimary;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: WafloColors.divider);
            }
            return const BorderSide(color: WafloColors.actionPrimary);
          }),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(WafloRadii.control),
              ),
            ),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          animationDuration: const Duration(milliseconds: 160),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: WafloColors.actionPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: WafloColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: WafloColors.surfaceSubtle,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? WafloColors.actionPrimary
                : WafloColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? WafloColors.actionPrimary
                : WafloColors.textMuted,
            size: 24,
          );
        }),
      ),
    );
  }

  static OutlineInputBorder _outlineBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(WafloRadii.control)),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
