import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsOptional,
  IsString,
  MaxLength
} from 'class-validator';

export class EnrollLoyaltyCustomerDto {
  @ApiPropertyOptional({ example: '+9647700000000', nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  phone?: string | null;

  @ApiPropertyOptional({ example: 'customer@example.com', nullable: true })
  @IsOptional()
  @IsEmail()
  @MaxLength(200)
  email?: string | null;

  @ApiPropertyOptional({ example: 'Demo Customer', nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(160)
  name?: string | null;

  @ApiPropertyOptional({
    example: 'loyalty_program_id',
    description: 'Optional when the business has exactly one active program.'
  })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  programId?: string;
}
