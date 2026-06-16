import { Controller, Param, Post, UseGuards } from '@nestjs/common';
import {
  ApiBadGatewayResponse,
  ApiBearerAuth,
  ApiForbiddenResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiTags,
  ApiUnauthorizedResponse
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ClerkAuthGuard } from '../auth/guards/clerk-auth.guard';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { WalletPassService } from './wallet-pass.service';

@ApiTags('google wallet')
@ApiBearerAuth()
@UseGuards(ClerkAuthGuard)
@Controller('businesses/:businessId/loyalty/memberships/:membershipId/google-wallet')
@ApiUnauthorizedResponse({ description: 'Missing or invalid bearer token.' })
@ApiForbiddenResponse({
  description: 'Active OWNER, MANAGER, or STAFF membership is required.'
})
export class WalletPassController {
  constructor(private readonly walletPassService: WalletPassService) {}

  @Post()
  @ApiOkResponse({
    description:
      'Creates, syncs, or reuses a Google Wallet pass for a real loyalty membership and returns a Save URL.',
    schema: {
      example: {
        platform: 'GOOGLE_WALLET',
        membershipId: 'membership_id',
        googleClassId: '3388000000023161301.business_bus_123_loyalty_program_1',
        googleObjectId: '3388000000023161301.membership_membership_id',
        saveUrl: 'https://pay.google.com/gp/v/save/signed.jwt',
        status: 'ACTIVE',
        lastSyncedAt: '2026-06-16T09:00:00.000Z'
      }
    }
  })
  @ApiNotFoundResponse({ description: 'Loyalty membership not found.' })
  @ApiBadGatewayResponse({ description: 'Google Wallet sync failed.' })
  syncGoogleWalletPass(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('businessId') businessId: string,
    @Param('membershipId') membershipId: string
  ) {
    return this.walletPassService.syncGoogleWalletPass(
      currentUser,
      businessId,
      membershipId
    );
  }
}
