import { ConfigService } from '@nestjs/config';
import { strict as assert } from 'assert';
import { createVerify, generateKeyPairSync } from 'crypto';
import { mkdtempSync, rmSync, writeFileSync } from 'fs';
import { tmpdir } from 'os';
import { join } from 'path';
import { after, before, describe, it } from 'node:test';
import {
  StoreStampImageInput,
  StoredStampImage
} from '../loyalty/stamp-image-storage.service';
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

class MockStampImageStorage {
  readonly renderInputs: StoreStampImageInput[] = [];

  constructor(private readonly publicUrl: string | null) {}

  async renderAndStore(input: StoreStampImageInput): Promise<StoredStampImage> {
    this.renderInputs.push(input);

    return {
      fileName: 'wallet-smoke.png',
      relativePath: 'wallet-stamps/wallet-smoke.png',
      absolutePath: 'D:\\local\\wallet-smoke.png',
      localPublicPath: '/generated/wallet-stamps/wallet-smoke.png',
      publicUrl: this.publicUrl
    };
  }

  requirePublicUrl(storedImage: StoredStampImage) {
    if (!storedImage.publicUrl) {
      throw new Error(
        'WALLET_IMAGE_PUBLIC_BASE_URL is required to attach generated Wallet images'
      );
    }

    return storedImage.publicUrl;
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
      string: '3/5'
    });
    assert.equal(objectPayload.loyaltyPoints.label, 'Progress');
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

  it('builds a smoke loyalty object with an HTTPS hero image and progress copy', async () => {
    const storage = new MockStampImageStorage(
      'https://api.waflo.app/generated/wallet-stamps/wallet-smoke.png'
    );
    const service = createService(new RecordingWalletClient(), storage, {
      WALLET_IMAGE_PUBLIC_BASE_URL: 'https://api.waflo.app/generated'
    });

    const payload = await service.buildSmokeLoyaltyObjectPayloadWithStampImage({
      classSuffix: 'waflo_test_class',
      objectSuffix: 'waflo_test_object'
    });

    assert.equal(payload.accountName, 'Waflo Member');
    assert.equal(payload.accountId, 'WFLO-SMOKE-01');
    assert.equal(payload.barcode?.alternateText, 'WFLO-SMOKE-01');
    assert.deepEqual(payload.loyaltyPoints, {
      label: 'Progress',
      balance: {
        string: '3/10'
      }
    });
    assert.equal(
      payload.heroImage?.sourceUri.uri,
      'https://api.waflo.app/generated/wallet-stamps/wallet-smoke.png'
    );
    assert.equal(payload.heroImage?.sourceUri.uri.startsWith('https://'), true);
    assert.equal(payload.heroImage?.sourceUri.uri.includes('D:\\'), false);
    assert.deepEqual(payload.textModulesData, [
      {
        id: 'reward',
        header: 'Reward',
        body: 'Free reward after 10 stamps'
      },
      {
        id: 'progress',
        header: 'Progress',
        body: '3 of 10 stamps collected'
      }
    ]);
    assert.equal(storage.renderInputs[0]?.presetKey, 'COOKIE');
    assert.equal(storage.renderInputs[0]?.stampCount, 3);
    assert.equal(storage.renderInputs[0]?.stampGoal, 10);
  });

  it('rejects local paths for Wallet hero images', () => {
    const service = createService();

    assert.throws(
      () =>
        service.buildLoyaltyObjectPayload({
          classSuffix: 'waflo_test_class',
          objectSuffix: 'waflo_test_object',
          accountName: 'Waflo Member',
          accountId: 'WFLO-SMOKE-01',
          stampCount: 3,
          stampGoal: 10,
          rewardName: 'Free reward after 10 stamps',
          heroImageUrl: 'D:\\local\\wallet-smoke.png'
        }),
      /heroImageUrl must be a valid HTTPS URL/
    );
  });

  it('fails clearly when the live smoke image public base URL is missing', async () => {
    const storage = new MockStampImageStorage(null);
    const service = createService(new RecordingWalletClient(), storage);

    await assert.rejects(
      () =>
        service.buildSmokeLoyaltyObjectPayloadWithStampImage({
          classSuffix: 'waflo_test_class',
          objectSuffix: 'waflo_test_object'
        }),
      /WALLET_IMAGE_PUBLIC_BASE_URL is required/
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

  function createService(
    client: GoogleWalletApiClient = new RecordingWalletClient(),
    stampImageStorage?: MockStampImageStorage,
    configOverrides: Record<string, unknown> = {}
  ) {
    return new GoogleWalletService(
      new ConfigService({
        GOOGLE_WALLET_ENABLED: true,
        GOOGLE_WALLET_ISSUER_ID: issuerId,
        GOOGLE_WALLET_CREDENTIALS_PATH: credentialsPath,
        GOOGLE_WALLET_ORIGINS: ['https://menu.example.test'],
        ...configOverrides
      }),
      client,
      stampImageStorage as never
    );
  }
});
