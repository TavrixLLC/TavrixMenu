import 'reflect-metadata';
import {
  BadRequestException,
  BadGatewayException,
  ForbiddenException,
  NotFoundException,
  RequestMethod
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GUARDS_METADATA, METHOD_METADATA } from '@nestjs/common/constants';
import { strict as assert } from 'assert';
import { readFileSync } from 'fs';
import { describe, it } from 'node:test';
import { join } from 'path';
import {
  LoyaltyMembershipStatus,
  WalletPassPlatform,
  WalletPassStatus
} from '../../generated/prisma';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { ClerkAuthGuard } from '../auth/guards/clerk-auth.guard';
import { GoogleWalletApiError } from './google-wallet-api.client';
import { PublicWalletPassController } from './public-wallet-pass.controller';
import { PublicWalletPassService } from './public-wallet-pass.service';
import { WalletPassController } from './wallet-pass.controller';
import { WalletPassService } from './wallet-pass.service';
import { WalletScanTokenService } from './wallet-scan-token.service';

type MockState = {
  membership: ReturnType<typeof membership> | null;
  pass: ReturnType<typeof walletPass> | null;
  createdPasses: number;
  membershipQueries: unknown[];
  walletPassFindQueries: unknown[];
  upsertArgs: unknown[];
  updateArgs: Array<{
    where: { id: string };
    data: Record<string, unknown>;
  }>;
};

class MockGoogleWalletService {
  readonly classInputs: unknown[] = [];
  readonly objectInputs: unknown[] = [];
  readonly upsertedClasses: unknown[] = [];
  readonly upsertedObjects: unknown[] = [];

  enabled = true;
  upsertClassError?: Error;
  upsertObjectError?: Error;

  isEnabled() {
    return this.enabled;
  }

  buildLoyaltyClassPayload(input: {
    classSuffix: string;
    programName?: string;
    hexBackgroundColor?: string;
  }) {
    this.classInputs.push(input);

    return {
      id: `issuer.${input.classSuffix}`,
      issuerName: 'Tavrix Cafe',
      reviewStatus: 'UNDER_REVIEW',
      programName: input.programName ?? 'Rewards',
      programLogo: {
        sourceUri: {
          uri: 'https://example.test/logo.png'
        },
        contentDescription: {
          defaultValue: {
            language: 'en-US',
            value: 'Logo'
          }
        }
      },
      accountNameLabel: 'Member',
      accountIdLabel: 'Member ID',
      hexBackgroundColor: input.hexBackgroundColor
    };
  }

  buildLoyaltyObjectPayload(input: {
    classSuffix: string;
    objectSuffix: string;
    accountName: string;
    accountId: string;
    barcodeValue?: string;
    barcodeAlternateText?: string;
    includeBarcode?: boolean;
    includeLoyaltyPoints?: boolean;
    includeTextModules?: boolean;
    heroImageUrl?: string;
  }) {
    this.objectInputs.push(input);

    return {
      id: `issuer.${input.objectSuffix}`,
      classId: `issuer.${input.classSuffix}`,
      state: 'ACTIVE',
      accountName: input.accountName,
      accountId: input.accountId,
      ...(input.includeBarcode === false
        ? {}
        : {
            barcode: {
              type: 'QR_CODE',
              value: input.barcodeValue ?? input.accountId,
              alternateText: input.barcodeAlternateText ?? input.accountId
            }
          }),
      ...(input.includeLoyaltyPoints === false
        ? {}
        : {
            loyaltyPoints: {
              label: 'Progress',
              balance: {
                string: `${(input as any).stampCount}/${(input as any).stampGoal}`
              }
            }
          }),
      ...(input.includeTextModules === false
        ? {}
        : {
            textModulesData: [
              {
                id: 'progress',
                header: 'Progress',
                body: (input as any).progressText
              }
            ]
          }),
      heroImage: input.heroImageUrl
        ? {
            sourceUri: {
              uri: input.heroImageUrl
            },
            contentDescription: {
              defaultValue: {
                language: 'en-US',
                value: 'Hero image'
              }
            }
          }
        : undefined
    };
  }

  async upsertLoyaltyClass(payload: unknown) {
    if (this.upsertClassError) {
      throw this.upsertClassError;
    }

    this.upsertedClasses.push(payload);

    return payload;
  }

  async upsertLoyaltyObject(payload: unknown) {
    if (this.upsertObjectError) {
      throw this.upsertObjectError;
    }

    this.upsertedObjects.push(payload);

    return payload;
  }

  generateSaveUrl(input: unknown) {
    return `https://pay.google.com/gp/v/save/${Buffer.from(
      JSON.stringify(input)
    ).toString('base64url')}`;
  }
}

class MockStampImageStorage {
  readonly renderInputs: unknown[] = [];

