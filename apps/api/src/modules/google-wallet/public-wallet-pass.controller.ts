import { Controller, Param, Post } from '@nestjs/common';
import {
  ApiBadGatewayResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiTags
} from '@nestjs/swagger';
import { PublicLoyaltyCardTokenParamDto } from '../loyalty/dto/public-loyalty-card-token-param.dto';
import { PublicWalletPassService } from './public-wallet-pass.service';

@ApiTags('public loyalty')
@Controller('public/loyalty/cards/:token/google-wallet')
export class PublicWalletPassController {
  constructor(
    private readonly publicWalletPassService: PublicWalletPassService
  ) {}

  @Post()
  @ApiOkResponse({
    description:
      'Creates, syncs, or reuses a Google Wallet pass for an active public loyalty card token and returns a public-safe Save URL response.',
    schema: {
      example: {
        platform: 'GOOGLE_WALLET',
        saveUrl: 'https://pay.google.com/gp/v/save/signed.jwt',
        status: 'ACTIVE',
        businessName: 'Tavrix Cafe',
        programName: 'Tavrix Cafe Stamp Card',
        lastSyncedAt: '2026-06-16T09:00:00.000Z'
      }
    }
  })
  @ApiNotFoundResponse({
    description: 'Invalid, inactive, or expired public card token.'
  })
  @ApiBadGatewayResponse({ description: 'Google Wallet sync failed.' })
  syncGoogleWalletPass(@Param() params: PublicLoyaltyCardTokenParamDto) {
    return this.publicWalletPassService.syncGoogleWalletPass(params.token);
  }
}
