import 'reflect-metadata';
import {
  BadRequestException,
  HttpException,
  HttpStatus,
  NotFoundException,
  RequestMethod
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  GUARDS_METADATA,
  HTTP_CODE_METADATA,
  METHOD_METADATA
} from '@nestjs/common/constants';
import { strict as assert } from 'assert';
import { readFileSync } from 'fs';
import { describe, it } from 'node:test';
import { join } from 'path';
import {
  LoyaltyMembershipStatus,
  WalletPassPlatform,
  WalletPassStatus
} from '../../generated/prisma';
import { WalletScanTokenService } from '../google-wallet/wallet-scan-token.service';
import { AppleWalletPassBuilderService } from './apple-wallet-pass-builder.service';
import { AppleWalletSignerService } from './apple-wallet-signer.service';
import { AppleWalletService } from './apple-wallet.service';
import { AppleWalletUpdateAuthTokenService } from './apple-wallet-update-auth-token.service';
import {
  AppleWalletPassAssets,
  AppleWalletPassPayload,
  AppleWalletReadiness,
  GenerateAppleWalletPassInput
} from './apple-wallet.types';
import { PublicAppleWalletPassController } from './public-apple-wallet-pass.controller';
import {
  APPLE_WALLET_PASS_CONTENT_TYPE,
  APPLE_WALLET_PASS_FILE_NAME,
  PublicAppleWalletErrorCode,
  PublicAppleWalletPassService
} from './public-apple-wallet-pass.service';

class RecordingSigner {
  payload?: AppleWalletPassPayload;
  error?: Error;

  async sign(payload: AppleWalletPassPayload, _assets: AppleWalletPassAssets) {
    this.payload = payload;

    if (this.error) {
      throw this.error;
    }

    return Buffer.from('mock-signed-apple-pass');
  }
}

describe('PublicAppleWalletPassService readiness and errors', () => {
  it('returns APPLE_WALLET_DISABLED before resolving a public token', async () => {
    const setup = createSetup({ readiness: 'DISABLED' });

    await expectPublicError(
      setup.service.generatePublicPass(publicCardToken()),
      HttpStatus.SERVICE_UNAVAILABLE,
      'APPLE_WALLET_DISABLED'
    );
    assert.equal(setup.state.tokens.length, 0);
    assert.equal(setup.state.upserts.length, 0);
  });

  it('returns APPLE_WALLET_NOT_CONFIGURED before resolving a public token', async () => {
    const setup = createSetup({ readiness: 'NOT_CONFIGURED' });

    await expectPublicError(
      setup.service.generatePublicPass(publicCardToken()),
      HttpStatus.SERVICE_UNAVAILABLE,
      'APPLE_WALLET_NOT_CONFIGURED'
    );
    assert.equal(setup.state.tokens.length, 0);
    assert.equal(setup.state.upserts.length, 0);
  });

  it('maps invalid public tokens to PUBLIC_LOYALTY_CARD_NOT_FOUND', async () => {
    const setup = createSetup({
      lookupError: new NotFoundException('Internal lookup detail')
    });

    await expectPublicError(
      setup.service.generatePublicPass(publicCardToken()),
      HttpStatus.NOT_FOUND,
      'PUBLIC_LOYALTY_CARD_NOT_FOUND'
    );
    assert.equal(setup.state.upserts.length, 0);
  });

  it('maps malformed public tokens to PUBLIC_LOYALTY_CARD_NOT_FOUND', async () => {
    const setup = createSetup({
      lookupError: new BadRequestException('Internal token detail')
    });

    await expectPublicError(
      setup.service.generatePublicPass(publicCardToken()),
      HttpStatus.NOT_FOUND,
      'PUBLIC_LOYALTY_CARD_NOT_FOUND'
    );
    assert.equal(setup.state.upserts.length, 0);
  });

  it('maps signer failures to a safe error and persisted status', async () => {
    const setup = createSetup();
    setup.signer.error = new Error('Internal signing failure');

    await expectPublicError(
      setup.service.generatePublicPass(publicCardToken()),
      HttpStatus.BAD_GATEWAY,
      'APPLE_WALLET_SIGNING_FAILED'
    );

    const finalUpdate = setup.state.updates.at(-1)?.data ?? {};
    assert.equal(finalUpdate.status, WalletPassStatus.ERROR);
    assert.equal(finalUpdate.syncError, 'APPLE_WALLET_SIGNING_FAILED');
    assert.equal(JSON.stringify(finalUpdate).includes('Internal signing'), false);
  });
});