  constructor(private readonly publicUrl?: string) {}

  async renderAndStore(input: unknown) {
    this.renderInputs.push(input);
    const membershipId =
      typeof (input as { membershipId?: unknown }).membershipId === 'string'
        ? (input as { membershipId: string }).membershipId
        : 'membership';
    const publicUrl =
      this.publicUrl ??
      `https://api.example.test/generated/wallet-stamps/${membershipId}.png`;

    return {
      fileName: `${membershipId}.png`,
      relativePath: `wallet-stamps/${membershipId}.png`,
      absolutePath: 'D:\\secret\\wallet-stamps\\membership_1.png',
      localPublicPath: `/generated/wallet-stamps/${membershipId}.png`,
      publicUrl
    };
  }

  requirePublicUrl(storedImage: { publicUrl: string | null }) {
    if (!storedImage.publicUrl) {
      throw new Error(
        'WALLET_IMAGE_PUBLIC_BASE_URL is required to attach generated Wallet images'
      );
    }

    return storedImage.publicUrl;
  }
}

describe('WalletPassService', () => {
  it('POST sync creates WalletPass for membership and returns a Google Wallet Save URL', async () => {
    const { service, state, wallet } = createService();

    const response = await service.syncGoogleWalletPass(
      user('staff_1'),
      'business_1',
      'membership_1'
    );

    assert.equal(state.createdPasses, 1);
    assert.equal(state.pass?.platform, WalletPassPlatform.GOOGLE_WALLET);
    assert.equal(response.platform, WalletPassPlatform.GOOGLE_WALLET);
    assert.equal(response.membershipId, 'membership_1');
    assert.match(response.googleClassId, /^issuer\.business_[a-f0-9]{24}$/);
    assert.match(response.googleObjectId, /^issuer\.membership_[a-f0-9]{24}$/);
    assert.equal(response.googleClassId.includes('business_1'), false);
    assert.equal(response.googleClassId.includes('program_1'), false);
    assert.equal(response.googleObjectId.includes('membership_1'), false);
    assert.equal(response.saveUrl.startsWith('https://pay.google.com/gp/v/save/'), true);
    assert.equal(response.status, WalletPassStatus.ACTIVE);
    assert.equal(wallet.upsertedClasses.length, 1);
    assert.equal(wallet.upsertedObjects.length, 1);
    assert.equal(state.updateArgs.at(-1)?.data.status, WalletPassStatus.ACTIVE);
  });

  it('repeated POST idempotently reuses an existing WalletPass row', async () => {
    const existingPass = walletPass({
      id: 'pass_existing',
      status: WalletPassStatus.ACTIVE
    });
    const { service, state } = createService({
      pass: existingPass
    });

    const response = await service.syncGoogleWalletPass(
      user('staff_1'),
      'business_1',
      'membership_1'
    );

    assert.equal(state.createdPasses, 0);
    assert.equal(state.pass?.id, 'pass_existing');
    assert.match(response.googleObjectId, /^issuer\.membership_[a-f0-9]{24}$/);
    assert.equal(response.googleObjectId.includes('membership_1'), false);
    assert.deepEqual((state.upsertArgs[0] as any).where, {
      membershipId_platform: {
        membershipId: 'membership_1',
        platform: WalletPassPlatform.GOOGLE_WALLET
      }
    });
  });

  it('rejects cross-business membership access', async () => {
    const { service, state } = createService({
      membership: null
    });

    await assert.rejects(
      () =>
        service.syncGoogleWalletPass(user('staff_1'), 'business_1', 'membership_2'),
      NotFoundException
    );
    assert.equal(state.upsertArgs.length, 0);
  });

  it('rejects unauthorized business access before querying memberships', async () => {
    const { service, state } = createService({
      assertRole: async () => {
        throw new ForbiddenException('Insufficient business role');
      }
    });

    await assert.rejects(
      () =>
        service.syncGoogleWalletPass(user('guest_1'), 'business_1', 'membership_1'),
      ForbiddenException
    );
    assert.equal(state.membershipQueries.length, 0);
  });

  it('uses the current loyalty program stamp style and wallet theme', async () => {
    const currentMembership = membership({
      loyaltyProgram: {
        ...membership().loyaltyProgram,
        name: 'Current Cafe Rewards',
        stampStyle: {
          id: 'style_1',
          loyaltyProgramId: 'program_1',
          styleType: 'PRESET',
          presetKey: 'COFFEE',
          backgroundColor: '#101827',
          accentColor: '#f97316',
          textColor: '#fff7ed',
          walletBackgroundColor: '#065f46',
          imageBackgroundColor: '#064e3b',
          imageSurfaceColor: '#047857',
          imageAccentColor: '#34d399',
          imageTextColor: '#ecfdf5',
          stampFilledColor: '#34d399',
          stampEmptyColor: '#a7f3d0',
          rewardBannerColor: '#047857',
          themePreset: 'RESTAURANT',
          colorMode: 'CUSTOM',
          layoutVariant: 'COMPACT',
          createdAt: new Date('2026-06-15T00:00:00.000Z'),
          updatedAt: new Date('2026-06-15T00:00:00.000Z')
        }
      }
    });
    const { service, wallet, storage } = createService({
      membership: currentMembership
    });

    await service.syncGoogleWalletPass(user('staff_1'), 'business_1', 'membership_1');

    const renderInput = storage.renderInputs[0] as Record<string, unknown>;
    const classInput = wallet.classInputs[0] as Record<string, unknown>;

    assert.equal(renderInput.programName, 'Current Cafe Rewards');
    assert.equal(renderInput.presetKey, 'COFFEE');
    assert.equal(renderInput.imageBackgroundColor, '#064e3b');
    assert.equal(renderInput.stampFilledColor, '#34d399');
    assert.equal(renderInput.rewardBannerColor, '#047857');
    assert.equal(renderInput.themePreset, 'RESTAURANT');
    assert.equal(renderInput.layoutVariant, 'COMPACT');
    assert.equal(classInput.hexBackgroundColor, '#065f46');
  });

  it('keeps legacy fallback colors consistent between native and hero surfaces', async () => {
    const { service, wallet, storage } = createService();

    await service.syncGoogleWalletPass(
      user('staff_1'),
      'business_1',
      'membership_1'
    );

    const renderInput = storage.renderInputs[0] as Record<string, unknown>;
    const classInput = wallet.classInputs[0] as Record<string, unknown>;

    assert.equal(classInput.hexBackgroundColor, '#111827');
    assert.equal(renderInput.imageBackgroundColor, '#111827');
    assert.equal(renderInput.imageAccentColor, '#f59e0b');
  });

  it('suppresses duplicate Google progress text when the hero image exists', async () => {
    const { service, wallet } = createService();

    await service.syncGoogleWalletPass(
      user('staff_1'),
      'business_1',
      'membership_1'
    );

    const objectInput = wallet.objectInputs[0] as Record<string, unknown>;
    const objectPayload = wallet.upsertedObjects[0] as Record<string, unknown>;

    assert.equal(objectInput.includeLoyaltyPoints, false);
    assert.equal(objectInput.includeTextModules, false);
    assert.ok(objectPayload.heroImage);
    assert.equal(objectPayload.loyaltyPoints, undefined);
    assert.equal(objectPayload.textModulesData, undefined);
  });

  it('does not leak local file paths in the response or persisted wallet fields', async () => {
    const { service, state, wallet } = createService();

    const response = await service.syncGoogleWalletPass(
      user('staff_1'),
      'business_1',
      'membership_1'
    );
    const responseJson = JSON.stringify(response);
    const finalUpdate = state.updateArgs.at(-1)?.data ?? {};
    const objectInput = wallet.objectInputs[0] as Record<string, unknown>;

    assert.equal(responseJson.includes('D:\\'), false);
    assert.equal(JSON.stringify(finalUpdate).includes('D:\\'), false);
    assert.equal(String(objectInput.heroImageUrl).startsWith('https://'), true);
    assert.equal(String(objectInput.heroImageUrl).includes('D:\\'), false);
  });

  it('includes a secure barcode without persisting or returning the raw scan token', async () => {
    const { service, state, wallet } = createService();

    const response = await service.syncGoogleWalletPass(
      user('staff_1'),
      'business_1',
      'membership_1'
    );
    const createInput = (state.upsertArgs[0] as any).create as Record<
      string,
      unknown
    >;
    const tokenUpdate = state.updateArgs.find((update) =>
      Object.hasOwn(update.data, 'scanTokenHash')
    )?.data;
    const objectInput = wallet.objectInputs[0] as Record<string, unknown>;
    const objectPayload = wallet.upsertedObjects[0] as Record<string, unknown>;
    const barcode = objectPayload.barcode as {
      type: string;
      value: string;
      alternateText: string;
    };
    const rawToken = String(objectInput.barcodeValue);

    assert.equal(Object.hasOwn(createInput, 'scanToken'), false);
    assert.ok(tokenUpdate);
    assert.match(rawToken, /^waflo_scan_v1\./);
    assert.equal(barcode.type, 'QR_CODE');
    assert.ok(barcode.value);
    assert.equal(barcode.value, rawToken);
    assert.notEqual(barcode.value, objectPayload.accountId);
    assert.equal(String(barcode.value).startsWith('WAFLO-'), false);
    assert.notEqual(barcode.alternateText, rawToken);
    assert.equal(
      barcode.alternateText,
      `Scan code ending ${rawToken.slice(-4).toUpperCase()}`
    );
    assert.equal(typeof tokenUpdate.scanTokenHash, 'string');
    assert.equal(String(tokenUpdate.scanTokenHash).length, 64);
    assert.equal(tokenUpdate.scanTokenHash === rawToken, false);
    assert.equal(tokenUpdate.scanTokenVersion, 1);
    assert.equal(tokenUpdate.scanTokenLast4, rawToken.slice(-4));
    assert.equal(JSON.stringify(response).includes(rawToken), false);
    assert.equal(
      JSON.stringify([...state.upsertArgs, ...state.updateArgs]).includes(rawToken),
      false
    );
    assert.equal(
      Object.hasOwn(response as unknown as Record<string, unknown>, 'scanTokenHash'),
      false
    );
  });

  it('stores a token hash and validates the generated barcode token', async () => {
    const tokenService = createTokenService();
    const { service, state, wallet } = createService({
      tokenService
    });

    await service.syncGoogleWalletPass(user('staff_1'), 'business_1', 'membership_1');

    const rawToken = String(
      (wallet.objectInputs[0] as Record<string, unknown>).barcodeValue
    );

    assert.ok(state.pass?.scanTokenHash);
    assert.equal(tokenService.verifyForPass(rawToken, state.pass!), true);
    assert.equal(tokenService.parse(rawToken)?.token, rawToken);
    assert.equal(tokenService.verifyForPass(`${rawToken.slice(0, -1)}x`, state.pass!), false);
    assert.equal(tokenService.parse('not-a-wallet-token'), null);
  });

  it('repeated Add to Wallet rebuilds a stable barcode without raw token persistence', async () => {
    const tokenService = createTokenService();
    const { service, state, wallet } = createService({
      tokenService
    });

    await service.syncGoogleWalletPass(user('staff_1'), 'business_1', 'membership_1');
    const firstRawToken = String(
      (wallet.objectInputs.at(-1) as Record<string, unknown>).barcodeValue
    );

    await service.syncGoogleWalletPass(user('staff_1'), 'business_1', 'membership_1');
    const secondRawToken = String(
      (wallet.objectInputs.at(-1) as Record<string, unknown>).barcodeValue
    );
    const tokenUpdates = state.updateArgs.filter((update) =>
      Object.hasOwn(update.data, 'scanTokenHash')
    );

    assert.equal(firstRawToken, secondRawToken);
    assert.equal(tokenUpdates.length, 1);
    assert.equal(JSON.stringify(state.pass).includes(firstRawToken), false);
  });

  it('refreshes an existing WalletPass with updated progress and preserves the barcode token', async () => {
    const tokenService = createTokenService();
    const existingPass = walletPass({
      id: 'pass_existing',
      status: WalletPassStatus.ACTIVE
    });
    const metadata = tokenService.buildMetadataForPass(existingPass);
    const { service, state, wallet } = createService({
      tokenService,
      pass: walletPass({
        ...existingPass,
        scanTokenHash: metadata.scanTokenHash,
        scanTokenVersion: metadata.scanTokenVersion,
        scanTokenIssuedAt: metadata.scanTokenIssuedAt,
        scanTokenLast4: metadata.scanTokenLast4
      }),
      membership: membership({
        stampCount: 4
      })
    });

    const response =
      await service.refreshGoogleWalletPassForMembership('membership_1');
    const objectInput = wallet.objectInputs[0] as Record<string, unknown>;
    const objectPayload = wallet.upsertedObjects[0] as Record<string, any>;
    const tokenUpdates = state.updateArgs.filter((update) =>
      Object.hasOwn(update.data, 'scanTokenHash')
    );

    assert.equal(response.status, 'REFRESHED');
    assert.equal(wallet.upsertedClasses.length, 0);
    assert.equal(wallet.upsertedObjects.length, 1);
    assert.equal(objectInput.stampCount, 4);
    assert.equal(objectInput.progressText, '4 of 5 stamps collected');
    assert.equal(objectPayload.loyaltyPoints, undefined);
    assert.equal(objectPayload.textModulesData, undefined);
    assert.ok(objectPayload.heroImage);
    assert.equal(objectPayload.barcode.type, 'QR_CODE');
    assert.equal(objectPayload.barcode.value, metadata.rawToken);
    assert.notEqual(objectPayload.barcode.alternateText, metadata.rawToken);
    assert.equal(tokenUpdates.length, 0);
    assert.equal(state.pass?.scanTokenHash, metadata.scanTokenHash);
    assert.equal(JSON.stringify(response).includes(metadata.rawToken), false);
  });

  it('does not rotate the scan token across repeated WalletPass refreshes', async () => {
    const tokenService = createTokenService();
    const existingPass = walletPass({
      id: 'pass_existing',
      status: WalletPassStatus.ACTIVE
    });
    const metadata = tokenService.buildMetadataForPass(existingPass);
    const { service, state, wallet } = createService({
      tokenService,
      pass: walletPass({
        ...existingPass,
        scanTokenHash: metadata.scanTokenHash,
        scanTokenVersion: metadata.scanTokenVersion,
        scanTokenIssuedAt: metadata.scanTokenIssuedAt,
        scanTokenLast4: metadata.scanTokenLast4
      })
    });

    await service.refreshGoogleWalletPassForMembership('membership_1');
    await service.refreshGoogleWalletPassForMembership('membership_1');

    const firstBarcode = (wallet.upsertedObjects[0] as any).barcode.value;
    const secondBarcode = (wallet.upsertedObjects[1] as any).barcode.value;
    const tokenUpdates = state.updateArgs.filter((update) =>
      Object.hasOwn(update.data, 'scanTokenHash')
    );

    assert.equal(firstBarcode, metadata.rawToken);
    assert.equal(secondBarcode, metadata.rawToken);
    assert.equal(firstBarcode, secondBarcode);
    assert.equal(tokenUpdates.length, 0);
  });

  it('skips refresh without calling Google Wallet when no WalletPass exists', async () => {
    const { service, wallet, state } = createService({
      pass: null
    });

    const response =
      await service.refreshGoogleWalletPassForMembership('membership_1');

    assert.equal(response.status, 'SKIPPED_NO_PASS');
    assert.equal(wallet.objectInputs.length, 0);
    assert.equal(wallet.upsertedObjects.length, 0);
    assert.equal(state.membershipQueries.length, 0);
  });

  it('skips refresh without lookup or Google calls when Google Wallet is disabled', async () => {
    const wallet = new MockGoogleWalletService();
    wallet.enabled = false;
    const { service, state } = createService({
      wallet
    });

    const response =
      await service.refreshGoogleWalletPassForMembership('membership_1');

    assert.equal(response.status, 'SKIPPED_DISABLED');
    assert.equal(wallet.objectInputs.length, 0);
    assert.equal(wallet.upsertedObjects.length, 0);
    assert.equal(state.walletPassFindQueries.length, 0);
    assert.equal(state.membershipQueries.length, 0);
  });

  it('marks WalletPass ERROR with a sanitized error when refresh fails', async () => {
    const tokenService = createTokenService();
    const existingPass = walletPass({
      id: 'pass_existing',
      status: WalletPassStatus.ACTIVE
    });
    const metadata = tokenService.buildMetadataForPass(existingPass);
    const wallet = new MockGoogleWalletService();
    wallet.upsertObjectError = new Error(`failed for ${metadata.rawToken}`);
    const { service, state } = createService({
      tokenService,
      wallet,
      pass: walletPass({
        ...existingPass,
        scanTokenHash: metadata.scanTokenHash,
        scanTokenVersion: metadata.scanTokenVersion,
        scanTokenIssuedAt: metadata.scanTokenIssuedAt,
        scanTokenLast4: metadata.scanTokenLast4
      })
    });
    const originalLog = console.log;
    const originalError = console.error;
    const calls: string[] = [];

    console.log = (...args: unknown[]) => {
      calls.push(args.join(' '));
    };
    console.error = (...args: unknown[]) => {
      calls.push(args.join(' '));
    };

    try {
      const response =
        await service.refreshGoogleWalletPassForMembership('membership_1');
      const finalUpdate = state.updateArgs.at(-1)?.data ?? {};

      assert.deepEqual(response, {
        status: 'FAILED',
        platform: WalletPassPlatform.GOOGLE_WALLET,
        membershipId: 'membership_1',
        error: 'Google Wallet sync failed'
      });
      assert.equal(finalUpdate.status, WalletPassStatus.ERROR);
      assert.equal(finalUpdate.syncError, 'Google Wallet sync failed');
      assert.equal(JSON.stringify(finalUpdate).includes(metadata.rawToken), false);
      assert.equal(JSON.stringify(response).includes(metadata.rawToken), false);
      assert.equal(calls.join(' ').includes(metadata.rawToken), false);
    } finally {
      console.log = originalLog;
      console.error = originalError;
    }
  });

  it('uses opaque Google Wallet resource IDs and hero image keys', async () => {
    const { service, wallet, storage } = createService();

    await service.syncGoogleWalletPass(user('staff_1'), 'business_1', 'membership_1');

    const classInput = wallet.classInputs[0] as Record<string, unknown>;
    const objectInput = wallet.objectInputs[0] as Record<string, unknown>;
    const renderInput = storage.renderInputs[0] as Record<string, unknown>;
    const objectPayload = wallet.upsertedObjects[0] as Record<string, unknown>;
    const walletJson = JSON.stringify({
      classInput,
      objectInput,
      renderInput,
      objectPayload
    });

    assert.match(String(classInput.classSuffix), /^business_[a-f0-9]{24}$/);
    assert.match(String(objectInput.objectSuffix), /^membership_[a-f0-9]{24}$/);
    assert.equal(walletJson.includes('business_1'), false);
    assert.equal(walletJson.includes('program_1'), false);
    assert.equal(walletJson.includes('membership_1'), false);
    assert.equal(walletJson.includes('customer_1'), false);
  });

  it('handles Google Wallet API failure cleanly and stores sanitized error state', async () => {
    const wallet = new MockGoogleWalletService();
    wallet.upsertObjectError = new GoogleWalletApiError(500, 'D:\\secret\\wallet.json');
    const { service, state } = createService({
      wallet
    });

    await assert.rejects(
      () =>
        service.syncGoogleWalletPass(user('staff_1'), 'business_1', 'membership_1'),
      BadGatewayException
    );

    const finalUpdate = state.updateArgs.at(-1)?.data ?? {};

    assert.equal(finalUpdate.status, WalletPassStatus.ERROR);
    assert.equal(finalUpdate.syncError, 'Google Wallet API request failed with status 500');
    assert.equal(JSON.stringify(finalUpdate).includes('D:\\'), false);
    assert.equal(JSON.stringify(finalUpdate).includes('secret'), false);
  });

  it('does not log service account credential details on wallet sync failure', async () => {
    const wallet = new MockGoogleWalletService();
    wallet.upsertClassError = new Error(
      'credential leaked from D:\\secret\\wallet.json'
    );
    const { service, state } = createService({
      wallet
    });
    const originalLog = console.log;
    const originalError = console.error;
    const calls: string[] = [];

    console.log = (...args: unknown[]) => {
      calls.push(args.join(' '));
    };
    console.error = (...args: unknown[]) => {
      calls.push(args.join(' '));
    };

    try {
      await assert.rejects(
        () =>
          service.syncGoogleWalletPass(
            user('staff_1'),
            'business_1',
            'membership_1'
          ),
        BadGatewayException
      );
    } finally {
      console.log = originalLog;
      console.error = originalError;
    }

    assert.equal(calls.length, 0);
    assert.equal(state.updateArgs.at(-1)?.data.syncError, 'Google Wallet sync failed');
  });
});

