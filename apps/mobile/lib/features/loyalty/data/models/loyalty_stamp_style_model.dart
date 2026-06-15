import '../../domain/entities/loyalty_stamp_style.dart';
import 'loyalty_json.dart';

class LoyaltyStampStyleModel extends LoyaltyStampStyle {
  const LoyaltyStampStyleModel({
    required super.id,
    required super.loyaltyProgramId,
    super.styleType,
    super.presetKey,
    super.themePreset,
    super.colorMode,
    super.backgroundColor,
    super.accentColor,
    super.textColor,
    super.walletBackgroundColor,
    super.imageBackgroundColor,
    super.imageSurfaceColor,
    super.imageAccentColor,
    super.imageTextColor,
    super.stampFilledColor,
    super.stampEmptyColor,
    super.rewardBannerColor,
    super.layoutVariant,
    super.isDefault,
    super.createdAt,
    super.updatedAt,
  });

  factory LoyaltyStampStyleModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyStampStyleModel(
      id: loyaltyString(json['id']) ?? '',
      loyaltyProgramId:
          loyaltyString(json['loyaltyProgramId']) ??
          loyaltyString(json['loyalty_program_id']) ??
          '',
      styleType:
          loyaltyString(json['styleType']) ??
          loyaltyString(json['style_type']) ??
          'PRESET',
      presetKey:
          loyaltyString(json['presetKey']) ??
          loyaltyString(json['preset_key']) ??
          'STAR',
      themePreset:
          loyaltyString(json['themePreset']) ??
          loyaltyString(json['theme_preset']),
      colorMode:
          loyaltyString(json['colorMode']) ?? loyaltyString(json['color_mode']),
      backgroundColor:
          loyaltyString(json['backgroundColor']) ??
          loyaltyString(json['background_color']),
      accentColor:
          loyaltyString(json['accentColor']) ??
          loyaltyString(json['accent_color']),
      textColor:
          loyaltyString(json['textColor']) ?? loyaltyString(json['text_color']),
      walletBackgroundColor:
          loyaltyString(json['walletBackgroundColor']) ??
          loyaltyString(json['wallet_background_color']),
      imageBackgroundColor:
          loyaltyString(json['imageBackgroundColor']) ??
          loyaltyString(json['image_background_color']),
      imageSurfaceColor:
          loyaltyString(json['imageSurfaceColor']) ??
          loyaltyString(json['image_surface_color']),
      imageAccentColor:
          loyaltyString(json['imageAccentColor']) ??
          loyaltyString(json['image_accent_color']),
      imageTextColor:
          loyaltyString(json['imageTextColor']) ??
          loyaltyString(json['image_text_color']),
      stampFilledColor:
          loyaltyString(json['stampFilledColor']) ??
          loyaltyString(json['stamp_filled_color']),
      stampEmptyColor:
          loyaltyString(json['stampEmptyColor']) ??
          loyaltyString(json['stamp_empty_color']),
      rewardBannerColor:
          loyaltyString(json['rewardBannerColor']) ??
          loyaltyString(json['reward_banner_color']),
      layoutVariant:
          loyaltyString(json['layoutVariant']) ??
          loyaltyString(json['layout_variant']) ??
          'MODERN',
      isDefault:
          loyaltyBool(json['isDefault']) ??
          loyaltyBool(json['is_default']) ??
          true,
      createdAt: loyaltyDateString(json['createdAt'] ?? json['created_at']),
      updatedAt: loyaltyDateString(json['updatedAt'] ?? json['updated_at']),
    );
  }

  LoyaltyStampStyle toEntity() {
    return LoyaltyStampStyle(
      id: id,
      loyaltyProgramId: loyaltyProgramId,
      styleType: styleType,
      presetKey: presetKey,
      themePreset: themePreset,
      colorMode: colorMode,
      backgroundColor: backgroundColor,
      accentColor: accentColor,
      textColor: textColor,
      walletBackgroundColor: walletBackgroundColor,
      imageBackgroundColor: imageBackgroundColor,
      imageSurfaceColor: imageSurfaceColor,
      imageAccentColor: imageAccentColor,
      imageTextColor: imageTextColor,
      stampFilledColor: stampFilledColor,
      stampEmptyColor: stampEmptyColor,
      rewardBannerColor: rewardBannerColor,
      layoutVariant: layoutVariant,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
