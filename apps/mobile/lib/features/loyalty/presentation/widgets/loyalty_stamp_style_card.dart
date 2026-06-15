import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/loyalty_card_state.dart';
import '../../domain/entities/loyalty_membership.dart';
import '../../domain/entities/loyalty_program.dart';
import '../../domain/entities/loyalty_requests.dart';
import '../../domain/entities/loyalty_stamp_style.dart';
import 'loyalty_stamp_style_preview.dart';

class LoyaltyStampStyleCard extends StatefulWidget {
  const LoyaltyStampStyleCard({
    required this.stampPresets,
    required this.stampStyle,
    required this.businessName,
    required this.program,
    required this.selectedMembership,
    required this.canEdit,
    required this.isLoading,
    required this.isSaving,
    required this.errorMessage,
    required this.onSave,
    super.key,
  });

  final LoyaltyStampPresets? stampPresets;
  final LoyaltyStampStyle? stampStyle;
  final String businessName;
  final LoyaltyProgram? program;
  final LoyaltyMembership? selectedMembership;
  final bool canEdit;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final ValueChanged<UpdateLoyaltyStampStyleRequest> onSave;

  @override
  State<LoyaltyStampStyleCard> createState() => _LoyaltyStampStyleCardState();
}

class _LoyaltyStampStyleCardState extends State<LoyaltyStampStyleCard> {
  final _backgroundController = TextEditingController();
  final _accentController = TextEditingController();
  final _textController = TextEditingController();
  final _walletBackgroundController = TextEditingController();
  final _imageBackgroundController = TextEditingController();
  final _imageSurfaceController = TextEditingController();
  final _imageAccentController = TextEditingController();
  final _imageTextController = TextEditingController();
  final _stampFilledController = TextEditingController();
  final _stampEmptyController = TextEditingController();
  final _rewardBannerController = TextEditingController();

  String _styleType = 'PRESET';
  String _presetKey = 'STAR';
  String _themePreset = 'DEFAULT';
  String _colorMode = 'PRESET';
  String _layoutVariant = 'MODERN';
  bool _isResetting = false;

  List<TextEditingController> get _controllers => [
    _backgroundController,
    _accentController,
    _textController,
    _walletBackgroundController,
    _imageBackgroundController,
    _imageSurfaceController,
    _imageAccentController,
    _imageTextController,
    _stampFilledController,
    _stampEmptyController,
    _rewardBannerController,
  ];

  @override
  void initState() {
    super.initState();
    _resetFormFromWidget();
    for (final controller in _controllers) {
      controller.addListener(_handleColorChanged);
    }
  }

