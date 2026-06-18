import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  Length,
  MaxLength
} from 'class-validator';

export class CreateBusinessDto {
  @ApiProperty({ example: 'Royal Cup' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  name: string;

  @ApiProperty({ example: 'cafe' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(40)
  type: string;

  @ApiPropertyOptional({ example: 'Baghdad' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  city?: string;

  @ApiPropertyOptional({ example: 'IQD', default: 'IQD' })
  @IsOptional()
  @IsString()
  @Length(3, 3)
  currency?: string;

  @ApiPropertyOptional({ example: 'ar', default: 'ar' })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  language?: string;
}