describe('PublicWalletPassService', () => {
  it('valid public card token returns a public-safe Save URL and creates a pass', async () => {
    const walletSetup = createService();
    const publicSetup = createPublicService(walletSetup);

    const response = await publicSetup.service.syncGoogleWalletPass(
      publicCardToken()
    );

    assert.deepEqual(publicSetup.tokens, [publicCardToken()]);
    assert.equal(walletSetup.state.createdPasses, 1);
    assert.equal(response.platform, WalletPassPlatform.GOOGLE_WALLET);
    assert.equal(response.status, WalletPassStatus.ACTIVE);
    assert.equal(response.businessName, 'Tavrix Cafe');
    assert.equal(response.programName, 'Tavrix Cafe Stamp Card');
    assert.equal(response.saveUrl.startsWith('https://pay.google.com/gp/v/save/'), true);
    assertPublicWalletResponseIsSafe(response as unknown as Record<string, unknown>);
  });

  it('rejects invalid public card tokens before syncing WalletPass', async () => {
    const walletSetup = createService();
    const publicSetup = createPublicService(walletSetup, {
      lookupError: new NotFoundException('Loyalty card not found')
    });

    await assert.rejects(
      () => publicSetup.service.syncGoogleWalletPass(publicCardToken()),
      NotFoundException
    );
    assert.equal(walletSetup.state.createdPasses, 0);
  });

  it('rejects inactive memberships from the public route', async () => {
    const walletSetup = createService({
      membership: membership({
        status: LoyaltyMembershipStatus.INACTIVE
      })
    });
    const publicSetup = createPublicService(walletSetup);

    await assert.rejects(
      () => publicSetup.service.syncGoogleWalletPass(publicCardToken()),
      BadRequestException
    );
    assert.equal(walletSetup.state.createdPasses, 0);
  });

  it('rejects inactive loyalty programs from the public route', async () => {
    const walletSetup = createService({
      membership: membership({
        loyaltyProgram: {
          ...membership().loyaltyProgram,
          isActive: false
        }
      })
    });
    const publicSetup = createPublicService(walletSetup);

    await assert.rejects(
      () => publicSetup.service.syncGoogleWalletPass(publicCardToken()),
      BadRequestException
    );
    assert.equal(walletSetup.state.createdPasses, 0);
  });

  it('repeated public POST idempotently reuses the existing WalletPass row', async () => {
    const walletSetup = createService();
    const publicSetup = createPublicService(walletSetup);

    const first = await publicSetup.service.syncGoogleWalletPass(publicCardToken());
    const second = await publicSetup.service.syncGoogleWalletPass(publicCardToken());

    assert.equal(walletSetup.state.createdPasses, 1);
    assert.equal(walletSetup.state.pass?.id, 'pass_1');
    assert.equal(first.saveUrl.startsWith('https://pay.google.com/gp/v/save/'), true);
    assert.equal(second.saveUrl.startsWith('https://pay.google.com/gp/v/save/'), true);
  });

  it('sanitizes Google Wallet API errors for public callers', async () => {
    const wallet = new MockGoogleWalletService();
    wallet.upsertObjectError = new GoogleWalletApiError(500, 'D:\\secret\\wallet.json');
    const walletSetup = createService({
      wallet
    });
    const publicSetup = createPublicService(walletSetup);

    await assert.rejects(
      () => publicSetup.service.syncGoogleWalletPass(publicCardToken()),
      BadGatewayException
    );

    const finalUpdate = walletSetup.state.updateArgs.at(-1)?.data ?? {};

    assert.equal(finalUpdate.status, WalletPassStatus.ERROR);
    assert.equal(finalUpdate.syncError, 'Google Wallet API request failed with status 500');
    assert.equal(JSON.stringify(finalUpdate).includes('D:\\'), false);
  });
});

