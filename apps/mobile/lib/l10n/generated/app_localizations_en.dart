// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Waflo for business';

  @override
  String get languageSelectionTitle => 'Choose your app language';

  @override
  String get languageSelectionBody =>
      'You can change this later from Settings. This does not change the language of your customer menu.';

  @override
  String get languageSuggested => 'Suggested';

  @override
  String get languageContinue => 'Continue';

  @override
  String get languageSaveFailed =>
      'We could not save that choice. Please try again.';

  @override
  String get appLanguage => 'App language';

  @override
  String get menuLanguage => 'Customer menu language';

  @override
  String get appLanguageHelp => 'Changes Waflo controls on this device only.';

  @override
  String get menuLanguageHelp =>
      'Controls the language used for customer-facing menu content.';

  @override
  String get arabicLanguage => 'Arabic';

  @override
  String get soraniLanguage => 'Kurdish / Sorani';

  @override
  String get englishLanguage => 'English';

  @override
  String get navHome => 'Home';

  @override
  String get navMenu => 'Menu';

  @override
  String get navScan => 'Scan';

  @override
  String get navLoyalty => 'Loyalty';

  @override
  String get navSettings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get workspaceImage => 'Workspace image';

  @override
  String unreadNotifications(int count) {
    return '$count unread notifications';
  }

  @override
  String get genericLoading => 'Loading';

  @override
  String get genericErrorTitle => 'Something needs attention';

  @override
  String get genericErrorBody => 'We could not complete that right now.';

  @override
  String get genericRetry => 'Try again';

  @override
  String get genericSave => 'Save';

  @override
  String get genericSaving => 'Saving';

  @override
  String get genericCancel => 'Cancel';

  @override
  String get genericClose => 'Close';

  @override
  String get genericDone => 'Done';

  @override
  String get genericSearch => 'Search';

  @override
  String get genericShowAll => 'Show all';

  @override
  String get genericUnavailable => 'Unavailable';

  @override
  String get genericActive => 'Active';

  @override
  String get genericInactive => 'Inactive';

  @override
  String get genericAvailable => 'Available';

  @override
  String get genericNotAvailable => 'Not available';

  @override
  String get genericReady => 'Ready';

  @override
  String get genericNotReady => 'Not ready';

  @override
  String get workspaceUnavailable =>
      'We could not display this workspace right now.';

  @override
  String get authBadge => 'Restaurant workspace';

  @override
  String get authTitle => 'Welcome to Waflo';

  @override
  String get authSubtitle =>
      'Set up your restaurant menu, loyalty, and cashier tools in clear steps.';

  @override
  String get authChoiceTitle => 'How would you like to start?';

  @override
  String get authChoiceSubtitle =>
      'Sign in to an existing workspace or create one for your restaurant.';

  @override
  String get signInExistingWorkspace => 'Sign in to an existing workspace';

  @override
  String get createBusinessWorkspace => 'Create a restaurant workspace';

  @override
  String get signInHeader => 'Sign in to your restaurant workspace';

  @override
  String get signUpHeader => 'Create a Waflo restaurant workspace';

  @override
  String get signInSubtitle =>
      'Enter the work email or phone number linked to your account.';

  @override
  String get signUpSubtitle =>
      'Start a new restaurant workspace with your work email or phone number.';

  @override
  String get contactLabel => 'Work email or phone number';

  @override
  String get contactHint => 'Enter your sign-in details';

  @override
  String get continueLabel => 'Continue';

  @override
  String get sendingCode => 'Sending code';

  @override
  String get verificationCode => 'Verification code';

  @override
  String get verifying => 'Checking';

  @override
  String get verifyAndCreate => 'Verify and create workspace';

  @override
  String get verifyAndSignIn => 'Verify and sign in';

  @override
  String get resendCode => 'Resend code';

  @override
  String get changeLogin => 'Change sign-in details';

  @override
  String get restoringSession => 'Restoring your session';

  @override
  String get checkingBusinessAccess => 'Checking restaurant access';

  @override
  String get signedIn => 'Signed in';

  @override
  String get confirmBusinessAccess =>
      'We need to confirm which restaurant workspace is available to this account.';

  @override
  String get retryWorkspaceCheck => 'Check again';

  @override
  String get signOut => 'Sign out';

  @override
  String get appConfigNeedsAttention => 'This app build needs attention';

  @override
  String get operatorBuildSupport =>
      'Contact the Waflo team for the correct business app build.';

  @override
  String get testAccess => 'Continue with a test account';

  @override
  String get accountNotFoundTitle => 'No existing account found';

  @override
  String get accountNotFoundBody =>
      'To start a new restaurant, choose Create a restaurant workspace.';

  @override
  String get authTemporaryErrorTitle => 'We could not continue';

  @override
  String get authTemporaryErrorBody => 'Please try again in a moment.';

  @override
  String get verificationFailedTitle => 'Verification was not completed';

  @override
  String get verificationFailedBody => 'Check the code and try again.';

  @override
  String get needsMoreVerificationTitle => 'More verification is required';

  @override
  String get needsMoreVerificationBody =>
      'Complete the requested verification step to continue.';

  @override
  String get passwordlessSetupTitle => 'Sign-in setup needs help';

  @override
  String get passwordlessSetupBody =>
      'Contact the Waflo team to finish sign-in setup for this account.';

  @override
  String get tooManyAttemptsTitle => 'Try again later';

  @override
  String get tooManyAttemptsBody =>
      'There were too many attempts. Wait a moment, then request a new code.';

  @override
  String get passwordRequiredStep =>
      'An additional verification step is required';

  @override
  String get authChoosePathTitle => 'Choose how to start';

  @override
  String get authChoosePathBody =>
      'Sign in to an existing workspace or create a restaurant workspace.';

  @override
  String get authMissingIdentifierTitle => 'Enter your sign-in details';

  @override
  String get authMissingIdentifierBody =>
      'Enter your work email or phone number.';

  @override
  String get authMissingCodeTitle => 'Enter the verification code';

  @override
  String get authMissingCodeBody =>
      'Enter the code sent to your email or phone.';

  @override
  String get authStartAgainTitle => 'Start again';

  @override
  String get authStartAgainBody => 'Request a new code before continuing.';

  @override
  String get homeTitle => 'Home';

  @override
  String get dashboardLoadFailedTitle => 'Home could not load';

  @override
  String get dashboardDetailsFailedTitle => 'Restaurant details could not load';

  @override
  String get dashboardHonestDataBody =>
      'We do not show estimated numbers. Try again to load confirmed data.';

  @override
  String get dashboardPartialFailureTitle =>
      'Some details could not be refreshed';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get atAGlance => 'At a glance';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get recentActivityUnavailable =>
      'Recent activity is not available yet';

  @override
  String get recentActivityHelp =>
      'Confirmed restaurant activity will appear here when it becomes available.';

  @override
  String get heroStartCategory => 'Start with your first menu category';

  @override
  String get heroStartCategoryBody =>
      'Organize the menu with a real category, then add your products.';

  @override
  String get heroAddProducts => 'Get your menu ready for customers';

  @override
  String get heroAddProductsBody =>
      'Add your first products so you can review and share the menu.';

  @override
  String get heroMenuReady => 'Your menu is ready to share';

  @override
  String get heroMenuReadyBody =>
      'The products and public menu are ready. Review it before sharing.';

  @override
  String get heroReviewMenu => 'Review your menu before sharing';

  @override
  String get heroReviewMenuBody =>
      'Products exist, but the public menu is not ready to open yet.';

  @override
  String setupProgress(int completed, int total) {
    return '$completed of $total steps ready';
  }

  @override
  String get addProduct => 'Add product';

  @override
  String get addFirstProduct => 'Add first product';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get openMenu => 'Open menu';

  @override
  String get menuPermissionDenied => 'Your current role cannot edit the menu.';

  @override
  String get publicMenuNotReady =>
      'Opening the menu becomes available after a product and public link are ready.';

  @override
  String get createLoyaltyCard => 'Create loyalty card';

  @override
  String get scanCard => 'Scan card';

  @override
  String get sendNotification => 'Send notification';

  @override
  String get permissionUnavailable => 'Not available for your current role';

  @override
  String get menuPermissionRequired => 'Menu management permission is required';

  @override
  String get scanPermissionDenied =>
      'Scanning is not available for your current role';

  @override
  String get customerNotificationsLater =>
      'Available when customer notifications are supported';

  @override
  String get products => 'Products';

  @override
  String get categories => 'Categories';

  @override
  String get loyaltyCards => 'Loyalty cards';

  @override
  String get customers => 'Customers';

  @override
  String get loyaltyPromotionTitle => 'Bring customers back with loyalty';

  @override
  String get loyaltyPromotionBody =>
      'Open Loyalty to set up the program or review customer cards.';

  @override
  String get openLoyalty => 'Open loyalty';

  @override
  String get loyaltyPermissionDenied =>
      'Your current role cannot manage loyalty.';

  @override
  String get menuManagementTitle => 'Menu management';

  @override
  String get menuManagementBody =>
      'Manage categories and products your customers can see.';

  @override
  String get menuLoading => 'Loading menu';

  @override
  String get menuLoadFailed => 'We could not load the menu.';

  @override
  String get addCategory => 'Add category';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryNameHint => 'For example: Hot drinks';

  @override
  String get categoryRequired => 'Enter a category name.';

  @override
  String get categoryCreated => 'Category added';

  @override
  String get categoryCreateFailed => 'The category could not be added.';

  @override
  String get activeCategories => 'Active categories';

  @override
  String get archivedCategories => 'Archived categories';

  @override
  String get menuItems => 'Menu items';

  @override
  String get menuStatus => 'Menu status';

  @override
  String get menuAddCategoryHint =>
      'Add the first category to start building your menu.';

  @override
  String get menuAddProductHint =>
      'Add the first product to start building your menu.';

  @override
  String get menuLoadedHint =>
      'Products are loaded from this workspace and ready to manage.';

  @override
  String get archivedItems => 'Archived products';

  @override
  String get searchProducts => 'Search products';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noCategoriesTitle => 'No categories yet';

  @override
  String get noCategoriesBody =>
      'Add a category before creating your first product.';

  @override
  String get noProductsTitle => 'No products yet';

  @override
  String get noProductsBody => 'Add the first product to this menu.';

  @override
  String get noSearchResultsTitle => 'No matching products';

  @override
  String get noSearchResultsBody => 'Try a different product name.';

  @override
  String get addCategoryPermissionDenied =>
      'Your current role cannot add a category.';

  @override
  String get addProductPermissionDenied =>
      'Your current role cannot add a product.';

  @override
  String productsInCategory(int count, int available) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products in this category',
      one: '1 product in this category',
    );
    return '$_temp0 • $available available';
  }

  @override
  String get availabilityUpdating => 'Updating availability…';

  @override
  String get previewMenuReadyBody =>
      'Open the confirmed link your customers will see.';

  @override
  String get previewMenuUnavailableBody =>
      'Preview becomes available when the customer menu is ready.';

  @override
  String get archive => 'Archive';

  @override
  String get restore => 'Restore';

  @override
  String get productName => 'Product name';

  @override
  String get productDescriptionOptional => 'Description (optional)';

  @override
  String get productCategory => 'Category';

  @override
  String get productPrice => 'Price';

  @override
  String get iqd => 'IQD';

  @override
  String get productAvailable => 'Available to customers';

  @override
  String get productUnavailable => 'Unavailable to customers';

  @override
  String get productNameRequired => 'Enter a product name.';

  @override
  String get productCategoryRequired => 'Choose a category.';

  @override
  String get productPriceRequired => 'Enter a price in whole Iraqi dinars.';

  @override
  String get productPriceInvalid =>
      'Enter a positive whole-dinar amount without decimals.';

  @override
  String get productImageUnavailable =>
      'Adding a product image is not available in this version.';

  @override
  String get leaveChangesTitle => 'Leave without saving?';

  @override
  String get leaveChangesBody => 'The information you entered will be lost.';

  @override
  String get stay => 'Stay';

  @override
  String get leave => 'Leave';

  @override
  String get back => 'Back';

  @override
  String get businessSetupTitle => 'Set up your restaurant workspace';

  @override
  String get businessSetupSubtitle =>
      'We only need the basics to open your workspace and public menu.';

  @override
  String get businessSetupSaved => 'Restaurant workspace saved';

  @override
  String get businessCreateLoading => 'Creating workspace';

  @override
  String get businessCreateAction => 'Create restaurant workspace';

  @override
  String get restaurantInfo => 'Restaurant information';

  @override
  String get restaurantInfoSubtitle =>
      'The name and business type shown to your team.';

  @override
  String get restaurantName => 'Restaurant name';

  @override
  String get restaurantNameHint => 'For example: Royal Cup';

  @override
  String get restaurantType => 'Business type';

  @override
  String get restaurantTypeCafe => 'Cafe';

  @override
  String get restaurantTypeRestaurant => 'Restaurant';

  @override
  String get restaurantTypeShop => 'Shop / retail';

  @override
  String get identityAndPhotos => 'Brand and photos';

  @override
  String get managedPhotosBody =>
      'The Waflo team can help prepare your logo and restaurant photos for the pilot.';

  @override
  String get locationCurrencyLanguage => 'City, currency, and language';

  @override
  String get locationCurrencyLanguageSubtitle =>
      'These options control how customer prices and menu content appear.';

  @override
  String get city => 'City';

  @override
  String get currency => 'Currency';

  @override
  String get currencyIqd => 'Iraqi dinar (IQD)';

  @override
  String get currencyUsd => 'US dollar (USD)';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get contactAndAddress => 'Contact and address';

  @override
  String get contactAndAddressBody =>
      'We will help complete contact and address details during setup so customers never see incomplete information.';

  @override
  String get businessProfileTitle => 'Restaurant settings';

  @override
  String get businessProfileLoading => 'Loading restaurant settings';

  @override
  String get businessProfileMissingTitle => 'Restaurant workspace is not ready';

  @override
  String get businessProfileMissingBody =>
      'Create a restaurant workspace before editing its information.';

  @override
  String get businessProfileRestrictedTitle => 'Limited permission';

  @override
  String get businessProfileRestrictedBody =>
      'Your current role cannot edit restaurant information.';

  @override
  String get businessProfileEditTitle => 'Edit restaurant information';

  @override
  String get businessProfileEditSubtitle =>
      'These details appear in your workspace and help prepare the customer menu.';

  @override
  String get businessProfileSaved => 'Restaurant information saved';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get savingChanges => 'Saving changes';

  @override
  String get optionalLogoLink => 'Optional logo link';

  @override
  String get optionalCoverLink => 'Optional cover link';

  @override
  String get optionalImageLinkHint => 'Optional image link when available';

  @override
  String get staffScannerTitle => 'Scan a customer loyalty card';

  @override
  String get staffScannerLoading => 'Preparing scanner access';

  @override
  String get staffScannerLoadFailed =>
      'We could not open the restaurant scanner.';

  @override
  String get businessWorkspaceNotReady =>
      'This restaurant workspace is not ready for scanning. Return Home and try again.';

  @override
  String get staffScannerSectionSubtitle =>
      'Confirm the card before adding a stamp or redeeming a reward.';

  @override
  String get manualCodeTitle => 'Manual entry when needed';

  @override
  String get manualCodeSubtitle =>
      'Use this only when the camera cannot read the customer card.';

  @override
  String get loyaltyQrCode => 'Loyalty card code';

  @override
  String get loyaltyQrHint => 'Enter the code from the customer card';

  @override
  String get loyaltyQrRequired => 'Enter the customer card code to continue.';

  @override
  String get checkingCard => 'Checking card';

  @override
  String get checkCard => 'Check card';

  @override
  String get scanAnotherCard => 'Scan another card';

  @override
  String get cameraScannerTitle => 'Camera scanner';

  @override
  String get cameraScannerSubtitle =>
      'Point the frame at the loyalty card. Waflo checks it without displaying the code.';

  @override
  String get enterCodeManually => 'Enter manually';

  @override
  String get cameraPermissionDeniedTitle => 'Camera permission is needed';

  @override
  String get cameraUnavailableTitle => 'Camera is unavailable';

  @override
  String get cameraPermissionDeniedBody =>
      'Enable camera permission in device settings, then try again.';

  @override
  String get cameraUnsupportedBody =>
      'This device cannot scan with the camera. Use manual entry instead.';

  @override
  String get cameraStartFailedBody =>
      'We could not open the camera. Try again or use manual entry.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get tryCameraAgain => 'Try camera again';

  @override
  String get scannerReady => 'Ready to scan';

  @override
  String get openWalletScanner => 'Open camera';

  @override
  String get scannerBusy => 'Scanning';

  @override
  String get scannerPrivacy =>
      'Scan the card from the customer screen. You do not need to type the code.';

  @override
  String get cardNotAccepted => 'Customer card was not accepted';

  @override
  String get retryCapturedCard => 'Try again or scan the customer card again.';

  @override
  String get scanAgain => 'Scan again';

  @override
  String get invalidQr =>
      'The loyalty card is invalid or expired. Ask the customer to open their latest card and scan it again.';

  @override
  String get wrongBusiness =>
      'This card does not belong to this restaurant, or your role cannot scan it.';

  @override
  String get cardFound => 'Card found';

  @override
  String get cardFoundSubtitle =>
      'Confirm the customer and progress before adding a stamp.';

  @override
  String get privateCustomerDetails =>
      'Customer details are shortened for privacy.';

  @override
  String get phoneEnding => 'Phone ending';

  @override
  String get rewardReadySuffix => 'is ready to redeem.';

  @override
  String get rewardNotReadySuffix => 'is not ready yet.';

  @override
  String get rewardAvailable => 'Reward available';

  @override
  String get readyToAddStamp => 'Ready to add stamp';

  @override
  String get stampRecorded => 'A stamp was already recorded for this scan.';

  @override
  String get rewardAvailableGuidance =>
      'The reward is ready. Follow the restaurant process before adding another stamp.';

  @override
  String get addOneStamp =>
      'Add one stamp after confirming the customer visit.';

  @override
  String get addingStamp => 'Adding stamp';

  @override
  String get addStamp => 'Add stamp';

  @override
  String get stampSuccess =>
      'Stamp added. The live card is current; Apple Wallet or Google Wallet may sync shortly.';

  @override
  String get loyaltyTitle => 'Loyalty';

  @override
  String get loyaltyLoading => 'Loading loyalty';

  @override
  String get loyaltyLoadFailed => 'We could not load loyalty right now.';

  @override
  String get loyaltySetupNeeded =>
      'Restaurant setup is required before loyalty can be used.';

  @override
  String get loyaltyInactiveTitle => 'Loyalty is not active';

  @override
  String get loyaltyInactiveBody =>
      'Set up and activate a real loyalty program before sharing enrollment with customers.';

  @override
  String get loyaltyEnrollmentUnavailableTitle => 'Enrollment link unavailable';

  @override
  String get loyaltyEnrollmentUnavailableBody =>
      'No active enrollment link is available for this restaurant.';

  @override
  String get loyaltyAdvancedWebStudio =>
      'Advanced loyalty setup remains managed through Web Studio.';

  @override
  String get programName => 'Program name';

  @override
  String get stampGoal => 'Stamp goal';

  @override
  String get rewardName => 'Reward name';

  @override
  String get description => 'Description';

  @override
  String get rewardDescription => 'Reward description';

  @override
  String get terms => 'Terms';

  @override
  String get editProgram => 'Edit program';

  @override
  String get setUpStampCard => 'Set up stamp card';

  @override
  String get viewOnlyProgramAccess => 'View-only program access';

  @override
  String get enrollCustomer => 'Enroll customer';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get customerName => 'Customer name';

  @override
  String get count => 'Count';

  @override
  String get reason => 'Reason';

  @override
  String get redeemReward => 'Redeem reward';

  @override
  String get redeemRewardQuestion => 'Redeem this reward?';

  @override
  String get memberships => 'Memberships';

  @override
  String get membershipHelp => 'Select a customer to open their stamp card.';

  @override
  String get searchMembers => 'Search by phone, email, or name';

  @override
  String get rewardReady => 'Reward ready';

  @override
  String get selectMembership => 'Select a membership';

  @override
  String get actions => 'Actions';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get noTransactionsTitle => 'No transactions yet';

  @override
  String get noTransactionsBody =>
      'Confirmed stamps and reward redemptions will appear here.';

  @override
  String progressTowardReward(int percent, String reward) {
    return '$percent% toward $reward';
  }

  @override
  String get loyaltyEnrollmentTitle => 'Customer enrollment';

  @override
  String get loyaltyEnrollmentHelp =>
      'Share this confirmed link with customers who want to join.';

  @override
  String get copyLink => 'Copy link';

  @override
  String get shareLink => 'Share link';

  @override
  String get linkCopied => 'Enrollment link copied';

  @override
  String get sharingUnavailableCopied =>
      'Sharing is unavailable. The enrollment link was copied.';

  @override
  String get menuAppearanceTitle => 'Menu appearance';

  @override
  String get menuAppearanceLoading => 'Loading menu styles';

  @override
  String get menuAppearanceLoadFailed => 'We could not load menu styles.';

  @override
  String get menuAppearanceEmpty => 'No menu styles are available right now.';

  @override
  String get publicMenuDesign => 'Public menu design';

  @override
  String get publicMenuDesignSubtitle =>
      'Choose a style that fits the restaurant. Previewing does not save it.';

  @override
  String get previewDraftMenu =>
      'Preview opens the QR menu temporarily without saving the change.';

  @override
  String get previewCouldNotOpen => 'We could not open the preview.';

  @override
  String get previewUnavailable =>
      'Preview requires a confirmed public menu link.';

  @override
  String get previewAction => 'Preview';

  @override
  String get selectTemplate => 'Select';

  @override
  String get selectedTemplate => 'Selected';

  @override
  String get currentTemplate => 'Current';

  @override
  String get saveTemplate => 'Save style';

  @override
  String get savingTemplate => 'Saving style';

  @override
  String get menuAppearanceSaved => 'Menu style saved';

  @override
  String get menuAppearancePermission =>
      'Your current role cannot change the menu style.';

  @override
  String get publicMenuQrTitle => 'Public menu QR';

  @override
  String get publicMenuQrLoading => 'Loading confirmed public menu link';

  @override
  String get publicMenuQrUnavailableTitle => 'Public menu QR is not available';

  @override
  String get publicMenuQrUnavailableBody =>
      'A QR can be shown only after Waflo confirms a secure public menu link.';

  @override
  String get copyPublicMenuLink => 'Copy public menu link';

  @override
  String get sharePublicMenu => 'Share public menu';

  @override
  String get publicMenuLinkCopied => 'Public menu link copied';

  @override
  String get businessSetupStep => 'Restaurant information';

  @override
  String get businessSetupIntro =>
      'Start with the restaurant details your team needs.';

  @override
  String get chooseMenuStyle => 'Choose a menu style';

  @override
  String get chooseMenuStyleBody =>
      'Preview a visual direction now. You can change it later.';

  @override
  String get firstCategory => 'Add your first menu category';

  @override
  String get firstCategoryBody =>
      'Use a real category such as Main dishes or Drinks.';

  @override
  String get firstProduct => 'Add your first product';

  @override
  String get firstProductBody => 'Add a real product and a whole-dinar price.';

  @override
  String get previewCustomerMenu => 'Preview the customer menu';

  @override
  String get previewCustomerMenuBody =>
      'Review confirmed menu information before sharing it.';

  @override
  String get qrNotActiveYet => 'QR sharing is not active yet';

  @override
  String get qrNotActiveYetBody =>
      'Waflo will show sharing only after a real public menu link is confirmed.';

  @override
  String get startNow => 'Start now';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get finishSetup => 'Go to Home';

  @override
  String get loyaltyWorkspaceBody =>
      'Manage the restaurant\'s confirmed stamp-card activity.';

  @override
  String get loyaltyStatusNote => 'Loyalty status';

  @override
  String get loyaltyProgramSaved => 'Loyalty program saved.';

  @override
  String get loyaltyProgramUpdated => 'Loyalty program updated.';

  @override
  String get loyaltyOperationCompleted => 'Loyalty activity updated.';

  @override
  String get setUpLoyaltyProgram => 'Set up loyalty program';

  @override
  String get programNameRequired => 'Enter a program name.';

  @override
  String get stampGoalInvalid => 'Choose a stamp goal from 1 to 50.';

  @override
  String get rewardNameRequired => 'Enter a reward name.';

  @override
  String get contactRequired => 'Enter a phone number or email.';

  @override
  String get addStampTitle => 'Add stamp';

  @override
  String get addAction => 'Add';

  @override
  String get redeemConfirmBody =>
      'Confirm that the reward is being given now. The stamp count will reset to zero.';

  @override
  String get noActiveLoyaltyProgram => 'No active loyalty program';

  @override
  String get loyaltySetupOwnerBody =>
      'Create a stamp-card program before enrolling customers.';

  @override
  String get loyaltySetupStaffBody =>
      'A program has not been set up yet. An owner or manager can configure it.';

  @override
  String programRewardRule(int goal, String reward) {
    return '$goal stamps unlock $reward.';
  }

  @override
  String termsValue(String terms) {
    return 'Terms: $terms';
  }

  @override
  String get viewOnlyProgramBody =>
      'You can view this program, but your current role cannot change it.';

  @override
  String get customerLookup => 'Customer lookup';

  @override
  String get noLoyaltyMembers => 'No loyalty members yet';

  @override
  String get noMembershipMatches => 'No matching customers';

  @override
  String get noLoyaltyMembersBody =>
      'Enroll a customer to create the first stamp-card membership.';

  @override
  String get noMembershipMatchesBody =>
      'Try a different phone number, email, or name.';

  @override
  String get loyaltyCustomer => 'Loyalty customer';

  @override
  String get noCustomerContact => 'No customer contact saved';

  @override
  String cardStampProgress(int count, int goal, String reward) {
    return '$count/$goal stamps for $reward';
  }

  @override
  String cardStampCount(int count, int goal) {
    return '$count/$goal stamps';
  }

  @override
  String rewardReadyMessage(String reward) {
    return 'Reward ready: $reward. Confirm before redeeming.';
  }

  @override
  String redeemAvailableAt(int goal) {
    return 'Redeem becomes available when the card reaches $goal stamps.';
  }

  @override
  String get selectMembershipBody =>
      'Choose a customer to view the card and available actions.';

  @override
  String get stampAddedTransaction => 'Stamp added';

  @override
  String get rewardRedeemedTransaction => 'Reward redeemed';

  @override
  String get adjustmentTransaction => 'Adjustment';

  @override
  String get voidTransaction => 'Voided transaction';

  @override
  String get unknownTransaction => 'Transaction';

  @override
  String positiveStampDelta(int count) {
    return '+$count stamps';
  }

  @override
  String negativeStampDelta(int count) {
    return '$count stamps';
  }

  @override
  String get noStampChange => 'No stamp change';

  @override
  String get phoneOrEmailHint => 'Phone number or email';

  @override
  String get customerNameHint => 'Customer name';

  @override
  String get stampReasonHint => 'Purchase note (optional)';

  @override
  String get redeemReasonHint => 'Redemption note (optional)';

  @override
  String loyaltyEnrollmentShareText(String url) {
    return 'Join our loyalty program: $url';
  }

  @override
  String wizardStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Welcome to Waflo';

  @override
  String get onboardingWelcomeBody =>
      'Let\'s prepare your restaurant and its customer menu one confirmed step at a time.';

  @override
  String get businessType => 'Business type';

  @override
  String get chooseStyleLater => 'Choose later';

  @override
  String get productImagesUnavailableTitle =>
      'Product images are not available yet';

  @override
  String get productImagesUnavailableBody =>
      'This version does not upload product images. Continue with real names and prices for now.';

  @override
  String get setupCompleteTitle => 'Your restaurant setup has started';

  @override
  String get setupCompleteBody =>
      'Continue the remaining confirmed steps from Home.';

  @override
  String get continueAction => 'Continue';

  @override
  String get templateWafloWarm => 'Warm and welcoming';

  @override
  String get templateCoffeehousePremium => 'Elegant coffeehouse';

  @override
  String get templateStreetBites => 'Bold street food';

  @override
  String get templateMinimalModern => 'Minimal and modern';

  @override
  String get templateLuxuryDining => 'Refined dining';

  @override
  String get templateArtisanCafe => 'Artisan cafe';

  @override
  String get templateQuickServeBold => 'Quick service';

  @override
  String get authPartialConfigNotice =>
      'Sign-in is available, but some services may need the correct pilot build.';

  @override
  String get termsLink => 'Terms';

  @override
  String get privacyLink => 'Privacy';

  @override
  String get consentPrefix => 'By continuing, you agree to the ';

  @override
  String get consentJoin => ' and ';
}
