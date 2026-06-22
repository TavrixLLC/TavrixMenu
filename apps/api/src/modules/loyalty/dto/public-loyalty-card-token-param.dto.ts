import { ApiProperty } from '@nestjs/swagger';
import { IsString, Length } from 'class-validator';

export class PublicLoyaltyCardTokenParamDto {
  @ApiProperty({
    example: 'public_card_token',
    description: 'Opaque public card access token returned by enrollment.'
  })
  @IsString()
  @Length(32, 128)
  token!: string;
}
