import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  ArrayMaxSize,
  IsArray,
  IsOptional,
  IsString,
  Length,
  Matches,
  MaxLength
} from 'class-validator';

export class AppleWalletPassPathDto {
  @ApiProperty({ description: 'Apple Pass Type Identifier.' })
  @IsString()
  @Length(1, 128)
  passTypeIdentifier!: string;

  @ApiProperty({ description: 'Opaque Apple pass serial number.' })
  @IsString()
  @Length(1, 128)
  serialNumber!: string;
}

export class AppleWalletDeviceRegistrationPathDto extends AppleWalletPassPathDto {
  @ApiProperty({ description: 'Opaque device library identifier.' })
  @IsString()
  @Length(1, 256)
  deviceLibraryIdentifier!: string;
}

export class AppleWalletDeviceListPathDto {
  @ApiProperty({ description: 'Opaque device library identifier.' })
  @IsString()
  @Length(1, 256)
  deviceLibraryIdentifier!: string;

  @ApiProperty({ description: 'Apple Pass Type Identifier.' })
  @IsString()
  @Length(1, 128)
  passTypeIdentifier!: string;
}

export class AppleWalletRegistrationDto {
  @ApiProperty({
    description: 'Sensitive APNs push token supplied by Apple Wallet.',
    writeOnly: true
  })
  @IsString()
  @Length(1, 512)
  pushToken!: string;
}

export class AppleWalletUpdatedPassesQueryDto {
  @ApiPropertyOptional({
    description: 'Opaque numeric update tag returned by the previous request.'
  })
  @IsOptional()
  @IsString()
  @Matches(/^\d+$/)
  passesUpdatedSince?: string;
}

export class AppleWalletLogDto {
  @ApiProperty({
    description: 'Apple Wallet diagnostic messages. Values are sanitized.'
  })
  @IsArray()
  @ArrayMaxSize(20)
  @IsString({ each: true })
  @MaxLength(1000, { each: true })
  logs!: string[];
}
