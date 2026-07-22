import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

const ckbMaterialLocalizationsDelegate = _CkbMaterialDelegate();
const ckbWidgetsLocalizationsDelegate = _CkbWidgetsDelegate();
const ckbCupertinoLocalizationsDelegate = _CkbCupertinoDelegate();

class _CkbMaterialDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _CkbMaterialDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(
      CkbMaterialLocalizations(
        fullYearFormat: intl.DateFormat('y'),
        compactDateFormat: intl.DateFormat('y/MM/dd'),
        shortDateFormat: intl.DateFormat('dd/MM/y'),
        mediumDateFormat: intl.DateFormat('dd MMM y'),
        longDateFormat: intl.DateFormat('EEEE، dd MMMM y'),
        yearMonthFormat: intl.DateFormat('MMMM y'),
        shortMonthDayFormat: intl.DateFormat('dd MMM'),
        decimalFormat: intl.NumberFormat.decimalPattern(),
        twoDigitZeroPaddedFormat: intl.NumberFormat('00'),
      ),
    );
  }

  @override
  bool shouldReload(_CkbMaterialDelegate old) => false;
}

class _CkbWidgetsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const _CkbWidgetsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    return SynchronousFuture<WidgetsLocalizations>(
      const CkbWidgetsLocalizations(),
    );
  }

  @override
  bool shouldReload(_CkbWidgetsDelegate old) => false;
}

class _CkbCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CkbCupertinoDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(
      CkbCupertinoLocalizations(
        fullYearFormat: intl.DateFormat('y'),
        dayFormat: intl.DateFormat('d'),
        weekdayFormat: intl.DateFormat('EEEE'),
        mediumDateFormat: intl.DateFormat('dd MMM y'),
        singleDigitHourFormat: intl.DateFormat('H'),
        singleDigitMinuteFormat: intl.DateFormat('m'),
        doubleDigitMinuteFormat: intl.DateFormat('mm'),
        singleDigitSecondFormat: intl.DateFormat('s'),
        decimalFormat: intl.NumberFormat.decimalPattern(),
      ),
    );
  }

  @override
  bool shouldReload(_CkbCupertinoDelegate old) => false;
}

class CkbWidgetsLocalizations extends GlobalWidgetsLocalizations {
  const CkbWidgetsLocalizations() : super(TextDirection.rtl);

  @override
  String get reorderItemToStart => 'گواستنەوە بۆ سەرەتا';
  @override
  String get reorderItemToEnd => 'گواستنەوە بۆ کۆتایی';
  @override
  String get reorderItemUp => 'گواستنەوە بۆ سەرەوە';
  @override
  String get reorderItemDown => 'گواستنەوە بۆ خوارەوە';
  @override
  String get reorderItemLeft => 'گواستنەوە بۆ چەپ';
  @override
  String get reorderItemRight => 'گواستنەوە بۆ ڕاست';
  @override
  String get searchResultsFound => 'ئەنجامی گەڕان دۆزرایەوە';
  @override
  String get noResultsFound => 'ئەنجام نەدۆزرایەوە';
  @override
  String get copyButtonLabel => 'لەبەرگرتنەوە';
  @override
  String get cutButtonLabel => 'بڕین';
  @override
  String get pasteButtonLabel => 'لکاندن';
  @override
  String get selectAllButtonLabel => 'هەمووی هەڵبژێرە';
  @override
  String get lookUpButtonLabel => 'گەڕان';
  @override
  String get searchWebButtonLabel => 'گەڕان لە وێب';
  @override
  String get shareButtonLabel => 'هاوبەشکردن';
  @override
  String get radioButtonUnselectedLabel => 'هەڵنەبژێردراو';
}

/// Sorani framework strings implemented directly for `ckb`.
///
/// This is intentionally not derived from Arabic, Persian, or English.
class CkbMaterialLocalizations extends GlobalMaterialLocalizations {
  const CkbMaterialLocalizations({
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  }) : super(localeName: 'ckb');

