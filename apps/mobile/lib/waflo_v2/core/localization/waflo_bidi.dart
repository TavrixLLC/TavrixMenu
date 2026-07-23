import 'package:flutter/widgets.dart';

abstract final class WafloBidi {
  static const String _leftToRightIsolate = '\u2066';
  static const String _popDirectionalIsolate = '\u2069';

  static bool isRtl(Locale locale) {
    return locale.languageCode == 'ar' || locale.languageCode == 'ckb';
  }

  static TextDirection directionFor(Locale locale) {
    return isRtl(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Keeps phone numbers, money, IDs, and codes readable inside RTL copy.
  static String isolateLtr(String value) {
    return '$_leftToRightIsolate$value$_popDirectionalIsolate';
  }
}
