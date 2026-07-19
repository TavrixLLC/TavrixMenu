import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/theme/v3/waflo_v3_theme.dart';
import 'package:tavrix_menu_mobile/core/theme/v3/waflo_v3_tokens.dart';

void main() {
  group('Waflo Mobile UI V3 light theme', () {
    test('uses Material 3 and the canonical color roles', () {
      final theme = WafloV3Theme.light();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, WafloV3Colors.primary);
      expect(theme.colorScheme.secondary, WafloV3Colors.accent);
      expect(theme.colorScheme.surface, WafloV3Colors.surface);
      expect(theme.scaffoldBackgroundColor, WafloV3Colors.background);
      expect(theme.colorScheme.onSurface, WafloV3Colors.primaryText);
      expect(theme.colorScheme.error, WafloV3Colors.error);
      expect(theme.colorScheme.error, isNot(theme.colorScheme.primary));
    });

    test('constructs without BuildContext', () {
      expect(WafloV3Theme.light, returnsNormally);
    });

    test('keeps both button themes at or above the touch target', () {
      final theme = WafloV3Theme.light();
      final primaryMinimum = theme.elevatedButtonTheme.style?.minimumSize
          ?.resolve(<WidgetState>{});
      final secondaryMinimum = theme.outlinedButtonTheme.style?.minimumSize
          ?.resolve(<WidgetState>{});

      expect(primaryMinimum, isNotNull);
      expect(secondaryMinimum, isNotNull);
      expect(
        primaryMinimum!.width,
        greaterThanOrEqualTo(WafloV3Spacing.minimumTouchTarget),
      );
      expect(
        primaryMinimum.height,
        greaterThanOrEqualTo(WafloV3Spacing.minimumTouchTarget),
      );
      expect(
        secondaryMinimum!.width,
        greaterThanOrEqualTo(WafloV3Spacing.minimumTouchTarget),
      );
      expect(
        secondaryMinimum.height,
        greaterThanOrEqualTo(WafloV3Spacing.minimumTouchTarget),
      );
    });

    test('does not require an undeclared font family', () {
      final source = File(
        'lib/core/theme/v3/waflo_v3_theme.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('fontFamily:')));
    });
  });
}
