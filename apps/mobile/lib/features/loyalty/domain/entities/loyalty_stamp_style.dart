import 'package:equatable/equatable.dart';

class LoyaltyStampPreset extends Equatable {
  const LoyaltyStampPreset({required this.key, required this.label});

  final String key;
  final String label;

  @override
  List<Object?> get props => [key, label];
}

class LoyaltyStampPresets extends Equatable {
  const LoyaltyStampPresets({
    this.presets = const [],
    this.styleTypes = const ['PRESET'],
    this.layoutVariants = const ['MODERN', 'COMPACT'],
  });

  final List<LoyaltyStampPreset> presets;
  final List<String> styleTypes;
  final List<String> layoutVariants;

  @override
  List<Object?> get props => [presets, styleTypes, layoutVariants];
}

class LoyaltyStampStyle extends Equatable {
  const LoyaltyStampStyle({
    required this.id,
    required this.loyaltyProgramId,
    this.styleType = 'PRESET',
    this.presetKey = 'STAR',
    this.themePreset,
    this.colorMode,
    this.backgroundColor,
    this.accentColor,
    this.textColor,
    this.walletBackgroundColor,
    this.imageBackgroundColor,
    this.imageSurfaceColor,
    this.imageAccentColor,
    this.imageTextColor,
    this.stampFilledColor,
    this.stampEmptyColor,
    this.rewardBannerColor,
    this.layoutVariant = 'MODERN',
    this.isDefault = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String loyaltyProgramId;
  final String styleType;
  final String presetKey;
  final String? themePreset;
  final String? colorMode;
  final String? backgroundColor;
  final String? accentColor;
  final String? textColor;
  final String? walletBackgroundColor;
  final String? imageBackgroundColor;
  final String? imageSurfaceColor;
  final String? imageAccentColor;
  final String? imageTextColor;
  final String? stampFilledColor;
  final String? stampEmptyColor;
  final String? rewardBannerColor;
  final String layoutVariant;
  final bool isDefault;
  final String? createdAt;
  final String? updatedAt;

  LoyaltyStampStyle copyWith({
    String? id,
    String? loyaltyProgramId,
    String? styleType,
    String? presetKey,
    String? themePreset,
    String? colorMode,
    String? backgroundColor,
    String? accentColor,
    String? textColor,
    String? walletBackgroundColor,
    String? imageBackgroundColor,
    String? imageSurfaceColor,
    String? imageAccentColor,
    String? imageTextColor,
    String? stampFilledColor,
    String? stampEmptyColor,
    String? rewardBannerColor,
    String? layoutVariant,
    bool? isDefault,
    String? createdAt,
    String? updatedAt,
  }) {
    return LoyaltyStampStyle(
      id: id ?? this.id,
      loyaltyProgramId: loyaltyProgramId ?? this.loyaltyProgramId,
      styleType: styleType ?? this.styleType,
      presetKey: presetKey ?? this.presetKey,
      themePreset: themePreset ?? this.themePreset,
      colorMode: colorMode ?? this.colorMode,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accentColor: accentColor ?? this.accentColor,
      textColor: textColor ?? this.textColor,
      walletBackgroundColor:
          walletBackgroundColor ?? this.walletBackgroundColor,
      imageBackgroundColor: imageBackgroundColor ?? this.imageBackgroundColor,
      imageSurfaceColor: imageSurfaceColor ?? this.imageSurfaceColor,
      imageAccentColor: imageAccentColor ?? this.imageAccentColor,
      imageTextColor: imageTextColor ?? this.imageTextColor,
      stampFilledColor: stampFilledColor ?? this.stampFilledColor,
      stampEmptyColor: stampEmptyColor ?? this.stampEmptyColor,
      rewardBannerColor: rewardBannerColor ?? this.rewardBannerColor,
      layoutVariant: layoutVariant ?? this.layoutVariant,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    loyaltyProgramId,
    styleType,
    presetKey,
    themePreset,
    colorMode,
    backgroundColor,
    accentColor,
    textColor,
    walletBackgroundColor,
    imageBackgroundColor,
    imageSurfaceColor,
    imageAccentColor,
    imageTextColor,
    stampFilledColor,
    stampEmptyColor,
    rewardBannerColor,
    layoutVariant,
    isDefault,
    createdAt,
    updatedAt,
  ];
}