describe('WalletPassController', () => {
  it('requires Clerk authentication', () => {
    const guards = Reflect.getMetadata(GUARDS_METADATA, WalletPassController);

    assert.ok(Array.isArray(guards));
    assert.equal(guards.includes(ClerkAuthGuard), true);
  });

  it('uses POST for generation and does not keep a side-effectful GET handler', () => {
    const method = Reflect.getMetadata(
      METHOD_METADATA,
      WalletPassController.prototype.syncGoogleWalletPass
    );
    const legacyGetHandler = (
      WalletPassController.prototype as unknown as Record<string, unknown>
    ).getGoogleWalletPass;

    assert.equal(method, RequestMethod.POST);
    assert.equal(legacyGetHandler, undefined);
  });

  it('documents POST generation in the current OpenAPI artifact without GET', () => {
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
      document.paths[
        '/businesses/{businessId}/loyalty/memberships/{membershipId}/google-wallet'
      ];

    assert.ok(path.post);
    assert.ok((path.post as { security?: unknown }).security);
    assert.equal(path.get, undefined);
  });
});

describe('PublicWalletPassController', () => {
  it('does not require Clerk authentication and uses POST', () => {
    const guards = Reflect.getMetadata(GUARDS_METADATA, PublicWalletPassController);
    const method = Reflect.getMetadata(
      METHOD_METADATA,
      PublicWalletPassController.prototype.syncGoogleWalletPass
    );

    assert.equal(guards, undefined);
    assert.equal(method, RequestMethod.POST);
  });

  it('documents public POST generation without bearer security', () => {
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
      document.paths['/public/loyalty/cards/{token}/google-wallet'];
    const publicPost = path.post as { security?: unknown };

    assert.ok(publicPost);
    assert.equal(path.get, undefined);
    assert.equal(publicPost.security, undefined);
  });
});

