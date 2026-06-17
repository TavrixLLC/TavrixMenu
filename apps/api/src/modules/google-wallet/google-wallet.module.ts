import { forwardRef, Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { BusinessesModule } from '../businesses/businesses.module';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import {
  GOOGLE_WALLET_API_CLIENT,
  GoogleWalletRestClient
} from './google-wallet-api.client';
import { GoogleWalletService } from './google-wallet.service';
import { PublicWalletPassController } from './public-wallet-pass.controller';
import { PublicWalletPassService } from './public-wallet-pass.service';
import { WalletPassController } from './wallet-pass.controller';
import { WalletPassService } from './wallet-pass.service';
import { WalletRefreshJobService } from './wallet-refresh-job.service';
import { WalletScanController } from './wallet-scan.controller';
import { WalletScanService } from './wallet-scan.service';
import { WalletScanTokenService } from './wallet-scan-token.service';

@Module({
  imports: [AuthModule, BusinessesModule, forwardRef(() => LoyaltyModule)],
  controllers: [
    WalletPassController,
    PublicWalletPassController,
    WalletScanController
  ],
  providers: [
    GoogleWalletService,
    GoogleWalletRestClient,
    PublicWalletPassService,
    WalletPassService,
    WalletRefreshJobService,
    WalletScanService,
    WalletScanTokenService,
    {
      provide: GOOGLE_WALLET_API_CLIENT,
      useExisting: GoogleWalletRestClient
    }
  ],
  exports: [GoogleWalletService, WalletPassService, WalletRefreshJobService]
})
export class GoogleWalletModule {}
