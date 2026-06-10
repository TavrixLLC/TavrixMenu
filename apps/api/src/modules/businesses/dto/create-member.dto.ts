import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';
import { BusinessUserRole } from '../../../generated/prisma';

export class CreateMemberDto {
  @ApiProperty({ example: 'user_tavrix_staff' })
  @IsString()
  @IsNotEmpty()
  clerkUserId: string;

  @ApiProperty({ enum: BusinessUserRole, example: BusinessUserRole.STAFF })
  @IsEnum(BusinessUserRole)
  role: BusinessUserRole;

  @ApiPropertyOptional({ example: 'staff@tavrix.local' })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  email?: string;

  @ApiPropertyOptional({ example: 'Tavrix Staff' })
  @IsOptional()
  @IsString()
  @MaxLength(160)
  name?: string;

  @ApiPropertyOptional({ example: '+9647700000000' })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  phone?: string;
}
