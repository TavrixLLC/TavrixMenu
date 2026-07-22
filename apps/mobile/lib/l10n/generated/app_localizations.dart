import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ckb.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ckb'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Waflo for business'**
  String get appTitle;

  /// No description provided for @languageSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your app language'**
  String get languageSelectionTitle;

  /// No description provided for @languageSelectionBody.
  ///
  /// In en, this message translates to:
  /// **'You can change this later from Settings. This does not change the language of your customer menu.'**
  String get languageSelectionBody;

  /// No description provided for @languageSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get languageSuggested;

  /// No description provided for @languageContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get languageContinue;

  /// No description provided for @languageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not save that choice. Please try again.'**
  String get languageSaveFailed;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Customer menu language'**
  String get menuLanguage;

  /// No description provided for @appLanguageHelp.
  ///
  /// In en, this message translates to:
  /// **'Changes Waflo controls on this device only.'**
  String get appLanguageHelp;

  /// No description provided for @menuLanguageHelp.
  ///
  /// In en, this message translates to:
  /// **'Controls the language used for customer-facing menu content.'**
  String get menuLanguageHelp;

  /// No description provided for @arabicLanguage.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicLanguage;

  /// No description provided for @soraniLanguage.
  ///
  /// In en, this message translates to:
  /// **'Kurdish / Sorani'**
  String get soraniLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navLoyalty.
  ///
  /// In en, this message translates to:
  /// **'Loyalty'**
  String get navLoyalty;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @workspaceImage.
  ///
  /// In en, this message translates to:
  /// **'Workspace image'**
  String get workspaceImage;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'{count} unread notifications'**
  String unreadNotifications(int count);

  /// No description provided for @genericLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get genericLoading;

  /// No description provided for @genericErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something needs attention'**
  String get genericErrorTitle;

  /// No description provided for @genericErrorBody.
  ///
  /// In en, this message translates to:
  /// **'We could not complete that right now.'**
  String get genericErrorBody;

  /// No description provided for @genericRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get genericRetry;

  /// No description provided for @genericSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get genericSave;

  /// No description provided for @genericSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get genericSaving;

  /// No description provided for @genericCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get genericCancel;

  /// No description provided for @genericClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get genericClose;

  /// No description provided for @genericDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get genericDone;

  /// No description provided for @genericSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get genericSearch;

  /// No description provided for @genericShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get genericShowAll;

  /// No description provided for @genericUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get genericUnavailable;

  /// No description provided for @genericActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get genericActive;

  /// No description provided for @genericInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get genericInactive;

  /// No description provided for @genericAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get genericAvailable;

  /// No description provided for @genericNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get genericNotAvailable;

  /// No description provided for @genericReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get genericReady;

  /// No description provided for @genericNotReady.
  ///
  /// In en, this message translates to:
  /// **'Not ready'**
  String get genericNotReady;

  /// No description provided for @workspaceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We could not display this workspace right now.'**
  String get workspaceUnavailable;

  /// No description provided for @authBadge.
  ///
  /// In en, this message translates to:
  /// **'Restaurant workspace'**
  String get authBadge;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Waflo'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your restaurant menu, loyalty, and cashier tools in clear steps.'**
  String get authSubtitle;

  /// No description provided for @authChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'How would you like to start?'**
  String get authChoiceTitle;

  /// No description provided for @authChoiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to an existing workspace or create one for your restaurant.'**
  String get authChoiceSubtitle;

  /// No description provided for @signInExistingWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Sign in to an existing workspace'**
  String get signInExistingWorkspace;

  /// No description provided for @createBusinessWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create a restaurant workspace'**
  String get createBusinessWorkspace;

  /// No description provided for @signInHeader.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your restaurant workspace'**
  String get signInHeader;

  /// No description provided for @signUpHeader.
  ///
  /// In en, this message translates to:
  /// **'Create a Waflo restaurant workspace'**
  String get signUpHeader;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the work email or phone number linked to your account.'**
  String get signInSubtitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new restaurant workspace with your work email or phone number.'**
  String get signUpSubtitle;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Work email or phone number'**
  String get contactLabel;

  /// No description provided for @contactHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your sign-in details'**
  String get contactHint;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @sendingCode.
  ///
  /// In en, this message translates to:
  /// **'Sending code'**
  String get sendingCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get verifying;

  /// No description provided for @verifyAndCreate.
  ///
  /// In en, this message translates to:
  /// **'Verify and create workspace'**
  String get verifyAndCreate;

  /// No description provided for @verifyAndSignIn.
  ///
  /// In en, this message translates to:
  /// **'Verify and sign in'**
  String get verifyAndSignIn;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @changeLogin.
  ///
  /// In en, this message translates to:
  /// **'Change sign-in details'**
  String get changeLogin;

  /// No description provided for @restoringSession.
  ///
  /// In en, this message translates to:
  /// **'Restoring your session'**
  String get restoringSession;

  /// No description provided for @checkingBusinessAccess.
  ///
  /// In en, this message translates to:
  /// **'Checking restaurant access'**
  String get checkingBusinessAccess;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @confirmBusinessAccess.
  ///
  /// In en, this message translates to:
  /// **'We need to confirm which restaurant workspace is available to this account.'**
  String get confirmBusinessAccess;

  /// No description provided for @retryWorkspaceCheck.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get retryWorkspaceCheck;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @appConfigNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'This app build needs attention'**
  String get appConfigNeedsAttention;

  /// No description provided for @operatorBuildSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact the Waflo team for the correct business app build.'**
  String get operatorBuildSupport;

  /// No description provided for @testAccess.
  ///
  /// In en, this message translates to:
  /// **'Continue with a test account'**
  String get testAccess;

  /// No description provided for @accountNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No existing account found'**
  String get accountNotFoundTitle;

  /// No description provided for @accountNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'To start a new restaurant, choose Create a restaurant workspace.'**
  String get accountNotFoundBody;

  /// No description provided for @authTemporaryErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We could not continue'**
  String get authTemporaryErrorTitle;

  /// No description provided for @authTemporaryErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get authTemporaryErrorBody;

  /// No description provided for @verificationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification was not completed'**
  String get verificationFailedTitle;

  /// No description provided for @verificationFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Check the code and try again.'**
  String get verificationFailedBody;

  /// No description provided for @needsMoreVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'More verification is required'**
  String get needsMoreVerificationTitle;

  /// No description provided for @needsMoreVerificationBody.
  ///
  /// In en, this message translates to:
  /// **'Complete the requested verification step to continue.'**
  String get needsMoreVerificationBody;

  /// No description provided for @passwordlessSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign-in setup needs help'**
  String get passwordlessSetupTitle;

  /// No description provided for @passwordlessSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Contact the Waflo team to finish sign-in setup for this account.'**
  String get passwordlessSetupBody;

  /// No description provided for @tooManyAttemptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Try again later'**
  String get tooManyAttemptsTitle;

  /// No description provided for @tooManyAttemptsBody.
  ///
  /// In en, this message translates to:
  /// **'There were too many attempts. Wait a moment, then request a new code.'**
  String get tooManyAttemptsBody;

  /// No description provided for @passwordRequiredStep.
  ///
  /// In en, this message translates to:
  /// **'An additional verification step is required'**
  String get passwordRequiredStep;

  /// No description provided for @authChoosePathTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how to start'**
  String get authChoosePathTitle;

  /// No description provided for @authChoosePathBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to an existing workspace or create a restaurant workspace.'**
  String get authChoosePathBody;

  /// No description provided for @authMissingIdentifierTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your sign-in details'**
  String get authMissingIdentifierTitle;

  /// No description provided for @authMissingIdentifierBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your work email or phone number.'**
  String get authMissingIdentifierBody;

  /// No description provided for @authMissingCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code'**
  String get authMissingCodeTitle;

  /// No description provided for @authMissingCodeBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to your email or phone.'**
  String get authMissingCodeBody;

  /// No description provided for @authStartAgainTitle.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get authStartAgainTitle;

  /// No description provided for @authStartAgainBody.
  ///
  /// In en, this message translates to:
  /// **'Request a new code before continuing.'**
  String get authStartAgainBody;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @dashboardLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Home could not load'**
  String get dashboardLoadFailedTitle;

  /// No description provided for @dashboardDetailsFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurant details could not load'**
  String get dashboardDetailsFailedTitle;

  /// No description provided for @dashboardHonestDataBody.
  ///
  /// In en, this message translates to:
  /// **'We do not show estimated numbers. Try again to load confirmed data.'**
  String get dashboardHonestDataBody;

  /// No description provided for @dashboardPartialFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Some details could not be refreshed'**
  String get dashboardPartialFailureTitle;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @atAGlance.
  ///
  /// In en, this message translates to:
  /// **'At a glance'**
  String get atAGlance;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @recentActivityUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Recent activity is not available yet'**
  String get recentActivityUnavailable;

  /// No description provided for @recentActivityHelp.
  ///
  /// In en, this message translates to:
  /// **'Confirmed restaurant activity will appear here when it becomes available.'**
  String get recentActivityHelp;

  /// No description provided for @heroStartCategory.
  ///
  /// In en, this message translates to:
  /// **'Start with your first menu category'**
  String get heroStartCategory;

  /// No description provided for @heroStartCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'Organize the menu with a real category, then add your products.'**
  String get heroStartCategoryBody;

  /// No description provided for @heroAddProducts.
  ///
  /// In en, this message translates to:
  /// **'Get your menu ready for customers'**
  String get heroAddProducts;

  /// No description provided for @heroAddProductsBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first products so you can review and share the menu.'**
  String get heroAddProductsBody;

  /// No description provided for @heroMenuReady.
  ///
  /// In en, this message translates to:
  /// **'Your menu is ready to share'**
  String get heroMenuReady;

  /// No description provided for @heroMenuReadyBody.
  ///
  /// In en, this message translates to:
  /// **'The products and public menu are ready. Review it before sharing.'**
  String get heroMenuReadyBody;

  /// No description provided for @heroReviewMenu.
  ///
  /// In en, this message translates to:
  /// **'Review your menu before sharing'**
  String get heroReviewMenu;

  /// No description provided for @heroReviewMenuBody.
  ///
  /// In en, this message translates to:
  /// **'Products exist, but the public menu is not ready to open yet.'**
  String get heroReviewMenuBody;

  /// No description provided for @setupProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} steps ready'**
  String setupProgress(int completed, int total);

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @addFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Add first product'**
  String get addFirstProduct;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategories;

  /// No description provided for @openMenu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get openMenu;

  /// No description provided for @menuPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Your current role cannot edit the menu.'**
  String get menuPermissionDenied;

  /// No description provided for @publicMenuNotReady.
  ///
  /// In en, this message translates to:
  /// **'Opening the menu becomes available after a product and public link are ready.'**
  String get publicMenuNotReady;

  /// No description provided for @createLoyaltyCard.
  ///
  /// In en, this message translates to:
  /// **'Create loyalty card'**
  String get createLoyaltyCard;

  /// No description provided for @scanCard.
  ///
  /// In en, this message translates to:
  /// **'Scan card'**
  String get scanCard;

  /// No description provided for @sendNotification.
  ///
  /// In en, this message translates to:
  /// **'Send notification'**
  String get sendNotification;

  /// No description provided for @permissionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available for your current role'**
  String get permissionUnavailable;

  /// No description provided for @menuPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Menu management permission is required'**
  String get menuPermissionRequired;

  /// No description provided for @scanPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Scanning is not available for your current role'**
  String get scanPermissionDenied;

  /// No description provided for @customerNotificationsLater.
  ///
  /// In en, this message translates to:
  /// **'Available when customer notifications are supported'**
  String get customerNotificationsLater;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @loyaltyCards.
  ///
  /// In en, this message translates to:
  /// **'Loyalty cards'**
  String get loyaltyCards;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @loyaltyPromotionTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring customers back with loyalty'**
  String get loyaltyPromotionTitle;

  /// No description provided for @loyaltyPromotionBody.
  ///
  /// In en, this message translates to:
  /// **'Open Loyalty to set up the program or review customer cards.'**
  String get loyaltyPromotionBody;

  /// No description provided for @openLoyalty.
  ///
  /// In en, this message translates to:
  /// **'Open loyalty'**
  String get openLoyalty;

  /// No description provided for @loyaltyPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Your current role cannot manage loyalty.'**
  String get loyaltyPermissionDenied;

  /// No description provided for @menuManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu management'**
  String get menuManagementTitle;

  /// No description provided for @menuManagementBody.
  ///
  /// In en, this message translates to:
  /// **'Manage categories and products your customers can see.'**
  String get menuManagementBody;

  /// No description provided for @menuLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading menu'**
  String get menuLoading;

  /// No description provided for @menuLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load the menu.'**
  String get menuLoadFailed;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Hot drinks'**
  String get categoryNameHint;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a category name.'**
  String get categoryRequired;

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category added'**
  String get categoryCreated;

  /// No description provided for @categoryCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'The category could not be added.'**
  String get categoryCreateFailed;

  /// No description provided for @activeCategories.
  ///
  /// In en, this message translates to:
  /// **'Active categories'**
  String get activeCategories;

  /// No description provided for @archivedCategories.
  ///
  /// In en, this message translates to:
  /// **'Archived categories'**
  String get archivedCategories;

  /// No description provided for @menuItems.
  ///
  /// In en, this message translates to:
  /// **'Menu items'**
  String get menuItems;

  /// No description provided for @menuStatus.
  ///
  /// In en, this message translates to:
  /// **'Menu status'**
  String get menuStatus;

  /// No description provided for @menuAddCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Add the first category to start building your menu.'**
  String get menuAddCategoryHint;

  /// No description provided for @menuAddProductHint.
  ///
  /// In en, this message translates to:
  /// **'Add the first product to start building your menu.'**
  String get menuAddProductHint;

  /// No description provided for @menuLoadedHint.
  ///
  /// In en, this message translates to:
  /// **'Products are loaded from this workspace and ready to manage.'**
  String get menuLoadedHint;

  /// No description provided for @archivedItems.
  ///
  /// In en, this message translates to:
  /// **'Archived products'**
  String get archivedItems;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchProducts;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesTitle;

  /// No description provided for @noCategoriesBody.
  ///
  /// In en, this message translates to:
  /// **'Add a category before creating your first product.'**
  String get noCategoriesBody;

  /// No description provided for @noProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsTitle;

  /// No description provided for @noProductsBody.
  ///
  /// In en, this message translates to:
  /// **'Add the first product to this menu.'**
  String get noProductsBody;

  /// No description provided for @noSearchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching products'**
  String get noSearchResultsTitle;

  /// No description provided for @noSearchResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different product name.'**
  String get noSearchResultsBody;

  /// No description provided for @addCategoryPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Your current role cannot add a category.'**
  String get addCategoryPermissionDenied;

  /// No description provided for @addProductPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Your current role cannot add a product.'**
  String get addProductPermissionDenied;

  /// No description provided for @productsInCategory.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 product in this category} other{{count} products in this category}} • {available} available'**
  String productsInCategory(int count, int available);

  /// No description provided for @availabilityUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating availability…'**
  String get availabilityUpdating;

  /// No description provided for @previewMenuReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Open the confirmed link your customers will see.'**
  String get previewMenuReadyBody;

  /// No description provided for @previewMenuUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Preview becomes available when the customer menu is ready.'**
  String get previewMenuUnavailableBody;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @productDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get productDescriptionOptional;

  /// No description provided for @productCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productCategory;

  /// No description provided for @productPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productPrice;

  /// No description provided for @iqd.
  ///
  /// In en, this message translates to:
  /// **'IQD'**
  String get iqd;

  /// No description provided for @productAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available to customers'**
  String get productAvailable;

  /// No description provided for @productUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable to customers'**
  String get productUnavailable;

  /// No description provided for @productNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a product name.'**
  String get productNameRequired;

  /// No description provided for @productCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a category.'**
  String get productCategoryRequired;

  /// No description provided for @productPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a price in whole Iraqi dinars.'**
  String get productPriceRequired;

  /// No description provided for @productPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive whole-dinar amount without decimals.'**
  String get productPriceInvalid;

  /// No description provided for @productImageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Adding a product image is not available in this version.'**
  String get productImageUnavailable;

  /// No description provided for @leaveChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave without saving?'**
  String get leaveChangesTitle;

  /// No description provided for @leaveChangesBody.
  ///
  /// In en, this message translates to:
  /// **'The information you entered will be lost.'**
  String get leaveChangesBody;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @businessSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your restaurant workspace'**
  String get businessSetupTitle;

  /// No description provided for @businessSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We only need the basics to open your workspace and public menu.'**
  String get businessSetupSubtitle;

  /// No description provided for @businessSetupSaved.
  ///
  /// In en, this message translates to:
  /// **'Restaurant workspace saved'**
  String get businessSetupSaved;

  /// No description provided for @businessCreateLoading.
  ///
  /// In en, this message translates to:
  /// **'Creating workspace'**
  String get businessCreateLoading;

  /// No description provided for @businessCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create restaurant workspace'**
  String get businessCreateAction;

  /// No description provided for @restaurantInfo.
  ///
  /// In en, this message translates to:
  /// **'Restaurant information'**
  String get restaurantInfo;

  /// No description provided for @restaurantInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The name and business type shown to your team.'**
  String get restaurantInfoSubtitle;

  /// No description provided for @restaurantName.
  ///
  /// In en, this message translates to:
  /// **'Restaurant name'**
  String get restaurantName;

  /// No description provided for @restaurantNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Royal Cup'**
  String get restaurantNameHint;

  /// No description provided for @restaurantType.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get restaurantType;

  /// No description provided for @restaurantTypeCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get restaurantTypeCafe;

  /// No description provided for @restaurantTypeRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurantTypeRestaurant;

  /// No description provided for @restaurantTypeShop.
  ///
  /// In en, this message translates to:
  /// **'Shop / retail'**
  String get restaurantTypeShop;

  /// No description provided for @identityAndPhotos.
  ///
  /// In en, this message translates to:
  /// **'Brand and photos'**
  String get identityAndPhotos;

  /// No description provided for @managedPhotosBody.
  ///
  /// In en, this message translates to:
  /// **'The Waflo team can help prepare your logo and restaurant photos for the pilot.'**
  String get managedPhotosBody;

  /// No description provided for @locationCurrencyLanguage.
  ///
  /// In en, this message translates to:
  /// **'City, currency, and language'**
  String get locationCurrencyLanguage;

  /// No description provided for @locationCurrencyLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These options control how customer prices and menu content appear.'**
  String get locationCurrencyLanguageSubtitle;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currencyIqd.
  ///
  /// In en, this message translates to:
  /// **'Iraqi dinar (IQD)'**
  String get currencyIqd;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'US dollar (USD)'**
  String get currencyUsd;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @contactAndAddress.
  ///
  /// In en, this message translates to:
  /// **'Contact and address'**
  String get contactAndAddress;

  /// No description provided for @contactAndAddressBody.
  ///
  /// In en, this message translates to:
  /// **'We will help complete contact and address details during setup so customers never see incomplete information.'**
  String get contactAndAddressBody;

  /// No description provided for @businessProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurant settings'**
  String get businessProfileTitle;

  /// No description provided for @businessProfileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading restaurant settings'**
  String get businessProfileLoading;

  /// No description provided for @businessProfileMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurant workspace is not ready'**
  String get businessProfileMissingTitle;

  /// No description provided for @businessProfileMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Create a restaurant workspace before editing its information.'**
  String get businessProfileMissingBody;

  /// No description provided for @businessProfileRestrictedTitle.
  ///
  /// In en, this message translates to:
  /// **'Limited permission'**
  String get businessProfileRestrictedTitle;

  /// No description provided for @businessProfileRestrictedBody.
  ///
  /// In en, this message translates to:
  /// **'Your current role cannot edit restaurant information.'**
  String get businessProfileRestrictedBody;

  /// No description provided for @businessProfileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit restaurant information'**
  String get businessProfileEditTitle;

  /// No description provided for @businessProfileEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These details appear in your workspace and help prepare the customer menu.'**
  String get businessProfileEditSubtitle;

  /// No description provided for @businessProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Restaurant information saved'**
  String get businessProfileSaved;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @savingChanges.
  ///
  /// In en, this message translates to:
  /// **'Saving changes'**
  String get savingChanges;

  /// No description provided for @optionalLogoLink.
  ///
  /// In en, this message translates to:
  /// **'Optional logo link'**
  String get optionalLogoLink;

  /// No description provided for @optionalCoverLink.
  ///
  /// In en, this message translates to:
  /// **'Optional cover link'**
  String get optionalCoverLink;

  /// No description provided for @optionalImageLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Optional image link when available'**
  String get optionalImageLinkHint;

  /// No description provided for @staffScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a customer loyalty card'**
  String get staffScannerTitle;

  /// No description provided for @staffScannerLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing scanner access'**
  String get staffScannerLoading;

  /// No description provided for @staffScannerLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not open the restaurant scanner.'**
  String get staffScannerLoadFailed;

  /// No description provided for @businessWorkspaceNotReady.
  ///
  /// In en, this message translates to:
  /// **'This restaurant workspace is not ready for scanning. Return Home and try again.'**
  String get businessWorkspaceNotReady;

  /// No description provided for @staffScannerSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the card before adding a stamp or redeeming a reward.'**
  String get staffScannerSectionSubtitle;

  /// No description provided for @manualCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual entry when needed'**
  String get manualCodeTitle;

  /// No description provided for @manualCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use this only when the camera cannot read the customer card.'**
  String get manualCodeSubtitle;

  /// No description provided for @loyaltyQrCode.
  ///
  /// In en, this message translates to:
  /// **'Loyalty card code'**
  String get loyaltyQrCode;

  /// No description provided for @loyaltyQrHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from the customer card'**
  String get loyaltyQrHint;

  /// No description provided for @loyaltyQrRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the customer card code to continue.'**
  String get loyaltyQrRequired;

  /// No description provided for @checkingCard.
  ///
  /// In en, this message translates to:
  /// **'Checking card'**
  String get checkingCard;

  /// No description provided for @checkCard.
  ///
  /// In en, this message translates to:
  /// **'Check card'**
  String get checkCard;

  /// No description provided for @scanAnotherCard.
  ///
  /// In en, this message translates to:
  /// **'Scan another card'**
  String get scanAnotherCard;

  /// No description provided for @cameraScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera scanner'**
  String get cameraScannerTitle;

  /// No description provided for @cameraScannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Point the frame at the loyalty card. Waflo checks it without displaying the code.'**
  String get cameraScannerSubtitle;

  /// No description provided for @enterCodeManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get enterCodeManually;

  /// No description provided for @cameraPermissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is needed'**
  String get cameraPermissionDeniedTitle;

  /// No description provided for @cameraUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera is unavailable'**
  String get cameraUnavailableTitle;

  /// No description provided for @cameraPermissionDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Enable camera permission in device settings, then try again.'**
  String get cameraPermissionDeniedBody;

  /// No description provided for @cameraUnsupportedBody.
  ///
  /// In en, this message translates to:
  /// **'This device cannot scan with the camera. Use manual entry instead.'**
  String get cameraUnsupportedBody;

  /// No description provided for @cameraStartFailedBody.
  ///
  /// In en, this message translates to:
  /// **'We could not open the camera. Try again or use manual entry.'**
  String get cameraStartFailedBody;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @tryCameraAgain.
  ///
  /// In en, this message translates to:
  /// **'Try camera again'**
  String get tryCameraAgain;

  /// No description provided for @scannerReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan'**
  String get scannerReady;

  /// No description provided for @openWalletScanner.
  ///
  /// In en, this message translates to:
  /// **'Open camera'**
  String get openWalletScanner;

  /// No description provided for @scannerBusy.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get scannerBusy;

  /// No description provided for @scannerPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Scan the card from the customer screen. You do not need to type the code.'**
  String get scannerPrivacy;

  /// No description provided for @cardNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'Customer card was not accepted'**
  String get cardNotAccepted;

  /// No description provided for @retryCapturedCard.
  ///
  /// In en, this message translates to:
  /// **'Try again or scan the customer card again.'**
  String get retryCapturedCard;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get scanAgain;

  /// No description provided for @invalidQr.
  ///
  /// In en, this message translates to:
  /// **'The loyalty card is invalid or expired. Ask the customer to open their latest card and scan it again.'**
  String get invalidQr;

  /// No description provided for @wrongBusiness.
  ///
  /// In en, this message translates to:
  /// **'This card does not belong to this restaurant, or your role cannot scan it.'**
  String get wrongBusiness;

  /// No description provided for @cardFound.
  ///
  /// In en, this message translates to:
  /// **'Card found'**
  String get cardFound;

  /// No description provided for @cardFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the customer and progress before adding a stamp.'**
  String get cardFoundSubtitle;

  /// No description provided for @privateCustomerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer details are shortened for privacy.'**
  String get privateCustomerDetails;

  /// No description provided for @phoneEnding.
  ///
  /// In en, this message translates to:
  /// **'Phone ending'**
  String get phoneEnding;

  /// No description provided for @rewardReadySuffix.
  ///
  /// In en, this message translates to:
  /// **'is ready to redeem.'**
  String get rewardReadySuffix;

  /// No description provided for @rewardNotReadySuffix.
  ///
  /// In en, this message translates to:
  /// **'is not ready yet.'**
  String get rewardNotReadySuffix;

  /// No description provided for @rewardAvailable.
  ///
  /// In en, this message translates to:
  /// **'Reward available'**
  String get rewardAvailable;

  /// No description provided for @readyToAddStamp.
  ///
  /// In en, this message translates to:
  /// **'Ready to add stamp'**
  String get readyToAddStamp;

  /// No description provided for @stampRecorded.
  ///
  /// In en, this message translates to:
  /// **'A stamp was already recorded for this scan.'**
  String get stampRecorded;

  /// No description provided for @rewardAvailableGuidance.
  ///
  /// In en, this message translates to:
  /// **'The reward is ready. Follow the restaurant process before adding another stamp.'**
  String get rewardAvailableGuidance;

  /// No description provided for @addOneStamp.
  ///
  /// In en, this message translates to:
  /// **'Add one stamp after confirming the customer visit.'**
  String get addOneStamp;

  /// No description provided for @addingStamp.
  ///
  /// In en, this message translates to:
  /// **'Adding stamp'**
  String get addingStamp;

  /// No description provided for @addStamp.
  ///
  /// In en, this message translates to:
  /// **'Add stamp'**
  String get addStamp;

  /// No description provided for @stampSuccess.
  ///
  /// In en, this message translates to:
  /// **'Stamp added. The live card is current; Apple Wallet or Google Wallet may sync shortly.'**
  String get stampSuccess;

  /// No description provided for @loyaltyTitle.
  ///
  /// In en, this message translates to:
  /// **'Loyalty'**
  String get loyaltyTitle;

  /// No description provided for @loyaltyLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading loyalty'**
  String get loyaltyLoading;

  /// No description provided for @loyaltyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load loyalty right now.'**
  String get loyaltyLoadFailed;

  /// No description provided for @loyaltySetupNeeded.
  ///
  /// In en, this message translates to:
  /// **'Restaurant setup is required before loyalty can be used.'**
  String get loyaltySetupNeeded;

  /// No description provided for @loyaltyInactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Loyalty is not active'**
  String get loyaltyInactiveTitle;

  /// No description provided for @loyaltyInactiveBody.
  ///
  /// In en, this message translates to:
  /// **'Set up and activate a real loyalty program before sharing enrollment with customers.'**
  String get loyaltyInactiveBody;

  /// No description provided for @loyaltyEnrollmentUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Enrollment link unavailable'**
  String get loyaltyEnrollmentUnavailableTitle;

  /// No description provided for @loyaltyEnrollmentUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'No active enrollment link is available for this restaurant.'**
  String get loyaltyEnrollmentUnavailableBody;

  /// No description provided for @loyaltyAdvancedWebStudio.
  ///
  /// In en, this message translates to:
  /// **'Advanced loyalty setup remains managed through Web Studio.'**
  String get loyaltyAdvancedWebStudio;

  /// No description provided for @programName.
  ///
  /// In en, this message translates to:
  /// **'Program name'**
  String get programName;

  /// No description provided for @stampGoal.
  ///
  /// In en, this message translates to:
  /// **'Stamp goal'**
  String get stampGoal;

  /// No description provided for @rewardName.
  ///
  /// In en, this message translates to:
  /// **'Reward name'**
  String get rewardName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @rewardDescription.
  ///
  /// In en, this message translates to:
  /// **'Reward description'**
  String get rewardDescription;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @editProgram.
  ///
  /// In en, this message translates to:
  /// **'Edit program'**
  String get editProgram;

  /// No description provided for @setUpStampCard.
  ///
  /// In en, this message translates to:
  /// **'Set up stamp card'**
  String get setUpStampCard;

  /// No description provided for @viewOnlyProgramAccess.
  ///
  /// In en, this message translates to:
  /// **'View-only program access'**
  String get viewOnlyProgramAccess;

  /// No description provided for @enrollCustomer.
  ///
  /// In en, this message translates to:
  /// **'Enroll customer'**
  String get enrollCustomer;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get customerName;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @redeemReward.
  ///
  /// In en, this message translates to:
  /// **'Redeem reward'**
  String get redeemReward;

  /// No description provided for @redeemRewardQuestion.
  ///
  /// In en, this message translates to:
  /// **'Redeem this reward?'**
  String get redeemRewardQuestion;

  /// No description provided for @memberships.
  ///
  /// In en, this message translates to:
  /// **'Memberships'**
  String get memberships;

  /// No description provided for @membershipHelp.
  ///
  /// In en, this message translates to:
  /// **'Select a customer to open their stamp card.'**
  String get membershipHelp;

  /// No description provided for @searchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search by phone, email, or name'**
  String get searchMembers;

  /// No description provided for @rewardReady.
  ///
  /// In en, this message translates to:
  /// **'Reward ready'**
  String get rewardReady;

  /// No description provided for @selectMembership.
  ///
  /// In en, this message translates to:
  /// **'Select a membership'**
  String get selectMembership;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @noTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsTitle;

  /// No description provided for @noTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Confirmed stamps and reward redemptions will appear here.'**
  String get noTransactionsBody;

  /// No description provided for @progressTowardReward.
  ///
  /// In en, this message translates to:
  /// **'{percent}% toward {reward}'**
  String progressTowardReward(int percent, String reward);

  /// No description provided for @loyaltyEnrollmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer enrollment'**
  String get loyaltyEnrollmentTitle;

  /// No description provided for @loyaltyEnrollmentHelp.
  ///
  /// In en, this message translates to:
  /// **'Share this confirmed link with customers who want to join.'**
  String get loyaltyEnrollmentHelp;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get shareLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Enrollment link copied'**
  String get linkCopied;

  /// No description provided for @sharingUnavailableCopied.
  ///
  /// In en, this message translates to:
  /// **'Sharing is unavailable. The enrollment link was copied.'**
  String get sharingUnavailableCopied;

  /// No description provided for @menuAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu appearance'**
  String get menuAppearanceTitle;

  /// No description provided for @menuAppearanceLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading menu styles'**
  String get menuAppearanceLoading;

  /// No description provided for @menuAppearanceLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load menu styles.'**
  String get menuAppearanceLoadFailed;

  /// No description provided for @menuAppearanceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No menu styles are available right now.'**
  String get menuAppearanceEmpty;

  /// No description provided for @publicMenuDesign.
  ///
  /// In en, this message translates to:
  /// **'Public menu design'**
  String get publicMenuDesign;

  /// No description provided for @publicMenuDesignSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a style that fits the restaurant. Previewing does not save it.'**
  String get publicMenuDesignSubtitle;

  /// No description provided for @previewDraftMenu.
  ///
  /// In en, this message translates to:
  /// **'Preview opens the QR menu temporarily without saving the change.'**
  String get previewDraftMenu;

  /// No description provided for @previewCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'We could not open the preview.'**
  String get previewCouldNotOpen;

  /// No description provided for @previewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Preview requires a confirmed public menu link.'**
  String get previewUnavailable;

  /// No description provided for @previewAction.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewAction;

  /// No description provided for @selectTemplate.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectTemplate;

  /// No description provided for @selectedTemplate.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selectedTemplate;

  /// No description provided for @currentTemplate.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentTemplate;

  /// No description provided for @saveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save style'**
  String get saveTemplate;

  /// No description provided for @savingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Saving style'**
  String get savingTemplate;

  /// No description provided for @menuAppearanceSaved.
  ///
  /// In en, this message translates to:
  /// **'Menu style saved'**
  String get menuAppearanceSaved;

  /// No description provided for @menuAppearancePermission.
  ///
  /// In en, this message translates to:
  /// **'Your current role cannot change the menu style.'**
  String get menuAppearancePermission;

  /// No description provided for @publicMenuQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Public menu QR'**
  String get publicMenuQrTitle;

  /// No description provided for @publicMenuQrLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading confirmed public menu link'**
  String get publicMenuQrLoading;

  /// No description provided for @publicMenuQrUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Public menu QR is not available'**
  String get publicMenuQrUnavailableTitle;

  /// No description provided for @publicMenuQrUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'A QR can be shown only after Waflo confirms a secure public menu link.'**
  String get publicMenuQrUnavailableBody;

  /// No description provided for @copyPublicMenuLink.
  ///
  /// In en, this message translates to:
  /// **'Copy public menu link'**
  String get copyPublicMenuLink;

  /// No description provided for @sharePublicMenu.
  ///
  /// In en, this message translates to:
  /// **'Share public menu'**
  String get sharePublicMenu;

  /// No description provided for @publicMenuLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Public menu link copied'**
  String get publicMenuLinkCopied;

  /// No description provided for @businessSetupStep.
  ///
  /// In en, this message translates to:
  /// **'Restaurant information'**
  String get businessSetupStep;

  /// No description provided for @businessSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Start with the restaurant details your team needs.'**
  String get businessSetupIntro;

  /// No description provided for @chooseMenuStyle.
  ///
  /// In en, this message translates to:
  /// **'Choose a menu style'**
  String get chooseMenuStyle;

  /// No description provided for @chooseMenuStyleBody.
  ///
  /// In en, this message translates to:
  /// **'Preview a visual direction now. You can change it later.'**
  String get chooseMenuStyleBody;

  /// No description provided for @firstCategory.
  ///
  /// In en, this message translates to:
  /// **'Add your first menu category'**
  String get firstCategory;

  /// No description provided for @firstCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'Use a real category such as Main dishes or Drinks.'**
  String get firstCategoryBody;

  /// No description provided for @firstProduct.
  ///
  /// In en, this message translates to:
  /// **'Add your first product'**
  String get firstProduct;

  /// No description provided for @firstProductBody.
  ///
  /// In en, this message translates to:
  /// **'Add a real product and a whole-dinar price.'**
  String get firstProductBody;

  /// No description provided for @previewCustomerMenu.
  ///
  /// In en, this message translates to:
  /// **'Preview the customer menu'**
  String get previewCustomerMenu;

  /// No description provided for @previewCustomerMenuBody.
  ///
  /// In en, this message translates to:
  /// **'Review confirmed menu information before sharing it.'**
  String get previewCustomerMenuBody;

  /// No description provided for @qrNotActiveYet.
  ///
  /// In en, this message translates to:
  /// **'QR sharing is not active yet'**
  String get qrNotActiveYet;

  /// No description provided for @qrNotActiveYetBody.
  ///
  /// In en, this message translates to:
  /// **'Waflo will show sharing only after a real public menu link is confirmed.'**
  String get qrNotActiveYetBody;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get startNow;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get saveAndContinue;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get finishSetup;

  /// No description provided for @loyaltyWorkspaceBody.
  ///
  /// In en, this message translates to:
  /// **'Manage the restaurant\'s confirmed stamp-card activity.'**
  String get loyaltyWorkspaceBody;

  /// No description provided for @loyaltyStatusNote.
  ///
  /// In en, this message translates to:
  /// **'Loyalty status'**
  String get loyaltyStatusNote;

  /// No description provided for @loyaltyProgramSaved.
  ///
  /// In en, this message translates to:
  /// **'Loyalty program saved.'**
  String get loyaltyProgramSaved;

  /// No description provided for @loyaltyProgramUpdated.
  ///
  /// In en, this message translates to:
  /// **'Loyalty program updated.'**
  String get loyaltyProgramUpdated;

  /// No description provided for @loyaltyOperationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Loyalty activity updated.'**
  String get loyaltyOperationCompleted;

  /// No description provided for @setUpLoyaltyProgram.
  ///
  /// In en, this message translates to:
  /// **'Set up loyalty program'**
  String get setUpLoyaltyProgram;

  /// No description provided for @programNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a program name.'**
  String get programNameRequired;

  /// No description provided for @stampGoalInvalid.
  ///
  /// In en, this message translates to:
  /// **'Choose a stamp goal from 1 to 50.'**
  String get stampGoalInvalid;

  /// No description provided for @rewardNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a reward name.'**
  String get rewardNameRequired;

  /// No description provided for @contactRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number or email.'**
  String get contactRequired;

  /// No description provided for @addStampTitle.
  ///
  /// In en, this message translates to:
  /// **'Add stamp'**
  String get addStampTitle;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @redeemConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm that the reward is being given now. The stamp count will reset to zero.'**
  String get redeemConfirmBody;

  /// No description provided for @noActiveLoyaltyProgram.
  ///
  /// In en, this message translates to:
  /// **'No active loyalty program'**
  String get noActiveLoyaltyProgram;

  /// No description provided for @loyaltySetupOwnerBody.
  ///
  /// In en, this message translates to:
  /// **'Create a stamp-card program before enrolling customers.'**
  String get loyaltySetupOwnerBody;

  /// No description provided for @loyaltySetupStaffBody.
  ///
  /// In en, this message translates to:
  /// **'A program has not been set up yet. An owner or manager can configure it.'**
  String get loyaltySetupStaffBody;

  /// No description provided for @programRewardRule.
  ///
  /// In en, this message translates to:
  /// **'{goal} stamps unlock {reward}.'**
  String programRewardRule(int goal, String reward);

  /// No description provided for @termsValue.
  ///
  /// In en, this message translates to:
  /// **'Terms: {terms}'**
  String termsValue(String terms);

  /// No description provided for @viewOnlyProgramBody.
  ///
  /// In en, this message translates to:
  /// **'You can view this program, but your current role cannot change it.'**
  String get viewOnlyProgramBody;

  /// No description provided for @customerLookup.
  ///
  /// In en, this message translates to:
  /// **'Customer lookup'**
  String get customerLookup;

  /// No description provided for @noLoyaltyMembers.
  ///
  /// In en, this message translates to:
  /// **'No loyalty members yet'**
  String get noLoyaltyMembers;

  /// No description provided for @noMembershipMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching customers'**
  String get noMembershipMatches;

  /// No description provided for @noLoyaltyMembersBody.
  ///
  /// In en, this message translates to:
  /// **'Enroll a customer to create the first stamp-card membership.'**
  String get noLoyaltyMembersBody;

  /// No description provided for @noMembershipMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different phone number, email, or name.'**
  String get noMembershipMatchesBody;

  /// No description provided for @loyaltyCustomer.
  ///
  /// In en, this message translates to:
  /// **'Loyalty customer'**
  String get loyaltyCustomer;

  /// No description provided for @noCustomerContact.
  ///
  /// In en, this message translates to:
  /// **'No customer contact saved'**
  String get noCustomerContact;

  /// No description provided for @cardStampProgress.
  ///
  /// In en, this message translates to:
  /// **'{count}/{goal} stamps for {reward}'**
  String cardStampProgress(int count, int goal, String reward);

  /// No description provided for @cardStampCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/{goal} stamps'**
  String cardStampCount(int count, int goal);

  /// No description provided for @rewardReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Reward ready: {reward}. Confirm before redeeming.'**
  String rewardReadyMessage(String reward);

  /// No description provided for @redeemAvailableAt.
  ///
  /// In en, this message translates to:
  /// **'Redeem becomes available when the card reaches {goal} stamps.'**
  String redeemAvailableAt(int goal);

  /// No description provided for @selectMembershipBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a customer to view the card and available actions.'**
  String get selectMembershipBody;

  /// No description provided for @stampAddedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Stamp added'**
  String get stampAddedTransaction;

  /// No description provided for @rewardRedeemedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Reward redeemed'**
  String get rewardRedeemedTransaction;

  /// No description provided for @adjustmentTransaction.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get adjustmentTransaction;

  /// No description provided for @voidTransaction.
  ///
  /// In en, this message translates to:
  /// **'Voided transaction'**
  String get voidTransaction;

  /// No description provided for @unknownTransaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get unknownTransaction;

  /// No description provided for @positiveStampDelta.
  ///
  /// In en, this message translates to:
  /// **'+{count} stamps'**
  String positiveStampDelta(int count);

  /// No description provided for @negativeStampDelta.
  ///
  /// In en, this message translates to:
  /// **'{count} stamps'**
  String negativeStampDelta(int count);

  /// No description provided for @noStampChange.
  ///
  /// In en, this message translates to:
  /// **'No stamp change'**
  String get noStampChange;

  /// No description provided for @phoneOrEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number or email'**
  String get phoneOrEmailHint;

  /// No description provided for @customerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get customerNameHint;

  /// No description provided for @stampReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Purchase note (optional)'**
  String get stampReasonHint;

  /// No description provided for @redeemReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Redemption note (optional)'**
  String get redeemReasonHint;

  /// No description provided for @loyaltyEnrollmentShareText.
  ///
  /// In en, this message translates to:
  /// **'Join our loyalty program: {url}'**
  String loyaltyEnrollmentShareText(String url);

  /// No description provided for @wizardStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String wizardStep(int current, int total);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Waflo'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Let\'s prepare your restaurant and its customer menu one confirmed step at a time.'**
  String get onboardingWelcomeBody;

  /// No description provided for @businessType.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get businessType;

  /// No description provided for @chooseStyleLater.
  ///
  /// In en, this message translates to:
  /// **'Choose later'**
  String get chooseStyleLater;

  /// No description provided for @productImagesUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Product images are not available yet'**
  String get productImagesUnavailableTitle;

  /// No description provided for @productImagesUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This version does not upload product images. Continue with real names and prices for now.'**
  String get productImagesUnavailableBody;

  /// No description provided for @setupCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Your restaurant setup has started'**
  String get setupCompleteTitle;

  /// No description provided for @setupCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Continue the remaining confirmed steps from Home.'**
  String get setupCompleteBody;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @templateWafloWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm and welcoming'**
  String get templateWafloWarm;

  /// No description provided for @templateCoffeehousePremium.
  ///
  /// In en, this message translates to:
  /// **'Elegant coffeehouse'**
  String get templateCoffeehousePremium;

  /// No description provided for @templateStreetBites.
  ///
  /// In en, this message translates to:
  /// **'Bold street food'**
  String get templateStreetBites;

  /// No description provided for @templateMinimalModern.
  ///
  /// In en, this message translates to:
  /// **'Minimal and modern'**
  String get templateMinimalModern;

  /// No description provided for @templateLuxuryDining.
  ///
  /// In en, this message translates to:
  /// **'Refined dining'**
  String get templateLuxuryDining;

  /// No description provided for @templateArtisanCafe.
  ///
  /// In en, this message translates to:
  /// **'Artisan cafe'**
  String get templateArtisanCafe;

  /// No description provided for @templateQuickServeBold.
  ///
  /// In en, this message translates to:
  /// **'Quick service'**
  String get templateQuickServeBold;

  /// No description provided for @authPartialConfigNotice.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is available, but some services may need the correct pilot build.'**
  String get authPartialConfigNotice;

  /// No description provided for @termsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get termsLink;

  /// No description provided for @privacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyLink;

  /// No description provided for @consentPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to the '**
  String get consentPrefix;

  /// No description provided for @consentJoin.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get consentJoin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'ckb', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ckb':
      return AppLocalizationsCkb();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
