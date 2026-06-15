import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsString, Matches, ValidateIf } from 'class-validator';
import {
  HEX_COLOR_PATTERN,
  LOYALTY_STAMP_LAYOUT_VARIANTS,
  LOYALTY_STAMP_PRESET_KEYS,
  LOYALTY_STAMP_STYLE_TYPES,
  LoyaltyStampLayoutVariantValue,
  LoyaltyStampPresetKeyValue,
  LoyaltyStampStyleTypeValue
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

  @ApiPropertyOptional({
    enum: LOYALTY_STAMP_LAYOUT_VARIANTS,
    example: 'MODERN'
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsIn(LOYALTY_STAMP_LAYOUT_VARIANTS)
  layoutVariant?: LoyaltyStampLayoutVariantValue;
}