function createPublicService(
  walletSetup: ReturnType<typeof createService>,
  overrides: {
    lookupError?: Error;
    membership?: ReturnType<typeof membership>;
  } = {}
) {
  const tokens: string[] = [];
  const publicLoyaltyService = {
    findMembershipByPublicCardToken: async (token: string) => {
      tokens.push(token);

      if (overrides.lookupError) {
        throw overrides.lookupError;
      }

      const foundMembership = overrides.membership ?? walletSetup.state.membership;

      if (!foundMembership) {
        throw new NotFoundException('Loyalty card not found');
      }

      return foundMembership;
    }
  };

  return {
    service: new PublicWalletPassService(
      publicLoyaltyService as never,
      walletSetup.service
    ),
    tokens
  };
}

function createService(overrides: {
  membership?: ReturnType<typeof membership> | null;
  pass?: ReturnType<typeof walletPass> | null;
  wallet?: MockGoogleWalletService;
  tokenService?: WalletScanTokenService;
  storage?: MockStampImageStorage;
  assertRole?: () => Promise<void>;
} = {}) {
  const state: MockState = {
    membership: overrides.membership === undefined ? membership() : overrides.membership,
    pass: overrides.pass ?? null,
    createdPasses: 0,
    membershipQueries: [],
    walletPassFindQueries: [],
    upsertArgs: [],
    updateArgs: []
  };
  const wallet = overrides.wallet ?? new MockGoogleWalletService();
  const tokenService = overrides.tokenService ?? createTokenService();
  const storage = overrides.storage ?? new MockStampImageStorage();
  const prisma = {
    loyaltyMembership: {
      findFirst: async (query: unknown) => {
        state.membershipQueries.push(query);

        return state.membership;
      },
      findUnique: async (query: unknown) => {
        state.membershipQueries.push(query);

        return state.membership;
      }
    },
    walletPass: {
      findFirst: async (query: unknown) => {
        state.walletPassFindQueries.push(query);

        return state.pass;
      },
      upsert: async (args: any) => {
        state.upsertArgs.push(args);

        if (!state.pass) {
          state.createdPasses += 1;
          state.pass = walletPass({
            ...args.create,
            id: 'pass_1'
          });

          return state.pass;
        }

        state.pass = {
          ...state.pass,
          ...args.update,
          updatedAt: now()
        };

        return state.pass;
      },
      update: async (args: { where: { id: string }; data: Record<string, unknown> }) => {
        state.updateArgs.push(args);
        state.pass = walletPass({
          ...(state.pass ?? walletPass()),
          ...args.data,
          id: args.where.id,
          updatedAt: now()
        });

        return state.pass;
      }
    }
  };
  const businessAccess = {
    assertRole:
      overrides.assertRole ??
      (async () => {
        undefined;
      })
  };
  const service = new WalletPassService(
    prisma as never,
    businessAccess as never,
    wallet as never,
    tokenService,
    storage as never
  );

  return {
    service,
    state,
    wallet,
    storage
  };
}