describe('PublicAppleWalletPassService token safety', () => {
  it('returns a mocked signed pass and persists only fresh scan-token metadata', async () => {
    const setup = createSetup();
    const originalLog = console.log;
    const originalError = console.error;
    const logs: string[] = [];
    console.log = (...values: unknown[]) => logs.push(values.join(' '));
    console.error = (...values: unknown[]) => logs.push(values.join(' '));

    try {
      const result = await setup.service.generatePublicPass(publicCardToken());
      const barcodeValue = setup.signer.payload?.barcodes[0]?.message ?? '';

      assert.equal(result.pass.toString(), 'mock-signed-apple-pass');
      assert.equal(result.fileName, APPLE_WALLET_PASS_FILE_NAME);
      assert.match(barcodeValue, /^waflo_scan_v1\./);
      assert.equal(barcodeValue.includes(publicCardToken()), false);
      const passPayload = setup.signer.payload as unknown as Record<
        string,
        unknown
      >;
      assert.equal(passPayload.webServiceURL, undefined);
      assert.equal(passPayload.authenticationToken, undefined);
      assert.equal(setup.signer.payload?.logoText, 'Waflo Test Business');
      assert.equal(
        setup.signer.payload?.backgroundColor,
        'rgb(14, 19, 31)'
      );
      assert.equal(setup.signer.payload?.labelColor, 'rgb(163, 165, 170)');
      assert.deepEqual(setup.signer.payload?.storeCard.headerFields, [
        {
          key: 'progress',
          label: 'STAMPS',
          value: '3 / 10',
          textAlignment: 'PKTextAlignmentRight'
        }
      ]);
      assert.deepEqual(setup.signer.payload?.storeCard.primaryFields, []);
      assert.deepEqual(setup.signer.payload?.storeCard.secondaryFields, [
        {
          key: 'reward',
          label: 'REWARD',
          value: 'Loyalty reward'
        }
      ]);
      assert.deepEqual(setup.signer.payload?.storeCard.auxiliaryFields, [
        {
          key: 'status',
          label: 'STATUS',
          value: '7 stamps to reward'
        }
      ]);
      assert.equal(JSON.stringify(result).includes(barcodeValue), false);
      assert.equal(logs.join('\n').includes(barcodeValue), false);
      assert.equal(setup.state.upserts[0]?.create.platform, WalletPassPlatform.APPLE_WALLET);

      const activeUpdate = setup.state.updates.at(-1)?.data ?? {};
      assert.equal(activeUpdate.status, WalletPassStatus.ACTIVE);
      assert.equal(typeof activeUpdate.scanTokenHash, 'string');
      assert.equal(String(activeUpdate.scanTokenHash).length, 64);
      assert.equal(Object.hasOwn(activeUpdate, 'rawToken'), false);
      assert.equal(JSON.stringify(activeUpdate).includes(barcodeValue), false);
    } finally {
      console.log = originalLog;
      console.error = originalError;
    }
  });

  it('rotates instead of reconstructing an existing Apple scan token', async () => {
    const tokenService = createTokenService();
    const basePass = walletPass();
    const oldMetadata = tokenService.buildMetadataForPass(
      basePass,
      new Date('2026-06-20T09:00:00.000Z')
    );
    const setup = createSetup({
      pass: walletPass({
        scanTokenHash: oldMetadata.scanTokenHash,
        scanTokenVersion: oldMetadata.scanTokenVersion,
        scanTokenIssuedAt: oldMetadata.scanTokenIssuedAt,
        scanTokenLast4: oldMetadata.scanTokenLast4
      })
    });

    await setup.service.generatePublicPass(publicCardToken());

    const newBarcodeValue = setup.signer.payload?.barcodes[0]?.message;
    assert.ok(newBarcodeValue);
    assert.notEqual(newBarcodeValue, oldMetadata.rawToken);
  });

  it('embeds a separate update token and persists only its metadata when enabled', async () => {
    const setup = createSetup({ updateReadiness: 'READY' });

    await setup.service.generatePublicPass(publicCardToken());

    const payload = setup.signer.payload;
    const updateToken = payload?.authenticationToken ?? '';
    const scanToken = payload?.barcodes[0]?.message ?? '';
    const activeUpdate = setup.state.updates.at(-1)?.data ?? {};

    assert.equal(
      payload?.webServiceURL,
      'http://localhost:3000/apple-wallet/v1'
    );
    assert.match(updateToken, /^waflo_apple_update_v1\./);
    assert.notEqual(updateToken, scanToken);
    assert.equal(updateToken.includes(publicCardToken()), false);
    assert.equal(String(activeUpdate.appleUpdateAuthTokenHash).length, 64);
    assert.equal(activeUpdate.appleUpdateAuthTokenVersion, 1);
    assert.ok(activeUpdate.appleUpdateAuthTokenIssuedAt instanceof Date);
    assert.equal(String(activeUpdate.appleUpdateAuthTokenLast4).length, 4);
    assert.equal(JSON.stringify(activeUpdate).includes(updateToken), false);
  });
});

