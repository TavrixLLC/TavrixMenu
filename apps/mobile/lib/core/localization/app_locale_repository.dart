import 'package:shared_preferences/shared_preferences.dart';

import 'app_locale.dart';

typedef SharedPreferencesLoader = Future<SharedPreferences> Function();

class AppLocaleRepository {
  AppLocaleRepository({SharedPreferencesLoader? loadPreferences})
    : _loadPreferences = loadPreferences ?? SharedPreferences.getInstance;

  static const preferenceKey = 'waflo.app_locale.v1';

  final SharedPreferencesLoader _loadPreferences;

  Future<AppLocale?> read() async {
    final preferences = await _loadPreferences();
    final rawValue = preferences.getString(preferenceKey);
    final locale = AppLocale.fromLanguageCode(rawValue);
    if (rawValue != null && locale == null) {
      await preferences.remove(preferenceKey);
    }
    return locale;
  }

  Future<bool> write(AppLocale locale) async {
    final preferences = await _loadPreferences();
    return preferences.setString(preferenceKey, locale.languageCode);
  }
}
