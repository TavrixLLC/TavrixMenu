import 'reflect-metadata';
import {
  BadGatewayException,
  ForbiddenException,
  NotFoundException,
  RequestMethod
} from '@nestjs/common';
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
import { WalletPassController } from './wallet-pass.controller';
import { WalletPassService } from './wallet-pass.service';

type MockState = {
  membership: ReturnType<typeof membership> | null;
  pass: ReturnType<typeof walletPass> | null;
  createdPasses: number;
  membershipQueries: unknown[];
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

  upsertClassError?: Error;
  upsertObjectError?: Error;

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
    includeBarcode?: boolean;
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
              alternateText: input.accountId
            }
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

  constructor(
    private readonly publicUrl =
      'https://api.example.test/generated/wallet-stamps/membership_1.png'
  ) {}

  async renderAndStore(input: unknown) {
    this.renderInputs.push(input);

    return {
      fileName: 'membership_1.png',
      relativePath: 'wallet-stamps/membership_1.png',
      absolutePath: 'D:\\secret\\wallet-stamps\\membership_1.png',
      localPublicPath: '/generated/wallet-stamps/membership_1.png',
      publicUrl: this.publicUrl
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
    assert.equal(response.googleClassId, 'issuer.business_business_1_loyalty_program_1');
    assert.equal(response.googleObjectId, 'issuer.membership_membership_1');
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
    assert.equal(response.googleObjectId, 'issuer.membership_membership_1');
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

  it('does not persist or return raw token fields and omits barcode support', async () => {
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
    const updateInput = state.updateArgs.at(-1)?.data ?? {};
    const objectInput = wallet.objectInputs[0] as Record<string, unknown>;
    const objectPayload = wallet.upsertedObjects[0] as Record<string, unknown>;

    assert.equal(hasTokenKey(createInput), false);
    assert.equal(hasTokenKey(updateInput), false);
    assert.equal(hasTokenKey(response as unknown as Record<string, unknown>), false);
    assert.equal(objectInput.includeBarcode, false);
    assert.equal(Object.hasOwn(objectPayload, 'barcode'), false);
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
    assert.equal(path.get, undefined);
  });
});

function createService(overrides: {
  membership?: ReturnType<typeof membership> | null;
  pass?: ReturnType<typeof walletPass> | null;
  wallet?: MockGoogleWalletService;
  storage?: MockStampImageStorage;
  assertRole?: () => Promise<void>;
} = {}) {
  const state: MockState = {
    membership: overrides.membership === undefined ? membership() : overrides.membership,
    pass: overrides.pass ?? null,
    createdPasses: 0,
    membershipQueries: [],
    upsertArgs: [],
    updateArgs: []
  };
  const wallet = overrides.wallet ?? new MockGoogleWalletService();
  const storage = overrides.storage ?? new MockStampImageStorage();
  const prisma = {
    loyaltyMembership: {
      findFirst: async (query: unknown) => {
        state.membershipQueries.push(query);

        return state.membership;
      }
    },
    walletPass: {
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
    status: WalletPassStatus.PENDING,
    lastSyncedAt: null,
    syncError: null,
    createdAt: now(),
    updatedAt: now(),
    ...overrides
  };
}

function hasTokenKey(value: Record<string, unknown>) {
  return Object.keys(value).some((key) => key.toLowerCase().includes('token'));
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
