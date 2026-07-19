import 'package:flutter/material.dart';

import 'waflo_v3_tokens.dart';

/// Unwired theme foundation for Waflo Mobile UI V3.
abstract final class WafloV3Theme {
  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      primary: WafloV3Colors.primary,
      onPrimary: WafloV3Colors.surface,
      secondary: WafloV3Colors.accent,
      onSecondary: WafloV3Colors.primaryText,
      error: WafloV3Colors.error,
      onError: WafloV3Colors.surface,
      surface: WafloV3Colors.surface,
      onSurface: WafloV3Colors.primaryText,
      surfaceContainerLowest: WafloV3Colors.surface,
      surfaceContainer: WafloV3Colors.background,
      outline: WafloV3Colors.primaryText.withValues(alpha: 0.32),
      outlineVariant: WafloV3Colors.primaryText.withValues(alpha: 0.12),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: WafloV3Colors.background,
      disabledColor: WafloV3Colors.primaryText.withValues(alpha: 0.38),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: WafloV3Colors.primaryText,
        displayColor: WafloV3Colors.primaryText,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: WafloV3Colors.primary,
        selectionColor: WafloV3Colors.accent.withValues(alpha: 0.32),
        selectionHandleColor: WafloV3Colors.primary,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: WafloV3Colors.primary,
      ),
    );
  }

  static ButtonStyle get primaryButtonStyle {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size(
          WafloV3Spacing.minimumTouchTarget,
          WafloV3Spacing.minimumTouchTarget,
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsetsDirectional.symmetric(
          horizontal: WafloV3Spacing.space20,
          vertical: WafloV3Spacing.space12,
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return WafloV3Colors.primaryText.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.pressed)) {
          return Color.alphaBlend(
            WafloV3Colors.surface.withValues(alpha: 0.12),
            WafloV3Colors.primary,
          );
        }
        return WafloV3Colors.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return WafloV3Colors.primaryText.withValues(alpha: 0.38);
        }
        return WafloV3Colors.surface;
      }),
      overlayColor: WidgetStatePropertyAll(
        WafloV3Colors.surface.withValues(alpha: 0.12),
      ),
      elevation: const WidgetStatePropertyAll(0),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(color: WafloV3Colors.accent, width: 2);
        }
        return BorderSide.none;
      }),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(WafloV3Radius.inputControl),
          ),
        ),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  static ButtonStyle get secondaryButtonStyle {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size(
          WafloV3Spacing.minimumTouchTarget,
          WafloV3Spacing.minimumTouchTarget,
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsetsDirectional.symmetric(
          horizontal: WafloV3Spacing.space20,
          vertical: WafloV3Spacing.space12,
        ),
      ),
      backgroundColor: const WidgetStatePropertyAll(WafloV3Colors.surface),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return WafloV3Colors.primaryText.withValues(alpha: 0.38);
        }
        return WafloV3Colors.primary;
      }),
      overlayColor: WidgetStatePropertyAll(
        WafloV3Colors.primary.withValues(alpha: 0.08),
      ),
      elevation: const WidgetStatePropertyAll(0),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(
            color: WafloV3Colors.primaryText.withValues(alpha: 0.12),
          );
        }
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(color: WafloV3Colors.accent, width: 2);
        }
        return const BorderSide(color: WafloV3Colors.primary);
      }),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(WafloV3Radius.inputControl),
          ),
        ),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
