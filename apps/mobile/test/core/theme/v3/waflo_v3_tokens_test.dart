import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/theme/v3/waflo_v3_tokens.dart';

void main() {
  group('Waflo Mobile UI V3 colors', () {
    test('match the locked canonical palette', () {
      expect(WafloV3Colors.primary, const Color(0xFFAE3115));
      expect(WafloV3Colors.accent, const Color(0xFFFF6B4A));
      expect(WafloV3Colors.background, const Color(0xFFF7F9FF));
      expect(WafloV3Colors.surface, const Color(0xFFFFFFFF));
      expect(WafloV3Colors.primaryText, const Color(0xFF181C20));
      expect(WafloV3Colors.error, const Color(0xFFBA1A1A));
    });

    test('keeps semantic error distinct from the primary action color', () {
      expect(WafloV3Colors.error, isNot(WafloV3Colors.primary));
    });
  });

  group('Waflo Mobile UI V3 spacing', () {
    test('uses the locked 4px grid', () {
      const spacing = <double>[
        WafloV3Spacing.space4,
        WafloV3Spacing.space8,
        WafloV3Spacing.space12,
        WafloV3Spacing.space16,
        WafloV3Spacing.space20,
        WafloV3Spacing.space24,
        WafloV3Spacing.space32,
        WafloV3Spacing.space48,
      ];

      expect(spacing, <double>[4, 8, 12, 16, 20, 24, 32, 48]);
      expect(spacing.every((value) => value % 4 == 0), isTrue);
    });

    test('exposes the locked semantic spacing values', () {
      expect(WafloV3Spacing.standardPageMargin, 16);
      expect(WafloV3Spacing.commonCardPadding, 24);
      expect(WafloV3Spacing.minimumTouchTarget, greaterThanOrEqualTo(48));
    });
  });

  group('Waflo Mobile UI V3 geometry', () {
    test('keeps controls and cards within the locked radius hierarchy', () {
      expect(WafloV3Radius.inputControl, 16);
      expect(WafloV3Radius.standardCard, 20);
      expect(WafloV3Radius.largeCard, 24);
      expect(WafloV3Radius.inputControl, lessThan(WafloV3Radius.standardCard));
      expect(WafloV3Radius.standardCard, lessThan(WafloV3Radius.largeCard));
      expect(WafloV3Radius.pill, WafloV3Radius.largeCard);
    });

    test('keeps responsive widths ordered as references', () {
      expect(
        WafloV3Responsive.compactReferenceWidth,
        lessThan(WafloV3Responsive.expandedMobileReferenceWidth),
      );
    });

    test('does not define a screenshot-height layout token', () {
      final source = File(
        'lib/core/theme/v3/waflo_v3_tokens.dart',
      ).readAsStringSync();

      expect(
        source,
        isNot(
          contains(
            RegExp(
              r'(screenshot|reference|fixed)[A-Za-z_]*height',
              caseSensitive: false,
            ),
          ),
        ),
      );
    });
  });
}
