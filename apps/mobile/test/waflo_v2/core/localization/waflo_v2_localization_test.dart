import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/localization/waflo_bidi.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/localization/waflo_v2_strings.dart';

import '../../test_fixtures.dart';

void main() {
  for (final locale in WafloV2Strings.supportedLocales) {
    testWidgets('${locale.languageCode} loads V2 strings and direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        foundationHarness(
          locale: locale,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Text(
                  context.wafloV2.foundationReady,
                  key: const ValueKey('localized-copy'),
                ),
              );
            },
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.byKey(const ValueKey('localized-copy')),
      );
      expect(text.data, isNotEmpty);
      expect(
        Directionality.of(
          tester.element(find.byKey(const ValueKey('localized-copy'))),
        ),
        WafloBidi.directionFor(locale),
      );
    });
  }

  test('Arabic and Sorani are RTL while English is LTR', () {
    expect(WafloBidi.directionFor(const Locale('ar')), TextDirection.rtl);
    expect(WafloBidi.directionFor(const Locale('ckb')), TextDirection.rtl);
    expect(WafloBidi.directionFor(const Locale('en')), TextDirection.ltr);
  });

  test('phone, money, and identifiers receive LTR isolation', () {
    final isolated = WafloBidi.isolateLtr('5,900 IQD');
    expect(isolated.codeUnits.first, 0x2066);
    expect(isolated.codeUnits.last, 0x2069);
    expect(isolated, contains('5,900 IQD'));
  });

  test('all locale maps expose critical state and studio strings', () {
    for (final locale in WafloV2Strings.supportedLocales) {
      final strings = WafloV2Strings(locale);
      expect(strings.loadingTitle, isNotEmpty);
      expect(strings.errorTitle, isNotEmpty);
      expect(strings.offlineTitle, isNotEmpty);
      expect(strings.cardStudio, isNotEmpty);
      expect(strings.notDeviceVerified, isNotEmpty);
      expect(strings.joinHeadline, isNotEmpty);
      expect(strings.cardShape, isNotEmpty);
      expect(strings.rewardIcon, isNotEmpty);
      expect(strings.notUploaded, isNotEmpty);
      expect(strings.previousStep, isNotEmpty);
      expect(strings.nextStep, isNotEmpty);
      expect(strings.scrollStepsHint, isNotEmpty);
      expect(strings.stepProgress(2, 8), contains('2'));
      expect(strings.stepProgress(2, 8), contains('8'));
      expect(strings.compactWafloCardPreview, isNotEmpty);
    }
  });
}
