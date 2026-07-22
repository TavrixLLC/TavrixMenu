import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

extension AppLocalizationsBuildContext on BuildContext {
  AppLocalizations get l10n {
    return Localizations.of<AppLocalizations>(this, AppLocalizations) ??
        lookupAppLocalizations(const Locale('ar'));
  }
}
