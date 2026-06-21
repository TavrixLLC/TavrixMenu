import 'reflect-metadata';
import {
  BadRequestException,
  UnauthorizedException
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { strict as assert } from 'assert';
import { readFileSync } from 'fs';
import { describe, it } from 'node:test';
import { join } from 'path';
import { WalletScanTokenService } from '../google-wallet/wallet-scan-token.service';
import { AppleWalletUpdateAuthTokenService } from './apple-wallet-update-auth-token.service';
import { AppleWalletUpdateController } from './apple-wallet-update.controller';
import { AppleWalletUpdateService } from './apple-wallet-update.service';
import { APPLE_WALLET_PASS_CONTENT_TYPE } from './public-apple-wallet-pass.service';

const fixedIssuedAt = new Date('2026-06-20T12:00:00.000Z');
const membershipUpdatedAt = new Date('2026-06-20T12:10:00.000Z');
const programUpdatedAt = new Date('2026-06-20T12:05:00.000Z');

describe('AppleWalletUpdateAuthTokenService', () => {
  it('creates a stable token that is separate from public and scan tokens', () => {
    const config = tokenConfig();
    const service = new AppleWalletUpdateAuthTokenService(config);
    const pass = tokenPassFields();
    const first = service.buildMetadataForPass(pass, fixedIssuedAt);
    const persistedPass = {
      ...pass,
      appleUpdateAuthTokenHash: first.tokenHash,
      appleUpdateAuthTokenVersion: first.tokenVersion,
      appleUpdateAuthTokenIssuedAt: first.tokenIssuedAt,
      appleUpdateAuthTokenLast4: first.tokenLast4
    };
    const second = service.buildMetadataForPass(persistedPass);
    const scan = new WalletScanTokenService(config).buildMetadataForPass(
      {
        id: pass.id,
        businessId: pass.businessId,
        membershipId: pass.membershipId,
        scanTokenHash: null,
        scanTokenVersion: null,
        scanTokenIssuedAt: null,
        scanTokenLast4: null
      },
      fixedIssuedAt
    );

    assert.match(first.rawToken, /^waflo_apple_update_v1\./);
    assert.equal(first.rawToken, second.rawToken);
    assert.equal(service.verifyForPass(first.rawToken, persistedPass), true);
    assert.equal(service.verifyForPass(`${first.rawToken}x`, persistedPass), false);
    assert.notEqual(first.rawToken, scan.rawToken);
    assert.notEqual(first.rawToken, 'public_card_token_placeholder');
    assert.equal(first.tokenHash.length, 64);
    assert.equal(JSON.stringify(persistedPass).includes(first.rawToken), false);
  });
});

describe('AppleWalletUpdateService', () => {
  it('registers a device with valid auth and never returns the push token', async () => {
    const setup = createSetup();
    const pushToken = 'sensitive-push-token-placeholder';
    const logs: string[] = [];
    (setup.service as any).logger = {
      log: (message: string) => logs.push(message),
      warn: (message: string) => logs.push(message)
    };
    const result = await setup.service.registerDevice({
      authorization: `ApplePass ${setup.rawToken}`,
      deviceLibraryIdentifier: 'device-library-identifier-1234',
      passTypeIdentifier: setup.pass.applePassTypeIdentifier,
      serialNumber: setup.pass.appleSerialNumber,
      pushToken
    });

    assert.deepEqual(result, { created: true });
    assert.equal(JSON.stringify(result).includes(pushToken), false);
    assert.equal(setup.state.registrationWrites.length, 1);
    assert.equal(setup.state.registrationWrites[0].create.pushToken, pushToken);
    assert.notEqual(
      setup.state.registrationWrites[0].create.deviceLibraryIdentifierHash,
      'device-library-identifier-1234'
    );
    const output = logs.join('\n');
    assert.match(output, /apple_wallet\.registration_received/);
    assert.match(output, /apple_wallet\.registration_authorized/);
    assert.match(output, /apple_wallet\.registration_persisted/);
    assert.equal(output.includes(setup.rawToken), false);
    assert.equal(output.includes(pushToken), false);
    assert.equal(output.includes('device-library-identifier-1234'), false);
    assert.match(output, /"deviceLibraryIdentifierSuffix":"1234"/);
  });

  it('rejects invalid ApplePass authorization before registration', async () => {
    const setup = createSetup();

    await assert.rejects(
      setup.service.registerDevice({
        authorization: 'ApplePass invalid-token-value',
        deviceLibraryIdentifier: 'device-library-identifier-1234',
        passTypeIdentifier: setup.pass.applePassTypeIdentifier,
        serialNumber: setup.pass.appleSerialNumber,
        pushToken: 'push-token-placeholder'
      }),
      UnauthorizedException
    );
    assert.equal(setup.state.registrationWrites.length, 0);
  });

  it('lists only passes changed after the supplied update tag', async () => {
    const setup = createSetup();
    setup.state.registrations = [
      {
        serialNumber: setup.pass.appleSerialNumber,
        walletPass: setup.pass
      }
    ];

    const result = await setup.service.listUpdatedPasses({
      deviceLibraryIdentifier: 'device-library-identifier-1234',
      passTypeIdentifier: setup.pass.applePassTypeIdentifier,
      passesUpdatedSince: String(membershipUpdatedAt.getTime() - 1)
    });
    const unchanged = await setup.service.listUpdatedPasses({
      deviceLibraryIdentifier: 'device-library-identifier-1234',
      passTypeIdentifier: setup.pass.applePassTypeIdentifier,
      passesUpdatedSince: String(membershipUpdatedAt.getTime())
    });

    assert.deepEqual(result, {
      serialNumbers: [setup.pass.appleSerialNumber],
      lastUpdated: String(membershipUpdatedAt.getTime())
    });
    assert.equal(unchanged, null);
    await assert.rejects(
      setup.service.listUpdatedPasses({
        deviceLibraryIdentifier: 'device-library-identifier-1234',
        passTypeIdentifier: setup.pass.applePassTypeIdentifier,
        passesUpdatedSince: 'not-a-tag'
      }),
      BadRequestException
    );
  });

  it('lists a registered serial after the Apple pass update marker advances', async () => {
    const setup = createSetup();
    const marker = new Date('2026-06-20T12:20:00.000Z');
    setup.pass.applePassUpdatedAt = marker;
    setup.state.registrations = [
      {
        serialNumber: setup.pass.appleSerialNumber,
        walletPass: setup.pass
      }
    ];

    const result = await setup.service.listUpdatedPasses({
      deviceLibraryIdentifier: 'device-library-identifier-1234',
      passTypeIdentifier: setup.pass.applePassTypeIdentifier,
      passesUpdatedSince: String(membershipUpdatedAt.getTime())
    });

    assert.deepEqual(result, {
      serialNumbers: [setup.pass.appleSerialNumber],
      lastUpdated: String(marker.getTime())
    });
  });

  it('returns an updated pass with the stable update token and fresh scan metadata', async () => {
    const setup = createSetup();
    const result = await setup.service.getUpdatedPass({
      authorization: `ApplePass ${setup.rawToken}`,
      passTypeIdentifier: setup.pass.applePassTypeIdentifier,
      serialNumber: setup.pass.appleSerialNumber
    });

    assert.equal(result.status, 'UPDATED');
    assert.equal(result.pass?.toString(), 'signed-updated-pass');
    assert.equal(setup.state.generateInputs[0].updateAuthenticationToken, setup.rawToken);
    assert.equal(
      setup.state.generateInputs[0].businessName,
      'Waflo Test Business'
    );
    assert.equal(
      setup.state.generateInputs[0].programDescription,
      'Collect stamps.'
    );
    assert.equal(setup.state.generateInputs[0].stampCount, 4);
    assert.equal(setup.state.generateInputs[0].stampGoal, 10);
    assert.equal(setup.state.generateInputs[0].rewardName, 'Reward');
    assert.equal(setup.state.generateInputs[0].terms, 'Test terms');
    assert.equal(
      setup.state.generateInputs[0].theme.walletBackgroundColor,
      '#111827'
    );
    assert.equal(setup.state.walletPassUpdates.length, 1);
    assert.equal(
      setup.state.walletPassUpdates[0].data.scanTokenHash,
      'scan-token-hash-placeholder'
    );

    const notModified = await setup.service.getUpdatedPass({
      authorization: `ApplePass ${setup.rawToken}`,
      passTypeIdentifier: setup.pass.applePassTypeIdentifier,
      serialNumber: setup.pass.appleSerialNumber,
      ifModifiedSince: membershipUpdatedAt.toUTCString()
    });

    assert.equal(notModified.status, 'NOT_MODIFIED');
    assert.equal(setup.state.generateInputs.length, 1);
  });

  it('soft-unregisters a device and clears the stored push token', async () => {
    const setup = createSetup();

    await setup.service.unregisterDevice({
      authorization: `ApplePass ${setup.rawToken}`,
      deviceLibraryIdentifier: 'device-library-identifier-1234',
      passTypeIdentifier: setup.pass.applePassTypeIdentifier,
      serialNumber: setup.pass.appleSerialNumber
    });

    assert.equal(setup.state.registrationRemovals.length, 1);
    assert.equal(setup.state.registrationRemovals[0].data.pushToken, null);
    assert.equal(setup.state.registrationRemovals[0].data.pushTokenLast4, null);
    assert.ok(setup.state.registrationRemovals[0].data.unregisteredAt instanceof Date);
  });

  it('sanitizes diagnostic logs before writing them', () => {
    const setup = createSetup();
    const logged: string[] = [];
    (setup.service as any).logger = {
      warn: (message: string) => logged.push(message)
    };
    const scanToken =
      'waflo_scan_v1.1.1781956800000.AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA.BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';

    setup.service.acceptLogs([
      `Authorization ApplePass ${setup.rawToken}`,
      `pushToken=${'p'.repeat(80)}`,
      `scan=${scanToken}`
    ]);

    const output = logged.join('\n');
    assert.equal(output.includes(setup.rawToken), false);
    assert.equal(output.includes(scanToken), false);
    assert.equal(output.includes('p'.repeat(80)), false);
    assert.match(output, /redacted/);
  });
});

describe('AppleWalletUpdateController', () => {
  it('returns 201 for a new registration and 200 for an existing one', async () => {
    const calls: any[] = [];
    let created = true;
    const service = {
      registerDevice: async (input: any) => {
        calls.push(input);
        return { created };
      }
    };
    const controller = new AppleWalletUpdateController(service as never);
    const params = {
      deviceLibraryIdentifier: 'device-library-identifier-1234',
      passTypeIdentifier: 'pass.app.waflo.loyalty',
      serialNumber: 'waflo-apple-serial-placeholder'
    };
    const createdResponse = new RecordingResponse();

    await controller.registerDevice(
      'ApplePass token-placeholder-value',
      params,
      { pushToken: 'push-token-placeholder' },
      createdResponse
    );

    assert.equal(createdResponse.statusCode, 201);
    assert.equal(calls[0].authorization, 'ApplePass token-placeholder-value');
    assert.equal(calls[0].pushToken, 'push-token-placeholder');

    created = false;
    const updatedResponse = new RecordingResponse();
    await controller.registerDevice(
      'ApplePass token-placeholder-value',
      params,
      { pushToken: 'push-token-placeholder' },
      updatedResponse
    );

    assert.equal(updatedResponse.statusCode, 200);
  });

  it('returns the updated pass with Apple Wallet content metadata', async () => {
    const service = {
      getUpdatedPass: async () => ({
        status: 'UPDATED',
        pass: Buffer.from('signed-updated-pass'),
        lastModified: membershipUpdatedAt
      })
    };
    const controller = new AppleWalletUpdateController(service as never);
    const response = new RecordingResponse();

    await controller.getUpdatedPass(
      'ApplePass token-placeholder-value',
      undefined,
      {
        passTypeIdentifier: 'pass.app.waflo.loyalty',
        serialNumber: 'waflo-apple-serial-placeholder'
      },
      response
    );

    assert.equal(response.statusCode, 200);
    assert.equal(
      response.headers['Content-Type'],
      APPLE_WALLET_PASS_CONTENT_TYPE
    );
    assert.equal(
      response.headers['Last-Modified'],
      membershipUpdatedAt.toUTCString()
    );
    assert.equal((response.body as Buffer).toString(), 'signed-updated-pass');
  });

  it('documents all five Apple protocol operations without token examples', () => {
    const document = JSON.parse(
      readFileSync(
        join(
          __dirname,
          '..',
          '..',
          '..',
          '..',
          '..',
          'docs',
          'openapi',
          'waflo-openapi-current.json'
        ),
        'utf8'
      )
    ) as any;
    const registration =
      document.paths[
        '/apple-wallet/v1/devices/{deviceLibraryIdentifier}/registrations/{passTypeIdentifier}/{serialNumber}'
      ];
    const list =
      document.paths[
        '/apple-wallet/v1/devices/{deviceLibraryIdentifier}/registrations/{passTypeIdentifier}'
      ];
    const pass =
      document.paths[
        '/apple-wallet/v1/passes/{passTypeIdentifier}/{serialNumber}'
      ];
    const logs = document.paths['/apple-wallet/v1/log'];
    const pushToken =
      document.components.schemas.AppleWalletRegistrationDto.properties
        .pushToken;

    assert.ok(registration.post);
    assert.ok(registration.delete);
    assert.ok(list.get);
    assert.ok(pass.get);
    assert.ok(logs.post);
    assert.ok(pass.get.responses['200'].content[APPLE_WALLET_PASS_CONTENT_TYPE]);
    assert.equal(pushToken.writeOnly, true);
    assert.equal(pushToken.example, undefined);
  });
});

class RecordingResponse {
  statusCode?: number;
  body?: unknown;
  headers: Record<string, string> = {};

  status(code: number) {
    this.statusCode = code;
    return this;
  }

  send(body?: unknown) {
    this.body = body;
  }

  json(body: unknown) {
    this.body = body;
  }

  setHeader(name: string, value: string) {
    this.headers[name] = value;
  }
}

function createSetup() {
  const config = tokenConfig();
  const tokenService = new AppleWalletUpdateAuthTokenService(config);
  const basePass = tokenPassFields();
  const token = tokenService.buildMetadataForPass(basePass, fixedIssuedAt);
  const pass = {
    ...basePass,
    applePassTypeIdentifier: 'pass.app.waflo.loyalty',
    appleSerialNumber: 'waflo-apple-serial-placeholder',
    appleUpdateAuthTokenHash: token.tokenHash,
    appleUpdateAuthTokenVersion: token.tokenVersion,
    appleUpdateAuthTokenIssuedAt: token.tokenIssuedAt,
    appleUpdateAuthTokenLast4: token.tokenLast4,
    applePassUpdatedAt: new Date('2026-06-20T12:01:00.000Z'),
    membership: {
      stampCount: 4,
      updatedAt: membershipUpdatedAt,
      business: {
        name: 'Waflo Test Business'
      },
      loyaltyProgram: {
        name: 'Waflo Loyalty',
        description: 'Collect stamps.',
        stampGoal: 10,
        rewardName: 'Reward',
        rewardDescription: 'Reward after ten stamps',
        terms: 'Test terms',
        cardColor: '#111827',
        accentColor: '#f59e0b',
        stampStyle: null,
        updatedAt: programUpdatedAt
      }
    }
  };
  const state: any = {
    existingRegistration: null,
    registrationWrites: [],
    registrationRemovals: [],
    registrations: [],
    generateInputs: [],
    walletPassUpdates: []
  };
  const prisma = {
    walletPass: {
      findFirst: async () => pass,
      update: async (input: any) => {
        state.walletPassUpdates.push(input);
        return pass;
      }
    },
    appleWalletDeviceRegistration: {
      findUnique: async () => state.existingRegistration,
      upsert: async (input: any) => {
        state.registrationWrites.push(input);
        return input.create;
      },
      findMany: async () => state.registrations,
      updateMany: async (input: any) => {
        state.registrationRemovals.push(input);
        return { count: 1 };
      }
    }
  };
  const appleWalletService = {
    getReadiness: () => 'READY',
    getUpdateWebServiceReadiness: () => 'READY',
    generatePass: async (input: any) => {
      state.generateInputs.push(input);
      return {
        pass: Buffer.from('signed-updated-pass'),
        metadata: {
          passTypeIdentifier: pass.applePassTypeIdentifier,
          serialNumber: pass.appleSerialNumber,
          fileSize: 19
        },
        scanTokenMetadata: {
          scanTokenHash: 'scan-token-hash-placeholder',
          scanTokenVersion: 1,
          scanTokenIssuedAt: fixedIssuedAt,
          scanTokenLast4: 'scan'
        }
      };
    }
  };

  return {
    service: new AppleWalletUpdateService(
      prisma as never,
      appleWalletService as never,
      tokenService
    ),
    pass,
    rawToken: token.rawToken,
    state
  };
}

function tokenConfig() {
  return new ConfigService({
    APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET:
      'test-apple-update-token-secret-at-least-32-characters',
    WALLET_SCAN_TOKEN_SECRET:
      'test-wallet-scan-token-secret-at-least-32-characters'
  });
}

function tokenPassFields() {
  return {
    id: 'apple-wallet-pass-id-placeholder',
    businessId: 'business-id-placeholder',
    membershipId: 'membership-id-placeholder',
    appleUpdateAuthTokenHash: null,
    appleUpdateAuthTokenVersion: null,
    appleUpdateAuthTokenIssuedAt: null,
    appleUpdateAuthTokenLast4: null
  };
}
