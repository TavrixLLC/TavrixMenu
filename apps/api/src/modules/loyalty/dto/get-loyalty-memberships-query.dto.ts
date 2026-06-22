import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsBooleanString, IsEnum, IsOptional, IsString } from 'class-validator';
import { LoyaltyMembershipStatus } from '../../../generated/prisma';

export class GetLoyaltyMembershipsQueryDto {
  @ApiPropertyOptional({
    example: 'customer@example.com',
    description: 'Searches customer name, email, or phone.'
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ enum: LoyaltyMembershipStatus })
  @IsOptional()
  @IsEnum(LoyaltyMembershipStatus)
  status?: LoyaltyMembershipStatus;

  @ApiPropertyOptional({ example: 'true' })
  @IsOptional()
  @IsBooleanString()
  rewardReady?: string;
}