  @override
  void didUpdateWidget(covariant LoyaltyStampStyleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stampStyle != widget.stampStyle ||
        oldWidget.stampPresets != widget.stampPresets) {
      _resetFormFromWidget();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_handleColorChanged);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presetOptions = _presetOptions();
    final layoutOptions = _withSelected(
      widget.stampPresets?.layoutVariants ?? const ['MODERN', 'COMPACT'],
      _layoutVariant,
    );
    final draftStyle = _draftStyle();
    final cardState = _previewCardState();
    final canSave = widget.canEdit && widget.program != null;
    final controlsEnabled = canSave && !widget.isSaving;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.palette_outlined),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loyalty Card Style',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      widget.canEdit
                          ? 'Customize the stamp card customers see during loyalty operations.'
                          : 'Only owners and managers can edit the card style.',
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.isLoading) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(),
          ],
          if ((widget.errorMessage ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.errorMessage!,
              style: const TextStyle(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          LoyaltyStampStylePreview(
            style: draftStyle,
            cardState: cardState,
            businessName: widget.businessName,
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            key: ValueKey('preset-$_presetKey'),
            initialValue: _presetKey,
            decoration: const InputDecoration(labelText: 'Preset'),
            items: [
              for (final preset in presetOptions)
                DropdownMenuItem(value: preset.key, child: Text(preset.label)),
            ],
            onChanged: controlsEnabled
                ? (value) {
                    if (value != null) {
                      setState(() => _presetKey = value);
                    }
                  }
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            key: ValueKey('theme-$_themePreset'),
            initialValue: _themePreset,
            decoration: const InputDecoration(labelText: 'Theme preset'),
            items: [
              for (final value in _themePresetOptions)
                DropdownMenuItem(value: value, child: Text(_labelFor(value))),
            ],
            onChanged: controlsEnabled
                ? (value) {
                    if (value != null) {
                      setState(() {
                        _themePreset = value;
                        if (_colorMode != 'CUSTOM') {
                          _applyColors(_themeColors(value));
                        }
                      });
                    }
                  }
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            key: ValueKey('layout-$_layoutVariant'),
            initialValue: _layoutVariant,
            decoration: const InputDecoration(labelText: 'Layout variant'),
            items: [
              for (final value in layoutOptions)
                DropdownMenuItem(value: value, child: Text(_labelFor(value))),
            ],
            onChanged: controlsEnabled
                ? (value) {
                    if (value != null) {
                      setState(() => _layoutVariant = value);
                    }
                  }
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            key: ValueKey('mode-$_colorMode'),
            initialValue: _colorMode,
            decoration: const InputDecoration(labelText: 'Color mode'),
            items: [
              for (final value in _colorModeOptions)
                DropdownMenuItem(value: value, child: Text(_labelFor(value))),
            ],
            onChanged: controlsEnabled
                ? (value) {
                    if (value != null) {
                      setState(() {
                        if (value == 'CUSTOM' && _colorMode != 'CUSTOM') {
                          _applyColors(_themeColors(_themePreset));
                          _themePreset = 'CUSTOM';
                        }
                        _colorMode = value;
                      });
                    }
                  }
                : null,
          ),
          if (_colorMode == 'CUSTOM') ...[
            const SizedBox(height: AppSpacing.lg),
            _ColorField(
              controller: _backgroundController,
              label: 'Background color',
              enabled: controlsEnabled,
            ),
            _ColorField(
              controller: _accentController,
              label: 'Accent color',
              enabled: controlsEnabled,
            ),
            _ColorField(
              controller: _textController,
              label: 'Text color',
              enabled: controlsEnabled,
            ),
            _ColorField(
              controller: _walletBackgroundController,
              label: 'Wallet background color',
              enabled: controlsEnabled,
            ),
            _ColorField(
              controller: _imageBackgroundController,
              label: 'Image background color',
              enabled: controlsEnabled,
            ),
            _ColorField(
              controller: _imageSurfaceController,
              label: 'Image surface color',
              enabled: controlsEnabled,
            ),
            _ColorField(
              controller: _imageAccentController,
              label: 'Image accent color',
              enabled: controlsEnabled,
            ),
            _ColorField(
              controller: _imageTextController,
              label: 'Image text color',
              enabled: controlsEnabled,
            ),
            _ColorField(
              controller: _stampFilledController,
              label: 'Filled stamp color',
              enabled: controlsEnabled,
            ),
            _ColorField(
              controller: _stampEmptyController,
              label: 'Empty stamp color',
              enabled: controlsEnabled,
            ),
            _ColorField(
              controller: _rewardBannerController,
              label: 'Reward banner color',
              enabled: controlsEnabled,
            ),
          ],
          if (canSave) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: widget.isSaving ? 'Saving style' : 'Save card style',
              icon: Icons.save_outlined,
              onPressed: widget.isSaving
                  ? null
                  : () => widget.onSave(_request()),
            ),
          ],
          if (widget.isSaving) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  void _resetFormFromWidget() {
    _isResetting = true;
    final style = widget.stampStyle;
    _styleType = _firstAllowed(
      style?.styleType ?? 'PRESET',
      widget.stampPresets?.styleTypes ?? const ['PRESET'],
      fallback: 'PRESET',
    );
    _presetKey = _firstAllowed(
      style?.presetKey ?? 'STAR',
      _presetOptions().map((preset) => preset.key).toList(growable: false),
      fallback: _presetOptions().first.key,
    );
    _themePreset = _firstAllowed(
      style?.themePreset ?? 'DEFAULT',
      _themePresetOptions,
      fallback: 'DEFAULT',
    );
    _colorMode = _firstAllowed(
      style?.colorMode ?? 'PRESET',
      _colorModeOptions,
      fallback: 'PRESET',
    );
    _layoutVariant = _firstAllowed(
      style?.layoutVariant ?? 'MODERN',
      widget.stampPresets?.layoutVariants ?? const ['MODERN', 'COMPACT'],
      fallback: 'MODERN',
    );

    final fallbackColors = _themeColors(_themePreset);
    _backgroundController.text =
        style?.backgroundColor ?? fallbackColors.backgroundColor;
    _accentController.text = style?.accentColor ?? fallbackColors.accentColor;
    _textController.text = style?.textColor ?? fallbackColors.textColor;
    _walletBackgroundController.text =
        style?.walletBackgroundColor ?? fallbackColors.walletBackgroundColor;
    _imageBackgroundController.text =
        style?.imageBackgroundColor ?? fallbackColors.imageBackgroundColor;
    _imageSurfaceController.text =
        style?.imageSurfaceColor ?? fallbackColors.imageSurfaceColor;
    _imageAccentController.text =
        style?.imageAccentColor ?? fallbackColors.imageAccentColor;
    _imageTextController.text =
        style?.imageTextColor ?? fallbackColors.imageTextColor;
    _stampFilledController.text =
        style?.stampFilledColor ?? fallbackColors.stampFilledColor;
    _stampEmptyController.text =
        style?.stampEmptyColor ?? fallbackColors.stampEmptyColor;
    _rewardBannerController.text =
        style?.rewardBannerColor ?? fallbackColors.rewardBannerColor;
    _isResetting = false;
  }

  void _handleColorChanged() {
    if (!_isResetting && mounted) {
      setState(() {});
    }
  }

  LoyaltyStampStyle _draftStyle() {
    final colors = _colorMode == 'CUSTOM'
        ? _ThemeColors(
            backgroundColor: _backgroundController.text,
            accentColor: _accentController.text,
            textColor: _textController.text,
            walletBackgroundColor: _walletBackgroundController.text,
            imageBackgroundColor: _imageBackgroundController.text,
            imageSurfaceColor: _imageSurfaceController.text,
            imageAccentColor: _imageAccentController.text,
            imageTextColor: _imageTextController.text,
            stampFilledColor: _stampFilledController.text,
            stampEmptyColor: _stampEmptyController.text,
            rewardBannerColor: _rewardBannerController.text,
          )
        : _themeColors(_themePreset);

    return LoyaltyStampStyle(
      id: widget.stampStyle?.id ?? 'preview-stamp-style',
      loyaltyProgramId: widget.stampStyle?.loyaltyProgramId ?? '',
      styleType: _styleType,
      presetKey: _presetKey,
      themePreset: _themePreset,
      colorMode: _colorMode,
      backgroundColor: colors.backgroundColor,
      accentColor: colors.accentColor,
      textColor: colors.textColor,
      walletBackgroundColor: colors.walletBackgroundColor,
      imageBackgroundColor: colors.imageBackgroundColor,
      imageSurfaceColor: colors.imageSurfaceColor,
      imageAccentColor: colors.imageAccentColor,
      imageTextColor: colors.imageTextColor,
      stampFilledColor: colors.stampFilledColor,
      stampEmptyColor: colors.stampEmptyColor,
      rewardBannerColor: colors.rewardBannerColor,
      layoutVariant: _layoutVariant,
      isDefault: widget.stampStyle?.isDefault ?? true,
    );
  }

  UpdateLoyaltyStampStyleRequest _request() {
    final style = _draftStyle();
    return UpdateLoyaltyStampStyleRequest(
      styleType: style.styleType,
      presetKey: style.presetKey,
      themePreset: style.themePreset,
      colorMode: style.colorMode,
      backgroundColor: style.backgroundColor,
      accentColor: style.accentColor,
      textColor: style.textColor,
      walletBackgroundColor: style.walletBackgroundColor,
      imageBackgroundColor: style.imageBackgroundColor,
      imageSurfaceColor: style.imageSurfaceColor,
      imageAccentColor: style.imageAccentColor,
      imageTextColor: style.imageTextColor,
      stampFilledColor: style.stampFilledColor,
      stampEmptyColor: style.stampEmptyColor,
      rewardBannerColor: style.rewardBannerColor,
      layoutVariant: style.layoutVariant,
    );
  }

  LoyaltyCardState _previewCardState() {
    final selected = widget.selectedMembership?.effectiveCardState;
    if (selected != null) {
      return selected;
    }

    final goal = widget.program?.stampGoal ?? 7;
    final safeGoal = goal <= 0 ? 7 : goal;
    final count = safeGoal < 3 ? safeGoal : 3;
    final progress = ((count / safeGoal) * 100).round();
    return LoyaltyCardState(
      stampCount: count,
      stampGoal: safeGoal,
      rewardReady: count >= safeGoal,
      progressPercent: progress,
      rewardName: widget.program?.rewardName ?? 'Free reward',
      programName: widget.program?.name ?? 'Loyalty program',
    );
  }

  List<LoyaltyStampPreset> _presetOptions() {
    final apiPresets = widget.stampPresets?.presets ?? const [];
    final options = apiPresets.isEmpty ? _fallbackPresets : apiPresets;
    return [
      ...options,
      if (!options.any((preset) => preset.key == _presetKey))
        LoyaltyStampPreset(key: _presetKey, label: _labelFor(_presetKey)),
    ];
  }

  void _applyColors(_ThemeColors colors) {
    _backgroundController.text = colors.backgroundColor;
    _accentController.text = colors.accentColor;
    _textController.text = colors.textColor;
    _walletBackgroundController.text = colors.walletBackgroundColor;
    _imageBackgroundController.text = colors.imageBackgroundColor;
    _imageSurfaceController.text = colors.imageSurfaceColor;
    _imageAccentController.text = colors.imageAccentColor;
    _imageTextController.text = colors.imageTextColor;
    _stampFilledController.text = colors.stampFilledColor;
    _stampEmptyController.text = colors.stampEmptyColor;
    _rewardBannerController.text = colors.rewardBannerColor;
  }
}