function membership(overrides: Record<string, any> = {}) {
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
      name: 'Tavrix Cafe',
      slug: 'tavrix-cafe',
      type: 'cafe',
      logoUrl: 'https://example.test/logo.png',
      coverUrl: null,
      currency: 'IQD',
      language: 'ar',
      city: 'Baghdad',
      status: 'ACTIVE',
      createdAt: now(),
      updatedAt: now()
    },
    customer: {
      id: 'customer_1',
      phone: '+9647700000000',
      email: 'customer@example.test',
      name: 'Demo Customer',
      createdAt: now(),
      updatedAt: now()
    },
    loyaltyProgram: {
      id: 'program_1',
      businessId: 'business_1',
      name: 'Tavrix Cafe Stamp Card',
      description: 'Collect stamps.',
      stampGoal: 5,
      rewardName: 'Free coffee',
      rewardDescription: 'One free Turkish Coffee after 5 stamps.',
      isActive: true,
      cardColor: '#111827',
      accentColor: '#f59e0b',
      logoUrl: null,
      terms: null,
      createdAt: now(),
      updatedAt: now(),
      stampStyle: null
    },
    ...overrides
  };
}

function walletPass(overrides: Record<string, any> = {}) {
  return {
    id: 'pass_1',
    businessId: 'business_1',
    membershipId: 'membership_1',
    platform: WalletPassPlatform.GOOGLE_WALLET,
    googleClassId: null,
    googleObjectId: null,
    saveUrl: null,
    heroImageUrl: null,
    scanTokenHash: null,
    scanTokenVersion: null,
    scanTokenIssuedAt: null,
    scanTokenLast4: null,
    status: WalletPassStatus.PENDING,
    lastSyncedAt: null,
    syncError: null,
    createdAt: now(),
    updatedAt: now(),
    ...overrides
  };
}

