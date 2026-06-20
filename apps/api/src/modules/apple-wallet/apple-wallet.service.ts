import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { WalletScanTokenService } from '../google-wallet/wallet-scan-token.service';
import { AppleWalletPassBuilderService } from './apple-wallet-pass-builder.service';
import { AppleWalletSignerService } from './apple-wallet-signer.service';
import {
  AppleWalletPassGenerationResult,
  GenerateAppleWalletPassInput
} from './apple-wallet.types';

@Injectable()
export class AppleWalletService {
  constructor(
    private readonly configService: ConfigService,
    private readonly passBuilder: AppleWalletPassBuilderService,
    private readonly signer: AppleWalletSignerService,
    private readonly walletScanTokenService: WalletScanTokenService
  ) {}

  isEnabled() {
    return this.configService.get<boolean>('APPLE_WALLET_ENABLED') === true;
  }

  async generatePass(
    input: GenerateAppleWalletPassInput
  ): Promise<AppleWalletPassGenerationResult> {
    this.assertEnabled();

    const passTypeIdentifier = this.requireConfig(
      'APPLE_WALLET_PASS_TYPE_IDENTIFIER'
    );
    const scanToken = this.walletScanTokenService.buildMetadataForPass(
      input.scanTokenPass
    );
    const payload = this.passBuilder.buildPayload({
      ...input,
      passTypeIdentifier,
      teamIdentifier: this.requireConfig('APPLE_WALLET_TEAM_ID'),
      organizationName: this.requireConfig('APPLE_WALLET_ORGANIZATION_NAME'),
      barcodeValue: scanToken.rawToken
    });
    const pass = await this.signer.sign(
      payload,
      await this.passBuilder.buildAssets()
    );

    return {
      pass,
      metadata: {
        passTypeIdentifier,
        serialNumber: payload.serialNumber,
        fileSize: pass.length
      },
      scanTokenMetadata: {
        scanTokenHash: scanToken.scanTokenHash,
        scanTokenVersion: scanToken.scanTokenVersion,
        scanTokenIssuedAt: scanToken.scanTokenIssuedAt,
        scanTokenLast4: scanToken.scanTokenLast4
      }
    };
  }

  private assertEnabled() {
    if (!this.isEnabled()) {
      throw new Error('Apple Wallet integration is disabled');
    }
  }

  private requireConfig(name: string) {
    const value = this.configService.get<string>(name)?.trim() ?? '';

    if (!value) {
      throw new Error(`${name} is required when APPLE_WALLET_ENABLED=true`);
    }

    return value;
  }
}
