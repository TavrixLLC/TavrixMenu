import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../core/localization/ckb_framework_localizations.dart';
import '../../l10n/generated/app_localizations.dart';
import '../core/localization/waflo_v2_strings.dart';
import '../core/theme/waflo_theme.dart';

/// Isolated host for Phase 1 review and widget tests.
///
/// It is deliberately not wired into the Legacy application bootstrap.
class WafloV2FoundationApp extends StatelessWidget {
  const WafloV2FoundationApp({
    required this.locale,
    required this.home,
    super.key,
  });

  final Locale locale;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        WafloV2Strings.delegate,
        AppLocalizations.delegate,
        ckbMaterialLocalizationsDelegate,
        ckbWidgetsLocalizationsDelegate,
        ckbCupertinoLocalizationsDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: WafloTheme.light(locale),
      home: home,
    );
  }
}
