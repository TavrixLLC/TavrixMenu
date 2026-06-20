import 'reflect-metadata';
import {
  BadRequestException,
  ForbiddenException,
  RequestMethod
} from '@nestjs/common';
import { GUARDS_METADATA, METHOD_METADATA } from '@nestjs/common/constants';
import { ConfigService } from '@nestjs/config';
import { strict as assert } from 'assert';
import { readFileSync } from 'fs';
import { describe, it } from 'node:test';
import { join } from 'path';
import {
  BusinessUserRole,
  LoyaltyMembershipStatus,
  WalletPassPlatform,
  WalletPassStatus
} from '../../generated/prisma';
import { ClerkAuthGuard } from '../auth/guards/clerk-auth.guard';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { WalletScanController } from './wallet-scan.controller';
import { WalletScanService } from './wallet-scan.service';
import { WalletScanTokenService } from './wallet-scan-token.service';

describe('WalletScanService', () => {
  it('validates a Google Wallet barcode token and returns safe scan data', async () => {
    const { service, rawToken, queries } = createScanService();

    const response = await service.scanGoogleWalletPass(
      user('staff_1'),
      'business_1',
      {
        token: rawToken
      }
    );

    assert.equal(queries.length, 1);
    assert.deepEqual(response, {
      membershipId: 'membership_1',
      customer: {
        name: 'Demo Customer',
        phone: '+9647700000000'
      },
      program: {
        name: 'Tavrix Cafe Stamp Card',
        stampGoal: 10,
        rewardName: 'Free coffee'
      },
      progress: {
        stamps: 3,
        goal: 10,
        canRedeem: false
      },
      walletPass: {
        platform: WalletPassPlatform.GOOGLE_WALLET,
        status: WalletPassStatus.ACTIVE
      }
    });
    assert.equal(JSON.stringify(response).includes(rawToken), false);
    assert.equal(JSON.stringify(response).includes('scanTokenHash'), false);
  });

  it('validates an Apple Wallet barcode token through the same staff flow', async () => {
    const tokenService = createTokenService();
    const applePass = walletPass({
      platform: WalletPassPlatform.APPLE_WALLET,
      googleClassId: null,
      googleObjectId: null,
      saveUrl: null,
      heroImageUrl: null
    });
    const metadata = tokenService.buildMetadataForPass(applePass);
    const { service } = createScanService({
      tokenService,
      rawToken: metadata.rawToken,
      pass: {
        ...applePass,
        scanTokenHash: metadata.scanTokenHash,
        scanTokenVersion: metadata.scanTokenVersion,
        scanTokenIssuedAt: metadata.scanTokenIssuedAt,
        scanTokenLast4: metadata.scanTokenLast4
      }
    });

    const response = await service.scanGoogleWalletPass(
      user('staff_1'),
      'business_1',
      {
        token: metadata.rawToken
      }
    );

    assert.equal(response.walletPass.platform, WalletPassPlatform.APPLE_WALLET);
    assert.equal(JSON.stringify(response).includes(metadata.rawToken), false);
  });

  it('rejects invalid and malformed scan tokens', async () => {
    const { service, rawToken, queries } = createScanService();

    await assert.rejects(
      () =>
        service.scanGoogleWalletPass(user('staff_1'), 'business_1', {
          token: `${rawToken.slice(0, -1)}x`
        }),
      BadRequestException
    );

    await assert.rejects(
      () =>
        service.scanGoogleWalletPass(user('staff_1'), 'business_1', {
          token: 'not-a-wallet-token'
        }),
      BadRequestException
    );
    assert.equal(queries.length, 1);
  });

  it('rejects a rotated token whose stored metadata no longer matches', async () => {
    const tokenService = createTokenService();
    const basePass = walletPass();
    const metadata = tokenService.buildMetadataForPass(basePass);
    const rotatedPass = {
      ...basePass,
      scanTokenHash: metadata.scanTokenHash,
      scanTokenVersion: metadata.scanTokenVersion + 1,
      scanTokenIssuedAt: metadata.scanTokenIssuedAt,
      scanTokenLast4: metadata.scanTokenLast4
    };
    const { service } = createScanService({
      tokenService,
      pass: rotatedPass,
      rawToken: metadata.rawToken
    });

    await assert.rejects(
      () =>
        service.scanGoogleWalletPass(user('staff_1'), 'business_1', {
          token: metadata.rawToken
        }),
      BadRequestException
    );
  });

  it('requires an active OWNER, MANAGER, or STAFF business role before lookup', async () => {
    const rolesSeen: BusinessUserRole[][] = [];
    const { service, rawToken, queries } = createScanService({
      assertRole: async (_businessId, _userId, allowedRoles) => {
        rolesSeen.push(allowedRoles);
        throw new ForbiddenException('Insufficient business role');
      }
    });

    await assert.rejects(
      () =>
        service.scanGoogleWalletPass(user('guest_1'), 'business_1', {
          token: rawToken
        }),
      ForbiddenException
    );
    assert.deepEqual(rolesSeen, [
      [
        BusinessUserRole.OWNER,
        BusinessUserRole.MANAGER,
        BusinessUserRole.STAFF
      ]
    ]);
    assert.equal(queries.length, 0);
  });

  it('rejects cross-business wallet scans', async () => {
    const tokenService = createTokenService();
    const otherBusinessPass = walletPass({
      businessId: 'business_2',
      membership: {
        ...walletPass().membership,
        businessId: 'business_2'
      }
    });
    const metadata = tokenService.buildMetadataForPass(otherBusinessPass);
    const { service } = createScanService({
      tokenService,
      pass: {
        ...otherBusinessPass,
        scanTokenHash: metadata.scanTokenHash,
        scanTokenVersion: metadata.scanTokenVersion,
        scanTokenIssuedAt: metadata.scanTokenIssuedAt,
        scanTokenLast4: metadata.scanTokenLast4
      },
      rawToken: metadata.rawToken
    });

    await assert.rejects(
      () =>
        service.scanGoogleWalletPass(user('staff_1'), 'business_1', {
          token: metadata.rawToken
        }),
      ForbiddenException
    );
  });

  it('does not log or echo raw scan tokens on errors', async () => {
    const { service, rawToken } = createScanService();
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
      await service.scanGoogleWalletPass(user('staff_1'), 'business_1', {
        token: `${rawToken.slice(0, -1)}x`
      });
      assert.fail('Expected invalid token to be rejected');
    } catch (error) {
      assert.ok(error instanceof BadRequestException);
      assert.equal(JSON.stringify(error.getResponse()).includes(rawToken), false);
      assert.equal(calls.join(' ').includes(rawToken), false);
    } finally {
      console.log = originalLog;
      console.error = originalError;
    }
  });
});

