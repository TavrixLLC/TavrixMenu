import { Module } from '@nestjs/common';
import { GoogleWalletModule } from '../google-wallet/google-wallet.module';
import { AppleWalletPassBuilderService } from './apple-wallet-pass-builder.service';
import { AppleWalletSignerService } from './apple-wallet-signer.service';
import { AppleWalletService } from './apple-wallet.service';

@Module({
  imports: [GoogleWalletModule],
  providers: [
    AppleWalletPassBuilderService,
    AppleWalletSignerService,
    AppleWalletService
  ],
  exports: [AppleWalletService]
})
export class AppleWalletModule {}
