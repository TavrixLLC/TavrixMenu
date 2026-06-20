import { Module } from '@nestjs/common';
import { GoogleWalletModule } from '../google-wallet/google-wallet.module';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import { AppleWalletPassBuilderService } from './apple-wallet-pass-builder.service';
import { AppleWalletApnsClient } from './apple-wallet-apns.client';
import {
  APPLE_WALLET_APNS_TRANSPORT,
  NodeAppleWalletApnsTransport
} from './apple-wallet-apns.transport';
import { AppleWalletPushJobService } from './apple-wallet-push-job.service';
import { AppleWalletSignerService } from './apple-wallet-signer.service';
import { AppleWalletService } from './apple-wallet.service';
import { AppleWalletUpdateAuthTokenService } from './apple-wallet-update-auth-token.service';
import { AppleWalletUpdateController } from './apple-wallet-update.controller';
import { AppleWalletUpdateService } from './apple-wallet-update.service';
import { PublicAppleWalletPassController } from './public-apple-wallet-pass.controller';
import { PublicAppleWalletPassService } from './public-apple-wallet-pass.service';

@Module({
  imports: [GoogleWalletModule, LoyaltyModule],
  controllers: [PublicAppleWalletPassController, AppleWalletUpdateController],
  providers: [
    AppleWalletApnsClient,
    NodeAppleWalletApnsTransport,
    AppleWalletPushJobService,
    AppleWalletPassBuilderService,
    AppleWalletSignerService,
    AppleWalletService,
    AppleWalletUpdateAuthTokenService,
    AppleWalletUpdateService,
    PublicAppleWalletPassService,
    {
      provide: APPLE_WALLET_APNS_TRANSPORT,
      useExisting: NodeAppleWalletApnsTransport
    }
  ],
  exports: [AppleWalletService, AppleWalletUpdateAuthTokenService]
})
export class AppleWalletModule {}
