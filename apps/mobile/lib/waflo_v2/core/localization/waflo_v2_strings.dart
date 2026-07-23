import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class WafloV2Strings {
  const WafloV2Strings(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ckb'),
    Locale('en'),
  ];

  static const LocalizationsDelegate<WafloV2Strings> delegate =
      _WafloV2StringsDelegate();

  static WafloV2Strings of(BuildContext context) {
    final strings = Localizations.of<WafloV2Strings>(context, WafloV2Strings);
    assert(strings != null, 'WafloV2Strings delegate is missing.');
    return strings!;
  }

  String _value(String key) {
    final language = _values.containsKey(locale.languageCode)
        ? locale.languageCode
        : 'en';
    return _values[language]![key] ?? _values['en']![key] ?? key;
  }

  String get appName => _value('appName');
  String get foundationPreview => _value('foundationPreview');
  String get previewOnly => _value('previewOnly');
  String get workspace => _value('workspace');
  String get branch => _value('branch');
  String get owner => _value('owner');
  String get manager => _value('manager');
  String get staff => _value('staff');
  String get home => _value('home');
  String get programs => _value('programs');
  String get scan => _value('scan');
  String get customers => _value('customers');
  String get more => _value('more');
  String get myActivity => _value('myActivity');
  String get account => _value('account');
  String get manualCustomerSearch => _value('manualCustomerSearch');
  String get manualCustomerSearchBody => _value('manualCustomerSearchBody');
  String get foundationReady => _value('foundationReady');
  String get foundationReadyBody => _value('foundationReadyBody');
  String get activeProgram => _value('activeProgram');
  String get activeProgramBody => _value('activeProgramBody');
  String get oneActivePolicy => _value('oneActivePolicy');
  String get branchAccess => _value('branchAccess');
  String get branchAccessBody => _value('branchAccessBody');
  String get loadingTitle => _value('loadingTitle');
  String get loadingBody => _value('loadingBody');
  String get emptyTitle => _value('emptyTitle');
  String get emptyBody => _value('emptyBody');
  String get errorTitle => _value('errorTitle');
  String get errorBody => _value('errorBody');
  String get offlineTitle => _value('offlineTitle');
  String get offlineBody => _value('offlineBody');
  String get forbiddenTitle => _value('forbiddenTitle');
  String get forbiddenBody => _value('forbiddenBody');
  String get disabledTitle => _value('disabledTitle');
  String get disabledBody => _value('disabledBody');
  String get staleTitle => _value('staleTitle');
  String get staleBody => _value('staleBody');
  String get confirmedTitle => _value('confirmedTitle');
  String get confirmedBody => _value('confirmedBody');
  String get draftTitle => _value('draftTitle');
  String get draftBody => _value('draftBody');
  String get retry => _value('retry');
  String get unavailableAction => _value('unavailableAction');
  String get cardStudio => _value('cardStudio');
  String get cardStudioBody => _value('cardStudioBody');
  String get baseDesign => _value('baseDesign');
  String get brand => _value('brand');
  String get texts => _value('texts');
  String get cardShape => _value('cardShape');
  String get stampShape => _value('stampShape');
  String get stampIcon => _value('stampIcon');
  String get rewardIcon => _value('rewardIcon');
  String get logo => _value('logo');
  String get cover => _value('cover');
  String get rewardImage => _value('rewardImage');
  String get notUploaded => _value('notUploaded');
  String get localMediaPreview => _value('localMediaPreview');
  String get confirmedMedia => _value('confirmedMedia');
  String get joinHeadline => _value('joinHeadline');
  String get joinDescription => _value('joinDescription');
  String get rewardLabel => _value('rewardLabel');
  String get softRounded => _value('softRounded');
  String get roundedCard => _value('roundedCard');
  String get roundedSquare => _value('roundedSquare');
  String get circle => _value('circle');
  String get star => _value('star');
  String get customIcon => _value('customIcon');
  String get coffeeIcon => _value('coffeeIcon');
  String get giftIcon => _value('giftIcon');
  String get serviceIcon => _value('serviceIcon');
  String get fieldPreviewOnly => _value('fieldPreviewOnly');
  String get colors => _value('colors');
  String get earningVisual => _value('earningVisual');
  String get rewards => _value('rewards');
  String get joinPage => _value('joinPage');
  String get poster => _value('poster');
  String get wallet => _value('wallet');
  String get review => _value('review');
  String get previousStep => _value('previousStep');
  String get nextStep => _value('nextStep');
  String get scrollStepsHint => _value('scrollStepsHint');
  String stepProgress(int current, int total) => _value(
    'stepProgress',
  ).replaceAll('{current}', '$current').replaceAll('{total}', '$total');
  String get primaryColor => _value('primaryColor');
  String get secondaryColor => _value('secondaryColor');
  String get accentColor => _value('accentColor');
  String get backgroundColor => _value('backgroundColor');
  String get textColor => _value('textColor');
  String get appleWallet => _value('appleWallet');
  String get googleWallet => _value('googleWallet');
  String get webCard => _value('webCard');
  String get compactWafloCardPreview => _value('compactWafloCardPreview');
  String get providerPreview => _value('providerPreview');
  String get exactWafloPreview => _value('exactWafloPreview');
  String get platformApproximation => _value('platformApproximation');
  String get previewUnavailable => _value('previewUnavailable');
  String get previewUnavailableBody => _value('previewUnavailableBody');
  String get notDeviceVerified => _value('notDeviceVerified');
  String get pointsBalance => _value('pointsBalance');
  String get memberId => _value('memberId');
  String get nextReward => _value('nextReward');
  String get qrUnavailable => _value('qrUnavailable');
  String get qrUnavailableBody => _value('qrUnavailableBody');
  String get publishingDisabled => _value('publishingDisabled');
  String get publishingDisabledBody => _value('publishingDisabledBody');
  String get accessibleContrast => _value('accessibleContrast');
  String get inaccessibleContrast => _value('inaccessibleContrast');
  String get presentationOnly => _value('presentationOnly');
  String get seasonalDeferred => _value('seasonalDeferred');
  String get seasonalDeferredBody => _value('seasonalDeferredBody');
  String get selectWorkspace => _value('selectWorkspace');
  String get selectWorkspaceBody => _value('selectWorkspaceBody');
  String get noAccess => _value('noAccess');
  String get noAccessBody => _value('noAccessBody');

  static const Map<String, Map<String, String>> _values = {
    'ar': {
      'appName': 'Waflo V2',
      'foundationPreview': 'معاينة أساس المرحلة الأولى',
      'previewOnly': 'معاينة محلية فقط — لا حفظ أو نشر',
      'workspace': 'النشاط الحالي',
      'branch': 'الفرع',
      'owner': 'المالك',
      'manager': 'المدير',
      'staff': 'الموظف',
      'home': 'الرئيسية',
      'programs': 'برامج الولاء',
      'scan': 'المسح',
      'customers': 'الزبائن',
      'more': 'المزيد',
      'myActivity': 'نشاطي',
      'account': 'الحساب',
      'manualCustomerSearch': 'البحث اليدوي عن الزبون',
      'manualCustomerSearchBody':
          'خيار احتياطي داخل المسح فقط، ولا يُعرض كتبويب مستقل.',
      'foundationReady': 'أساس واضح للخطوات التالية',
      'foundationReadyBody':
          'هذه واجهة مراجعة معزولة. لا تتصل بعمليات الولاء أو بيانات الإنتاج.',
      'activeProgram': 'البرنامج النشط',
      'activeProgramBody':
          'يدعم العرض برنامجاً منشوراً واحداً وعدة مسودات أو برامج مؤرشفة.',
      'oneActivePolicy': 'برنامج نشط واحد في V1',
      'branchAccess': 'نطاق الفروع',
      'branchAccessBody':
          'تظهر الفروع المسموحة فقط، ويجب على الخادم إعادة التحقق من الصلاحية.',
      'loadingTitle': 'جارٍ تحميل البيانات',
      'loadingBody': 'لن نعرض أرقاماً أو بيانات قديمة أثناء الانتظار.',
      'emptyTitle': 'لا توجد بيانات بعد',
      'emptyBody': 'اكتمل الطلب بنجاح ولم يُرجع أي سجلات.',
      'errorTitle': 'تعذر تحميل البيانات',
      'errorBody': 'حصل خطأ آمن. أعد المحاولة دون اعتبار النتيجة فارغة.',
      'offlineTitle': 'أنت غير متصل',
      'offlineBody': 'القراءة فقط متاحة. عمليات القيمة تحتاج تأكيد الخادم.',
      'forbiddenTitle': 'لا تملك الصلاحية',
      'forbiddenBody': 'يتطلب هذا الإجراء دوراً أو نطاق فرع مختلفاً.',
      'disabledTitle': 'الإجراء غير متاح',
      'disabledBody': 'هذه الخطوة غير مرتبطة بالخادم في المرحلة الأولى.',
      'staleTitle': 'بيانات محفوظة مؤقتاً',
      'staleBody': 'قديمة وموسومة بوضوح حتى ينجح التحديث.',
      'confirmedTitle': 'تم التأكيد من الخادم',
      'confirmedBody': 'يظهر النجاح فقط بعد نتيجة مؤكدة.',
      'draftTitle': 'مسودة غير منشورة',
      'draftBody': 'التغييرات المحلية ليست حفظاً أو نشراً.',
      'retry': 'إعادة المحاولة',
      'unavailableAction': 'غير متاح في المرحلة الأولى',
      'cardStudio': 'استوديو تخصيص البطاقة',
      'cardStudioBody':
          'خصّص العرض بصورة مستقلة عن الأرصدة وقواعد الكسب والمكافآت.',
      'baseDesign': 'التصميم الأساسي',
      'brand': 'الهوية',
      'texts': 'النصوص',
      'cardShape': 'شكل البطاقة',
      'stampShape': 'شكل الطابع',
      'stampIcon': 'أيقونة الطابع',
      'rewardIcon': 'أيقونة المكافأة',
      'logo': 'الشعار',
      'cover': 'صورة الغلاف',
      'rewardImage': 'صورة المكافأة',
      'notUploaded': 'لم تُرفع بعد',
      'localMediaPreview': 'معاينة محلية غير محفوظة',
      'confirmedMedia': 'وسائط مؤكدة من الخادم',
      'joinHeadline': 'عنوان الانضمام',
      'joinDescription': 'وصف الانضمام',
      'rewardLabel': 'اسم المكافأة',
      'softRounded': 'حواف ناعمة',
      'roundedCard': 'بطاقة مستديرة',
      'roundedSquare': 'مربع مستدير',
      'circle': 'دائرة',
      'star': 'نجمة',
      'customIcon': 'أيقونة مخصصة',
      'coffeeIcon': 'كوب قهوة',
      'giftIcon': 'هدية',
      'serviceIcon': 'خدمة',
      'fieldPreviewOnly': 'للمعاينة فقط',
      'colors': 'الألوان',
      'earningVisual': 'شكل الكسب',
      'rewards': 'المكافآت',
      'joinPage': 'صفحة الانضمام',
      'poster': 'البوستر',
      'wallet': 'المحفظة',
      'review': 'المراجعة',
      'previousStep': 'السابق',
      'nextStep': 'التالي',
      'scrollStepsHint': 'اسحب أفقياً لاستعراض الخطوات',
      'stepProgress': 'الخطوة {current} من {total}',
      'primaryColor': 'اللون الأساسي',
      'secondaryColor': 'اللون الثانوي',
      'accentColor': 'لون الإبراز',
      'backgroundColor': 'لون الخلفية',
      'textColor': 'لون النص',
      'appleWallet': 'Apple Wallet',
      'googleWallet': 'Google Wallet',
      'webCard': 'بطاقة Waflo',
      'compactWafloCardPreview': 'معاينة مدمجة لبطاقة Waflo',
      'providerPreview': 'معاينة تقريبية لمزوّد الخدمة',
      'exactWafloPreview': 'معاينة Waflo دقيقة وحتمية',
      'platformApproximation': 'تقريب لمنصة التشغيل',
      'previewUnavailable': 'المعاينة غير متاحة',
      'previewUnavailableBody':
          'هذه المنصة غير متاحة ضمن قدرة المعاينة الحالية.',
      'notDeviceVerified': 'لم تُختبر على جهاز حقيقي',
      'pointsBalance': 'رصيد النقاط',
      'memberId': 'رقم العضوية',
      'nextReward': 'المكافأة التالية',
      'qrUnavailable': 'QR غير متاح في هذه المعاينة',
      'qrUnavailableBody': 'يظهر فقط بعد رابط مؤكد وآمن من الخادم.',
      'publishingDisabled': 'الحفظ والنشر متوقفان',
      'publishingDisabledBody': 'لا توجد خدمة Backend مرتبطة بهذه المعاينة.',
      'accessibleContrast': 'تباين قابل للوصول',
      'inaccessibleContrast': 'التباين يحتاج تصحيحاً',
      'presentationOnly': 'تغييرات بصرية فقط',
      'seasonalDeferred': 'الثيمات الموسمية ضمن V1.5',
      'seasonalDeferredBody':
          'العقود موجودة، لكن لا توجد جدولة أو تفعيل تلقائي هنا.',
      'selectWorkspace': 'اختر النشاط',
      'selectWorkspaceBody': 'يلزم اختيار صريح عند وجود أكثر من نشاط.',
      'noAccess': 'لا يوجد نشاط متاح',
      'noAccessBody': 'لم تُرجع العضويات الموثوقة أي نشاط مسموح.',
    },
    'ckb': {
      'appName': 'Waflo V2',
      'foundationPreview': 'پێشبینینی بنەمای قۆناغی یەکەم',
      'previewOnly': 'تەنها پێشبینینی ناوخۆییە — پاشەکەوت یان بڵاوناکرێتەوە',
      'workspace': 'کارگەی چالاک',
      'branch': 'لق',
      'owner': 'خاوەن',
      'manager': 'بەڕێوەبەر',
      'staff': 'کارمەند',
      'home': 'سەرەکی',
      'programs': 'بەرنامەکانی دڵسۆزی',
      'scan': 'سکان',
      'customers': 'کڕیارەکان',
      'more': 'زیاتر',
      'myActivity': 'چالاکییەکانم',
      'account': 'هەژمار',
      'manualCustomerSearch': 'گەڕانی دەستی بۆ کڕیار',
      'manualCustomerSearchBody':
          'تەنها هەڵبژاردەیەکی جێگرەوەیە لە ناو سکان، نە تابێکی سەرەکی.',
      'foundationReady': 'بنەمایەکی ڕوون بۆ هەنگاوەکانی داهاتوو',
      'foundationReadyBody':
          'ئەمە ڕووکاری پێداچوونەوەیەکی جیاکراوەیە و بە کردارەکانی دڵسۆزی یان داتای بەرهەمهێنان نەبەستراوە.',
      'activeProgram': 'بەرنامەی چالاک',
      'activeProgramBody':
          'پیشاندان پشتگیری لە یەک بەرنامەی بڵاوکراوە و چەند ڕەشنووس یان ئەرشیفکراو دەکات.',
      'oneActivePolicy': 'یەک بەرنامەی چالاک لە V1',
      'branchAccess': 'سنووری لقەکان',
      'branchAccessBody':
          'تەنها لقە ڕێگەپێدراوەکان دەردەکەون و ڕاژەکار دەبێت دەسەڵات دووبارە بپشکنێت.',
      'loadingTitle': 'داتا بار دەکرێت',
      'loadingBody': 'لە کاتی چاوەڕوانیدا ژمارە یان داتای کۆن نیشان نادرێت.',
      'emptyTitle': 'هێشتا هیچ داتایەک نییە',
      'emptyBody': 'داواکارییەکە سەرکەوتوو بوو بەڵام هیچ تۆمارێکی نەگەڕاندەوە.',
      'errorTitle': 'بارکردنی داتا سەرکەوتوو نەبوو',
      'errorBody': 'هەڵەیەکی پارێزراو ڕوویدا؛ ئەنجامەکە بە بەتاڵی مەژمێرە.',
      'offlineTitle': 'ئۆفلاینیت',
      'offlineBody':
          'تەنها خوێندنەوە بەردەستە؛ کردارەکانی نرخ پێویستیان بە پشتڕاستکردنەوەی ڕاژەکارە.',
      'forbiddenTitle': 'دەسەڵاتت نییە',
      'forbiddenBody': 'ئەم کردارە پێویستی بە ڕۆڵ یان سنووری لقێکی جیاوازە.',
      'disabledTitle': 'کردارەکە بەردەست نییە',
      'disabledBody': 'ئەم هەنگاوە لە قۆناغی یەکەم بە ڕاژەکار نەبەستراوە.',
      'staleTitle': 'داتای کاتی',
      'staleBody':
          'داتاکە کۆنە و بە ڕوونی نیشانەکراوە تا نوێکردنەوە سەرکەوتوو دەبێت.',
      'confirmedTitle': 'لە ڕاژەکارەوە پشتڕاستکرایەوە',
      'confirmedBody': 'سەرکەوتن تەنها دوای ئەنجامی پشتڕاستکراوە نیشان دەدرێت.',
      'draftTitle': 'ڕەشنووسی بڵاونەکراوە',
      'draftBody': 'گۆڕانکاری ناوخۆیی پاشەکەوتکردن یان بڵاوکردنەوە نییە.',
      'retry': 'هەوڵدانەوە',
      'unavailableAction': 'لە قۆناغی یەکەم بەردەست نییە',
      'cardStudio': 'ستۆدیۆی تایبەتمەندکردنی کارت',
      'cardStudioBody':
          'پیشاندان بە جیاوازی لە باڵانس و یاساکانی بەدەستهێنان و خەڵات تایبەتمەند بکە.',
      'baseDesign': 'دیزاینی بنەڕەتی',
      'brand': 'ناسنامە',
      'texts': 'دەقەکان',
      'cardShape': 'شێوەی کارت',
      'stampShape': 'شێوەی مۆر',
      'stampIcon': 'ئایکۆنی مۆر',
      'rewardIcon': 'ئایکۆنی خەڵات',
      'logo': 'لۆگۆ',
      'cover': 'وێنەی سەرپۆش',
      'rewardImage': 'وێنەی خەڵات',
      'notUploaded': 'هێشتا بارنەکراوە',
      'localMediaPreview': 'پێشبینینی ناوخۆیی پاشەکەوتنەکراو',
      'confirmedMedia': 'میدیای پشتڕاستکراوەی ڕاژەکار',
      'joinHeadline': 'ناونیشانی بەشداربوون',
      'joinDescription': 'وەسفی بەشداربوون',
      'rewardLabel': 'ناوی خەڵات',
      'softRounded': 'گۆشەی نەرم',
      'roundedCard': 'کارتی خڕ',
      'roundedSquare': 'چوارگۆشەی خڕ',
      'circle': 'بازنە',
      'star': 'ئەستێرە',
      'customIcon': 'ئایکۆنی تایبەت',
      'coffeeIcon': 'کوپێک قاوە',
      'giftIcon': 'دیاری',
      'serviceIcon': 'خزمەتگوزاری',
      'fieldPreviewOnly': 'تەنها بۆ پێشبینین',
      'colors': 'ڕەنگەکان',
      'earningVisual': 'شێوەی بەدەستهێنان',
      'rewards': 'خەڵاتەکان',
      'joinPage': 'پەڕەی بەشداربوون',
      'poster': 'پۆستەر',
      'wallet': 'جزدان',
      'review': 'پێداچوونەوە',
      'previousStep': 'پێشوو',
      'nextStep': 'دواتر',
      'scrollStepsHint': 'بە ئاسۆیی بکێشە بۆ بینینی هەنگاوەکان',
      'stepProgress': 'هەنگاوی {current} لە {total}',
      'primaryColor': 'ڕەنگی سەرەکی',
      'secondaryColor': 'ڕەنگی لاوەکی',
      'accentColor': 'ڕەنگی جەختکردنەوە',
      'backgroundColor': 'ڕەنگی پاشبنەما',
      'textColor': 'ڕەنگی دەق',
      'appleWallet': 'Apple Wallet',
      'googleWallet': 'Google Wallet',
      'webCard': 'کارتی Waflo',
      'compactWafloCardPreview': 'پێشبینینی کورتکراوەی کارتی Waflo',
      'providerPreview': 'پێشبینینی نزیکەی دابینکەر',
      'exactWafloPreview': 'پێشبینینی ورد و دیاریکراوی Waflo',
      'platformApproximation': 'نزیککردنەوەی پلاتفۆرم',
      'previewUnavailable': 'پێشبینینی بەردەست نییە',
      'previewUnavailableBody':
          'ئەم پلاتفۆرمە لە توانای پێشبینینی ئێستادا بەردەست نییە.',
      'notDeviceVerified': 'لەسەر ئامێری ڕاستەقینە تاقینەکراوەتەوە',
      'pointsBalance': 'باڵانسی خاڵ',
      'memberId': 'ژمارەی ئەندامێتی',
      'nextReward': 'خەڵاتی داهاتوو',
      'qrUnavailable': 'QR لەم پێشبینینەدا بەردەست نییە',
      'qrUnavailableBody':
          'تەنها دوای لینکی پارێزراو و پشتڕاستکراوە دەردەکەوێت.',
      'publishingDisabled': 'پاشەکەوت و بڵاوکردنەوە وەستێنراون',
      'publishingDisabledBody':
          'هیچ خزمەتگوزاری Backend بەم پێشبینینە نەبەستراوە.',
      'accessibleContrast': 'کۆنتراستی گونجاو بۆ دەستگەیشتن',
      'inaccessibleContrast': 'کۆنتراست پێویستی بە چاککردنەوەیە',
      'presentationOnly': 'تەنها گۆڕانکاری بینراو',
      'seasonalDeferred': 'ثیمی وەرزی لە V1.5 ـە',
      'seasonalDeferredBody':
          'گرێبەستەکان هەن، بەڵام خشتەکردن یان چالاککردنی خۆکار نییە.',
      'selectWorkspace': 'کارگە هەڵبژێرە',
      'selectWorkspaceBody':
          'کاتێک زیاتر لە یەک کارگە هەیە هەڵبژاردنی ڕوون پێویستە.',
      'noAccess': 'هیچ کارگەیەک بەردەست نییە',
      'noAccessBody':
          'ئەندامێتی متمانەپێکراو هیچ کارگەیەکی ڕێگەپێدراوی نەگەڕاندەوە.',
    },
    'en': {
      'appName': 'Waflo V2',
      'foundationPreview': 'Phase 1 foundation preview',
      'previewOnly': 'Local preview only — no save or publish',
      'workspace': 'Active business',
      'branch': 'Branch',
      'owner': 'Owner',
      'manager': 'Manager',
      'staff': 'Staff',
      'home': 'Home',
      'programs': 'Loyalty programs',
      'scan': 'Scan',
      'customers': 'Customers',
      'more': 'More',
      'myActivity': 'My Activity',
      'account': 'Account',
      'manualCustomerSearch': 'Manual customer search',
      'manualCustomerSearchBody':
          'A fallback inside Scan only, not a separate top-level tab.',
      'foundationReady': 'A clear foundation for what comes next',
      'foundationReadyBody':
          'This is an isolated review surface. It is not connected to loyalty mutations or production data.',
      'activeProgram': 'Active program',
      'activeProgramBody':
          'The presentation supports one published program and multiple draft or archived programs.',
      'oneActivePolicy': 'One active program in V1',
      'branchAccess': 'Branch access',
      'branchAccessBody':
          'Only permitted branches are shown; the server must authorize them again.',
      'loadingTitle': 'Loading data',
      'loadingBody': 'No numbers or stale identity are shown while waiting.',
      'emptyTitle': 'No data yet',
      'emptyBody': 'The request succeeded and returned no records.',
      'errorTitle': 'Could not load data',
      'errorBody': 'A safe error occurred. Retry without treating it as empty.',
      'offlineTitle': 'You are offline',
      'offlineBody':
          'Read-only context is available. Value changes need server confirmation.',
      'forbiddenTitle': 'You do not have access',
      'forbiddenBody': 'This action needs a different role or branch scope.',
      'disabledTitle': 'Action unavailable',
      'disabledBody': 'This step is not connected to the server in Phase 1.',
      'staleTitle': 'Cached information',
      'staleBody': 'It is old and clearly labeled until refresh succeeds.',
      'confirmedTitle': 'Confirmed by the server',
      'confirmedBody': 'Success is shown only after a confirmed result.',
      'draftTitle': 'Unpublished draft',
      'draftBody': 'Local changes are not saved or published.',
      'retry': 'Retry',
      'unavailableAction': 'Unavailable in Phase 1',
      'cardStudio': 'Card Customization Studio',
      'cardStudioBody':
          'Customize presentation independently from balances, earning rules, and rewards.',
      'baseDesign': 'Base design',
      'brand': 'Brand',
      'texts': 'Text',
      'cardShape': 'Card shape',
      'stampShape': 'Stamp shape',
      'stampIcon': 'Stamp icon',
      'rewardIcon': 'Reward icon',
      'logo': 'Logo',
      'cover': 'Cover image',
      'rewardImage': 'Reward image',
      'notUploaded': 'Not uploaded yet',
      'localMediaPreview': 'Unsaved local preview',
      'confirmedMedia': 'Server-confirmed media',
      'joinHeadline': 'Join headline',
      'joinDescription': 'Join description',
      'rewardLabel': 'Reward label',
      'softRounded': 'Soft corners',
      'roundedCard': 'Rounded card',
      'roundedSquare': 'Rounded square',
      'circle': 'Circle',
      'star': 'Star',
      'customIcon': 'Custom icon',
      'coffeeIcon': 'Coffee cup',
      'giftIcon': 'Gift',
      'serviceIcon': 'Service',
      'fieldPreviewOnly': 'Preview only',
      'colors': 'Colors',
      'earningVisual': 'Earning visual',
      'rewards': 'Rewards',
      'joinPage': 'Join page',
      'poster': 'Poster',
      'wallet': 'Wallet',
      'review': 'Review',
      'previousStep': 'Previous',
      'nextStep': 'Next',
      'scrollStepsHint': 'Swipe horizontally to explore steps',
      'stepProgress': 'Step {current} of {total}',
      'primaryColor': 'Primary color',
      'secondaryColor': 'Secondary color',
      'accentColor': 'Accent color',
      'backgroundColor': 'Background color',
      'textColor': 'Text color',
      'appleWallet': 'Apple Wallet',
      'googleWallet': 'Google Wallet',
      'webCard': 'Waflo Card',
      'compactWafloCardPreview': 'Compact Waflo Card preview',
      'providerPreview': 'Approximate provider preview',
      'exactWafloPreview': 'Exact / deterministic Waflo preview',
      'platformApproximation': 'Platform approximation',
      'previewUnavailable': 'Preview unavailable',
      'previewUnavailableBody':
          'This platform is unavailable in the current preview capability.',
      'notDeviceVerified': 'Not verified on a real device',
      'pointsBalance': 'Points balance',
      'memberId': 'Member ID',
      'nextReward': 'Next reward',
      'qrUnavailable': 'QR unavailable in this preview',
      'qrUnavailableBody':
          'It appears only after a secure, server-confirmed link.',
      'publishingDisabled': 'Save and publish are disabled',
      'publishingDisabledBody':
          'No backend service is connected to this preview.',
      'accessibleContrast': 'Accessible contrast',
      'inaccessibleContrast': 'Contrast needs correction',
      'presentationOnly': 'Presentation changes only',
      'seasonalDeferred': 'Seasonal themes are in V1.5',
      'seasonalDeferredBody':
          'Contracts exist, but there is no scheduling or automatic activation here.',
      'selectWorkspace': 'Select a business',
      'selectWorkspaceBody':
          'Explicit selection is required when more than one business is available.',
      'noAccess': 'No business access',
      'noAccessBody':
          'Authoritative memberships returned no permitted business.',
    },
  };
}

extension WafloV2StringsContext on BuildContext {
  WafloV2Strings get wafloV2 => WafloV2Strings.of(this);
}

class _WafloV2StringsDelegate extends LocalizationsDelegate<WafloV2Strings> {
  const _WafloV2StringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return WafloV2Strings.supportedLocales.any(
      (candidate) => candidate.languageCode == locale.languageCode,
    );
  }

  @override
  Future<WafloV2Strings> load(Locale locale) {
    return SynchronousFuture<WafloV2Strings>(WafloV2Strings(locale));
  }

  @override
  bool shouldReload(_WafloV2StringsDelegate old) => false;
}
