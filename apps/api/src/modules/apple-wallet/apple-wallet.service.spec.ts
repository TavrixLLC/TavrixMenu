import { ConfigService } from '@nestjs/config';
import { strict as assert } from 'assert';
import { readFileSync } from 'fs';
import { resolve } from 'path';
import { describe, it } from 'node:test';
import { WalletScanTokenService } from '../google-wallet/wallet-scan-token.service';
import { AppleWalletPassBuilderService } from './apple-wallet-pass-builder.service';
import { AppleWalletSignerService } from './apple-wallet-signer.service';
import { AppleWalletService } from './apple-wallet.service';
import {
  AppleWalletPassAssets,
  AppleWalletPassPayload
} from './apple-wallet.types';

class RecordingSigner {
  payload?: AppleWalletPassPayload;
  assets?: AppleWalletPassAssets;

  async sign(payload: AppleWalletPassPayload, assets: AppleWalletPassAssets) {
    this.payload = payload;
    this.assets = assets;
    return Buffer.from('mock-signed-pass');
  }
}

describe('AppleWalletPassBuilderService', () => {
  it('builds a generic store card with required identifiers and a QR barcode', () => {
    const rawToken = 'internal-sensitive-barcode-value';
    const payload = new AppleWalletPassBuilderService().buildPayload({
      passTypeIdentifier: 'pass.app.waflo.loyalty',
      serialNumber: 'waflo-test-serial',
      teamIdentifier: 'A1B2C3D4E5',
      organizationName: 'Waflo',
      barcodeValue: rawToken,
      programName: 'Waflo Loyalty',
      stampCount: 3,
      stampGoal: 10
    });

    assert.equal(payload.passTypeIdentifier, 'pass.app.waflo.loyalty');
    assert.equal(payload.teamIdentifier, 'A1B2C3D4E5');
    assert.equal(payload.serialNumber, 'waflo-test-serial');
    assert.ok(payload.storeCard);
    assert.equal(payload.barcodes[0]?.format, 'PKBarcodeFormatQR');
    assert.equal(payload.barcodes[0]?.message, rawToken);
    assert.equal(payload.barcodes[0]?.altText.includes(rawToken), false);
    assert.equal(payload.barcodes[0]?.altText, 'Scan to update loyalty');

    const visibleFields = JSON.stringify(payload.storeCard).toLowerCase();
    assert.match(visibleFields, /stamps/);
    assert.doesNotMatch(
      visibleFields,
      /restaurant|coffee|dinar|currency|iraq|points|spend/
    );
  });
});

describe('AppleWalletService', () => {
  it('stays disabled without certificates or signer activity', async () => {
    const signer = new RecordingSigner();
    const service = createService(signer, {
      APPLE_WALLET_ENABLED: false
    });

    await assert.rejects(
      () => service.generatePass(generationInput()),
      /Apple Wallet integration is disabled/
    );
    assert.equal(service.getReadiness(), 'DISABLED');
    assert.equal(signer.payload, undefined);
  });

  it('reports missing signing config without reading certificate contents', () => {
    const signer = new RecordingSigner();
    const incomplete = createService(signer);
    const configured = createService(signer, {
      APPLE_WALLET_CERTIFICATE_PATH: __filename,
      APPLE_WALLET_CERTIFICATE_PASSWORD: 'test-only-placeholder',
      APPLE_WALLET_WWDR_CERTIFICATE_PATH: __filename
    });

    assert.equal(incomplete.getReadiness(), 'NOT_CONFIGURED');
    assert.equal(configured.getReadiness(), 'READY');
    assert.equal(signer.payload, undefined);
  });

  it('keeps the raw barcode in memory and out of logs and return metadata', async () => {
    const signer = new RecordingSigner();
    const service = createService(signer);
    const logged: string[] = [];
    const originalLog = console.log;
    const originalError = console.error;
    console.log = (...values: unknown[]) => logged.push(values.join(' '));
    console.error = (...values: unknown[]) => logged.push(values.join(' '));

    try {
      const result = await service.generatePass(generationInput());
      const rawToken = signer.payload?.barcodes[0]?.message;

      assert.match(rawToken ?? '', /^waflo_scan_v1\./);
      assert.equal(JSON.stringify(result).includes(rawToken ?? ''), false);
      assert.equal(logged.join('\n').includes(rawToken ?? ''), false);
      assert.equal(
        signer.payload?.barcodes[0]?.altText.includes(rawToken ?? ''),
        false
      );
      assert.equal(result.metadata.passTypeIdentifier, 'pass.app.waflo.loyalty');
      assert.equal(result.metadata.serialNumber, 'waflo-smoke-test-serial');
      assert.equal(result.metadata.fileSize, Buffer.byteLength('mock-signed-pass'));
      assert.equal(result.pass.toString(), 'mock-signed-pass');
      assert.equal(typeof result.scanTokenMetadata.scanTokenHash, 'string');
      assert.equal(result.scanTokenMetadata.scanTokenHash.length, 64);
      assert.equal((signer.assets?.['icon.png']?.length ?? 0) > 0, true);
    } finally {
      console.log = originalLog;
      console.error = originalError;
    }
  });

  it('keeps generated Apple Wallet pass output ignored', () => {
    const gitignore = readFileSync(
      resolve(__dirname, '../../../../../.gitignore'),
      'utf8'
    );

    assert.match(gitignore, /apps\/api\/public\/generated\/apple-wallet\//);
  });
});

function createService(
  signer: RecordingSigner,
  overrides: Record<string, unknown> = {}
) {
  const config = new ConfigService({
    APPLE_WALLET_ENABLED: true,
    APPLE_WALLET_TEAM_ID: 'A1B2C3D4E5',
    APPLE_WALLET_PASS_TYPE_IDENTIFIER: 'pass.app.waflo.loyalty',
    APPLE_WALLET_ORGANIZATION_NAME: 'Waflo',
    WALLET_SCAN_TOKEN_SECRET:
      'test-wallet-scan-token-secret-at-least-32-characters',
    ...overrides
  });

  return new AppleWalletService(
    config,
    new AppleWalletPassBuilderService(),
    signer as unknown as AppleWalletSignerService,
    new WalletScanTokenService(config)
  );
}

function generationInput() {
  return {
    serialNumber: 'waflo-smoke-test-serial',
    programName: 'Waflo Loyalty',
    stampCount: 3,
    stampGoal: 10,
    rewardDescription: 'Reward after 10 stamps',
    scanTokenPass: {
      id: 'apple-wallet-smoke-pass',
      businessId: 'internal-smoke-business',
      membershipId: 'internal-smoke-membership',
      scanTokenHash: null,
      scanTokenVersion: null,
      scanTokenIssuedAt: null,
      scanTokenLast4: null
    }
  };
}
