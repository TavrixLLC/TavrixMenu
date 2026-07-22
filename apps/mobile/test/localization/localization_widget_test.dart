import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tavrix_menu_mobile/core/localization/app_locale.dart';
import 'package:tavrix_menu_mobile/core/localization/app_locale_controller.dart';
import 'package:tavrix_menu_mobile/core/localization/app_locale_repository.dart';
import 'package:tavrix_menu_mobile/core/localization/ckb_framework_localizations.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:tavrix_menu_mobile/features/localization/presentation/pages/language_selection_screen.dart';
import 'package:tavrix_menu_mobile/features/localization/presentation/widgets/app_language_picker.dart';
import 'package:tavrix_menu_mobile/l10n/generated/app_localizations.dart';
import 'package:tavrix_menu_mobile/shared/widgets/qr_preview_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Sorani framework localization', () {
    test('delegates support only the real ckb locale', () {
      expect(
        ckbMaterialLocalizationsDelegate.isSupported(const Locale('ckb')),
        isTrue,
      );
      expect(
        ckbWidgetsLocalizationsDelegate.isSupported(const Locale('ckb')),
        isTrue,
      );
      expect(
        ckbCupertinoLocalizationsDelegate.isSupported(const Locale('ckb')),
        isTrue,
      );
      expect(
        ckbMaterialLocalizationsDelegate.isSupported(const Locale('ar')),
        isFalse,
      );
      expect(
        ckbMaterialLocalizationsDelegate.isSupported(const Locale('fa')),
        isFalse,
      );
    });

    test('Material labels resolve directly in Sorani', () async {
      final material = await ckbMaterialLocalizationsDelegate.load(
        const Locale('ckb'),
      );

      expect(material, isA<CkbMaterialLocalizations>());
      expect(material.backButtonTooltip, 'گەڕانەوە');
      expect(material.cancelButtonLabel, 'هەڵوەشاندنەوە');
      expect(material.searchFieldLabel, 'گەڕان');
      expect(material.copyButtonLabel, 'لەبەرگرتنەوە');
      expect(material.saveButtonLabel, 'پاشەکەوتکردن');
      expect(material.backButtonTooltip, isNot('Back'));
    });

    test('Widgets and Cupertino labels resolve in Sorani RTL', () async {
      final widgets = await ckbWidgetsLocalizationsDelegate.load(
        const Locale('ckb'),
      );
      final cupertino = await ckbCupertinoLocalizationsDelegate.load(
        const Locale('ckb'),
      );

      expect(widgets.textDirection, TextDirection.rtl);
      expect(widgets.copyButtonLabel, 'لەبەرگرتنەوە');
      expect(cupertino.copyButtonLabel, 'لەبەرگرتنەوە');
      expect(cupertino.cancelButtonLabel, 'هەڵوەشاندنەوە');
    });

    testWidgets('MaterialApp reports ckb and RTL without locale aliasing', (
      tester,
    ) async {
      late Locale activeLocale;
      late TextDirection direction;
      late String cancelLabel;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ckb'),
          supportedLocales: AppLocale.supportedLocales,
          localizationsDelegates: _delegates,
          home: Builder(
            builder: (context) {
              activeLocale = Localizations.localeOf(context);
              direction = Directionality.of(context);
              cancelLabel = MaterialLocalizations.of(context).cancelButtonLabel;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(activeLocale.languageCode, 'ckb');
      expect(direction, TextDirection.rtl);
      expect(cancelLabel, 'هەڵوەشاندنەوە');
    });
  });

  group('first-launch selector', () {
    testWidgets('requires an explicit choice before authentication', (
      tester,
    ) async {
      final controller = await _selectionRequiredController();
      addTearDown(controller.close);

      await tester.pumpWidget(
        _dynamicLocaleApp(controller, const LanguageSelectionScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectionScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('کوردی / سۆرانی'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('language-selection-continue')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('choices are semantic, selected, and at least 48px tall', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final controller = await _selectionRequiredController();
      addTearDown(controller.close);

      await tester.pumpWidget(
        _dynamicLocaleApp(controller, const LanguageSelectionScreen()),
      );
      await tester.pumpAndSettle();

      for (final locale in AppLocale.values) {
        final label = find.text(locale.nativeName);
        final target = find.ancestor(of: label, matching: find.byType(InkWell));
        expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
      }

      await tester.tap(find.text(AppLocale.sorani.nativeName));
      await tester.pump();
      final selected = tester
          .getSemantics(find.text(AppLocale.sorani.nativeName))
          .getSemanticsData();
      expect(selected.flagsCollection.isSelected, ui.Tristate.isTrue);
      final continueButton = tester.widget<FilledButton>(
        find.byKey(const ValueKey('language-selection-continue')),
      );
      expect(continueButton.onPressed, isNotNull);
      semantics.dispose();
    });

    for (final locale in AppLocale.values) {
      testWidgets('${locale.languageCode} applies immediately after confirm', (
        tester,
      ) async {
        final controller = await _selectionRequiredController();
        addTearDown(controller.close);

        await tester.pumpWidget(
          _dynamicLocaleApp(controller, const LanguageSelectionScreen()),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(locale.nativeName));
        await tester.pump();
        await tester.tap(
          find.byKey(const ValueKey('language-selection-continue')),
        );
        await tester.pumpAndSettle();

        expect(controller.state.locale, locale);
        expect(controller.state.hasConfirmedChoice, isTrue);
        expect(
          Localizations.localeOf(
            tester.element(find.byType(LanguageSelectionScreen)),
          ).languageCode,
          locale.languageCode,
        );
        expect(
          Directionality.of(
            tester.element(find.byType(LanguageSelectionScreen)),
          ),
          locale.textDirection,
        );
      });
    }

    testWidgets('saved choice skips the language selector', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AppLocaleRepository.preferenceKey: 'en',
      });
      final controller = AppLocaleController(AppLocaleRepository());
      addTearDown(controller.close);
      await controller.restore();

      await tester.pumpWidget(
        BlocProvider<AppLocaleController>.value(
          value: controller,
          child: MaterialApp(
            locale: controller.state.locale?.locale,
            supportedLocales: AppLocale.supportedLocales,
            localizationsDelegates: _delegates,
            home: controller.state.hasConfirmedChoice
                ? const Text('authenticated-flow')
                : const LanguageSelectionScreen(),
          ),
        ),
      );

      expect(find.text('authenticated-flow'), findsOneWidget);
      expect(find.byType(LanguageSelectionScreen), findsNothing);
    });

    testWidgets('fits a 360px screen with moderate text scaling', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final controller = await _selectionRequiredController();
      addTearDown(controller.close);

      await tester.pumpWidget(
        _dynamicLocaleApp(controller, const LanguageSelectionScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectionScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('settings language picker', () {
    testWidgets('separates app language from customer menu language', (
      tester,
    ) async {
      const menuLanguageKey = 'fixture.business.menu_language';
      SharedPreferences.setMockInitialValues(<String, Object>{
        AppLocaleRepository.preferenceKey: 'ar',
        menuLanguageKey: 'ar',
      });
      final controller = AppLocaleController(AppLocaleRepository());
      addTearDown(controller.close);
      await controller.restore();

      await tester.pumpWidget(
        _dynamicLocaleApp(controller, const _SettingsLanguageSurface()),
      );
      await tester.pumpAndSettle();

      expect(find.text('لغة التطبيق'), findsOneWidget);
      expect(find.text('لغة منيو الزبائن'), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(controller.state.locale, AppLocale.english);
      expect(find.text('App language'), findsOneWidget);
      expect(find.text('Customer menu language'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(AppLanguagePicker))),
        TextDirection.ltr,
      );
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(menuLanguageKey), 'ar');
    });
  });

  group('public menu QR truth', () {
    testWidgets('invalid or local URL never renders a decorative QR', (
      tester,
    ) async {
      await tester.pumpWidget(
        _staticLocaleApp(
          const Locale('ar'),
          const QRPreviewCard(publicUrl: 'http://localhost:3001/m/demo'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsNothing);
      expect(
        find.byKey(const ValueKey('confirmed-public-menu-qr')),
        findsNothing,
      );
      expect(find.text('QR المنيو العام غير متاح'), findsOneWidget);
    });

    testWidgets('confirmed HTTPS URL is the exact generated QR value', (
      tester,
    ) async {
      const confirmedUrl = 'https://menu.example.test/m/fixture';
      await tester.pumpWidget(
        _staticLocaleApp(
          const Locale('en'),
          const QRPreviewCard(publicUrl: confirmedUrl),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('confirmed-public-menu-qr')),
        findsOneWidget,
      );
      expect(find.text(confirmedUrl), findsOneWidget);
    });

    test('URL confirmation accepts HTTPS only', () {
      expect(
        confirmedPublicMenuUrl('https://menu.example.test/m/fixture'),
        'https://menu.example.test/m/fixture',
      );
      expect(
        confirmedPublicMenuUrl('http://menu.example.test/m/fixture'),
        isNull,
      );
      expect(confirmedPublicMenuUrl('https://localhost/m/fixture'), isNull);
      expect(confirmedPublicMenuUrl('not-a-url'), isNull);
    });
  });
}

const _delegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  ckbMaterialLocalizationsDelegate,
  GlobalMaterialLocalizations.delegate,
  ckbCupertinoLocalizationsDelegate,
  GlobalCupertinoLocalizations.delegate,
  ckbWidgetsLocalizationsDelegate,
  GlobalWidgetsLocalizations.delegate,
];

Future<AppLocaleController> _selectionRequiredController() async {
  final controller = AppLocaleController(AppLocaleRepository());
  await controller.restore();
  return controller;
}

Widget _dynamicLocaleApp(AppLocaleController controller, Widget home) {
  return BlocProvider<AppLocaleController>.value(
    value: controller,
    child: BlocBuilder<AppLocaleController, AppLocaleState>(
      builder: (context, state) {
        return MaterialApp(
          locale: state.locale?.locale ?? AppLocale.arabic.locale,
          supportedLocales: AppLocale.supportedLocales,
          localizationsDelegates: _delegates,
          home: home,
        );
      },
    ),
  );
}

Widget _staticLocaleApp(Locale locale, Widget home) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocale.supportedLocales,
    localizationsDelegates: _delegates,
    home: Scaffold(body: home),
  );
}

class _SettingsLanguageSurface extends StatelessWidget {
  const _SettingsLanguageSurface();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const AppLanguagePicker(),
          Text(AppLocalizations.of(context).menuLanguage),
        ],
      ),
    );
  }
}
