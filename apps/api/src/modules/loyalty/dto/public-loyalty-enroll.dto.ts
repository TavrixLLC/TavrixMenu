import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsOptional,
  IsString,
  MaxLength,
  ValidateIf
} from 'class-validator';

export class PublicLoyaltyEnrollDto {
  @ApiPropertyOptional({ example: '+9647700000000', nullable: true })
  @ValidateIf((dto: PublicLoyaltyEnrollDto) => dto.phone !== undefined || !dto.email)
  @IsString()
  @MaxLength(40)
  phone?: string | null;

  @ApiPropertyOptional({ example: 'customer@example.com', nullable: true })
  @ValidateIf((dto: PublicLoyaltyEnrollDto) => dto.email !== undefined || !dto.phone)
  @IsEmail()
  @MaxLength(200)
  email?: string | null;

  @ApiPropertyOptional({ example: 'Demo Customer', nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(160)
  name?: string | null;
}
