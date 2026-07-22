import 'package:flutter/widgets.dart';

enum AppLocale {
  arabic('ar', 'العربية', TextDirection.rtl),
  sorani('ckb', 'کوردی / سۆرانی', TextDirection.rtl),
  english('en', 'English', TextDirection.ltr);

  const AppLocale(this.languageCode, this.nativeName, this.textDirection);

  final String languageCode;
  final String nativeName;
  final TextDirection textDirection;

  Locale get locale => Locale(languageCode);

  static const supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ckb'),
    Locale('en'),
  ];

  static AppLocale? fromLanguageCode(String? languageCode) {
    final normalized = languageCode?.trim().toLowerCase();
    for (final value in values) {
      if (value.languageCode == normalized) {
        return value;
      }
    }
    return null;
  }

  static AppLocale? suggestedFromDevice(Locale locale) {
    return fromLanguageCode(locale.languageCode);
  }
}
