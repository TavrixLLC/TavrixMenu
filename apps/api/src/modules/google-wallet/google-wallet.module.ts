import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { BusinessesModule } from '../businesses/businesses.module';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import {
  GOOGLE_WALLET_API_CLIENT,
  GoogleWalletRestClient
} from './google-wallet-api.client';
import { GoogleWalletService } from './google-wallet.service';
import { WalletPassController } from './wallet-pass.controller';
import { WalletPassService } from './wallet-pass.service';

@Module({
  imports: [AuthModule, BusinessesModule, LoyaltyModule],
  controllers: [WalletPassController],
  providers: [
    GoogleWalletService,
    GoogleWalletRestClient,
    WalletPassService,
    {
      provide: GOOGLE_WALLET_API_CLIENT,
      useExisting: GoogleWalletRestClient
    }
  ],
  exports: [GoogleWalletService]
})
export class GoogleWalletModule {}