class _ColorField extends StatelessWidget {
  const _ColorField({
    required this.controller,
    required this.label,
    required this.enabled,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(labelText: label, hintText: '#111827'),
      ),
    );
  }
}

class _ThemeColors {
  const _ThemeColors({
    required this.backgroundColor,
    required this.accentColor,
    required this.textColor,
    required this.walletBackgroundColor,
    required this.imageBackgroundColor,
    required this.imageSurfaceColor,
    required this.imageAccentColor,
    required this.imageTextColor,
    required this.stampFilledColor,
    required this.stampEmptyColor,
    required this.rewardBannerColor,
  });

  final String backgroundColor;
  final String accentColor;
  final String textColor;
  final String walletBackgroundColor;
  final String imageBackgroundColor;
  final String imageSurfaceColor;
  final String imageAccentColor;
  final String imageTextColor;
  final String stampFilledColor;
  final String stampEmptyColor;
  final String rewardBannerColor;
}

_ThemeColors _themeColors(String themePreset) {
  return switch (themePreset.toUpperCase()) {
    'COFFEE' => const _ThemeColors(
      backgroundColor: '#3f2a1f',
      accentColor: '#d97706',
      textColor: '#fff7ed',
      walletBackgroundColor: '#92400e',
      imageBackgroundColor: '#7c2d12',
      imageSurfaceColor: '#92400e',
      imageAccentColor: '#facc15',
      imageTextColor: '#ffffff',
      stampFilledColor: '#facc15',
      stampEmptyColor: '#d6d3d1',
      rewardBannerColor: '#a16207',
    ),
    'RESTAURANT' => const _ThemeColors(
      backgroundColor: '#14532d',
      accentColor: '#f97316',
      textColor: '#ffffff',
      walletBackgroundColor: '#166534',
      imageBackgroundColor: '#052e16',
      imageSurfaceColor: '#166534',
      imageAccentColor: '#fed7aa',
      imageTextColor: '#ffffff',
      stampFilledColor: '#fdba74',
      stampEmptyColor: '#dcfce7',
      rewardBannerColor: '#9a3412',
    ),
    'DESSERT' => const _ThemeColors(
      backgroundColor: '#831843',
      accentColor: '#f9a8d4',
      textColor: '#fff1f2',
      walletBackgroundColor: '#be185d',
      imageBackgroundColor: '#701a75',
      imageSurfaceColor: '#9d174d',
      imageAccentColor: '#fde68a',
      imageTextColor: '#ffffff',
      stampFilledColor: '#fbcfe8',
      stampEmptyColor: '#f5d0fe',
      rewardBannerColor: '#be123c',
    ),
    'MINIMAL' => const _ThemeColors(
      backgroundColor: '#f8fafc',
      accentColor: '#334155',
      textColor: '#0f172a',
      walletBackgroundColor: '#e2e8f0',
      imageBackgroundColor: '#f1f5f9',
      imageSurfaceColor: '#ffffff',
      imageAccentColor: '#475569',
      imageTextColor: '#0f172a',
      stampFilledColor: '#334155',
      stampEmptyColor: '#cbd5e1',
      rewardBannerColor: '#e2e8f0',
    ),
    _ => const _ThemeColors(
      backgroundColor: '#111827',
      accentColor: '#f59e0b',
      textColor: '#ffffff',
      walletBackgroundColor: '#2563eb',
      imageBackgroundColor: '#7c2d12',
      imageSurfaceColor: '#92400e',
      imageAccentColor: '#facc15',
      imageTextColor: '#ffffff',
      stampFilledColor: '#facc15',
      stampEmptyColor: '#d6d3d1',
      rewardBannerColor: '#a16207',
    ),
  };
}

