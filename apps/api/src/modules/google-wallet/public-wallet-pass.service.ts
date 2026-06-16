import { Injectable } from '@nestjs/common';
import { WalletPassPlatform, WalletPassStatus } from '../../generated/prisma';
import { PublicLoyaltyService } from '../loyalty/public-loyalty.service';
import { WalletPassService } from './wallet-pass.service';

export type PublicGoogleWalletPassResponse = {
  platform: WalletPassPlatform;
  saveUrl: string;
  status: WalletPassStatus;
  businessName: string;
  programName: string;
  lastSyncedAt: Date;
};

@Injectable()
export class PublicWalletPassService {
  constructor(
    private readonly publicLoyaltyService: PublicLoyaltyService,
    private readonly walletPassService: WalletPassService
  ) {}

  async syncGoogleWalletPass(
    token: string
  ): Promise<PublicGoogleWalletPassResponse> {
    const membership =
      await this.publicLoyaltyService.findMembershipByPublicCardToken(token);
    const pass =
      await this.walletPassService.syncResolvedGoogleWalletPass(membership);

    return {
      platform: pass.platform,
      saveUrl: pass.saveUrl,
      status: pass.status,
      businessName: membership.business.name,
      programName: membership.loyaltyProgram.name,
      lastSyncedAt: pass.lastSyncedAt
    };
  }
}
