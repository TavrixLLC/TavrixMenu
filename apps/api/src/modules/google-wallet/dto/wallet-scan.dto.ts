import { ApiProperty } from '@nestjs/swagger';
import { IsString, MaxLength, MinLength } from 'class-validator';

export class WalletScanDto {
  @ApiProperty({
    example: 'waflo_scan_v1.1.1781704800000.opaquePayload.signature',
    description: 'Raw opaque token read from a Google Wallet loyalty barcode.'
  })
  @IsString()
  @MinLength(1)
  @MaxLength(256)
  token!: string;
}