function assertPublicWalletResponseIsSafe(value: Record<string, unknown>) {
  const camelScanField = `scan${'Token'}`;
  const snakeScanField = `scan_${'token'}`;

  for (const key of [
    'membershipId',
    'businessId',
    'customerId',
    'programId',
    'googleClassId',
    'googleObjectId',
    'barcode',
    camelScanField,
    snakeScanField
  ]) {
    assert.equal(Object.hasOwn(value, key), false);
  }

  const publicJson = JSON.stringify(value);

  for (const forbiddenValue of [
    'business_1',
    'program_1',
    'membership_1',
    'customer_1',
    'D:\\',
    camelScanField,
    snakeScanField
  ]) {
    assert.equal(publicJson.includes(forbiddenValue), false);
  }
}

function publicCardToken() {
  return 'public_card_token_123456789012345678901234';
}

function createTokenService() {
  return new WalletScanTokenService(
    new ConfigService({
      WALLET_SCAN_TOKEN_SECRET:
        'test-wallet-scan-token-secret-at-least-32-characters'
    })
  );
}

function user(id: string): AuthenticatedUser {
  return {
    id,
    clerkUserId: id,
    name: id,
    email: `${id}@example.test`,
    phone: null,
    status: 'ACTIVE',
    createdAt: now(),
    updatedAt: now()
  } as AuthenticatedUser;
}

function now() {
  return new Date('2026-06-16T09:00:00.000Z');
}
