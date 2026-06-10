import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsInt,
  IsNotEmpty,
  IsString,
  MaxLength,
  Min,
  ValidateIf
} from 'class-validator';

export class UpdateCategoryDto {
  @ApiPropertyOptional({ example: 'Desserts' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  nameAr?: string;

  @ApiPropertyOptional({ type: String, example: 'Desserts', nullable: true })
  @ValidateIf((_, value) => value !== undefined && value !== null)
  @IsString()
  @MaxLength(120)
  nameEn?: string | null;

  @ApiPropertyOptional({ example: 1 })
  @ValidateIf((_, value) => value !== undefined)
  @Type(() => Number)
  @IsInt()
  @Min(0)
  sortOrder?: number;

  @ApiPropertyOptional({ example: true })
  @ValidateIf((_, value) => value !== undefined)
  @IsBoolean()
  isActive?: boolean;
}
