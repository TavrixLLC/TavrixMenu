import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/v3/waflo_v3_theme.dart';
import '../../../../core/theme/v3/waflo_v3_tokens.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/v3/waflo_inline_error.dart';
import '../../../../shared/widgets/v3/waflo_primary_button.dart';
import '../../domain/entities/menu_category.dart';
import '../bloc/menu_cubit.dart';
import '../bloc/menu_state.dart';

class ProductEditorResult {
  const ProductEditorResult({
    required this.categoryId,
    required this.productId,
  });

  final String categoryId;
  final String productId;
}

class ProductEditorScreen extends StatefulWidget {
  const ProductEditorScreen({required this.initialCategoryId, super.key});

  final String initialCategoryId;

  @override
  State<ProductEditorScreen> createState() => _ProductEditorScreenState();
}

class _ProductEditorScreenState extends State<ProductEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategoryId;
  String? _initialBusinessId;
  bool _isAvailable = true;
  bool _workspaceDismissal = false;
  bool _allowPop = false;

  bool get _isDirty {
    return _nameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _priceController.text.isNotEmpty ||
        _selectedCategoryId != widget.initialCategoryId ||
        !_isAvailable;
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<MenuCubit>().state;
    _initialBusinessId = state.business?.id;
    _selectedCategoryId =
        state.visibleCategories.any(
          (category) => category.id == widget.initialCategoryId,
        )
        ? widget.initialCategoryId
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: WafloV3Theme.light(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<MenuCubit, MenuState>(
          listenWhen: (previous, current) {
            return previous.status != current.status ||
                previous.business?.id != current.business?.id;
          },
          listener: (context, state) {
            final businessChanged = state.business?.id != _initialBusinessId;
            if (!_workspaceDismissal &&
                (state.status == MenuStatus.initial || businessChanged)) {
              setState(() {
                _workspaceDismissal = true;
                _allowPop = true;
              });
              _popAfterBuild();
            }
          },
          builder: (context, state) {
            final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
            final categories = state.visibleCategories
                .where((category) => category.businessId == _initialBusinessId)
                .toList();
            final selectedStillValid = categories.any(
              (category) => category.id == _selectedCategoryId,
            );
            if (!selectedStillValid) {
              _selectedCategoryId = null;
            }

            return PopScope(
              canPop: !_isDirty || _workspaceDismissal || _allowPop,
              onPopInvokedWithResult: (didPop, _) async {
                if (didPop) return;
                if (await _confirmDiscardIfNeeded() && context.mounted) {
                  setState(() => _allowPop = true);
                  _popAfterBuild();
                }
              },
              child: Scaffold(
                key: const ValueKey('product-editor-v3'),
                backgroundColor: WafloV3Colors.background,
                resizeToAvoidBottomInset: true,
                body: SafeArea(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      key: const ValueKey('product-editor-scroll-view'),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsetsDirectional.fromSTEB(
                        WafloV3Spacing.standardPageMargin,
                        WafloV3Spacing.standardPageMargin,
                        WafloV3Spacing.standardPageMargin,
                        keyboardVisible
                            ? WafloV3Spacing.space32
                            : WafloV3Spacing.space24,
                      ),
                      children: [
                        _FocusedHeader(onBack: _handleBack),
                        const SizedBox(height: WafloV3Spacing.space16),
                        TextFormField(
                          key: const ValueKey('product-name-field'),
                          controller: _nameController,
                          maxLength: 160,
                          textInputAction: TextInputAction.next,
                          textAlign: TextAlign.start,
                          decoration: _fieldDecoration(
                            label: 'اسم المنتج',
                            hint: 'مثال: قهوة عربية',
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'اكتب اسم المنتج.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: WafloV3Spacing.space12),
                        TextFormField(
                          key: const ValueKey('product-description-field'),
                          controller: _descriptionController,
                          maxLength: 1000,
                          minLines: 2,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          textAlign: TextAlign.start,
                          decoration: _fieldDecoration(
                            label: 'الوصف (اختياري)',
                            hint: 'أضف وصفاً مختصراً للزبائن',
                          ),
                        ),
                        const SizedBox(height: WafloV3Spacing.space12),
                        DropdownButtonFormField<String>(
                          key: const ValueKey('product-category-field'),
                          initialValue: _selectedCategoryId,
                          isExpanded: true,
                          decoration: _fieldDecoration(label: 'القسم'),
                          items: [
                            for (final category in categories)
                              DropdownMenuItem(
                                value: category.id,
                                child: Text(
                                  category.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: state.isProductMutationPending
                              ? null
                              : (value) =>
                                    setState(() => _selectedCategoryId = value),
                          validator: (value) {
                            if (value == null ||
                                !_isAuthoritativeCategory(value, categories)) {
                              return 'اختر قسماً من أقسام مساحة عملك.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: WafloV3Spacing.space12),
                        TextFormField(
                          key: const ValueKey('product-price-field'),
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(16),
                          ],
                          textInputAction: TextInputAction.done,
                          textAlign: TextAlign.start,
                          scrollPadding: const EdgeInsets.only(bottom: 160),
                          decoration: _fieldDecoration(
                            label: 'السعر',
                            hint: 'مثال: ٦٥٠٠',
                            suffixIcon: _CurrencyAffordance(
                              label: _currencyLabel(state),
                            ),
                          ),
                          validator: (value) {
                            if (MoneyFormatter.parsePositiveMajorUnits(
                                  value ?? '',
                                ) ==
                                null) {
                              return 'أدخل سعراً صحيحاً أكبر من صفر.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: WafloV3Spacing.space12),
                        _AvailabilityControl(
                          value: _isAvailable,
                          enabled: !state.isProductMutationPending,
                          onChanged: (value) =>
                              setState(() => _isAvailable = value),
                        ),
                        const SizedBox(height: WafloV3Spacing.space12),
                        const _UnavailableFeatureNote(),
                        if (state.errorMessage != null) ...[
                          const SizedBox(height: WafloV3Spacing.space16),
                          WafloInlineError(message: state.errorMessage!),
                        ],
                        const SizedBox(height: WafloV3Spacing.space16),
                        WafloPrimaryButton(
                          key: const ValueKey('product-submit-action'),
                          label: 'إضافة المنتج',
                          isLoading: state.isProductMutationPending,
                          onPressed:
                              state.canManageMenu &&
                                  !state.isProductMutationPending
                              ? () => _submit(categories)
                              : null,
                        ),
                        if (!state.canManageMenu) ...[
                          const SizedBox(height: WafloV3Spacing.space8),
                          const Text(
                            'صلاحيتك الحالية لا تسمح بإضافة منتج.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: WafloV3Spacing.space16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit(List<MenuCategory> categories) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final categoryId = _selectedCategoryId;
    final price = MoneyFormatter.parsePositiveMajorUnits(_priceController.text);
    if (categoryId == null ||
        price == null ||
        !_isAuthoritativeCategory(categoryId, categories)) {
      return;
    }

    final created = await context.read<MenuCubit>().addItem(
      categoryId: categoryId,
      name: _nameController.text,
      description: _descriptionController.text,
      priceCents: price,
      isAvailable: _isAvailable,
    );
    if (!mounted || created == null) return;
    setState(() => _allowPop = true);
    _popAfterBuild(
      ProductEditorResult(
        categoryId: created.categoryId,
        productId: created.id,
      ),
    );
  }

  bool _isAuthoritativeCategory(
    String categoryId,
    List<MenuCategory> categories,
  ) {
    return categories.any(
      (category) =>
          category.id == categoryId &&
          category.businessId == _initialBusinessId &&
          category.isActive,
    );
  }

  String _currencyLabel(MenuState state) {
    return state.business?.currency.trim().toUpperCase() == 'IQD'
        ? 'د.ع'
        : state.business?.currency.trim().toUpperCase() ?? '';
  }

  Future<bool> _confirmDiscardIfNeeded() async {
    if (!_isDirty || _workspaceDismissal) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ترك التعديلات؟'),
        content: const Text('ستفقد البيانات التي أدخلتها.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('البقاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ترك التعديلات'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _handleBack() async {
    if (await _confirmDiscardIfNeeded() && mounted) {
      setState(() => _allowPop = true);
      _popAfterBuild();
    }
  }

  void _popAfterBuild([Object? result]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }
}

class _FocusedHeader extends StatelessWidget {
  const _FocusedHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('product-editor-focused-header'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton.outlined(
          key: const ValueKey('product-editor-back'),
          tooltip: 'رجوع',
          constraints: const BoxConstraints.tightFor(
            width: WafloV3Spacing.minimumTouchTarget,
            height: WafloV3Spacing.minimumTouchTarget,
          ),
          onPressed: onBack,
          icon: const Icon(Icons.arrow_forward_ios_rounded),
        ),
        const SizedBox(width: WafloV3Spacing.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إضافة منتج',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: WafloV3Spacing.space4),
              Text(
                'أضف التفاصيل التي سيراها زبائنك.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WafloV3Colors.primaryText.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvailabilityControl extends StatelessWidget {
  const _AvailabilityControl({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: WafloV3Colors.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(WafloV3Radius.inputControl),
        ),
        border: Border.all(
          color: WafloV3Colors.primaryText.withValues(alpha: 0.14),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: WafloV3Spacing.minimumTouchTarget,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: WafloV3Spacing.space16,
            vertical: WafloV3Spacing.space4,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التوفر للزبائن',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(value ? 'متوفر' : 'غير متوفر'),
                  ],
                ),
              ),
              Switch(
                key: const ValueKey('product-availability-field'),
                value: value,
                onChanged: enabled ? onChanged : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnavailableFeatureNote extends StatelessWidget {
  const _UnavailableFeatureNote();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: WafloV3Colors.primaryText.withValues(alpha: 0.04),
        borderRadius: const BorderRadius.all(
          Radius.circular(WafloV3Radius.inputControl),
        ),
      ),
      child: const Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: WafloV3Spacing.space12,
          vertical: WafloV3Spacing.space8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded, size: WafloV3Spacing.space20),
            SizedBox(width: WafloV3Spacing.space8),
            Expanded(
              child: Text('إضافة صورة للمنتج غير متاحة في هذه المرحلة.'),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required String label,
  String? hint,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffixIcon,
    isDense: true,
    counterText: '',
    contentPadding: const EdgeInsetsDirectional.symmetric(
      horizontal: WafloV3Spacing.space16,
      vertical: WafloV3Spacing.space12,
    ),
    constraints: const BoxConstraints(
      minHeight: WafloV3Spacing.minimumTouchTarget,
    ),
    filled: true,
    fillColor: WafloV3Colors.surface,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(WafloV3Radius.inputControl),
      ),
    ),
  );
}

class _CurrencyAffordance extends StatelessWidget {
  const _CurrencyAffordance({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('product-price-currency'),
      width: 56,
      child: Center(
        child: Text(
          label,
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: WafloV3Colors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
