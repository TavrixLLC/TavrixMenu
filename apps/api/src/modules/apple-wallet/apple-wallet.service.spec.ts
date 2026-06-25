import { ConfigService } from '@nestjs/config';
import { strict as assert } from 'assert';
import { readFileSync } from 'fs';
import { resolve } from 'path';
import { describe, it } from 'node:test';
import sharp from 'sharp';
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
    assert.equal(payload.barcodes[0]?.altText, 'Scan at checkout');

    const visibleFields = JSON.stringify({
      headerFields: payload.storeCard.headerFields,
      primaryFields: payload.storeCard.primaryFields,
      secondaryFields: payload.storeCard.secondaryFields,
      auxiliaryFields: payload.storeCard.auxiliaryFields
    }).toLowerCase();
    assert.match(visibleFields, /stamps|reward|status/);
    assert.doesNotMatch(
      visibleFields,
      /restaurant|coffee|dinar|currency|iraq|points|spend/
    );
  });

  it('builds a themed loyalty hierarchy with a concise update boundary', () => {
    const payload = new AppleWalletPassBuilderService().buildPayload({
      passTypeIdentifier: 'pass.app.waflo.loyalty',
      serialNumber: 'waflo-themed-serial',
      teamIdentifier: 'A1B2C3D4E5',
      organizationName: 'Waflo',
      barcodeValue: 'internal-sensitive-barcode-value',
      businessName: 'Tavrix Cafe',
      programName: 'Coffee Rewards',
      programDescription: 'A simple coffee loyalty card.',
      stampCount: 7,
      stampGoal: 10,
      rewardName: 'Free Turkish coffee',
      rewardDescription: 'Choose one Turkish coffee from the regular menu.',
      terms: 'One reward per completed card.',
      theme: {
        walletBackgroundColor: '#123abc',
        imageAccentColor: '#f59e0b',
        imageTextColor: '#f9fafb'
      }
    });

    assert.equal(payload.logoText, 'Tavrix Cafe');
    assert.equal(payload.backgroundColor, 'rgb(14, 46, 150)');
    assert.equal(payload.foregroundColor, 'rgb(255, 255, 255)');
    assert.equal(payload.labelColor, 'rgb(163, 176, 215)');
    assert.equal(payload.suppressStripShine, true);
    assert.deepEqual(payload.storeCard.headerFields, [
      {
        key: 'progress',
        label: 'STAMPS',
        value: '7 / 10',
        textAlignment: 'PKTextAlignmentRight'
      }
    ]);
    assert.deepEqual(payload.storeCard.primaryFields, []);
    assert.deepEqual(payload.storeCard.secondaryFields, [
      {
        key: 'reward',
        label: 'REWARD',
        value: 'Free Turkish coffee'
      }
    ]);
    assert.deepEqual(payload.storeCard.auxiliaryFields, [
      {
        key: 'status',
        label: 'STATUS',
        value: '3 stamps to reward'
      }
    ]);

    const backText = JSON.stringify(payload.storeCard.backFields);
    assert.match(backText, /A simple coffee loyalty card/);
    assert.match(backText, /One reward per completed card/);
    assert.doesNotMatch(backText, /web loyalty card/);
    assert.doesNotMatch(backText, /auto.?refresh|automatically update/i);
    assert.equal(payload.barcodes[0]?.format, 'PKBarcodeFormatQR');
    assert.equal(
      payload.barcodes[0]?.message,
      'internal-sensitive-barcode-value'
    );
  });

  it('falls back from invalid colors without weakening the loyalty hierarchy', () => {
    const payload = new AppleWalletPassBuilderService().buildPayload({
      passTypeIdentifier: 'pass.app.waflo.loyalty',
      serialNumber: 'waflo-fallback-serial',
      teamIdentifier: 'A1B2C3D4E5',
      organizationName: 'Waflo',
      barcodeValue: 'internal-sensitive-barcode-value',
      businessName: 'Tavrix Cafe',
      stampCount: 10,
      stampGoal: 10,
      rewardName: 'Free coffee',
      theme: {
        walletBackgroundColor: 'not-a-color',
        imageAccentColor: '#abc',
        imageTextColor: ''
      }
    });

    assert.equal(payload.backgroundColor, 'rgb(30, 79, 188)');
    assert.equal(payload.foregroundColor, 'rgb(255, 255, 255)');
    assert.equal(payload.labelColor, 'rgb(170, 188, 230)');
    assert.deepEqual(payload.storeCard.primaryFields, []);
    assert.equal(payload.storeCard.headerFields.length, 1);
    assert.equal(payload.barcodes.length, 1);
  });

  it('keeps the long staging business name native and out of strip content', () => {
    const payload = new AppleWalletPassBuilderService().buildPayload({
      passTypeIdentifier: 'pass.app.waflo.loyalty',
      serialNumber: 'waflo-birthday-serial',
      teamIdentifier: 'A1B2C3D4E5',
      organizationName: 'Waflo',
      barcodeValue: 'internal-sensitive-barcode-value',
      businessName: 'Happy Birthday Staging',
      programName: 'Happy Birthday Loyalty',
      stampCount: 4,
      stampGoal: 10,
      rewardName: 'Free Staging Reward'
    });

    assert.equal(payload.logoText, 'Happy Birthday Staging');
    assert.equal(payload.storeCard.primaryFields.length, 0);
    assert.deepEqual(payload.storeCard.headerFields[0], {
      key: 'progress',
      label: 'STAMPS',
      value: '4 / 10',
      textAlignment: 'PKTextAlignmentRight'
    });
    assert.equal(
      payload.storeCard.secondaryFields[0]?.value,
      'Free Staging Reward'
    );
  });

  it('renders theme-aware icon, logo, and strip assets in PassKit sizes', async () => {
    const builder = new AppleWalletPassBuilderService();
    const input = {
      passTypeIdentifier: 'pass.app.waflo.loyalty',
      serialNumber: 'waflo-assets-serial',
      teamIdentifier: 'A1B2C3D4E5',
      organizationName: 'Waflo',
      barcodeValue: 'internal-sensitive-barcode-value',
      businessName: 'Tavrix Cafe',
      programName: 'Coffee Rewards',
      stampCount: 4,
      stampGoal: 10,
      rewardName: 'Free coffee',
      theme: {
        imageBackgroundColor: '#111827',
        imageSurfaceColor: '#1f2937',
        imageAccentColor: '#f59e0b',
        imageTextColor: '#ffffff',
        stampFilledColor: '#f59e0b',
        stampEmptyColor: '#6b7280'
      }
    };
    const assets = await builder.buildAssets(input);

    assert.deepEqual(Object.keys(assets).sort(), [
      'icon.png',
      'icon@2x.png',
      'icon@3x.png',
      'logo.png',
      'logo@2x.png',
      'logo@3x.png',
      'strip.png',
      'strip@2x.png',
      'strip@3x.png'
    ]);
    assert.deepEqual(
      await imageSize(assets['logo.png']),
      { width: 50, height: 50 }
    );
    assert.deepEqual(
      await imageSize(assets['logo@3x.png']),
      { width: 150, height: 150 }
    );
    assert.deepEqual(
      await imageSize(assets['strip.png']),
      { width: 375, height: 123 }
    );
    assert.deepEqual(
      await imageSize(assets['strip@2x.png']),
      { width: 750, height: 246 }
    );
    assert.deepEqual(
      await imageSize(assets['strip@3x.png']),
      { width: 1125, height: 369 }
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
      assert.equal((signer.assets?.['strip@2x.png']?.length ?? 0) > 0, true);
    } finally {
      console.log = originalLog;
      console.error = originalError;
    }
  });

  it('adds update fields only when the update service is ready', async () => {
    const signer = new RecordingSigner();
    const service = createService(signer, {
      APPLE_WALLET_WEB_SERVICE_ENABLED: true,
      APPLE_WALLET_WEB_SERVICE_BASE_URL: 'http://localhost:3000/apple-wallet',
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
      'http://localhost:3000/apple-wallet'
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

  it('keeps the Apple device-registration and APNs blocker unresolved', () => {
    const blocker = readFileSync(
      resolve(
        __dirname,
        '../../../../../docs/blockers/apple-wallet-device-registration-no-callback.md'
      ),
      'utf8'
    );

    assert.match(
      blocker,
      /BLOCKED_BY_DEVICE_REGISTRATION_NO_DEVICE_CALLBACK/
    );
    assert.match(blocker, /\(APNs\) updates \*\*cannot be tested\*\*/);
    assert.doesNotMatch(blocker, /RESOLVED_BY_/);
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

async function imageSize(image: Buffer) {
  const metadata = await sharp(image).metadata();
  return {
    width: metadata.width,
    height: metadata.height
  };
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
