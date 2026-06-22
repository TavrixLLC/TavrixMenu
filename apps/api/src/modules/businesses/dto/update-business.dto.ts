import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  Length,
  MaxLength,
  ValidateIf
} from 'class-validator';

export class UpdateBusinessDto {
  @ApiPropertyOptional({ example: 'Royal Cup' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  name?: string;

  @ApiPropertyOptional({ example: 'cafe' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @IsNotEmpty()
  @MaxLength(40)
  type?: string;

  @ApiPropertyOptional({ type: String, example: 'Baghdad', nullable: true })
  @ValidateIf((_, value) => value !== undefined && value !== null)
  @IsString()
  @MaxLength(80)
  city?: string | null;

  @ApiPropertyOptional({ example: 'IQD' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Length(3, 3)
  currency?: string;

  @ApiPropertyOptional({ example: 'ar' })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @MaxLength(10)
  language?: string;

  @ApiPropertyOptional({
    type: String,
    example: 'https://example.com/logo.png',
    nullable: true
  })
  @ValidateIf((_, value) => value !== undefined && value !== null)
  @IsString()
  @MaxLength(500)
  logoUrl?: string | null;

  @ApiPropertyOptional({
    type: String,
    example: 'https://example.com/cover.png',
    nullable: true
  })
  @ValidateIf((_, value) => value !== undefined && value !== null)
  @IsString()
  @MaxLength(500)
  coverUrl?: string | null;
}