  @override
  String get aboutListTileTitleRaw => r'دەربارەی "$applicationName"';
  @override
  String get alertDialogLabel => 'ئاگادارکردنەوە';
  @override
  String get anteMeridiemAbbreviation => 'پ.ن';
  @override
  String get backButtonTooltip => 'گەڕانەوە';
  @override
  String get bottomSheetLabel => 'پەڕەی خوارەوە';
  @override
  String get calendarModeButtonLabel => 'گۆڕین بۆ ڕۆژژمێر';
  @override
  String get cancelButtonLabel => 'هەڵوەشاندنەوە';
  @override
  String get clearButtonTooltip => 'سڕینەوەی دەق';
  @override
  String get closeButtonLabel => 'داخستن';
  @override
  String get closeButtonTooltip => 'داخستن';
  @override
  String get collapsedHint => 'فراوانکراو';
  @override
  String get collapsedIconTapHint => 'فراوانکردن';
  @override
  String get continueButtonLabel => 'بەردەوام بە';
  @override
  String get copyButtonLabel => 'لەبەرگرتنەوە';
  @override
  String get currentDateLabel => 'ڕێکەوتی ئەمڕۆ';
  @override
  String get cutButtonLabel => 'بڕین';
  @override
  String get dateHelpText => 'ساڵ/مانگ/ڕۆژ';
  @override
  String get dateInputLabel => 'نووسینی ڕێکەوت';
  @override
  String get dateOutOfRangeLabel => 'ڕێکەوت لە سنوورەکە دەرەوەیە.';
  @override
  String get datePickerHelpText => 'ڕێکەوت هەڵبژێرە';
  @override
  String get dateRangeEndDateSemanticLabelRaw => r'کۆتایی $fullDate';
  @override
  String get dateRangeEndLabel => 'ڕێکەوتی کۆتایی';
  @override
  String get dateRangePickerHelpText => 'ماوەی ڕێکەوت هەڵبژێرە';
  @override
  String get dateRangeStartDateSemanticLabelRaw => r'دەستپێک $fullDate';
  @override
  String get dateRangeStartLabel => 'ڕێکەوتی دەستپێک';
  @override
  String get dateSeparator => '/';
  @override
  String get deleteButtonTooltip => 'سڕینەوە';
  @override
  String get dialModeButtonLabel => 'گۆڕین بۆ کاتژمێری بازنەیی';
  @override
  String get dialogLabel => 'پەنجەرەی گفتوگۆ';
  @override
  String get drawerLabel => 'لیستی ڕێنیشاندەر';
  @override
  String get expandedHint => 'کورتکراو';
  @override
  String get expandedIconTapHint => 'کورتکردنەوە';
  @override
  String get expansionTileCollapsedHint => 'دووجار لێبدە بۆ فراوانکردن';
  @override
  String get expansionTileCollapsedTapHint => 'بۆ وردەکاری زیاتر فراوانی بکە.';
  @override
  String get expansionTileExpandedHint => 'دووجار لێبدە بۆ کورتکردنەوە';
  @override
  String get expansionTileExpandedTapHint => 'کورتکردنەوە';
  @override
  String get firstPageTooltip => 'یەکەم پەڕە';
  @override
  String get hideAccountsLabel => 'شاردنەوەی هەژمارەکان';
  @override
  String get inputDateModeButtonLabel => 'گۆڕین بۆ نووسینی ڕێکەوت';
  @override
  String get inputTimeModeButtonLabel => 'گۆڕین بۆ نووسینی کات';
  @override
  String get invalidDateFormatLabel => 'شێوازی ڕێکەوت نادروستە.';
  @override
  String get invalidDateRangeLabel => 'ماوەی ڕێکەوت نادروستە.';
  @override
  String get invalidTimeLabel => 'کاتێکی دروست بنووسە.';
  @override
  String get keyboardKeyAlt => 'دووەم';
  @override
  String get keyboardKeyAltGraph => 'دووەمی گراف';
  @override
  String get keyboardKeyBackspace => 'سڕینەوە بۆ دواوە';
  @override
  String get keyboardKeyCapsLock => 'قفڵی پیتی گەورە';
  @override
  String get keyboardKeyChannelDown => 'کەناڵی دواتر';
  @override
  String get keyboardKeyChannelUp => 'کەناڵی پێشوو';
  @override
  String get keyboardKeyControl => 'کۆنترۆڵ';
  @override
  String get keyboardKeyDelete => 'سڕینەوە';
  @override
  String get keyboardKeyEject => 'دەرهێنان';
  @override
  String get keyboardKeyEnd => 'کۆتایی';
  @override
  String get keyboardKeyEscape => 'دەربازبوون';
  @override
  String get keyboardKeyFn => 'کردار';
  @override
  String get keyboardKeyHome => 'سەرەکی';
  @override
  String get keyboardKeyInsert => 'دانان';
  @override
  String get keyboardKeyMeta => 'مێتا';
  @override
  String get keyboardKeyMetaMacOs => 'فەرمان';
  @override
  String get keyboardKeyMetaWindows => 'پەنجەرە';
  @override
  String get keyboardKeyNumLock => 'قفڵی ژمارە';
  @override
  String get keyboardKeyNumpad0 => 'ژمارە ٠';
  @override
  String get keyboardKeyNumpad1 => 'ژمارە ١';
  @override
  String get keyboardKeyNumpad2 => 'ژمارە ٢';
  @override
  String get keyboardKeyNumpad3 => 'ژمارە ٣';
  @override
  String get keyboardKeyNumpad4 => 'ژمارە ٤';
  @override
  String get keyboardKeyNumpad5 => 'ژمارە ٥';
  @override
  String get keyboardKeyNumpad6 => 'ژمارە ٦';
  @override
  String get keyboardKeyNumpad7 => 'ژمارە ٧';
  @override
  String get keyboardKeyNumpad8 => 'ژمارە ٨';
  @override
  String get keyboardKeyNumpad9 => 'ژمارە ٩';
  @override
  String get keyboardKeyNumpadAdd => 'زیادکردن +';
  @override
  String get keyboardKeyNumpadComma => 'کۆما ،';
  @override
  String get keyboardKeyNumpadDecimal => 'خاڵ .';
  @override
  String get keyboardKeyNumpadDivide => 'دابەشکردن /';
  @override
  String get keyboardKeyNumpadEnter => 'چوونەژوورەوە';
  @override
  String get keyboardKeyNumpadEqual => 'یەکسان =';
  @override
  String get keyboardKeyNumpadMultiply => 'لێکدان *';
  @override
  String get keyboardKeyNumpadParenLeft => 'کەوانەی چەپ';
  @override
  String get keyboardKeyNumpadParenRight => 'کەوانەی ڕاست';
  @override
  String get keyboardKeyNumpadSubtract => 'کەمکردن -';
  @override
  String get keyboardKeyPageDown => 'پەڕە بۆ خوارەوە';
  @override
  String get keyboardKeyPageUp => 'پەڕە بۆ سەرەوە';
  @override
  String get keyboardKeyPower => 'هێز';
  @override
  String get keyboardKeyPowerOff => 'کوژاندنەوە';
  @override
  String get keyboardKeyPrintScreen => 'وێنەی شاشە';
  @override
  String get keyboardKeyScrollLock => 'قفڵی جوڵان';
  @override
  String get keyboardKeySelect => 'هەڵبژاردن';
  @override
  String get keyboardKeyShift => 'گواستنەوە';
  @override
  String get keyboardKeySpace => 'بۆشایی';
  @override
  String get lastPageTooltip => 'کۆتا پەڕە';
  @override
  String? get licensesPackageDetailTextFew => r'$licenseCount مۆڵەت';
  @override
  String? get licensesPackageDetailTextMany => r'$licenseCount مۆڵەت';
  @override
  String? get licensesPackageDetailTextOne => 'یەک مۆڵەت';
  @override
  String get licensesPackageDetailTextOther => r'$licenseCount مۆڵەت';
  @override
  String? get licensesPackageDetailTextTwo => 'دوو مۆڵەت';
  @override
  String? get licensesPackageDetailTextZero => 'مۆڵەت نییە';
  @override
  String get licensesPageTitle => 'مۆڵەتەکان';
  @override
  String get lookUpButtonLabel => 'گەڕان';
  @override
  String get menuBarMenuLabel => 'لیستی تووڵەکان';
  @override
  String get menuDismissLabel => 'داخستنی لیست';
  @override
  String get modalBarrierDismissLabel => 'داخستن';
  @override
  String get moreButtonTooltip => 'زیاتر';
  @override
  String get nextMonthTooltip => 'مانگی داهاتوو';
  @override
  String get nextPageTooltip => 'پەڕەی داهاتوو';
  @override
  String get okButtonLabel => 'باشە';
  @override
  String get openAppDrawerTooltip => 'کردنەوەی لیستی ڕێنیشاندەر';
  @override
  String get pageRowsInfoTitleRaw => r'$firstRow تا $lastRow لە $rowCount';
  @override
  String get pageRowsInfoTitleApproximateRaw =>
      r'$firstRow تا $lastRow لە نزیکەی $rowCount';
  @override
  String get pasteButtonLabel => 'لکاندن';
  @override
  String get popupMenuLabel => 'لیستی هەڵپەڕیو';
  @override
  String get postMeridiemAbbreviation => 'د.ن';
  @override
  String get previousMonthTooltip => 'مانگی پێشوو';
  @override
  String get previousPageTooltip => 'پەڕەی پێشوو';
  @override
  String get refreshIndicatorSemanticLabel => 'نوێکردنەوە';
  @override
  String? get remainingTextFieldCharacterCountFew =>
      r'$remainingCount پیت ماوە';
  @override
  String? get remainingTextFieldCharacterCountMany =>
      r'$remainingCount پیت ماوە';
  @override
  String? get remainingTextFieldCharacterCountOne => 'یەک پیت ماوە';
  @override
  String get remainingTextFieldCharacterCountOther =>
      r'$remainingCount پیت ماوە';
  @override
  String? get remainingTextFieldCharacterCountTwo => 'دوو پیت ماوە';
  @override
  String? get remainingTextFieldCharacterCountZero => 'هیچ پیتێک نەماوە';
  @override
  String get reorderItemDown => 'گواستنەوە بۆ خوارەوە';
  @override
  String get reorderItemLeft => 'گواستنەوە بۆ چەپ';
  @override
  String get reorderItemRight => 'گواستنەوە بۆ ڕاست';
  @override
  String get reorderItemToEnd => 'گواستنەوە بۆ کۆتایی';
  @override
  String get reorderItemToStart => 'گواستنەوە بۆ سەرەتا';
  @override
  String get reorderItemUp => 'گواستنەوە بۆ سەرەوە';
  @override
  String get rowsPerPageTitle => 'ڕیز لە هەر پەڕەیەک:';
  @override
  String get saveButtonLabel => 'پاشەکەوتکردن';
  @override
  String get scanTextButtonLabel => 'پشکنینی دەق';
  @override
  String get scrimLabel => 'پاشبنەمای تاریک';
  @override
  String get scrimOnTapHintRaw => r'داخستنی "$modalRouteContentName"';
  @override
  ScriptCategory get scriptCategory => ScriptCategory.tall;
  @override
  String get searchFieldLabel => 'گەڕان';
  @override
  String get searchWebButtonLabel => 'گەڕان لە وێب';
  @override
  String get selectAllButtonLabel => 'هەمووی هەڵبژێرە';
  @override
  String get selectYearSemanticsLabel => 'ساڵ هەڵبژێرە';
  @override
  String get selectedDateLabel => 'ڕێکەوتی هەڵبژێردراو';
  @override
  String? get selectedRowCountTitleFew => r'$selectedRowCount دانە هەڵبژێردرا';
  @override
  String? get selectedRowCountTitleMany => r'$selectedRowCount دانە هەڵبژێردرا';
  @override
  String? get selectedRowCountTitleOne => 'یەک دانە هەڵبژێردرا';
  @override
  String get selectedRowCountTitleOther => r'$selectedRowCount دانە هەڵبژێردرا';
  @override
  String? get selectedRowCountTitleTwo => 'دوو دانە هەڵبژێردرا';
  @override
  String? get selectedRowCountTitleZero => 'هیچ دانەیەک هەڵنەبژێردرا';
  @override
  String get shareButtonLabel => 'هاوبەشکردن';
  @override
  String get showAccountsLabel => 'پیشاندانی هەژمارەکان';
  @override
  String get showMenuTooltip => 'پیشاندانی لیست';
  @override
  String get signedInLabel => 'چوونەژوورەوە ئەنجام درا';
  @override
  String get tabLabelRaw => r'تابی $tabIndex لە $tabCount';
  @override
  TimeOfDayFormat get timeOfDayFormatRaw => TimeOfDayFormat.HH_colon_mm;
  @override
  String get timePickerDialHelpText => 'کات هەڵبژێرە';
  @override
  String get timePickerHourLabel => 'کاتژمێر';
  @override
  String get timePickerHourModeAnnouncement => 'کاتژمێر هەڵبژێرە';
  @override
  String get timePickerInputHelpText => 'کات بنووسە';
  @override
  String get timePickerMinuteLabel => 'خولەک';
  @override
  String get timePickerMinuteModeAnnouncement => 'خولەک هەڵبژێرە';
  @override
  String get unspecifiedDate => 'ڕێکەوت';
  @override
  String get unspecifiedDateRange => 'ماوەی ڕێکەوت';
  @override
  String get viewLicensesButtonLabel => 'بینینی مۆڵەتەکان';
}

