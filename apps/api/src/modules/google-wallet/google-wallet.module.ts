import { Module } from '@nestjs/common';
import {
  GOOGLE_WALLET_API_CLIENT,
  GoogleWalletRestClient
} from './google-wallet-api.client';
import { GoogleWalletService } from './google-wallet.service';

@Module({
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