String _firstAllowed(
  String value,
  List<String> options, {
  required String fallback,
}) {
  final clean = value.trim();
  if (options.contains(clean)) {
    return clean;
  }
  return options.isNotEmpty ? options.first : fallback;
}

List<String> _withSelected(List<String> options, String selected) {
  final cleanOptions = options
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
  if (cleanOptions.contains(selected)) {
    return cleanOptions;
  }
  return [...cleanOptions, selected];
}

String _labelFor(String value) {
  final lower = value.replaceAll('_', ' ').toLowerCase();
  return lower.isEmpty
      ? value
      : '${lower[0].toUpperCase()}${lower.substring(1)}';
}

const _themePresetOptions = [
  'DEFAULT',
  'COFFEE',
  'RESTAURANT',
  'DESSERT',
  'MINIMAL',
  'CUSTOM',
];

const _colorModeOptions = ['PRESET', 'CUSTOM'];

const _fallbackPresets = [
  LoyaltyStampPreset(key: 'STAR', label: 'Star'),
  LoyaltyStampPreset(key: 'COOKIE', label: 'Cookie'),
  LoyaltyStampPreset(key: 'COFFEE', label: 'Coffee'),
  LoyaltyStampPreset(key: 'BOWL', label: 'Bowl'),
  LoyaltyStampPreset(key: 'BURGER', label: 'Burger'),
  LoyaltyStampPreset(key: 'PIZZA', label: 'Pizza'),
  LoyaltyStampPreset(key: 'HEART', label: 'Heart'),
  LoyaltyStampPreset(key: 'CUPCAKE', label: 'Cupcake'),
];
