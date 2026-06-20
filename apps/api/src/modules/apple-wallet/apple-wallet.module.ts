import { Module } from '@nestjs/common';
import { GoogleWalletModule } from '../google-wallet/google-wallet.module';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import { AppleWalletPassBuilderService } from './apple-wallet-pass-builder.service';
import { AppleWalletSignerService } from './apple-wallet-signer.service';
import { AppleWalletService } from './apple-wallet.service';
import { PublicAppleWalletPassController } from './public-apple-wallet-pass.controller';
import { PublicAppleWalletPassService } from './public-apple-wallet-pass.service';

@Module({
  imports: [GoogleWalletModule, LoyaltyModule],
  controllers: [PublicAppleWalletPassController],
  providers: [
    AppleWalletPassBuilderService,
    AppleWalletSignerService,
    AppleWalletService,
    PublicAppleWalletPassService
  ],
  exports: [AppleWalletService]
})
export class AppleWalletModule {}
