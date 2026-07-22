// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Waflo للتجار';

  @override
  String get languageSelectionTitle => 'اختر لغة التطبيق';

  @override
  String get languageSelectionBody =>
      'يمكنك تغييرها لاحقاً من الإعدادات. هذا الاختيار لا يغيّر لغة منيو الزبائن.';

  @override
  String get languageSuggested => 'مقترحة';

  @override
  String get languageContinue => 'متابعة';

  @override
  String get languageSaveFailed => 'تعذر حفظ الاختيار. حاول مرة أخرى.';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get menuLanguage => 'لغة منيو الزبائن';

  @override
  String get appLanguageHelp => 'تغيّر واجهة Waflo على هذا الجهاز فقط.';

  @override
  String get menuLanguageHelp => 'تحدد لغة محتوى المنيو الذي يراه الزبائن.';

  @override
  String get arabicLanguage => 'العربية';

  @override
  String get soraniLanguage => 'الكردية / السورانية';

  @override
  String get englishLanguage => 'الإنجليزية';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navMenu => 'المنيو';

  @override
  String get navScan => 'المسح';

  @override
  String get navLoyalty => 'الولاء';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get workspaceImage => 'صورة مساحة العمل';

  @override
  String unreadNotifications(int count) {
    return '$count إشعارات غير مقروءة';
  }

  @override
  String get genericLoading => 'جارٍ التنفيذ';

  @override
  String get genericErrorTitle => 'يوجد أمر يحتاج انتباهك';

  @override
  String get genericErrorBody => 'تعذر إكمال العملية الآن.';

  @override
  String get genericRetry => 'حاول مرة أخرى';

  @override
  String get genericSave => 'حفظ';

  @override
  String get genericSaving => 'جاري الحفظ';

  @override
  String get genericCancel => 'إلغاء';

  @override
  String get genericClose => 'إغلاق';

  @override
  String get genericDone => 'تم';

  @override
  String get genericSearch => 'بحث';

  @override
  String get genericShowAll => 'عرض الكل';

  @override
  String get genericUnavailable => 'غير متاح';

  @override
  String get genericActive => 'فعّال';

  @override
  String get genericInactive => 'غير فعّال';

  @override
  String get genericAvailable => 'متوفر';

  @override
  String get genericNotAvailable => 'غير متوفر';

  @override
  String get genericReady => 'جاهز';

  @override
  String get genericNotReady => 'غير جاهز';

  @override
  String get workspaceUnavailable => 'تعذر عرض مساحة العمل الآن.';

  @override
  String get authBadge => 'مساحة المطعم';

  @override
  String get authTitle => 'أهلاً بك في Waflo';

  @override
  String get authSubtitle =>
      'جهّز منيو مطعمك والولاء وأدوات الكاشير بخطوات واضحة.';

  @override
  String get authChoiceTitle => 'كيف تريد أن تبدأ؟';

  @override
  String get authChoiceSubtitle =>
      'ادخل إلى مساحة موجودة أو أنشئ مساحة جديدة لمطعمك.';

  @override
  String get signInExistingWorkspace => 'دخول لمساحة موجودة';

  @override
  String get createBusinessWorkspace => 'إنشاء مساحة مطعم';

  @override
  String get signInHeader => 'دخول لمساحة المطعم';

  @override
  String get signUpHeader => 'إنشاء مساحة Waflo للمطعم';

  @override
  String get signInSubtitle => 'اكتب بريد العمل أو رقم الهاتف المرتبط بحسابك.';

  @override
  String get signUpSubtitle =>
      'ابدأ مساحة جديدة للمطعم ببريد العمل أو رقم الهاتف.';

  @override
  String get contactLabel => 'إيميل العمل أو رقم الهاتف';

  @override
  String get contactHint => 'اكتب بيانات الدخول';

  @override
  String get continueLabel => 'استمرار';

  @override
  String get sendingCode => 'جاري إرسال الرمز';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get verifying => 'جاري التحقق';

  @override
  String get verifyAndCreate => 'تحقق وأنشئ المساحة';

  @override
  String get verifyAndSignIn => 'تحقق وادخل';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get changeLogin => 'تغيير بيانات الدخول';

  @override
  String get restoringSession => 'نرجع جلسة العمل';

  @override
  String get checkingBusinessAccess => 'جاري التحقق من صلاحية المطعم';

  @override
  String get signedIn => 'تم تسجيل الدخول';

  @override
  String get confirmBusinessAccess =>
      'نحتاج إلى تأكيد مساحة المطعم المتاحة لهذا الحساب.';

  @override
  String get retryWorkspaceCheck => 'تحقق مرة أخرى';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get appConfigNeedsAttention => 'إعدادات التطبيق تحتاج مراجعة';

  @override
  String get operatorBuildSupport =>
      'تواصل مع فريق Waflo للحصول على نسخة التاجر الصحيحة.';

  @override
  String get testAccess => 'متابعة بحساب اختبار';

  @override
  String get accountNotFoundTitle => 'لم نجد حساباً جاهزاً';

  @override
  String get accountNotFoundBody =>
      'إذا تريد تبدأ مطعماً جديداً، اختر إنشاء مساحة مطعم.';

  @override
  String get authTemporaryErrorTitle => 'تعذر الاستمرار';

  @override
  String get authTemporaryErrorBody => 'حاول مرة أخرى بعد قليل.';

  @override
  String get verificationFailedTitle => 'لم يكتمل التحقق';

  @override
  String get verificationFailedBody => 'تأكد من الرمز وحاول مرة أخرى.';

  @override
  String get needsMoreVerificationTitle => 'نحتاج تحقق إضافي';

  @override
  String get needsMoreVerificationBody =>
      'أكمل خطوة التحقق المطلوبة حتى تستمر.';

  @override
  String get passwordlessSetupTitle => 'تسجيل الحساب يحتاج مساعدة';

  @override
  String get passwordlessSetupBody =>
      'تواصل مع فريق Waflo حتى نكمل إعداد تسجيل الدخول لهذا الحساب.';

  @override
  String get tooManyAttemptsTitle => 'حاول لاحقاً';

  @override
  String get tooManyAttemptsBody =>
      'كانت هناك محاولات كثيرة. انتظر قليلاً ثم اطلب رمزاً جديداً.';

  @override
  String get passwordRequiredStep => 'تحتاج خطوة تحقق إضافية';

  @override
  String get authChoosePathTitle => 'اختر طريقة البدء';

  @override
  String get authChoosePathBody => 'ادخل إلى مساحة موجودة أو أنشئ مساحة مطعم.';

  @override
  String get authMissingIdentifierTitle => 'اكتب بيانات الدخول';

  @override
  String get authMissingIdentifierBody => 'اكتب بريد العمل أو رقم الهاتف.';

  @override
  String get authMissingCodeTitle => 'اكتب رمز التحقق';

  @override
  String get authMissingCodeBody =>
      'اكتب الرمز الذي وصلك على البريد أو الهاتف.';

  @override
  String get authStartAgainTitle => 'ابدأ من جديد';

  @override
  String get authStartAgainBody => 'اطلب رمزاً جديداً قبل المتابعة.';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get dashboardLoadFailedTitle => 'تعذر تحميل الرئيسية';

  @override
  String get dashboardDetailsFailedTitle => 'تعذر تحميل تفاصيل المطعم';

  @override
  String get dashboardHonestDataBody =>
      'لا نعرض أرقاماً تقديرية. حاول مرة أخرى لعرض البيانات المؤكدة.';

  @override
  String get dashboardPartialFailureTitle => 'تعذر تحديث بعض التفاصيل';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get atAGlance => 'لمحة سريعة';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get recentActivityUnavailable => 'النشاط الأخير غير متاح حالياً';

  @override
  String get recentActivityHelp =>
      'سيظهر نشاط المطعم المؤكد هنا عندما يصبح متاحاً.';

  @override
  String get heroStartCategory => 'ابدأ بأول قسم في منيوك';

  @override
  String get heroStartCategoryBody =>
      'رتّب المنيو بإضافة قسم حقيقي، ثم أضف منتجاتك.';

  @override
  String get heroAddProducts => 'خلّ منيوك جاهز للزبائن';

  @override
  String get heroAddProductsBody =>
      'أضف منتجاتك الأولى حتى تراجع المنيو وتشاركه.';

  @override
  String get heroMenuReady => 'منيوك جاهز للمشاركة';

  @override
  String get heroMenuReadyBody =>
      'المنتجات والمنيو العام جاهزان. راجعه قبل المشاركة.';

  @override
  String get heroReviewMenu => 'راجع منيوك قبل مشاركته';

  @override
  String get heroReviewMenuBody =>
      'المنتجات موجودة، لكن المنيو العام غير جاهز للفتح بعد.';

  @override
  String setupProgress(int completed, int total) {
    return '$completed من $total خطوات جاهزة';
  }

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get addFirstProduct => 'إضافة أول منتج';

  @override
  String get manageCategories => 'إدارة الأقسام';

  @override
  String get openMenu => 'فتح المنيو';

  @override
  String get menuPermissionDenied => 'صلاحيتك الحالية لا تسمح بتعديل المنيو.';

  @override
  String get publicMenuNotReady =>
      'يتوفر فتح المنيو بعد تجهيز منتج والرابط العام.';

  @override
  String get createLoyaltyCard => 'إنشاء بطاقة ولاء';

  @override
  String get scanCard => 'مسح بطاقة';

  @override
  String get sendNotification => 'إرسال إشعار';

  @override
  String get permissionUnavailable => 'غير متاح لصلاحيتك الحالية';

  @override
  String get menuPermissionRequired => 'تحتاج إلى صلاحية إدارة المنيو';

  @override
  String get scanPermissionDenied => 'المسح غير متاح لصلاحيتك الحالية';

  @override
  String get customerNotificationsLater => 'يتفعّل عند توفر إشعارات العملاء';

  @override
  String get products => 'المنتجات';

  @override
  String get categories => 'الأقسام';

  @override
  String get loyaltyCards => 'بطاقات الولاء';

  @override
  String get customers => 'الزبائن';

  @override
  String get loyaltyPromotionTitle => 'أعد زبائنك ببرنامج ولاء';

  @override
  String get loyaltyPromotionBody =>
      'افتح قسم الولاء لإعداد البرنامج أو متابعة بطاقات الزبائن.';

  @override
  String get openLoyalty => 'فتح الولاء';

  @override
  String get loyaltyPermissionDenied =>
      'صلاحيتك الحالية لا تسمح بإدارة الولاء.';

  @override
  String get menuManagementTitle => 'إدارة المنيو';

  @override
  String get menuManagementBody => 'أدر الأقسام والمنتجات التي يراها الزبائن.';

  @override
  String get menuLoading => 'جاري تحميل المنيو';

  @override
  String get menuLoadFailed => 'تعذر تحميل المنيو.';

  @override
  String get addCategory => 'إضافة قسم';

  @override
  String get categoryName => 'اسم القسم';

  @override
  String get categoryNameHint => 'مثال: المشروبات الساخنة';

  @override
  String get categoryRequired => 'اكتب اسم القسم.';

  @override
  String get categoryCreated => 'تمت إضافة القسم';

  @override
  String get categoryCreateFailed => 'تعذرت إضافة القسم.';

  @override
  String get activeCategories => 'الأقسام الفعّالة';

  @override
  String get archivedCategories => 'الأقسام المؤرشفة';

  @override
  String get menuItems => 'منتجات المنيو';

  @override
  String get menuStatus => 'حالة المنيو';

  @override
  String get menuAddCategoryHint => 'أضف أول قسم حتى تبدأ بناء منيوك.';

  @override
  String get menuAddProductHint => 'أضف أول منتج حتى يبدأ منيوك بالتكوّن.';

  @override
  String get menuLoadedHint => 'منتجاتك محمّلة من مساحة العمل وجاهزة للإدارة.';

  @override
  String get archivedItems => 'المنتجات المؤرشفة';

  @override
  String get searchProducts => 'ابحث عن منتج';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get noCategoriesTitle => 'ابدأ بأول قسم في منيوك';

  @override
  String get noCategoriesBody => 'أضف قسماً قبل إنشاء أول منتج.';

  @override
  String get noProductsTitle => 'هذا القسم بعده بدون منتجات';

  @override
  String get noProductsBody => 'أضف أول منتج إلى هذا المنيو.';

  @override
  String get noSearchResultsTitle => 'لا توجد منتجات مطابقة';

  @override
  String get noSearchResultsBody => 'جرّب اسماً مختلفاً للمنتج.';

  @override
  String get addCategoryPermissionDenied =>
      'صلاحيتك الحالية لا تسمح بإضافة قسم.';

  @override
  String get addProductPermissionDenied =>
      'صلاحيتك الحالية لا تسمح بإضافة منتج.';

  @override
  String productsInCategory(int count, int available) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتجات في هذا القسم',
      two: 'منتجان في هذا القسم',
      one: 'منتج واحد في هذا القسم',
    );
    return '$_temp0 • $available متوفر';
  }

  @override
  String get availabilityUpdating => 'جاري تحديث التوفر…';

  @override
  String get previewMenuReadyBody => 'افتح الرابط المؤكد الذي سيراه زبائنك.';

  @override
  String get previewMenuUnavailableBody =>
      'تتفعّل المعاينة بعد جاهزية منيو الزبائن.';

  @override
  String get archive => 'أرشفة';

  @override
  String get restore => 'استعادة';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get productDescriptionOptional => 'الوصف (اختياري)';

  @override
  String get productCategory => 'القسم';

  @override
  String get productPrice => 'السعر';

  @override
  String get iqd => 'د.ع';

  @override
  String get productAvailable => 'متوفر للزبائن';

  @override
  String get productUnavailable => 'غير متوفر للزبائن';

  @override
  String get productNameRequired => 'اكتب اسم المنتج.';

  @override
  String get productCategoryRequired => 'اختر قسماً.';

  @override
  String get productPriceRequired => 'اكتب السعر بالدينار العراقي من دون كسور.';

  @override
  String get productPriceInvalid =>
      'اكتب مبلغاً صحيحاً موجباً من دون كسور عشرية.';

  @override
  String get productImageUnavailable =>
      'إضافة صورة للمنتج غير متاحة في هذه المرحلة.';

  @override
  String get leaveChangesTitle => 'ترك التعديلات؟';

  @override
  String get leaveChangesBody => 'ستفقد المعلومات التي أدخلتها.';

  @override
  String get stay => 'البقاء';

  @override
  String get leave => 'مغادرة';

  @override
  String get back => 'رجوع';

  @override
  String get businessSetupTitle => 'جهّز مساحة المطعم';

  @override
  String get businessSetupSubtitle =>
      'نحتاج الأساسيات فقط حتى يفتح Waflo لوحة المطعم والمنيو العام.';

  @override
  String get businessSetupSaved => 'تم حفظ مساحة المطعم';

  @override
  String get businessCreateLoading => 'جاري إنشاء المساحة';

  @override
  String get businessCreateAction => 'إنشاء مساحة المطعم';

  @override
  String get restaurantInfo => 'معلومات المطعم';

  @override
  String get restaurantInfoSubtitle => 'الاسم ونوع النشاط الذي يظهر للفريق.';

  @override
  String get restaurantName => 'اسم المطعم';

  @override
  String get restaurantNameHint => 'مثال: Royal Cup';

  @override
  String get restaurantType => 'نوع النشاط';

  @override
  String get restaurantTypeCafe => 'كافيه';

  @override
  String get restaurantTypeRestaurant => 'مطعم';

  @override
  String get restaurantTypeShop => 'محل / متجر';

  @override
  String get identityAndPhotos => 'الهوية والصور';

  @override
  String get managedPhotosBody =>
      'فريق Waflo يساعدك برفع الشعار وصور المطعم بالبداية. تقدر ترسل الصور للفريق ونرتبها قبل التجربة.';

  @override
  String get locationCurrencyLanguage => 'المدينة والعملة واللغة';

  @override
  String get locationCurrencyLanguageSubtitle =>
      'تحدد هذه الخيارات شكل الأسعار ومحتوى المنيو للزبائن.';

  @override
  String get city => 'المدينة';

  @override
  String get currency => 'العملة';

  @override
  String get currencyIqd => 'الدينار العراقي (IQD)';

  @override
  String get currencyUsd => 'الدولار الأمريكي (USD)';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get contactAndAddress => 'التواصل والعنوان';

  @override
  String get contactAndAddressBody =>
      'سنساعدك في إكمال بيانات التواصل والعنوان أثناء التجهيز حتى لا يرى الزبائن معلومات ناقصة.';

  @override
  String get businessProfileTitle => 'إعدادات المطعم';

  @override
  String get businessProfileLoading => 'جاري تحميل إعدادات المطعم';

  @override
  String get businessProfileMissingTitle => 'مساحة المطعم غير جاهزة';

  @override
  String get businessProfileMissingBody =>
      'أنشئ مساحة مطعم قبل تعديل معلوماتها.';

  @override
  String get businessProfileRestrictedTitle => 'صلاحية محدودة';

  @override
  String get businessProfileRestrictedBody =>
      'صلاحيتك الحالية لا تسمح بتعديل معلومات المطعم.';

  @override
  String get businessProfileEditTitle => 'تعديل معلومات المطعم';

  @override
  String get businessProfileEditSubtitle =>
      'تظهر هذه التفاصيل في مساحة العمل وتساعد في تجهيز منيو الزبائن.';

  @override
  String get businessProfileSaved => 'تم حفظ معلومات المطعم';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get savingChanges => 'جاري حفظ التغييرات';

  @override
  String get optionalLogoLink => 'رابط الشعار اختياري';

  @override
  String get optionalCoverLink => 'رابط الغلاف اختياري';

  @override
  String get optionalImageLinkHint => 'رابط صورة اختياري عند توفره';

  @override
  String get staffScannerTitle => 'امسح كارت الزبون';

  @override
  String get staffScannerLoading => 'جاري تجهيز صلاحية المسح';

  @override
  String get staffScannerLoadFailed => 'تعذر فتح ماسح المطعم.';

  @override
  String get businessWorkspaceNotReady =>
      'مساحة المطعم غير جاهزة للمسح. ارجع إلى الرئيسية وحاول مرة أخرى.';

  @override
  String get staffScannerSectionSubtitle =>
      'تأكد من البطاقة قبل إضافة ختم أو استبدال جائزة.';

  @override
  String get manualCodeTitle => 'إدخال يدوي عند الحاجة';

  @override
  String get manualCodeSubtitle =>
      'استخدمه فقط عندما لا تستطيع الكاميرا قراءة بطاقة الزبون.';

  @override
  String get loyaltyQrCode => 'رمز كارت الولاء';

  @override
  String get loyaltyQrHint => 'اكتب الرمز من بطاقة الزبون';

  @override
  String get loyaltyQrRequired => 'اكتب رمز كارت الزبون حتى نتحقق منه.';

  @override
  String get checkingCard => 'نتحقق من الكارت';

  @override
  String get checkCard => 'تحقق من البطاقة';

  @override
  String get scanAnotherCard => 'امسح بطاقة أخرى';

  @override
  String get cameraScannerTitle => 'ماسح الكاميرا';

  @override
  String get cameraScannerSubtitle =>
      'وجّه الإطار نحو بطاقة الولاء. يتحقق Waflo منها من دون عرض الرمز.';

  @override
  String get enterCodeManually => 'إدخال يدوي';

  @override
  String get cameraPermissionDeniedTitle => 'نحتاج إلى صلاحية الكاميرا';

  @override
  String get cameraUnavailableTitle => 'الكاميرا غير متاحة';

  @override
  String get cameraPermissionDeniedBody =>
      'فعّل صلاحية الكاميرا من إعدادات الجهاز ثم حاول مرة أخرى.';

  @override
  String get cameraUnsupportedBody =>
      'لا يدعم هذا الجهاز المسح بالكاميرا. استخدم الإدخال اليدوي بدلاً منه.';

  @override
  String get cameraStartFailedBody =>
      'تعذر فتح الكاميرا. حاول مرة أخرى أو استخدم الإدخال اليدوي.';

  @override
  String get openSettings => 'افتح الإعدادات';

  @override
  String get tryCameraAgain => 'حاول بالكاميرا مرة ثانية';

  @override
  String get scannerReady => 'جاهز للمسح';

  @override
  String get openWalletScanner => 'فتح الكاميرا';

  @override
  String get scannerBusy => 'جاري المسح';

  @override
  String get scannerPrivacy =>
      'امسح البطاقة من شاشة الزبون. لا تحتاج إلى كتابة الرمز.';

  @override
  String get cardNotAccepted => 'لم تُقبل بطاقة الزبون';

  @override
  String get retryCapturedCard => 'حاول مرة أخرى أو امسح بطاقة الزبون من جديد.';

  @override
  String get scanAgain => 'المسح من جديد';

  @override
  String get invalidQr =>
      'كارت الولاء غير صالح أو منتهي. اطلب من الزبون فتح آخر كارت وامسحه من جديد.';

  @override
  String get wrongBusiness =>
      'هذه البطاقة لا تخص هذا المطعم، أو صلاحيتك لا تسمح بمسحها.';

  @override
  String get cardFound => 'تم العثور على البطاقة';

  @override
  String get cardFoundSubtitle => 'تأكد من الزبون والتقدم قبل إضافة ختم.';

  @override
  String get privateCustomerDetails =>
      'تم اختصار تفاصيل الزبون حفاظاً على الخصوصية.';

  @override
  String get phoneEnding => 'آخر أرقام الهاتف';

  @override
  String get rewardReadySuffix => 'جاهزة للاستبدال.';

  @override
  String get rewardNotReadySuffix => 'غير جاهزة بعد.';

  @override
  String get rewardAvailable => 'الجائزة جاهزة';

  @override
  String get readyToAddStamp => 'جاهز لإضافة ختم';

  @override
  String get stampRecorded => 'تم تسجيل ختم لهذا المسح من قبل.';

  @override
  String get rewardAvailableGuidance =>
      'الجائزة جاهزة. اتبع إجراء المطعم قبل إضافة ختم آخر.';

  @override
  String get addOneStamp => 'أضف ختماً واحداً بعد تأكيد زيارة الزبون.';

  @override
  String get addingStamp => 'نضيف الختم...';

  @override
  String get addStamp => 'إضافة ختم';

  @override
  String get stampSuccess =>
      'تمت إضافة الختم. الكارت المباشر تحدّث، وApple Wallet أو Google Wallet قد يتزامن بعد قليل.';

  @override
  String get loyaltyTitle => 'الولاء';

  @override
  String get loyaltyLoading => 'جاري تحميل الولاء';

  @override
  String get loyaltyLoadFailed => 'تعذر تحميل الولاء الآن.';

  @override
  String get loyaltySetupNeeded => 'يجب تجهيز المطعم قبل استخدام الولاء.';

  @override
  String get loyaltyInactiveTitle => 'برنامج الولاء غير فعّال';

  @override
  String get loyaltyInactiveBody =>
      'جهّز برنامج ولاء حقيقياً وفعّله قبل مشاركة التسجيل مع الزبائن.';

  @override
  String get loyaltyEnrollmentUnavailableTitle => 'رابط التسجيل غير متاح';

  @override
  String get loyaltyEnrollmentUnavailableBody =>
      'لا يوجد رابط تسجيل فعّال لهذا المطعم.';

  @override
  String get loyaltyAdvancedWebStudio =>
      'يبقى إعداد الولاء المتقدم مُداراً من Web Studio.';

  @override
  String get programName => 'اسم البرنامج';

  @override
  String get stampGoal => 'هدف الأختام';

  @override
  String get rewardName => 'اسم الجائزة';

  @override
  String get description => 'الوصف';

  @override
  String get rewardDescription => 'وصف الجائزة';

  @override
  String get terms => 'الشروط';

  @override
  String get editProgram => 'تعديل البرنامج';

  @override
  String get setUpStampCard => 'إعداد بطاقة الأختام';

  @override
  String get viewOnlyProgramAccess => 'صلاحية عرض البرنامج فقط';

  @override
  String get enrollCustomer => 'تسجيل زبون';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get customerName => 'اسم الزبون';

  @override
  String get count => 'العدد';

  @override
  String get reason => 'السبب';

  @override
  String get redeemReward => 'استبدال الجائزة';

  @override
  String get redeemRewardQuestion => 'هل تريد استبدال الجائزة؟';

  @override
  String get memberships => 'بطاقات الزبائن';

  @override
  String get membershipHelp => 'اختر زبوناً لفتح بطاقة الأختام.';

  @override
  String get searchMembers => 'ابحث برقم الهاتف أو البريد أو الاسم';

  @override
  String get rewardReady => 'الجائزة جاهزة';

  @override
  String get selectMembership => 'اختر بطاقة زبون';

  @override
  String get actions => 'الإجراءات';

  @override
  String get recentTransactions => 'العمليات الأخيرة';

  @override
  String get noTransactionsTitle => 'لا توجد عمليات بعد';

  @override
  String get noTransactionsBody =>
      'ستظهر هنا الأختام واستبدالات الجوائز المؤكدة.';

  @override
  String progressTowardReward(int percent, String reward) {
    return '$percent% باتجاه $reward';
  }

  @override
  String get loyaltyEnrollmentTitle => 'تسجيل الزبائن';

  @override
  String get loyaltyEnrollmentHelp =>
      'شارك هذا الرابط المؤكد مع الزبائن الراغبين في التسجيل.';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String get shareLink => 'مشاركة الرابط';

  @override
  String get linkCopied => 'تم نسخ رابط التسجيل';

  @override
  String get sharingUnavailableCopied =>
      'المشاركة غير متاحة. تم نسخ رابط التسجيل.';

  @override
  String get menuAppearanceTitle => 'شكل المنيو';

  @override
  String get menuAppearanceLoading => 'جاري تحميل أشكال المنيو';

  @override
  String get menuAppearanceLoadFailed => 'تعذر تحميل أشكال المنيو.';

  @override
  String get menuAppearanceEmpty => 'لا توجد أشكال منيو متاحة الآن.';

  @override
  String get publicMenuDesign => 'تصميم المنيو العام';

  @override
  String get publicMenuDesignSubtitle =>
      'اختر شكلاً يناسب المطعم. المعاينة لا تحفظ التغيير.';

  @override
  String get previewDraftMenu =>
      'المعاينة تفتح منيو QR بشكل مؤقت حتى تشوفه مثل الزبون، بدون حفظ التغيير.';

  @override
  String get previewCouldNotOpen => 'تعذر فتح المعاينة.';

  @override
  String get previewUnavailable =>
      'المعاينة تحتاج رابط منيو عام جاهز لهذا المطعم.';

  @override
  String get previewAction => 'معاينة';

  @override
  String get selectTemplate => 'اختيار';

  @override
  String get selectedTemplate => 'مختار';

  @override
  String get currentTemplate => 'الحالي';

  @override
  String get saveTemplate => 'حفظ الشكل';

  @override
  String get savingTemplate => 'جاري حفظ الشكل';

  @override
  String get menuAppearanceSaved => 'تم حفظ شكل المنيو';

  @override
  String get menuAppearancePermission =>
      'صلاحيتك الحالية لا تسمح بتغيير شكل المنيو.';

  @override
  String get publicMenuQrTitle => 'QR المنيو العام';

  @override
  String get publicMenuQrLoading => 'جاري تحميل رابط المنيو العام المؤكد';

  @override
  String get publicMenuQrUnavailableTitle => 'QR المنيو العام غير متاح';

  @override
  String get publicMenuQrUnavailableBody =>
      'يظهر QR فقط بعد أن يؤكد Waflo رابط منيو عام آمناً.';

  @override
  String get copyPublicMenuLink => 'نسخ رابط المنيو العام';

  @override
  String get sharePublicMenu => 'مشاركة المنيو العام';

  @override
  String get publicMenuLinkCopied => 'تم نسخ رابط المنيو العام';

  @override
  String get businessSetupStep => 'معلومات المطعم';

  @override
  String get businessSetupIntro => 'ابدأ بتفاصيل المطعم التي يحتاجها فريقك.';

  @override
  String get chooseMenuStyle => 'اختر شكل المنيو';

  @override
  String get chooseMenuStyleBody =>
      'عاين اتجاهاً بصرياً الآن. يمكنك تغييره لاحقاً.';

  @override
  String get firstCategory => 'أضف أول قسم للمنيو';

  @override
  String get firstCategoryBody =>
      'استخدم قسماً حقيقياً مثل الأطباق الرئيسية أو المشروبات.';

  @override
  String get firstProduct => 'أضف أول منتج';

  @override
  String get firstProductBody => 'أضف منتجاً حقيقياً وسعراً صحيحاً بالدينار.';

  @override
  String get previewCustomerMenu => 'معاينة منيو الزبائن';

  @override
  String get previewCustomerMenuBody =>
      'راجع معلومات المنيو المؤكدة قبل مشاركته.';

  @override
  String get qrNotActiveYet => 'مشاركة QR غير فعّالة بعد';

  @override
  String get qrNotActiveYetBody =>
      'سيعرض Waflo المشاركة فقط بعد تأكيد رابط منيو عام حقيقي.';

  @override
  String get startNow => 'ابدأ الآن';

  @override
  String get saveAndContinue => 'حفظ ومتابعة';

  @override
  String get skipForNow => 'التخطي الآن';

  @override
  String get finishSetup => 'الانتقال إلى الرئيسية';

  @override
  String get loyaltyWorkspaceBody => 'أدر نشاط بطاقات الأختام المؤكد للمطعم.';

  @override
  String get loyaltyStatusNote => 'حالة الولاء';

  @override
  String get loyaltyProgramSaved => 'تم حفظ برنامج الولاء.';

  @override
  String get loyaltyProgramUpdated => 'تم تحديث برنامج الولاء.';

  @override
  String get loyaltyOperationCompleted => 'تم تحديث نشاط الولاء.';

  @override
  String get setUpLoyaltyProgram => 'إعداد برنامج الولاء';

  @override
  String get programNameRequired => 'أدخل اسم البرنامج.';

  @override
  String get stampGoalInvalid => 'اختر هدف أختام من 1 إلى 50.';

  @override
  String get rewardNameRequired => 'أدخل اسم الجائزة.';

  @override
  String get contactRequired => 'أدخل رقم هاتف أو بريداً إلكترونياً.';

  @override
  String get addStampTitle => 'إضافة ختم';

  @override
  String get addAction => 'إضافة';

  @override
  String get redeemConfirmBody =>
      'تأكد من تقديم الجائزة الآن. سيعود عدد الأختام إلى صفر.';

  @override
  String get noActiveLoyaltyProgram => 'لا يوجد برنامج ولاء فعّال';

  @override
  String get loyaltySetupOwnerBody =>
      'أنشئ برنامج بطاقة أختام قبل تسجيل الزبائن.';

  @override
  String get loyaltySetupStaffBody =>
      'لم يتم إعداد برنامج بعد. يمكن للمالك أو المدير إعداده.';

  @override
  String programRewardRule(int goal, String reward) {
    return '$goal أختام تفتح جائزة $reward.';
  }

  @override
  String termsValue(String terms) {
    return 'الشروط: $terms';
  }

  @override
  String get viewOnlyProgramBody =>
      'يمكنك عرض البرنامج، لكن صلاحيتك الحالية لا تسمح بتعديله.';

  @override
  String get customerLookup => 'البحث عن زبون';

  @override
  String get noLoyaltyMembers => 'لا يوجد زبائن ولاء بعد';

  @override
  String get noMembershipMatches => 'لا يوجد زبائن مطابقون';

  @override
  String get noLoyaltyMembersBody => 'سجّل زبوناً لإنشاء أول بطاقة أختام.';

  @override
  String get noMembershipMatchesBody =>
      'جرب رقم هاتف أو بريداً إلكترونياً أو اسماً مختلفاً.';

  @override
  String get loyaltyCustomer => 'زبون ولاء';

  @override
  String get noCustomerContact => 'لا توجد وسيلة تواصل محفوظة';

  @override
  String cardStampProgress(int count, int goal, String reward) {
    return '$count/$goal أختام لجائزة $reward';
  }

  @override
  String cardStampCount(int count, int goal) {
    return '$count/$goal أختام';
  }

  @override
  String rewardReadyMessage(String reward) {
    return 'الجائزة جاهزة: $reward. تأكد قبل الاستبدال.';
  }

  @override
  String redeemAvailableAt(int goal) {
    return 'يظهر الاستبدال عند وصول البطاقة إلى $goal أختام.';
  }

  @override
  String get selectMembershipBody =>
      'اختر زبوناً لعرض البطاقة والإجراءات المتاحة.';

  @override
  String get stampAddedTransaction => 'تمت إضافة ختم';

  @override
  String get rewardRedeemedTransaction => 'تم استبدال الجائزة';

  @override
  String get adjustmentTransaction => 'تعديل';

  @override
  String get voidTransaction => 'معاملة ملغاة';

  @override
  String get unknownTransaction => 'معاملة';

  @override
  String positiveStampDelta(int count) {
    return '+$count أختام';
  }

  @override
  String negativeStampDelta(int count) {
    return '$count أختام';
  }

  @override
  String get noStampChange => 'لا تغيير في الأختام';

  @override
  String get phoneOrEmailHint => 'رقم الهاتف أو البريد الإلكتروني';

  @override
  String get customerNameHint => 'اسم الزبون';

  @override
  String get stampReasonHint => 'ملاحظة الشراء (اختياري)';

  @override
  String get redeemReasonHint => 'ملاحظة الاستبدال (اختياري)';

  @override
  String loyaltyEnrollmentShareText(String url) {
    return 'انضم إلى برنامج الولاء: $url';
  }

  @override
  String wizardStep(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get onboardingWelcomeTitle => 'أهلاً بك في Waflo';

  @override
  String get onboardingWelcomeBody =>
      'لنجهز مطعمك ومنيو الزبائن خطوة مؤكدة بعد أخرى.';

  @override
  String get businessType => 'نوع النشاط';

  @override
  String get chooseStyleLater => 'الاختيار لاحقاً';

  @override
  String get productImagesUnavailableTitle => 'صور المنتجات غير مفعّلة حالياً';

  @override
  String get productImagesUnavailableBody =>
      'هذا الإصدار لا يرفع صور المنتجات. تابع بالأسماء والأسعار الحقيقية الآن.';

  @override
  String get setupCompleteTitle => 'بدأت إعداد مطعمك';

  @override
  String get setupCompleteBody => 'أكمل الخطوات المؤكدة المتبقية من الرئيسية.';

  @override
  String get continueAction => 'متابعة';

  @override
  String get templateWafloWarm => 'دافئ ومريح';

  @override
  String get templateCoffeehousePremium => 'كافيه أنيق';

  @override
  String get templateStreetBites => 'أكل شارع جريء';

  @override
  String get templateMinimalModern => 'بسيط وحديث';

  @override
  String get templateLuxuryDining => 'مطعم راقٍ';

  @override
  String get templateArtisanCafe => 'كافيه حرفي';

  @override
  String get templateQuickServeBold => 'خدمة سريعة';

  @override
  String get authPartialConfigNotice =>
      'تسجيل الدخول متاح، لكن بعض الخدمات قد تحتاج نسخة الطيار الصحيحة.';

  @override
  String get termsLink => 'الشروط';

  @override
  String get privacyLink => 'الخصوصية';

  @override
  String get consentPrefix => 'بالمتابعة أنت توافق على ';

  @override
  String get consentJoin => ' و ';
}