describe('PublicAppleWalletPassController', () => {
  it('is an unauthenticated POST returning an Apple pass attachment', async () => {
    const service = {
      generatePublicPass: async () => ({
        pass: Buffer.from('pkpass-bytes'),
        fileName: APPLE_WALLET_PASS_FILE_NAME
      })
    };
    const controller = new PublicAppleWalletPassController(service as never);
    const guards = Reflect.getMetadata(
      GUARDS_METADATA,
      PublicAppleWalletPassController
    );
    const method = Reflect.getMetadata(
      METHOD_METADATA,
      PublicAppleWalletPassController.prototype.generateAppleWalletPass
    );
    const status = Reflect.getMetadata(
      HTTP_CODE_METADATA,
      PublicAppleWalletPassController.prototype.generateAppleWalletPass
    );
    const response = await controller.generateAppleWalletPass({
      token: publicCardToken()
    });

    assert.equal(guards, undefined);
    assert.equal(method, RequestMethod.POST);
    assert.equal(status, HttpStatus.OK);
    assert.deepEqual(response.getHeaders(), {
      type: APPLE_WALLET_PASS_CONTENT_TYPE,
      disposition: `attachment; filename="${APPLE_WALLET_PASS_FILE_NAME}"`,
      length: Buffer.byteLength('pkpass-bytes')
    });
  });

  it('documents binary public POST generation without bearer security', () => {
    const openApiPath = join(
      __dirname,
      '..',
      '..',
      '..',
      '..',
      '..',
      'docs',
      'openapi',
      'waflo-openapi-current.json'
    );
    const document = JSON.parse(readFileSync(openApiPath, 'utf8')) as {
      paths: Record<string, Record<string, unknown>>;
    };
    const path =
      document.paths['/public/loyalty/cards/{token}/apple-wallet'];
    const post = path?.post as {
      security?: unknown;
      responses?: Record<
        string,
        {
          content?: Record<string, unknown>;
          headers?: Record<string, unknown>;
        }
      >;
    };

    assert.ok(post);
    assert.equal(path.get, undefined);
    assert.equal(post.security, undefined);
    assert.ok(
      post.responses?.['200']?.content?.[APPLE_WALLET_PASS_CONTENT_TYPE]
    );
    assert.ok(post.responses?.['200']?.headers?.['Content-Disposition']);
    assert.ok(post.responses?.['404']?.content?.['application/json']);
    assert.ok(post.responses?.['502']?.content?.['application/json']);
    assert.ok(post.responses?.['503']?.content?.['application/json']);
  });
});

type MockPass = ReturnType<typeof walletPass>;

function createSetup(options: {
  readiness?: AppleWalletReadiness;
  updateReadiness?: AppleWalletReadiness;
  lookupError?: Error;
  pass?: MockPass | null;
} = {}) {
  const state: {
    tokens: string[];
    pass: MockPass | null;
    upserts: any[];
    updates: Array<{ where: { id: string }; data: Record<string, unknown> }>;
  } = {
    tokens: [],
    pass: options.pass === undefined ? null : options.pass,
    upserts: [],
    updates: []
  };
  const prisma = {
    walletPass: {
      upsert: async (args: any) => {
        state.upserts.push(args);
        state.pass = state.pass
          ? walletPass({ ...state.pass, ...args.update })
          : walletPass({ ...args.create });
        return state.pass;
      },
      update: async (args: {
        where: { id: string };
        data: Record<string, unknown>;
      }) => {
        state.updates.push(args);
        state.pass = walletPass({
          ...(state.pass ?? walletPass()),
          ...args.data,
          id: args.where.id
        });
        return state.pass;
      }
    }
  };
  const publicLoyaltyService = {
    findMembershipByPublicCardToken: async (token: string) => {
      state.tokens.push(token);

      if (options.lookupError) {
        throw options.lookupError;
      }

      return membership();
    }
  };
  const config = new ConfigService({
    APPLE_WALLET_ENABLED: true,
    APPLE_WALLET_TEAM_ID: 'A1B2C3D4E5',
    APPLE_WALLET_PASS_TYPE_IDENTIFIER: 'pass.app.waflo.loyalty',
    APPLE_WALLET_ORGANIZATION_NAME: 'Waflo',
    WALLET_SCAN_TOKEN_SECRET:
      'test-wallet-scan-token-secret-at-least-32-characters',
    APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET:
      'test-apple-update-token-secret-at-least-32-characters',
    APPLE_WALLET_WEB_SERVICE_ENABLED: options.updateReadiness === 'READY',
    APPLE_WALLET_WEB_SERVICE_BASE_URL:
      'http://localhost:3000/apple-wallet/v1'
  });
  const signer = new RecordingSigner();
  const appleWalletService = new AppleWalletService(
    config,
    new AppleWalletPassBuilderService(),
    signer as unknown as AppleWalletSignerService,
    createTokenService()
  );
  const appleWalletFacade = {
    getReadiness: () => options.readiness ?? 'READY',
    getUpdateWebServiceReadiness: () => options.updateReadiness ?? 'DISABLED',
    generatePass: (input: GenerateAppleWalletPassInput) =>
      appleWalletService.generatePass(input)
  };

  return {
    service: new PublicAppleWalletPassService(
      prisma as never,
      publicLoyaltyService as never,
      appleWalletFacade as never,
      new AppleWalletUpdateAuthTokenService(config)
    ),
    signer,
    state
  };
}

