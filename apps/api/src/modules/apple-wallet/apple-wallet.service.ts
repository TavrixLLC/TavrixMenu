import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { statSync } from 'fs';
import { resolve } from 'path';
import { WalletScanTokenService } from '../google-wallet/wallet-scan-token.service';
import { AppleWalletPassBuilderService } from './apple-wallet-pass-builder.service';
import { AppleWalletSignerService } from './apple-wallet-signer.service';
import {
  AppleWalletPassGenerationResult,
  AppleWalletReadiness,
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

  getReadiness(): AppleWalletReadiness {
    if (!this.isEnabled()) {
      return 'DISABLED';
    }

    const requiredValues = [
      this.configValue('APPLE_WALLET_TEAM_ID'),
      this.configValue('APPLE_WALLET_PASS_TYPE_IDENTIFIER'),
      this.configValue('APPLE_WALLET_ORGANIZATION_NAME'),
      this.configValue('APPLE_WALLET_CERTIFICATE_PASSWORD', false),
      this.configValue('WALLET_SCAN_TOKEN_SECRET')
    ];
    const certificatePath = this.configValue(
      'APPLE_WALLET_CERTIFICATE_PATH'
    );
    const wwdrCertificatePath = this.configValue(
      'APPLE_WALLET_WWDR_CERTIFICATE_PATH'
    );

    if (
      requiredValues.some((value) => !value) ||
      this.configValue('WALLET_SCAN_TOKEN_SECRET').length < 32 ||
      !certificatePath ||
      !wwdrCertificatePath ||
      !this.configuredFileExists(certificatePath) ||
      !this.configuredFileExists(wwdrCertificatePath)
    ) {
      return 'NOT_CONFIGURED';
    }

    return 'READY';
  }

  getUpdateWebServiceReadiness(): AppleWalletReadiness {
    if (
      this.configService.get<boolean>('APPLE_WALLET_WEB_SERVICE_ENABLED') !==
      true
    ) {
      return 'DISABLED';
    }

    const baseUrl = this.configValue('APPLE_WALLET_WEB_SERVICE_BASE_URL');
    const secret = this.configValue(
      'APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET'
    );

    return baseUrl && secret.length >= 32 ? 'READY' : 'NOT_CONFIGURED';
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
    const updateFields =
      this.getUpdateWebServiceReadiness() === 'READY' &&
      input.updateAuthenticationToken
        ? {
            webServiceURL: this.requireConfig(
              'APPLE_WALLET_WEB_SERVICE_BASE_URL'
            ),
            authenticationToken: input.updateAuthenticationToken
          }
        : {};
    const builderInput = {
      ...input,
      ...updateFields,
      passTypeIdentifier,
      teamIdentifier: this.requireConfig('APPLE_WALLET_TEAM_ID'),
      organizationName: this.requireConfig('APPLE_WALLET_ORGANIZATION_NAME'),
      barcodeValue: scanToken.rawToken
    };
    const payload = this.passBuilder.buildPayload(builderInput);
    const pass = await this.signer.sign(
      payload,
      await this.passBuilder.buildAssets(builderInput)
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
    const value = this.configValue(name);

    if (!value) {
      throw new Error(`${name} is required when APPLE_WALLET_ENABLED=true`);
    }

    return value;
  }

  private configValue(name: string, trim = true) {
    const configured = this.configService.get<string>(name) ?? '';
    return trim ? configured.trim() : configured;
  }

  private configuredFileExists(path: string) {
    try {
      return statSync(resolve(path)).isFile();
    } catch {
      return false;
    }
  }
}
