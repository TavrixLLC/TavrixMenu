import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsEnum, ValidateIf } from 'class-validator';
import { BusinessUserRole } from '../../../generated/prisma';

export class UpdateMemberDto {
  @ApiPropertyOptional({ enum: BusinessUserRole, example: BusinessUserRole.MANAGER })
  @ValidateIf((_, value) => value !== undefined)
  @IsEnum(BusinessUserRole)
  role?: BusinessUserRole;

  @ApiPropertyOptional({ example: true })
  @ValidateIf((_, value) => value !== undefined)
  @IsBoolean()
  isActive?: boolean;
}
