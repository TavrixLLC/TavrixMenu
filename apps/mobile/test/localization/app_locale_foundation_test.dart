import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tavrix_menu_mobile/core/localization/app_locale.dart';
import 'package:tavrix_menu_mobile/core/localization/app_locale_controller.dart';
import 'package:tavrix_menu_mobile/core/localization/app_locale_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('supported application locales', () {
    test('supports exactly Arabic, Sorani Kurdish, and English', () {
      expect(AppLocale.values, <AppLocale>[
        AppLocale.arabic,
        AppLocale.sorani,
        AppLocale.english,
      ]);
      expect(
        AppLocale.supportedLocales.map((locale) => locale.languageCode),
        <String>['ar', 'ckb', 'en'],
      );
    });

    test('uses RTL for Arabic and Sorani and LTR for English', () {
      expect(AppLocale.arabic.textDirection, TextDirection.rtl);
      expect(AppLocale.sorani.textDirection, TextDirection.rtl);
      expect(AppLocale.english.textDirection, TextDirection.ltr);
    });

    test('rejects unsupported locale codes instead of aliasing them', () {
      expect(AppLocale.fromLanguageCode('fa'), isNull);
      expect(AppLocale.fromLanguageCode('ku'), isNull);
      expect(AppLocale.fromLanguageCode('fr'), isNull);
      expect(AppLocale.fromLanguageCode(null), isNull);
      expect(AppLocale.suggestedFromDevice(const Locale('fa')), isNull);
    });

    test('uses native, unreversed language names', () {
      expect(AppLocale.arabic.nativeName, 'العربية');
      expect(AppLocale.sorani.nativeName, 'کوردی / سۆرانی');
      expect(AppLocale.english.nativeName, 'English');
    });
  });

  group('locale persistence', () {
    test('missing choice requires explicit first-launch selection', () async {
      final controller = AppLocaleController(AppLocaleRepository());
      addTearDown(controller.close);

      await controller.restore();

      expect(controller.state.status, AppLocaleStatus.selectionRequired);
      expect(controller.state.locale, isNull);
      expect(controller.state.hasConfirmedChoice, isFalse);
    });

    test('saved choice restores before the authenticated flow', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AppLocaleRepository.preferenceKey: 'ckb',
      });
      final controller = AppLocaleController(AppLocaleRepository());
      addTearDown(controller.close);

      await controller.restore();

      expect(controller.state.status, AppLocaleStatus.ready);
      expect(controller.state.locale, AppLocale.sorani);
      expect(controller.state.hasConfirmedChoice, isTrue);
    });

    test('unsupported persisted locale is removed safely', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AppLocaleRepository.preferenceKey: 'fa',
      });
      final repository = AppLocaleRepository();

      expect(await repository.read(), isNull);

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.containsKey(AppLocaleRepository.preferenceKey),
        isFalse,
      );
    });

    test('selection persists and survives controller restart', () async {
      final first = AppLocaleController(AppLocaleRepository());
      await first.restore();
      expect(await first.select(AppLocale.english), isTrue);
      await first.close();

      final restored = AppLocaleController(AppLocaleRepository());
      addTearDown(restored.close);
      await restored.restore();

      expect(restored.state.locale, AppLocale.english);
      expect(restored.state.status, AppLocaleStatus.ready);
    });

    test('selection changes only the device app-locale preference', () async {
      const businessMenuLanguageKey = 'fixture.business.menu_language';
      const workspaceIdentityKey = 'fixture.workspace.identity';
      SharedPreferences.setMockInitialValues(<String, Object>{
        businessMenuLanguageKey: 'ar',
        workspaceIdentityKey: 'workspace-a',
      });
      final controller = AppLocaleController(AppLocaleRepository());
      addTearDown(controller.close);
      await controller.restore();

      expect(await controller.select(AppLocale.sorani), isTrue);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(businessMenuLanguageKey), 'ar');
      expect(preferences.getString(workspaceIdentityKey), 'workspace-a');
      expect(
        preferences.getString(AppLocaleRepository.preferenceKey),
        AppLocale.sorani.languageCode,
      );
    });

    test('locale state contains no account or workspace identity', () {
      const state = AppLocaleState(
        status: AppLocaleStatus.ready,
        locale: AppLocale.arabic,
      );

      expect(state.props, <Object?>[
        AppLocaleStatus.ready,
        AppLocale.arabic,
        false,
        false,
      ]);
      expect(AppLocaleRepository.preferenceKey, 'waflo.app_locale.v1');
    });

    test('persistence failure does not confirm a missing choice', () async {
      final controller = AppLocaleController(
        AppLocaleRepository(loadPreferences: () => throw StateError('closed')),
      );
      addTearDown(controller.close);
      await controller.restore();

      expect(await controller.select(AppLocale.arabic), isFalse);
      expect(controller.state.status, AppLocaleStatus.selectionRequired);
      expect(controller.state.locale, isNull);
      expect(controller.state.persistenceFailed, isTrue);
    });
  });

  group('ARB resources', () {
    late Map<String, dynamic> english;
    late Map<String, dynamic> arabic;
    late Map<String, dynamic> sorani;

    setUpAll(() {
      english = _readArb('lib/l10n/app_en.arb');
      arabic = _readArb('lib/l10n/app_ar.arb');
      sorani = _readArb('lib/l10n/app_ckb.arb');
    });

    test('all locales contain the same message keys', () {
      final englishKeys = _messageKeys(english);
      expect(_messageKeys(arabic), englishKeys);
      expect(_messageKeys(sorani), englishKeys);
      expect(englishKeys.length, greaterThanOrEqualTo(400));
    });

    test('production messages are non-empty and never equal their key', () {
      for (final resource in <Map<String, dynamic>>[english, arabic, sorani]) {
        for (final key in _messageKeys(resource)) {
          final value = resource[key];
          expect(value, isA<String>(), reason: key);
          expect((value as String).trim(), isNotEmpty, reason: key);
          expect(value.trim(), isNot(key), reason: key);
        }
      }
    });

    test('placeholder names match across all locales', () {
      for (final key in _messageKeys(english)) {
        final expected = _placeholderNames(english[key] as String);
        expect(_placeholderNames(arabic[key] as String), expected, reason: key);
        expect(_placeholderNames(sorani[key] as String), expected, reason: key);
      }
    });

    test('template placeholders are typed and documented', () {
      for (final key in _messageKeys(english)) {
        final placeholders = _placeholderNames(english[key] as String);
        if (placeholders.isEmpty) {
          continue;
        }
        final metadata = english['@$key'] as Map<String, dynamic>?;
        expect(metadata, isNotNull, reason: key);
        final definitions = metadata?['placeholders'] as Map<String, dynamic>?;
        expect(definitions?.keys.toSet(), placeholders, reason: key);
        for (final placeholder in placeholders) {
          final definition = definitions?[placeholder] as Map<String, dynamic>?;
          expect(definition?['type'], isNotEmpty, reason: '$key.$placeholder');
          expect(
            definition?['description'],
            isNotEmpty,
            reason: '$key.$placeholder',
          );
        }
      }
    });

    test('reachable screen families have translations in every locale', () {
      const requiredKeys = <String>{
        'appTitle',
        'navHome',
        'navMenu',
        'navScan',
        'navLoyalty',
        'navSettings',
        'homeTitle',
        'menuManagementTitle',
        'addCategory',
        'addProduct',
        'productName',
        'productPrice',
        'staffScannerTitle',
        'loyaltyTitle',
        'restaurantInfo',
        'appLanguage',
        'menuLanguage',
        'loyaltyInactiveTitle',
        'publicMenuQrUnavailableTitle',
        'genericLoading',
        'genericRetry',
        'genericErrorTitle',
      };

      for (final resource in <Map<String, dynamic>>[english, arabic, sorani]) {
        expect(_messageKeys(resource), containsAll(requiredKeys));
        for (final key in requiredKeys) {
          expect((resource[key] as String).trim(), isNotEmpty, reason: key);
        }
      }
    });

    test('generated localization API contains every canonical message', () {
      final generated = File(
        'lib/l10n/generated/app_localizations.dart',
      ).readAsStringSync();
      for (final key in _messageKeys(english)) {
        expect(
          generated.contains(' get $key;') || generated.contains(' $key('),
          isTrue,
          reason: key,
        );
      }
    });
  });
}

Map<String, dynamic> _readArb(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

Set<String> _messageKeys(Map<String, dynamic> resource) {
  return resource.keys.where((key) => !key.startsWith('@')).toSet();
}

Set<String> _placeholderNames(String message) {
  return RegExp(
    r'\{([a-zA-Z_][a-zA-Z0-9_]*)',
  ).allMatches(message).map((match) => match.group(1)!).toSet();
}