class CkbCupertinoLocalizations extends GlobalCupertinoLocalizations {
  const CkbCupertinoLocalizations({
    required super.fullYearFormat,
    required super.dayFormat,
    required super.weekdayFormat,
    required super.mediumDateFormat,
    required super.singleDigitHourFormat,
    required super.singleDigitMinuteFormat,
    required super.doubleDigitMinuteFormat,
    required super.singleDigitSecondFormat,
    required super.decimalFormat,
  }) : super(localeName: 'ckb');

  @override
  String get alertDialogLabel => 'ئاگادارکردنەوە';
  @override
  String get anteMeridiemAbbreviation => 'پ.ن';
  @override
  String get backButtonLabel => 'گەڕانەوە';
  @override
  String get cancelButtonLabel => 'هەڵوەشاندنەوە';
  @override
  String get clearButtonLabel => 'سڕینەوە';
  @override
  String get collapsedHint => 'فراوانکراو';
  @override
  String get copyButtonLabel => 'لەبەرگرتنەوە';
  @override
  String get cutButtonLabel => 'بڕین';
  @override
  String get datePickerDateOrderString => 'dmy';
  @override
  String get datePickerDateTimeOrderString => 'date_time_dayPeriod';
  @override
  String? get datePickerHourSemanticsLabelFew => r'$hour کاتژمێر';
  @override
  String? get datePickerHourSemanticsLabelMany => r'$hour کاتژمێر';
  @override
  String? get datePickerHourSemanticsLabelOne => 'یەک کاتژمێر';
  @override
  String get datePickerHourSemanticsLabelOther => r'$hour کاتژمێر';
  @override
  String? get datePickerHourSemanticsLabelTwo => 'دوو کاتژمێر';
  @override
  String? get datePickerHourSemanticsLabelZero => 'سفر کاتژمێر';
  @override
  String? get datePickerMinuteSemanticsLabelFew => r'$minute خولەک';
  @override
  String? get datePickerMinuteSemanticsLabelMany => r'$minute خولەک';
  @override
  String? get datePickerMinuteSemanticsLabelOne => 'یەک خولەک';
  @override
  String get datePickerMinuteSemanticsLabelOther => r'$minute خولەک';
  @override
  String? get datePickerMinuteSemanticsLabelTwo => 'دوو خولەک';
  @override
  String? get datePickerMinuteSemanticsLabelZero => 'سفر خولەک';
  @override
  String get expandedHint => 'کورتکراو';
  @override
  String get expansionTileCollapsedHint => 'دووجار لێبدە بۆ فراوانکردن';
  @override
  String get expansionTileCollapsedTapHint => 'بۆ وردەکاری زیاتر فراوانی بکە.';
  @override
  String get expansionTileExpandedHint => 'دووجار لێبدە بۆ کورتکردنەوە';
  @override
  String get expansionTileExpandedTapHint => 'کورتکردنەوە';
  @override
  String get lookUpButtonLabel => 'گەڕان';
  @override
  String get menuDismissLabel => 'داخستنی لیست';
  @override
  String get modalBarrierDismissLabel => 'داخستن';
  @override
  String get noSpellCheckReplacementsLabel => 'جێگرەوە نەدۆزرایەوە';
  @override
  String get pasteButtonLabel => 'لکاندن';
  @override
  String get postMeridiemAbbreviation => 'د.ن';
  @override
  String get searchTextFieldPlaceholderLabel => 'گەڕان';
  @override
  String get searchWebButtonLabel => 'گەڕان لە وێب';
  @override
  String get selectAllButtonLabel => 'هەمووی هەڵبژێرە';
  @override
  String get shareButtonLabel => 'هاوبەشکردن';
  @override
  String get tabSemanticsLabelRaw => r'تابی $tabIndex لە $tabCount';
  @override
  String? get timerPickerHourLabelFew => 'کاتژمێر';
  @override
  String? get timerPickerHourLabelMany => 'کاتژمێر';
  @override
  String? get timerPickerHourLabelOne => 'کاتژمێر';
  @override
  String get timerPickerHourLabelOther => 'کاتژمێر';
  @override
  String? get timerPickerHourLabelTwo => 'دوو کاتژمێر';
  @override
  String? get timerPickerHourLabelZero => 'کاتژمێر';
  @override
  String? get timerPickerMinuteLabelFew => 'خولەک';
  @override
  String? get timerPickerMinuteLabelMany => 'خولەک';
  @override
  String? get timerPickerMinuteLabelOne => 'خولەک';
  @override
  String get timerPickerMinuteLabelOther => 'خولەک';
  @override
  String? get timerPickerMinuteLabelTwo => 'دوو خولەک';
  @override
  String? get timerPickerMinuteLabelZero => 'خولەک';
  @override
  String? get timerPickerSecondLabelFew => 'چرکە';
  @override
  String? get timerPickerSecondLabelMany => 'چرکە';
  @override
  String? get timerPickerSecondLabelOne => 'چرکە';
  @override
  String get timerPickerSecondLabelOther => 'چرکە';
  @override
  String? get timerPickerSecondLabelTwo => 'دوو چرکە';
  @override
  String? get timerPickerSecondLabelZero => 'چرکە';
  @override
  String get todayLabel => 'ئەمڕۆ';
}
