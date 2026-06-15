import { ConfigService } from '@nestjs/config';
import { strict as assert } from 'assert';
import { createVerify, generateKeyPairSync } from 'crypto';
import { mkdtempSync, rmSync, writeFileSync } from 'fs';
import { tmpdir } from 'os';
import { join } from 'path';
import { after, before, describe, it } from 'node:test';
import {
  GoogleWalletApiClient,
  GoogleWalletApiError,
  GoogleWalletHttpMethod
} from './google-wallet-api.client';
import { GoogleWalletService } from './google-wallet.service';

type RecordedCall = {
  method: GoogleWalletHttpMethod;
  path: string;
  body?: unknown;
};

type ExpectedCall = RecordedCall & {
  result?: unknown;
  error?: Error;
};

class RecordingWalletClient implements GoogleWalletApiClient {
  readonly calls: RecordedCall[] = [];

  constructor(private readonly expectedCalls: ExpectedCall[] = []) {}

  async request<TResponse>(
    method: GoogleWalletHttpMethod,
    path: string,
    body?: unknown
  ): Promise<TResponse> {
    this.calls.push({
      method,
      path,
      body
    });

    const expected = this.expectedCalls.shift();

    if (!expected) {
      throw new Error(`Unexpected ${method} ${path}`);
    }

    assert.equal(method, expected.method);
    assert.equal(path, expected.path);

    if ('body' in expected) {
      assert.deepEqual(body, expected.body);
    }

    if (expected.error) {
      throw expected.error;
    }

    return expected.result as TResponse;
  }
}

describe('GoogleWalletService', () => {
  const issuerId = '3388000000023161301';
  let tempDir = '';
  let credentialsPath = '';
  let publicKeyPem = '';

  before(() => {
    tempDir = mkdtempSync(join(tmpdir(), 'waflo-wallet-test-'));
    const { privateKey, publicKey } = generateKeyPairSync('rsa', {
      modulusLength: 2048
    });
    const privateKeyPem = privateKey
      .export({
        type: 'pkcs8',
        format: 'pem'
      })
      .toString();

    publicKeyPem = publicKey
      .export({
        type: 'spki',
        format: 'pem'
      })
      .toString();
    credentialsPath = join(tempDir, 'service-account.json');

    writeFileSync(
      credentialsPath,
      JSON.stringify({
        type: 'service_account',
        client_email: 'wallet-test@example.iam.gserviceaccount.com',
        private_key: privateKeyPem
      })
    );
  });

  after(() => {
    rmSync(tempDir, {
      recursive: true,
      force: true
    });
  });

  it('builds Waflo loyalty class and object payloads', () => {
    const service = createService();

    const classPayload = service.buildLoyaltyClassPayload({
      classSuffix: 'waflo_test_class',
      logoUrl: 'https://example.com/logo.png'
    });
    const objectPayload = service.buildLoyaltyObjectPayload({
      classSuffix: 'waflo_test_class',
      objectSuffix: 'waflo_test_object',
      accountName: 'Waflo Test Account',
      accountId: 'WAFLO-001',
      stampCount: 3,
      stampGoal: 5,
      rewardName: 'Free coffee'
    });

    assert.equal(classPayload.id, `${issuerId}.waflo_test_class`);
    assert.equal(classPayload.programName, 'Waflo Rewards');
    assert.equal(
      classPayload.programLogo.sourceUri.uri,
      'https://example.com/logo.png'
    );
    assert.equal(objectPayload.id, `${issuerId}.waflo_test_object`);
    assert.equal(objectPayload.classId, `${issuerId}.waflo_test_class`);
    assert.deepEqual(objectPayload.loyaltyPoints.balance, {
      int: 3
    });
  });

  it('upserts classes and objects with mocked Google Wallet API calls', async () => {
    const classPayload = createService().buildLoyaltyClassPayload({
      classSuffix: 'waflo_test_class',
      logoUrl: 'https://example.com/logo.png'
    });
    const objectPayload = createService().buildLoyaltyObjectPayload({
      classSuffix: 'waflo_test_class',
      objectSuffix: 'waflo_test_object',
      accountName: 'Waflo Test Account',
      accountId: 'WAFLO-001',
      stampCount: 3,
      stampGoal: 5,
      rewardName: 'Free coffee'
    });
    const client = new RecordingWalletClient([
      {
        method: 'GET',
        path: `/loyaltyClass/${encodeURIComponent(classPayload.id)}`,
        error: new GoogleWalletApiError(404, 'not found')
      },
      {
        method: 'POST',
        path: '/loyaltyClass',
        body: classPayload,
        result: classPayload
      },
      {
        method: 'GET',
        path: `/loyaltyObject/${encodeURIComponent(objectPayload.id)}`,
        result: objectPayload
      },
      {
        method: 'PUT',
        path: `/loyaltyObject/${encodeURIComponent(objectPayload.id)}`,
        body: objectPayload,
        result: objectPayload
      }
    ]);
    const service = createService(client);

    await service.upsertLoyaltyClass(classPayload);
    await service.upsertLoyaltyObject(objectPayload);

    assert.deepEqual(
      client.calls.map((call) => `${call.method} ${call.path}`),
      [
        `GET /loyaltyClass/${encodeURIComponent(classPayload.id)}`,
        'POST /loyaltyClass',
        `GET /loyaltyObject/${encodeURIComponent(objectPayload.id)}`,
        `PUT /loyaltyObject/${encodeURIComponent(objectPayload.id)}`
      ]
    );
  });

  it('generates a signed Save to Google Wallet JWT and URL', () => {
    const service = createService();
    const loyaltyObject = {
      id: `${issuerId}.waflo_test_object`,
      classId: `${issuerId}.waflo_test_class`
    };
    const token = service.generateSaveJwt({
      loyaltyObject
    });
    const saveUrl = service.generateSaveUrl({
      loyaltyObject
    });
    const parts = token.split('.');

    assert.equal(parts.length, 3);
    assert.ok(saveUrl.startsWith('https://pay.google.com/gp/v/save/'));

    const claims = JSON.parse(
      Buffer.from(parts[1], 'base64url').toString('utf8')
    );

    assert.equal(claims.iss, 'wallet-test@example.iam.gserviceaccount.com');
    assert.equal(claims.aud, 'google');
    assert.equal(claims.typ, 'savetowallet');
    assert.deepEqual(claims.origins, ['https://menu.example.test']);
    assert.deepEqual(claims.payload.loyaltyObjects, [loyaltyObject]);

    const verifier = createVerify('RSA-SHA256');
    verifier.update(`${parts[0]}.${parts[1]}`);

    assert.equal(
      verifier.verify(publicKeyPem, Buffer.from(parts[2], 'base64url')),
      true
    );
  });

  it('does not allow Wallet operations when the feature flag is off', () => {
    const service = new GoogleWalletService(
      new ConfigService({
        GOOGLE_WALLET_ENABLED: false
      }),
      new RecordingWalletClient()
    );

    assert.throws(
      () =>
        service.buildLoyaltyClassPayload({
          classSuffix: 'waflo_test_class'
        }),
      /Google Wallet integration is disabled/
    );
  });

  function createService(client: GoogleWalletApiClient = new RecordingWalletClient()) {
    return new GoogleWalletService(
      new ConfigService({
        GOOGLE_WALLET_ENABLED: true,
        GOOGLE_WALLET_ISSUER_ID: issuerId,
        GOOGLE_WALLET_CREDENTIALS_PATH: credentialsPath,
        GOOGLE_WALLET_ORIGINS: ['https://menu.example.test']
      }),
      client
    );
  }
});
