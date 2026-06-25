import { ApiProperty } from '@nestjs/swagger';
import { IsString, Length } from 'class-validator';

export class CreatePublicLoyaltyTransferDto {
  @ApiProperty({
    example: '<trusted-public-card-reference>',
    minLength: 32,
    maxLength: 128,
    description:
      'Opaque public card reference already held by the trusted browser. It is validated but never logged or stored in plaintext.'
  })
  @IsString()
  @Length(32, 128)
  cardToken!: string;
}

export class RedeemPublicLoyaltyTransferDto {
  @ApiProperty({
    example: '<short-lived-transfer-code>',
    minLength: 32,
    maxLength: 128,
    description:
      'Dedicated one-time loyalty card transfer token. Staff wallet scan QR values are not accepted.'
  })
  @IsString()
  @Length(32, 128)
  transferToken!: string;
}
