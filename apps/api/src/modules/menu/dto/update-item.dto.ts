import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsInt,
  IsNotEmpty,
  IsString,
  Matches,
  MaxLength,
  Min,
  ValidateIf
} from 'class-validator';

const pricePattern = /^\d+(\.\d{1,2})?$/;

export class UpdateItemDto {
  @ApiPropertyOptional({ example: 'category_id' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @IsNotEmpty()
  categoryId?: string;

  @ApiPropertyOptional({ example: 'Turkish Coffee' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @IsNotEmpty()
  @MaxLength(160)
  nameAr?: string;

  @ApiPropertyOptional({ type: String, example: 'Turkish Coffee', nullable: true })
  @ValidateIf((_, value) => value !== undefined && value !== null)
  @IsString()
  @MaxLength(160)
  nameEn?: string | null;

  @ApiPropertyOptional({
    type: String,
    example: 'Traditional strong coffee.',
    nullable: true
  })
  @ValidateIf((_, value) => value !== undefined && value !== null)
  @IsString()
  @MaxLength(1000)
  descriptionAr?: string | null;

  @ApiPropertyOptional({
    type: String,
    example: 'Traditional strong coffee.',
    nullable: true
  })
  @ValidateIf((_, value) => value !== undefined && value !== null)
  @IsString()
  @MaxLength(1000)
  descriptionEn?: string | null;

  @ApiPropertyOptional({ example: '3000' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(pricePattern, {
    message: 'price must be a non-negative decimal string with up to 2 decimals'
  })
  price?: string;

  @ApiPropertyOptional({
    type: String,
    example: 'https://example.com/item.png',
    nullable: true
  })
  @ValidateIf((_, value) => value !== undefined && value !== null)
  @IsString()
  @MaxLength(500)
  imageUrl?: string | null;

  @ApiPropertyOptional({ example: true })
  @ValidateIf((_, value) => value !== undefined)
  @IsBoolean()
  isAvailable?: boolean;

  @ApiPropertyOptional({ example: 0 })
  @ValidateIf((_, value) => value !== undefined)
  @Type(() => Number)
  @IsInt()
  @Min(0)
  sortOrder?: number;
}
