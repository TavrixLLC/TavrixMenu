import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class RedeemRewardDto {
  @ApiPropertyOptional({
    type: String,
    example: 'Free coffee redeemed',
    nullable: true
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  reason?: string | null;
}
