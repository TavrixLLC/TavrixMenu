import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsObject, ValidateIf } from 'class-validator';
import { MENU_TEMPLATE_IDS, type MenuTemplateId } from '../menu-appearance.constants';

export class UpdateMenuAppearanceDto {
  @ApiPropertyOptional({
    enum: MENU_TEMPLATE_IDS,
    example: 'waflo-warm',
    description: 'Public menu template ID selected for this business.'
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsIn(MENU_TEMPLATE_IDS)
  menuTemplateId?: MenuTemplateId;

  @ApiPropertyOptional({
    type: Object,
    nullable: true,
    description:
      'Reserved for future merchant theme overrides. Public rendering must remain safe when this is null.'
  })
  @ValidateIf((_, value) => value !== undefined && value !== null)
  @IsObject()
  menuThemeOverrides?: Record<string, unknown> | null;
}