async function expectPublicError(
  promise: Promise<unknown>,
  status: HttpStatus,
  code: PublicAppleWalletErrorCode
) {
  await assert.rejects(promise, (error: unknown) => {
    assert.ok(error instanceof HttpException);
    assert.equal(error.getStatus(), status);
    assert.deepEqual(error.getResponse(), {
      statusCode: status,
      code,
      message:
        code === 'PUBLIC_LOYALTY_CARD_NOT_FOUND'
          ? 'Loyalty card not found'
          : code === 'APPLE_WALLET_SIGNING_FAILED'
            ? 'Apple Wallet pass generation failed'
            : 'Apple Wallet is unavailable'
    });
    return true;
  });
}

function membership() {
  return {
    id: 'membership_1',
    businessId: 'business_1',
    loyaltyProgramId: 'program_1',
    customerId: 'customer_1',
    stampCount: 3,
    rewardReady: false,
    totalStampsEarned: 3,
    totalRewardsRedeemed: 0,
    publicAccessTokenHash: null,
    publicAccessTokenIssuedAt: null,
    publicAccessTokenLastViewedAt: null,
    status: LoyaltyMembershipStatus.ACTIVE,
    createdAt: now(),
    updatedAt: now(),
    business: {
      id: 'business_1',
      ownerId: 'owner_1',
      name: 'Waflo Test Business',
      slug: 'waflo-test',
      type: 'other',
      logoUrl: null,
      coverUrl: null,
      currency: 'USD',
      language: 'en',
      city: 'Test City',
      status: 'ACTIVE',
      createdAt: now(),
      updatedAt: now()
    },
    customer: {
      id: 'customer_1',
      phone: null,
      email: null,
      name: 'Test Member',
      createdAt: now(),
      updatedAt: now()
    },
    loyaltyProgram: {
      id: 'program_1',
      businessId: 'business_1',
      name: 'Waflo Loyalty',
      description: 'Collect stamps.',
      stampGoal: 10,
      rewardName: 'Loyalty reward',
      rewardDescription: 'Reward after 10 stamps',
      isActive: true,
      cardColor: '#111827',
      accentColor: '#f59e0b',
      logoUrl: null,
      terms: null,
      createdAt: now(),
      updatedAt: now(),
      stampStyle: null
    }
  };
}

function walletPass(overrides: Record<string, unknown> = {}) {
  return {
    id: 'apple_pass_1',
    businessId: 'business_1',
    membershipId: 'membership_1',
    platform: WalletPassPlatform.APPLE_WALLET,
    googleClassId: null,
    googleObjectId: null,
    saveUrl: null,
    heroImageUrl: null,
    scanTokenHash: null,
    scanTokenVersion: null,
    scanTokenIssuedAt: null,
    scanTokenLast4: null,
    applePassTypeIdentifier: null,
    appleSerialNumber: null,
    appleUpdateAuthTokenHash: null,
    appleUpdateAuthTokenVersion: null,
    appleUpdateAuthTokenIssuedAt: null,
    appleUpdateAuthTokenLast4: null,
    applePassUpdatedAt: null,
    status: WalletPassStatus.PENDING,
    lastSyncedAt: null,
    syncError: null,
    createdAt: now(),
    updatedAt: now(),
    ...overrides
  };
}

function createTokenService() {
  return new WalletScanTokenService(
    new ConfigService({
      WALLET_SCAN_TOKEN_SECRET:
        'test-wallet-scan-token-secret-at-least-32-characters'
    })
  );
}

function publicCardToken() {
  return 'public_card_token_123456789012345678901234';
}

function now() {
  return new Date('2026-06-20T09:00:00.000Z');
}
