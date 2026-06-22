import { ApiProperty } from '@nestjs/swagger';
import { IsString, MaxLength, MinLength } from 'class-validator';

export class WalletScanDto {
  @ApiProperty({
    example: '<paste-wallet-qr-token-here>',
    description: 'Opaque value read from a supported loyalty wallet barcode.'
  })
  @IsString()
  @MinLength(1)
  @MaxLength(256)
  token!: string;
}