describe('WalletScanController', () => {
  it('requires Clerk authentication and uses POST', () => {
    const guards = Reflect.getMetadata(GUARDS_METADATA, WalletScanController);
    const method = Reflect.getMetadata(
      METHOD_METADATA,
      WalletScanController.prototype.scanGoogleWalletPass
    );

    assert.ok(Array.isArray(guards));
    assert.equal(guards.includes(ClerkAuthGuard), true);
    assert.equal(method, RequestMethod.POST);
  });

  it('documents the staff scan endpoint in the current OpenAPI artifact', () => {
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
    const path = document.paths['/businesses/{businessId}/loyalty/wallet-scan'];
    const post = path.post as { security?: unknown };

    assert.ok(post);
    assert.ok(post.security);
  });
});

function createScanService(overrides: {
  tokenService?: WalletScanTokenService;
  pass?: ReturnType<typeof walletPass>;
  rawToken?: string;
  assertRole?: (
    businessId: string,
    userId: string,
    allowedRoles: BusinessUserRole[]
  ) => Promise<void>;
} = {}) {
  const tokenService = overrides.tokenService ?? createTokenService();
  const pass = overrides.pass ?? walletPass();
  const metadata = overrides.rawToken
    ? null
    : tokenService.buildMetadataForPass(pass);
  const storedPass = overrides.pass
    ? overrides.pass
    : {
        ...pass,
        scanTokenHash: metadata?.scanTokenHash ?? null,
        scanTokenVersion: metadata?.scanTokenVersion ?? null,
        scanTokenIssuedAt: metadata?.scanTokenIssuedAt ?? null,
        scanTokenLast4: metadata?.scanTokenLast4 ?? null
      };
  const rawToken = overrides.rawToken ?? metadata!.rawToken;
  const queries: unknown[] = [];
  const prisma = {
    walletPass: {
      findUnique: async (query: { where: { scanTokenHash: string } }) => {
        queries.push(query);

        return query.where.scanTokenHash === storedPass.scanTokenHash
          ? storedPass
          : null;
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

  return {
    service: new WalletScanService(
      prisma as never,
      businessAccess as never,
      tokenService
    ),
    rawToken,
    queries,
    pass: storedPass
  };
}

function walletPass(overrides: Record<string, any> = {}): any {
  return {
    id: 'pass_1',
    businessId: 'business_1',
    membershipId: 'membership_1',
    platform: WalletPassPlatform.GOOGLE_WALLET,
    googleClassId: 'issuer.class_1',
    googleObjectId: 'issuer.object_1',
    saveUrl: 'https://pay.google.com/gp/v/save/signed.jwt',
    heroImageUrl: 'https://api.example.test/generated/wallet-stamps/pass_1.png',
    scanTokenHash: null,
    scanTokenVersion: null,
    scanTokenIssuedAt: null,
    scanTokenLast4: null,
    status: WalletPassStatus.ACTIVE,
    lastSyncedAt: now(),
    syncError: null,
    createdAt: now(),
    updatedAt: now(),
    membership: {
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
        stampGoal: 10,
        rewardName: 'Free coffee',
        rewardDescription: 'One free Turkish Coffee after 10 stamps.',
        isActive: true,
        cardColor: '#111827',
        accentColor: '#f59e0b',
        logoUrl: null,
        terms: null,
        createdAt: now(),
        updatedAt: now()
      }
    },
    ...overrides
  };
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

function createTokenService() {
  return new WalletScanTokenService(
    new ConfigService({
      WALLET_SCAN_TOKEN_SECRET:
        'test-wallet-scan-token-secret-at-least-32-characters'
    })
  );
}

function now() {
  return new Date('2026-06-17T09:00:00.000Z');
}
