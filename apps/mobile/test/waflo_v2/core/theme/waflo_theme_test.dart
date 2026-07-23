import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/theme/waflo_colors.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/theme/waflo_primitives.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/theme/waflo_radii.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/theme/waflo_shadows.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/theme/waflo_spacing.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/theme/waflo_theme.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/theme/waflo_typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('primitive layer matches every official Brand System color', () {
    expect(WafloPrimitives.brick.toARGB32(), 0xFFAE3115);
    expect(WafloPrimitives.coral.toARGB32(), 0xFFFF6B4A);
    expect(WafloPrimitives.ember.toARGB32(), 0xFF7D2311);
    expect(WafloPrimitives.softCoral.toARGB32(), 0xFFFFF0EC);
    expect(WafloPrimitives.warmInk.toARGB32(), 0xFF241916);
    expect(WafloPrimitives.mutedClay.toARGB32(), 0xFF76645F);
    expect(WafloPrimitives.cloud.toARGB32(), 0xFFF7F9FF);
    expect(WafloPrimitives.white.toARGB32(), 0xFFFFFFFF);
    expect(WafloPrimitives.success.toARGB32(), 0xFF1F8F6A);
    expect(WafloPrimitives.warning.toARGB32(), 0xFFE6A23C);
    expect(WafloPrimitives.danger.toARGB32(), 0xFFC93C2B);
  });

  test('semantic foreground and container pairs meet WCAG AA', () {
    final pairs = <(Color, Color)>[
      (WafloColors.actionPrimary, WafloColors.onActionPrimary),
      (WafloColors.actionSecondary, WafloColors.onActionSecondary),
      (WafloColors.statusSuccess, WafloColors.onStatusSuccess),
      (WafloColors.successContainer, WafloColors.onSuccessContainer),
      (WafloColors.statusWarning, WafloColors.onStatusWarning),
      (WafloColors.warningContainer, WafloColors.onWarningContainer),
      (WafloColors.statusDanger, WafloColors.onStatusDanger),
      (WafloColors.dangerContainer, WafloColors.onDangerContainer),
      (WafloColors.informationContainer, WafloColors.onInformationContainer),
      (WafloColors.canvas, WafloColors.textStrong),
      (WafloColors.surface, WafloColors.textMuted),
    ];
    for (final pair in pairs) {
      expect(
        _contrast(pair.$1, pair.$2),
        greaterThanOrEqualTo(4.5),
        reason:
            '${pair.$1.toARGB32().toRadixString(16)} / '
            '${pair.$2.toARGB32().toRadixString(16)}',
      );
    }
  });

  test('Coral and Warning use Warm Ink rather than inaccessible white', () {
    expect(
      _contrast(WafloPrimitives.coral, WafloPrimitives.white),
      lessThan(4.5),
    );
    expect(WafloColors.onActionSecondary, WafloPrimitives.warmInk);
    expect(WafloColors.onStatusWarning, WafloPrimitives.warmInk);
    expect(
      _contrast(WafloColors.actionSecondary, WafloColors.onActionSecondary),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('official radii and the single elevation token are centralized', () {
    expect(
      [
        WafloRadii.compact,
        WafloRadii.control,
        WafloRadii.card,
        WafloRadii.prominent,
        WafloRadii.pill,
      ],
      [8, 14, 22, 32, 999],
    );
    final shadow = WafloShadows.elevated.single;
    expect(shadow.offset, const Offset(0, 12));
    expect(shadow.blurRadius, 32);
    expect(shadow.color.r, closeTo(36 / 255, 0.001));
    expect(shadow.color.g, closeTo(25 / 255, 0.001));
    expect(shadow.color.b, closeTo(22 / 255, 0.001));
    expect(shadow.color.a, closeTo(0.10, 0.005));
  });

  test('typography maps scripts, weights, sizes, and fallbacks explicitly', () {
    expect(WafloTypography.familyFor(const Locale('en')), 'Manrope');
    expect(WafloTypography.familyFor(const Locale('ar')), 'Noto Sans Arabic');
    expect(WafloTypography.familyFor(const Locale('ckb')), 'Noto Sans Arabic');
    expect(WafloTypography.fallbackFor(const Locale('en')), [
      'Noto Sans Arabic',
    ]);
    expect(WafloTypography.fallbackFor(const Locale('ar')), ['Manrope']);

    final theme = WafloTypography.textThemeFor(const Locale('en'));
    expect(theme.displayLarge?.fontSize, 48);
    expect(theme.displayLarge?.height, closeTo(56 / 48, 0.001));
    expect(theme.displayLarge?.fontWeight, FontWeight.w800);
    expect(theme.headlineLarge?.fontSize, 36);
    expect(theme.headlineLarge?.height, closeTo(44 / 36, 0.001));
    expect(theme.headlineMedium?.fontSize, 28);
    expect(theme.headlineMedium?.height, closeTo(36 / 28, 0.001));
    expect(theme.bodyLarge?.fontSize, 16);
    expect(theme.bodyLarge?.height, closeTo(26 / 16, 0.001));
    expect(theme.bodyLarge?.fontWeight, FontWeight.w400);
    expect(theme.labelLarge?.fontSize, 14);
    expect(theme.labelLarge?.height, closeTo(20 / 14, 0.001));
    expect(theme.labelLarge?.fontWeight, FontWeight.w600);
    expect(theme.bodySmall?.fontSize, 12);
    expect(theme.bodySmall?.height, closeTo(18 / 12, 0.001));
    expect(theme.bodySmall?.fontWeight, FontWeight.w500);
  });

  test('font files and OFL licenses are bundled as local assets', () async {
    final manrope = await rootBundle.load(
      'assets/waflo_v2/fonts/Manrope-VariableFont_wght.ttf',
    );
    final noto = await rootBundle.load(
      'assets/waflo_v2/fonts/NotoSansArabic-VariableFont_wdth-wght.ttf',
    );
    final manropeLicense = await rootBundle.loadString(
      'assets/waflo_v2/fonts/OFL-Manrope.txt',
    );
    final notoLicense = await rootBundle.loadString(
      'assets/waflo_v2/fonts/OFL-NotoSansArabic.txt',
    );
    expect(manrope.lengthInBytes, greaterThan(10000));
    expect(noto.lengthInBytes, greaterThan(10000));
    expect(manropeLicense, contains('SIL OPEN FONT LICENSE'));
    expect(notoLicense, contains('SIL OPEN FONT LICENSE'));
  });

  testWidgets('theme buttons meet the 48dp minimum touch target', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: WafloTheme.light(const Locale('ar')),
        home: Scaffold(
          body: Center(
            child: FilledButton(onPressed: () {}, child: const Text('حفظ')),
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(FilledButton));
    expect(size.width, greaterThanOrEqualTo(WafloSpacing.minimumTouchTarget));
    expect(size.height, greaterThanOrEqualTo(WafloSpacing.minimumTouchTarget));
  });

  test('only a complete light theme is exposed in Phase 1', () {
    final theme = WafloTheme.light(const Locale('en'));
    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, WafloColors.canvas);
  });
}

double _contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}
