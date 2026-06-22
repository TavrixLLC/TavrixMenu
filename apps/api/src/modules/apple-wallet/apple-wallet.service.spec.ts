import { ConfigService } from '@nestjs/config';
import { strict as assert } from 'assert';
import { readFileSync } from 'fs';
import { resolve } from 'path';
import sharp from 'sharp';
import { describe, it } from 'node:test';
import { WalletScanTokenService } from '../google-wallet/wallet-scan-token.service';
import { resolveLoyaltyVisualStyle } from '../loyalty/loyalty-visual-style';
import { StampImageRendererService } from '../loyalty/stamp-image-renderer.service';
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
  it('builds a themed store card without duplicate native progress fields', () => {
    const rawToken = 'internal-sensitive-barcode-value';
    const payload = new AppleWalletPassBuilderService(
      new StampImageRendererService()
    ).buildPayload({
      passTypeIdentifier: 'pass.app.waflo.loyalty',
      serialNumber: 'waflo-test-serial',
      teamIdentifier: 'A1B2C3D4E5',
      organizationName: 'Waflo',
      barcodeValue: rawToken,
      businessName: 'Blue Cafe',
      programName: 'Blue ⭐ Loyalty',
      stampCount: 3,
      stampGoal: 10,
      rewardName: 'Free 🎁 reward',
      visualStyle: blueVisualStyle()
    });

    assert.equal(payload.passTypeIdentifier, 'pass.app.waflo.loyalty');
    assert.equal(payload.teamIdentifier, 'A1B2C3D4E5');
    assert.equal(payload.serialNumber, 'waflo-test-serial');
    assert.ok(payload.storeCard);
    assert.equal(payload.barcodes[0]?.format, 'PKBarcodeFormatQR');
    assert.equal(payload.barcodes[0]?.message, rawToken);
    assert.equal(payload.barcodes[0]?.altText.includes(rawToken), false);
    assert.equal(payload.barcodes[0]?.altText, 'Scan to update loyalty');
    assert.equal(payload.logoText, 'Blue Cafe');
    assert.equal(payload.backgroundColor, 'rgb(37, 99, 235)');
    assert.equal(payload.foregroundColor, 'rgb(239, 246, 255)');
    assert.equal(payload.labelColor, 'rgb(253, 224, 71)');
    assert.deepEqual(payload.storeCard.headerFields, []);
    assert.deepEqual(payload.storeCard.primaryFields, []);
    assert.deepEqual(payload.storeCard.secondaryFields, []);
    assert.deepEqual(payload.storeCard.auxiliaryFields, []);
    assert.equal(
      JSON.stringify(payload.storeCard).includes('3 of 10 stamps'),
      false
    );
    assert.equal(JSON.stringify(payload).includes('⭐'), false);
    assert.equal(JSON.stringify(payload).includes('🎁'), false);
  });

  it('builds Apple strip assets for 1x, 2x, and 3x Wallet sizes', async () => {
    const builder = new AppleWalletPassBuilderService(
      new StampImageRendererService()
    );
    const assets = await builder.buildAssets({
      passTypeIdentifier: 'pass.app.waflo.loyalty',
      serialNumber: 'waflo-test-serial',
      teamIdentifier: 'A1B2C3D4E5',
      organizationName: 'Waflo',
      barcodeValue: 'sensitive-barcode-placeholder',
      businessName: 'Blue Cafe',
      programName: 'Blue Loyalty',
      stampCount: 7,
      stampGoal: 10,
      rewardName: 'Free reward',
      visualStyle: blueVisualStyle()
    });
    const oneX = await sharp(assets['strip.png']).metadata();
    const twoX = await sharp(assets['strip@2x.png']).metadata();
    const threeX = await sharp(assets['strip@3x.png']).metadata();

    assert.deepEqual([oneX.width, oneX.height], [375, 123]);
    assert.deepEqual([twoX.width, twoX.height], [750, 246]);
    assert.deepEqual([threeX.width, threeX.height], [1125, 369]);
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
      assert.equal((signer.assets?.['strip@3x.png']?.length ?? 0) > 1000, true);
    } finally {
      console.log = originalLog;
      console.error = originalError;
    }
  });

  it('adds update fields only when the update service is ready', async () => {
    const signer = new RecordingSigner();
    const service = createService(signer, {
      APPLE_WALLET_WEB_SERVICE_ENABLED: true,
      APPLE_WALLET_WEB_SERVICE_BASE_URL: 'http://localhost:3000/apple-wallet/v1',
      APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET:
        'test-apple-update-token-secret-at-least-32-characters'
    });
    const updateToken = 'waflo_apple_update_v1.test-only-token';

    await service.generatePass({
      ...generationInput(),
      updateAuthenticationToken: updateToken
    });

    assert.equal(
      signer.payload?.webServiceURL,
      'http://localhost:3000/apple-wallet/v1'
    );
    assert.equal(signer.payload?.authenticationToken, updateToken);
    assert.notEqual(signer.payload?.barcodes[0]?.message, updateToken);
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
    new AppleWalletPassBuilderService(new StampImageRendererService()),
    signer as unknown as AppleWalletSignerService,
    new WalletScanTokenService(config)
  );
}

function generationInput() {
  return {
    serialNumber: 'waflo-smoke-test-serial',
    businessName: 'Waflo',
    programName: 'Waflo Loyalty',
    stampCount: 3,
    stampGoal: 10,
    rewardName: 'Reward',
    rewardDescription: 'Reward after 10 stamps',
    visualStyle: blueVisualStyle(),
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

function blueVisualStyle() {
  return resolveLoyaltyVisualStyle({
    stampStyle: {
      presetKey: 'STAR',
      backgroundColor: '#2563eb',
      accentColor: '#fde047',
      textColor: '#eff6ff',
      walletBackgroundColor: '#2563eb',
      imageBackgroundColor: '#1d4ed8',
      imageSurfaceColor: '#2563eb',
      imageAccentColor: '#fde047',
      imageTextColor: '#eff6ff',
      stampFilledColor: '#fde047',
      stampEmptyColor: '#bfdbfe',
      rewardBannerColor: '#1e40af',
      themePreset: 'DEFAULT',
      colorMode: 'PRESET',
      layoutVariant: 'MODERN'
    }
  });
}
