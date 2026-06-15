import { Module } from '@nestjs/common';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import {
  GOOGLE_WALLET_API_CLIENT,
  GoogleWalletRestClient
} from './google-wallet-api.client';
import { GoogleWalletService } from './google-wallet.service';

@Module({
  imports: [LoyaltyModule],
  providers: [
    GoogleWalletService,
    GoogleWalletRestClient,
    {
      provide: GOOGLE_WALLET_API_CLIENT,
      useExisting: GoogleWalletRestClient
    }
  ],
  exports: [GoogleWalletService]
})
export class GoogleWalletModule {}
