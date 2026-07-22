import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/localization/localized_runtime_message.dart';
import '../../../../core/theme/v2/waflo_tokens_v2.dart';
import '../../../../shared/widgets/v2/waflo_button_v2.dart';
import '../../../../shared/widgets/v2/waflo_card_v2.dart';
import '../../../../shared/widgets/v2/waflo_input_v2.dart';
import '../../../../shared/widgets/v2/waflo_screen_v2.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../business_setup/presentation/bloc/business_setup_cubit.dart';
import '../../../business_setup/presentation/bloc/business_setup_state.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../../menu/presentation/bloc/menu_cubit.dart';
import '../../../menu/presentation/bloc/menu_state.dart';

class WafloFirstRunWizardScreen extends StatefulWidget {
  const WafloFirstRunWizardScreen({super.key});

  @override
  State<WafloFirstRunWizardScreen> createState() =>
      _WafloFirstRunWizardScreenState();
}

class _WafloFirstRunWizardScreenState extends State<WafloFirstRunWizardScreen> {
  int _currentStep = 0;

  // Controllers & Selections
  final _businessNameController = TextEditingController();
  String _selectedBusinessType = 'cafe'; // cafe, restaurant, shop

  final _categoryNameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();

  String? _createdCategoryId;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    _businessNameController.addListener(_onInputChanged);
    _categoryNameController.addListener(_onInputChanged);
    _productNameController.addListener(_onInputChanged);
    _productPriceController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (mounted) {
      setState(() {
        _priceError = null;
      });
    }
  }

  int? _parseAndValidateIqdPrice(String text) {
    if (text.isEmpty || text != text.trim()) return null;

    final rawText = text;

    // Replace Arabic/Persian digits with English digits
    String englishDigits = rawText
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9')
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9');

    // Only allow positive integers: reject decimals, signs, letters, symbols, spaces
    final regExp = RegExp(r'^[0-9]+$');
    if (!regExp.hasMatch(englishDigits)) {
      return null;
    }

    final parsed = int.tryParse(englishDigits);
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed;
  }

  @override
  void dispose() {
    _businessNameController.removeListener(_onInputChanged);
    _categoryNameController.removeListener(_onInputChanged);
    _productNameController.removeListener(_onInputChanged);
    _productPriceController.removeListener(_onInputChanged);
    _businessNameController.dispose();
    _categoryNameController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: MultiBlocListener(
        listeners: [
          BlocListener<BusinessSetupCubit, BusinessSetupState>(
            listener: (context, state) async {
              if (state.status == BusinessSetupStatus.success &&
                  _currentStep == 1) {
                await context.read<AuthCubit>().refreshCurrentUser();
                if (context.mounted) {
                  final business = state.business;
                  if (business != null) {
                    context.read<DashboardCubit>().primeBusiness(business);
                    await context.read<MenuCubit>().load();
                  }
                  _nextStep();
                }
              }
            },
          ),
          BlocListener<MenuCubit, MenuState>(
            listener: (context, state) {
              if (state.status == MenuStatus.success) {
                if (_currentStep == 3) {
                  final name = _categoryNameController.text.trim();
                  final addedCategory = state.categories
                      .where((c) => c.name.trim() == name)
                      .firstOrNull;
                  if (addedCategory != null) {
                    _createdCategoryId = addedCategory.id;
                  } else if (state.categories.isNotEmpty) {
                    _createdCategoryId = state.categories.first.id;
                  }
                  _nextStep();
                } else if (_currentStep == 4) {
                  _nextStep();
                }
              }
            },
          ),
        ],
        child: BlocBuilder<BusinessSetupCubit, BusinessSetupState>(
          builder: (context, businessState) {
            return BlocBuilder<MenuCubit, MenuState>(
              builder: (context, menuState) {
                final isBusinessLoading =
                    businessState.status == BusinessSetupStatus.loading;
                final isMenuLoading = menuState.status == MenuStatus.loading;

                return WafloScreenV2(
                  scrollable: true,
                  showGradient: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: WafloSpacingV2.md,
                    vertical: WafloSpacingV2.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wizard Stepper Progress Bar
                      if (_currentStep < 8) ...[
                        _buildProgressBar(),
                        const SizedBox(height: WafloSpacingV2.lg),
                      ],
                      // Animated Step Content switcher
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: KeyedSubtree(
                          key: ValueKey<int>(_currentStep),
                          child: _buildStepContent(
                            context,
                            businessState: businessState,
                            menuState: menuState,
                            isLoading: isBusinessLoading || isMenuLoading,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.wizardStep(_currentStep + 1, 9),
              style: WafloTypographyV2.bodyBold.copyWith(
                color: WafloColorsV2.primaryCoral,
              ),
            ),
            if (_currentStep > 0)
              GestureDetector(
                onTap: _prevStep,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: WafloColorsV2.textMedium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.back,
                      style: WafloTypographyV2.body.copyWith(
                        color: WafloColorsV2.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: WafloSpacingV2.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(WafloRadiusV2.xs),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 9.0,
            backgroundColor: WafloColorsV2.borderSoft,
            valueColor: const AlwaysStoppedAnimation<Color>(
              WafloColorsV2.primaryCoral,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(
    BuildContext context, {
    required BusinessSetupState businessState,
    required MenuState menuState,
    required bool isLoading,
  }) {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildWorkspaceStep(context, businessState, isLoading);
      case 2:
        return _buildChooseAppearanceStep();
      case 3:
        return _buildFirstCategoryStep(context, menuState, isLoading);
      case 4:
        return _buildFirstProductStep(context, menuState, isLoading);
      case 5:
        return _buildProductImageStep();
      case 6:
        return _buildCustomerPreviewStep();
      case 7:
        return _buildQrPublishStep();
      case 8:
        return _buildFinishStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // 1. Welcome Step
  Widget _buildWelcomeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: WafloSpacingV2.xl),
        Center(
          child: Text(
            context.l10n.onboardingWelcomeTitle,
            style: WafloTypographyV2.display,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: WafloSpacingV2.md),
        Center(
          child: Text(
            context.l10n.onboardingWelcomeBody,
            style: WafloTypographyV2.h2,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: WafloSpacingV2.xl),
        Center(
          child: Container(
            padding: const EdgeInsets.all(WafloSpacingV2.lg),
            decoration: BoxDecoration(
              color: WafloColorsV2.surfaceWhite,
              shape: BoxShape.circle,
              boxShadow: WafloShadowV2.medium,
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 80,
              color: WafloColorsV2.primaryCoral,
            ),
          ),
        ),
        const SizedBox(height: WafloSpacingV2.xxl),
        WafloButtonV2(
          label: context.l10n.startNow,
          icon: Icons.play_arrow_outlined,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // 2. Restaurant Workspace Step
  Widget _buildWorkspaceStep(
    BuildContext context,
    BusinessSetupState businessState,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.restaurantInfo, style: WafloTypographyV2.h1),
        const SizedBox(height: WafloSpacingV2.xs),
        Text(
          context.l10n.restaurantInfoSubtitle,
          style: WafloTypographyV2.body,
        ),
        const SizedBox(height: WafloSpacingV2.lg),
        WafloInputV2(
          label: context.l10n.restaurantName,
          hint: context.l10n.restaurantNameHint,
          controller: _businessNameController,
        ),
        const SizedBox(height: WafloSpacingV2.lg),
        Text(
          context.l10n.businessType,
          style: WafloTypographyV2.bodyBold.copyWith(
            color: WafloColorsV2.textDark,
          ),
        ),
        const SizedBox(height: WafloSpacingV2.sm),
        Row(
          children: [
            Expanded(
              child: _buildBusinessTypeCard(
                type: 'cafe',
                label: context.l10n.restaurantTypeCafe,
                icon: Icons.local_cafe_outlined,
              ),
            ),
            const SizedBox(width: WafloSpacingV2.sm),
            Expanded(
              child: _buildBusinessTypeCard(
                type: 'restaurant',
                label: context.l10n.restaurantTypeRestaurant,
                icon: Icons.restaurant_outlined,
              ),
            ),
            const SizedBox(width: WafloSpacingV2.sm),
            Expanded(
              child: _buildBusinessTypeCard(
                type: 'shop',
                label: context.l10n.restaurantTypeShop,
                icon: Icons.storefront_outlined,
              ),
            ),
          ],
        ),
        if (businessState.status == BusinessSetupStatus.failure &&
            businessState.errorMessage != null) ...[
          const SizedBox(height: WafloSpacingV2.md),
          Text(
            localizedRuntimeMessage(context.l10n, businessState.errorMessage),
            style: WafloTypographyV2.body.copyWith(color: WafloColorsV2.danger),
          ),
        ],
        const SizedBox(height: WafloSpacingV2.xl),
        WafloButtonV2(
          label: context.l10n.saveAndContinue,
          icon: Icons.save_outlined,
          isLoading: isLoading,
          onPressed: _businessNameController.text.trim().isEmpty
              ? null
              : () {
                  final name = _businessNameController.text.trim();
                  context.read<BusinessSetupCubit>().submit(
                    name: name,
                    type: _selectedBusinessType,
                    city: 'بغداد',
                    currency: 'IQD',
                    language: 'ar',
                  );
                },
        ),
      ],
    );
  }

  Widget _buildBusinessTypeCard({
    required String type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedBusinessType == type;

    return WafloCardV2(
      onTap: () {
        setState(() {
          _selectedBusinessType = type;
        });
      },
      padding: const EdgeInsets.symmetric(vertical: WafloSpacingV2.md),
      backgroundColor: isSelected
          ? WafloColorsV2.backgroundWarm
          : WafloColorsV2.surfaceWhite,
      borderRadius: WafloRadiusV2.mdBorder,
      showBorder: true,
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected
                ? WafloColorsV2.primaryCoral
                : WafloColorsV2.textMedium,
            size: 28,
          ),
          const SizedBox(height: WafloSpacingV2.xs),
          Text(
            label,
            style: WafloTypographyV2.bodyBold.copyWith(
              color: isSelected
                  ? WafloColorsV2.primaryCoral
                  : WafloColorsV2.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Choose Appearance Step (Preview Only)
  Widget _buildChooseAppearanceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.chooseMenuStyle, style: WafloTypographyV2.h1),
        const SizedBox(height: WafloSpacingV2.xs),
        Text(context.l10n.chooseMenuStyleBody, style: WafloTypographyV2.body),
        const SizedBox(height: WafloSpacingV2.lg),
        WafloCardV2(
          backgroundColor: WafloColorsV2.infoBg,
          borderRadius: WafloRadiusV2.lgBorder,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.palette_outlined, color: WafloColorsV2.info),
              const SizedBox(width: WafloSpacingV2.md),
              Expanded(
                child: Text(
                  context.l10n.previewDraftMenu,
                  style: WafloTypographyV2.body,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: WafloSpacingV2.xl),
        WafloButtonV2(
          label: context.l10n.continueAction,
          icon: Icons.arrow_back,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // 4. First Category Step
  Widget _buildFirstCategoryStep(
    BuildContext context,
    MenuState menuState,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.firstCategory, style: WafloTypographyV2.h1),
        const SizedBox(height: WafloSpacingV2.xs),
        Text(context.l10n.firstCategoryBody, style: WafloTypographyV2.body),
        const SizedBox(height: WafloSpacingV2.lg),
        WafloInputV2(
          label: context.l10n.categoryName,
          hint: context.l10n.categoryNameHint,
          controller: _categoryNameController,
        ),
        if (menuState.errorMessage != null) ...[
          const SizedBox(height: WafloSpacingV2.md),
          Text(
            localizedRuntimeMessage(context.l10n, menuState.errorMessage),
            style: WafloTypographyV2.body.copyWith(color: WafloColorsV2.danger),
          ),
        ],
        const SizedBox(height: WafloSpacingV2.xl),
        WafloButtonV2(
          label: context.l10n.saveAndContinue,
          icon: Icons.add_circle_outline,
          isLoading: isLoading,
          onPressed: _categoryNameController.text.trim().isEmpty
              ? null
              : () {
                  final name = _categoryNameController.text.trim();
                  context.read<MenuCubit>().addCategory(name);
                },
        ),
        const SizedBox(height: WafloSpacingV2.md),
        WafloButtonV2(
          label: context.l10n.skipForNow,
          variant: WafloButtonV2Variant.secondary,
          onPressed: () {
            setState(() {
              _currentStep =
                  5; // Skip directly to Step 6: Product Image notice step
            });
          },
        ),
      ],
    );
  }

  // 5. First Product Step
  Widget _buildFirstProductStep(
    BuildContext context,
    MenuState menuState,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.firstProduct, style: WafloTypographyV2.h1),
        const SizedBox(height: WafloSpacingV2.xs),
        Text(context.l10n.firstProductBody, style: WafloTypographyV2.body),
        const SizedBox(height: WafloSpacingV2.lg),
        WafloInputV2(
          label: context.l10n.productName,
          hint: context.l10n.productName,
          controller: _productNameController,
        ),
        const SizedBox(height: WafloSpacingV2.md),
        WafloInputV2(
          label: '${context.l10n.productPrice} (${context.l10n.iqd})',
          hint: context.l10n.productPrice,
          controller: _productPriceController,
          keyboardType: TextInputType.number,
        ),
        if (_priceError != null) ...[
          const SizedBox(height: WafloSpacingV2.xs),
          Text(
            _priceError!,
            style: WafloTypographyV2.body.copyWith(color: WafloColorsV2.danger),
          ),
        ],
        if (menuState.errorMessage != null) ...[
          const SizedBox(height: WafloSpacingV2.md),
          Text(
            localizedRuntimeMessage(context.l10n, menuState.errorMessage),
            style: WafloTypographyV2.body.copyWith(color: WafloColorsV2.danger),
          ),
        ],
        const SizedBox(height: WafloSpacingV2.xl),
        WafloButtonV2(
          label: context.l10n.saveAndContinue,
          icon: Icons.add_circle_outline,
          isLoading: isLoading,
          onPressed:
              _productNameController.text.trim().isEmpty ||
                  _productPriceController.text.isEmpty
              ? null
              : () {
                  final name = _productNameController.text.trim();
                  final parsedPrice = _parseAndValidateIqdPrice(
                    _productPriceController.text,
                  );
                  if (parsedPrice == null) {
                    setState(() {
                      _priceError = context.l10n.productPriceInvalid;
                    });
                    return;
                  }
                  final categoryId =
                      _createdCategoryId ??
                      context
                          .read<MenuCubit>()
                          .state
                          .categories
                          .firstOrNull
                          ?.id;

                  if (categoryId == null) {
                    setState(() {
                      _currentStep = 5; // skip to step 6
                    });
                    return;
                  }

                  context.read<MenuCubit>().addItem(
                    categoryId: categoryId,
                    name: name,
                    description: '',
                    priceCents: parsedPrice,
                  );
                },
        ),
        const SizedBox(height: WafloSpacingV2.md),
        WafloButtonV2(
          label: context.l10n.skipForNow,
          variant: WafloButtonV2Variant.secondary,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // 6. Product Image honest Notice Step
  Widget _buildProductImageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.productImagesUnavailableTitle,
          style: WafloTypographyV2.h1,
        ),
        const SizedBox(height: WafloSpacingV2.xs),
        Text(
          context.l10n.productImagesUnavailableBody,
          style: WafloTypographyV2.body,
        ),
        const SizedBox(height: WafloSpacingV2.lg),
        WafloCardV2(
          backgroundColor: WafloColorsV2.warningBg,
          borderRadius: WafloRadiusV2.lgBorder,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                color: WafloColorsV2.warning,
                size: 24,
              ),
              const SizedBox(width: WafloSpacingV2.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.productImagesUnavailableTitle,
                      style: WafloTypographyV2.title,
                    ),
                    const SizedBox(height: WafloSpacingV2.xs),
                    Text(
                      context.l10n.productImagesUnavailableBody,
                      style: WafloTypographyV2.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: WafloSpacingV2.xl),
        WafloButtonV2(
          label: context.l10n.continueAction,
          icon: Icons.arrow_back,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // 7. Customer Preview Step
  Widget _buildCustomerPreviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.previewCustomerMenu, style: WafloTypographyV2.h1),
        const SizedBox(height: WafloSpacingV2.xs),
        Text(
          context.l10n.previewCustomerMenuBody,
          style: WafloTypographyV2.body,
        ),
        const SizedBox(height: WafloSpacingV2.lg),
        WafloCardV2(
          backgroundColor: WafloColorsV2.surfaceWhite,
          borderRadius: WafloRadiusV2.lgBorder,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.preview_outlined,
                color: WafloColorsV2.primaryCoral,
                size: 24,
              ),
              const SizedBox(width: WafloSpacingV2.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.previewCustomerMenu,
                      style: WafloTypographyV2.title,
                    ),
                    const SizedBox(height: WafloSpacingV2.xs),
                    Text(
                      context.l10n.previewUnavailable,
                      style: WafloTypographyV2.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: WafloSpacingV2.xl),
        WafloButtonV2(
          label: context.l10n.continueAction,
          icon: Icons.arrow_back,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // 8. QR Publish/Share notice Step
  Widget _buildQrPublishStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.qrNotActiveYet, style: WafloTypographyV2.h1),
        const SizedBox(height: WafloSpacingV2.xs),
        Text(context.l10n.qrNotActiveYetBody, style: WafloTypographyV2.body),
        const SizedBox(height: WafloSpacingV2.lg),
        WafloCardV2(
          backgroundColor: WafloColorsV2.infoBg,
          borderRadius: WafloRadiusV2.lgBorder,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.qr_code_2_outlined,
                color: WafloColorsV2.info,
                size: 24,
              ),
              const SizedBox(width: WafloSpacingV2.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.qrNotActiveYet,
                      style: WafloTypographyV2.title,
                    ),
                    const SizedBox(height: WafloSpacingV2.xs),
                    Text(
                      context.l10n.qrNotActiveYetBody,
                      style: WafloTypographyV2.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: WafloSpacingV2.xl),
        WafloButtonV2(
          label: context.l10n.continueAction,
          icon: Icons.check,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // 9. Finish / Celebratory Step
  Widget _buildFinishStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: WafloSpacingV2.xl),
        Center(
          child: Text(
            context.l10n.setupCompleteTitle,
            style: WafloTypographyV2.display,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: WafloSpacingV2.md),
        Center(
          child: Text(
            context.l10n.setupCompleteBody,
            style: WafloTypographyV2.h2,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: WafloSpacingV2.xl),
        Center(
          child: Container(
            padding: const EdgeInsets.all(WafloSpacingV2.lg),
            decoration: BoxDecoration(
              color: WafloColorsV2.successBg,
              shape: BoxShape.circle,
              boxShadow: WafloShadowV2.brand,
            ),
            child: const Icon(
              Icons.stars,
              size: 80,
              color: WafloColorsV2.success,
            ),
          ),
        ),
        const SizedBox(height: WafloSpacingV2.xxl),
        WafloButtonV2(
          label: context.l10n.finishSetup,
          icon: Icons.home_outlined,
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRouteNames.dashboard);
          },
        ),
      ],
    );
  }
}
