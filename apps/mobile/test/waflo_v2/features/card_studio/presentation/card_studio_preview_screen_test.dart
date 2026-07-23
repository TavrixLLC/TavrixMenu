import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/domain/provider_preview.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/presentation/card_studio_preview_screen.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/presentation/components/provider_preview_panel.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/presentation/components/studio_step_rail.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_buttons.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_text_field.dart';

import '../../../test_fixtures.dart';

void main() {
  testWidgets('Studio is a one-section-at-a-time preview wizard', (
    tester,
  ) async {
    await _pumpStudio(tester);

    expect(find.text('استوديو تخصيص البطاقة'), findsOneWidget);
    expect(find.textContaining('معاينة محلية فقط'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    _expectOnlySection(0);

    await tester.ensureVisible(find.byKey(const ValueKey('waflo-studio-next')));
    await tester.tap(find.byKey(const ValueKey('waflo-studio-next')));
    await tester.pumpAndSettle();

    _expectOnlySection(1);
    expect(find.byKey(const ValueKey('waflo-studio-previous')), findsOneWidget);
    expect(find.byType(ProviderPreviewPanel), findsNothing);
  });

  testWidgets('provider availability and fidelity flags drive Wallet step', (
    tester,
  ) async {
    const unavailableGoogle = ProviderPreviewCapability(
      provider: CardPreviewProvider.googleWallet,
      isAvailable: false,
      isDeterministicPreview: false,
      isRealDeviceVerified: false,
      limitations: ['fixture unavailable'],
    );
    await _pumpStudio(
      tester,
      initialStep: 6,
      capabilities: [reviewProviderCapabilities.first, unavailableGoogle],
    );

    expect(find.text('المعاينة غير متاحة'), findsWidgets);
    expect(
      find.byKey(const ValueKey('google-platform-approximation')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('waflo-deterministic-preview')),
      findsOneWidget,
    );
    expect(find.text('معاينة مدمجة لبطاقة Waflo'), findsOneWidget);
  });

  testWidgets('preview-only copy appears once in Brand fields section', (
    tester,
  ) async {
    await _pumpStudio(tester);

    final fields = tester.widgetList<WafloTextField>(
      find.byType(WafloTextField),
    );
    expect(fields, hasLength(2));
    expect(fields.every((field) => field.readOnly), isTrue);
    expect(fields.every((field) => field.helperText == null), isTrue);
    expect(find.text('للمعاينة فقط'), findsOneWidget);
  });

  testWidgets('QR and publish remain honestly unavailable in their steps', (
    tester,
  ) async {
    await _pumpStudio(tester, initialStep: 5);
    expect(find.text('QR غير متاح في هذه المعاينة'), findsOneWidget);
    expect(
      find.widgetWithText(WafloPrimaryButton, 'الحفظ والنشر متوقفان'),
      findsNothing,
    );

    await _pumpStudio(tester, initialStep: 7);
    final publishButton = tester.widget<WafloPrimaryButton>(
      find.widgetWithText(WafloPrimaryButton, 'الحفظ والنشر متوقفان'),
    );
    expect(publishButton.onPressed, isNull);
  });

  for (final locale in const [Locale('ar'), Locale('en')]) {
    testWidgets(
      '${locale.languageCode} every step stays fully reachable at 360dp and 1.6x text',
      (tester) async {
        await _pumpStudio(
          tester,
          locale: locale,
          textScale: 1.6,
          size: const Size(360, 900),
        );

        final direction = locale.languageCode == 'en'
            ? TextDirection.ltr
            : TextDirection.rtl;
        expect(
          Directionality.of(
            tester.element(
              find.byKey(const ValueKey('waflo-studio-section-0')),
            ),
          ),
          direction,
        );
        expect(
          find.byKey(const ValueKey('waflo-studio-horizontal-step-rail')),
          findsOneWidget,
        );

        for (var index = 0; index < 8; index++) {
          if (index > 0) {
            tester
                .widget<StudioStepRail>(find.byType(StudioStepRail))
                .onSelected(index);
            await tester.pumpAndSettle();
          }

          _expectOnlySection(index);
          final railRect = tester.getRect(
            find.byKey(const ValueKey('waflo-studio-horizontal-step-rail')),
          );
          final selectedRect = tester.getRect(
            find.byKey(ValueKey('waflo-studio-step-$index')),
          );
          expect(
            selectedRect.left,
            greaterThanOrEqualTo(railRect.left - 0.5),
            reason:
                '${locale.languageCode} step $index left edge; selected=$selectedRect rail=$railRect',
          );
          expect(
            selectedRect.right,
            lessThanOrEqualTo(railRect.right + 0.5),
            reason:
                '${locale.languageCode} step $index right edge; selected=$selectedRect rail=$railRect',
          );
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets('Apple and Google remain explicit platform approximations', (
    tester,
  ) async {
    await _pumpStudio(tester, locale: const Locale('en'), initialStep: 6);

    expect(find.text('Platform approximation'), findsNWidgets(2));
    expect(find.text('Compact Waflo Card preview'), findsOneWidget);
    expect(find.text('Exact / deterministic Waflo preview'), findsOneWidget);
    expect(find.text('Not verified on a real device'), findsWidgets);
  });

  test(
    'production Studio source contains no backend, upload, or QR simulation',
    () {
      final source = File(
        'lib/waflo_v2/features/card_studio/presentation/card_studio_preview_screen.dart',
      ).readAsStringSync();
      expect(source, isNot(contains('Dio')));
      expect(source, isNot(contains('Repository')));
      expect(source, isNot(contains('QrImage')));
      expect(source, isNot(contains('saveDesign')));
      expect(source, isNot(contains('publishDesign')));
    },
  );
}

Future<void> _pumpStudio(
  WidgetTester tester, {
  Locale locale = const Locale('ar'),
  double textScale = 1,
  Size size = const Size(430, 932),
  int initialStep = 0,
  List<ProviderPreviewCapability> capabilities = reviewProviderCapabilities,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    foundationHarness(
      locale: locale,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: CardStudioPreviewScreen(
          design: reviewCardDesign(
            businessDisplayName: locale.languageCode == 'en'
                ? 'Dijla Café'
                : 'مقهى دجلة',
            programDisplayName: locale.languageCode == 'en'
                ? 'Visit rewards'
                : 'مكافآت الزيارة',
            joinHeadline: locale.languageCode == 'en'
                ? 'Join Visit rewards'
                : 'انضم إلى مكافآت الزيارة',
            joinBody: locale.languageCode == 'en'
                ? 'Collect visits and unlock your reward.'
                : 'اجمع زياراتك واستبدل مكافأتك.',
            rewardLabel: locale.languageCode == 'en'
                ? 'Visit reward'
                : 'مكافأة الزيارة',
          ),
          providerCapabilities: capabilities,
          initialStep: initialStep,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _expectOnlySection(int selectedIndex) {
  for (var index = 0; index < 8; index++) {
    expect(
      find.byKey(ValueKey('waflo-studio-section-$index')),
      index == selectedIndex ? findsOneWidget : findsNothing,
    );
  }
}
