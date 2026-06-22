import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min
} from 'class-validator';

export class CreateLoyaltyProgramDto {
  @ApiProperty({ example: 'Tavrix Cafe Stamp Card' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(160)
  name: string;

  @ApiPropertyOptional({
    example: 'Collect stamps on coffee visits.',
    nullable: true
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  description?: string | null;

  @ApiProperty({ example: 5, minimum: 1, maximum: 50 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  stampGoal: number;

  @ApiProperty({ example: 'Free coffee' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(160)
  rewardName: string;

  @ApiPropertyOptional({
    example: 'One free Turkish Coffee after 5 stamps.',
    nullable: true
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  rewardDescription?: string | null;

  @ApiPropertyOptional({ example: true, default: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({ example: '#111827', nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(32)
  cardColor?: string | null;

  @ApiPropertyOptional({ example: '#f59e0b', nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(32)
  accentColor?: string | null;

  @ApiPropertyOptional({
    example: 'https://example.com/logo.png',
    nullable: true
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  logoUrl?: string | null;

  @ApiPropertyOptional({
    example: 'Reward is valid for dine-in orders only.',
    nullable: true
  })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  terms?: string | null;
}
