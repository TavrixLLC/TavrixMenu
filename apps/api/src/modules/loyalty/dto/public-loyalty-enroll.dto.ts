import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
} from 'class-validator';

export enum PublicLoyaltyEnrollmentIntent {
  JOIN = 'JOIN',
  RECOVER = 'RECOVER'
}

export class PublicLoyaltyEnrollDto {
  @ApiProperty({
    example: '+9647700000000',
    pattern: '^(?:07\\d{9}|\\+9647\\d{9})$',
    description:
      'Required Iraqi mobile number in local 07xxxxxxxxx or international +9647xxxxxxxxx format.'
  })
  @IsString()
  @Matches(/^(?:07\d{9}|\+9647\d{9})$/, {
    message:
      'phone must use Iraqi local 07xxxxxxxxx or international +9647xxxxxxxxx format'
  })
  phone!: string;

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
    enum: PublicLoyaltyEnrollmentIntent,
    default: PublicLoyaltyEnrollmentIntent.JOIN,
    description:
      'JOIN creates or reuses a customer and membership. RECOVER returns only an existing active membership.'
  })
  @IsOptional()
  @IsEnum(PublicLoyaltyEnrollmentIntent)
  intent?: PublicLoyaltyEnrollmentIntent;
}
