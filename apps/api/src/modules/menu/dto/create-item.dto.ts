import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  Min
} from 'class-validator';

const pricePattern = /^\d+(\.\d{1,2})?$/;

export class CreateItemDto {
  @ApiProperty({ example: 'category_id' })
  @IsString()
  @IsNotEmpty()
  categoryId: string;

  @ApiProperty({ example: 'Turkish Coffee' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(160)
  nameAr: string;

  @ApiPropertyOptional({ example: 'Turkish Coffee', nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(160)
  nameEn?: string | null;

  @ApiPropertyOptional({
    example: 'Traditional strong coffee.',
    nullable: true
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  descriptionAr?: string | null;

  @ApiPropertyOptional({
    example: 'Traditional strong coffee.',
    nullable: true
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  descriptionEn?: string | null;

  @ApiProperty({ example: '3000' })
  @IsString()
  @Matches(pricePattern, {
    message: 'price must be a non-negative decimal string with up to 2 decimals'
  })
  price: string;

  @ApiPropertyOptional({ example: 'https://example.com/item.png', nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  imageUrl?: string | null;

  @ApiPropertyOptional({ example: true, default: true })
  @IsOptional()
  @IsBoolean()
  isAvailable?: boolean;

  @ApiPropertyOptional({ example: 0, default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  sortOrder?: number;
}
