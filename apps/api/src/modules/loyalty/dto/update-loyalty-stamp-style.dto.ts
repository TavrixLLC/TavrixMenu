import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsString, Matches, ValidateIf } from 'class-validator';
import {
  HEX_COLOR_PATTERN,
  LOYALTY_STAMP_LAYOUT_VARIANTS,
  LOYALTY_STAMP_PRESET_KEYS,
  LOYALTY_STAMP_STYLE_TYPES,
  LOYALTY_WALLET_COLOR_MODES,
  LOYALTY_WALLET_THEME_PRESETS,
  LoyaltyStampLayoutVariantValue,
  LoyaltyStampPresetKeyValue,
  LoyaltyStampStyleTypeValue,
  LoyaltyWalletColorModeValue,
  LoyaltyWalletThemePresetValue
} from '../loyalty-stamp-style.constants';

export class UpdateLoyaltyStampStyleDto {
  @ApiPropertyOptional({
    enum: LOYALTY_STAMP_STYLE_TYPES,
    example: 'PRESET'
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsIn(LOYALTY_STAMP_STYLE_TYPES)
  styleType?: LoyaltyStampStyleTypeValue;

  @ApiPropertyOptional({
    enum: LOYALTY_STAMP_PRESET_KEYS,
    example: 'COFFEE'
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsIn(LOYALTY_STAMP_PRESET_KEYS)
  presetKey?: LoyaltyStampPresetKeyValue;

  @ApiPropertyOptional({
    enum: LOYALTY_WALLET_THEME_PRESETS,
    example: 'COFFEE'
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsIn(LOYALTY_WALLET_THEME_PRESETS)
  themePreset?: LoyaltyWalletThemePresetValue;

  @ApiPropertyOptional({
    enum: LOYALTY_WALLET_COLOR_MODES,
    example: 'PRESET'
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsIn(LOYALTY_WALLET_COLOR_MODES)
  colorMode?: LoyaltyWalletColorModeValue;

  @ApiPropertyOptional({ example: '#111827' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(HEX_COLOR_PATTERN, {
    message: 'backgroundColor must be a valid hex color'
  })
  backgroundColor?: string;

  @ApiPropertyOptional({ example: '#f59e0b' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(HEX_COLOR_PATTERN, {
    message: 'accentColor must be a valid hex color'
  })
  accentColor?: string;

  @ApiPropertyOptional({ example: '#ffffff' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(HEX_COLOR_PATTERN, {
    message: 'textColor must be a valid hex color'
  })
  textColor?: string;

  @ApiPropertyOptional({ example: '#2563eb' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(HEX_COLOR_PATTERN, {
    message: 'walletBackgroundColor must be a valid hex color'
  })
  walletBackgroundColor?: string;

  @ApiPropertyOptional({ example: '#7c2d12' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(HEX_COLOR_PATTERN, {
    message: 'imageBackgroundColor must be a valid hex color'
  })
  imageBackgroundColor?: string;

  @ApiPropertyOptional({ example: '#92400e' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(HEX_COLOR_PATTERN, {
    message: 'imageSurfaceColor must be a valid hex color'
  })
  imageSurfaceColor?: string;

  @ApiPropertyOptional({ example: '#facc15' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(HEX_COLOR_PATTERN, {
    message: 'imageAccentColor must be a valid hex color'
  })
  imageAccentColor?: string;

  @ApiPropertyOptional({ example: '#ffffff' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(HEX_COLOR_PATTERN, {
    message: 'imageTextColor must be a valid hex color'
  })
  imageTextColor?: string;

  @ApiPropertyOptional({ example: '#facc15' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(HEX_COLOR_PATTERN, {
    message: 'stampFilledColor must be a valid hex color'
  })
  stampFilledColor?: string;

  @ApiPropertyOptional({ example: '#d6d3d1' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(HEX_COLOR_PATTERN, {
    message: 'stampEmptyColor must be a valid hex color'
  })
  stampEmptyColor?: string;

  @ApiPropertyOptional({ example: '#a16207' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(HEX_COLOR_PATTERN, {
    message: 'rewardBannerColor must be a valid hex color'
  })
  rewardBannerColor?: string;

  @ApiPropertyOptional({
    enum: LOYALTY_STAMP_LAYOUT_VARIANTS,
    example: 'MODERN'
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsIn(LOYALTY_STAMP_LAYOUT_VARIANTS)
  layoutVariant?: LoyaltyStampLayoutVariantValue;
}
