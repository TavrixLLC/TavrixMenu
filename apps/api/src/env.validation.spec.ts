import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import { validateEnvironment } from './env.validation';

describe('validateEnvironment Google Wallet config', () => {
  it('defaults Google Wallet to disabled without requiring credentials', () => {
    const config = validateEnvironment({
      NODE_ENV: 'development'
    });

    assert.equal(config.GOOGLE_WALLET_ENABLED, false);
    assert.deepEqual(config.GOOGLE_WALLET_ORIGINS, []);
  });

  it('requires Wallet issuer, credentials path, and origins when enabled', () => {
    assert.throws(
      () =>
        validateEnvironment({
          NODE_ENV: 'development',
          GOOGLE_WALLET_ENABLED: 'true'
        }),
      /GOOGLE_WALLET_ISSUER_ID is required/
    );

    assert.throws(
      () =>
        validateEnvironment({
          NODE_ENV: 'development',
          GOOGLE_WALLET_ENABLED: 'true',
          GOOGLE_WALLET_ISSUER_ID: '3388000000023161301'
        }),
      /GOOGLE_WALLET_CREDENTIALS_PATH is required/
    );

    assert.throws(
      () =>
        validateEnvironment({
          NODE_ENV: 'development',
          GOOGLE_WALLET_ENABLED: 'true',
          GOOGLE_WALLET_ISSUER_ID: '3388000000023161301',
          GOOGLE_WALLET_CREDENTIALS_PATH: 'service-account.json'
        }),
      /GOOGLE_WALLET_ORIGINS must include at least one origin/
    );

    assert.throws(
      () =>
        validateEnvironment({
          NODE_ENV: 'development',
          GOOGLE_WALLET_ENABLED: 'true',
          GOOGLE_WALLET_ISSUER_ID: '3388000000023161301',
          GOOGLE_WALLET_CREDENTIALS_PATH: 'service-account.json',
          GOOGLE_WALLET_ORIGINS: 'https://menu.example.test'
        }),
      /WALLET_SCAN_TOKEN_SECRET must be at least 32 characters/
    );
  });

  it('normalizes comma-separated Wallet origins', () => {
    const config = validateEnvironment({
      NODE_ENV: 'development',
      GOOGLE_WALLET_ENABLED: 'true',
      GOOGLE_WALLET_ISSUER_ID: '3388000000023161301',
      GOOGLE_WALLET_CREDENTIALS_PATH: 'service-account.json',
      GOOGLE_WALLET_ORIGINS:
        'https://menu.example.test/, http://localhost:3001/path',
      WALLET_IMAGE_PUBLIC_BASE_URL: 'https://api.waflo.app/generated/',
      WALLET_SCAN_TOKEN_SECRET:
        'test-wallet-scan-token-secret-at-least-32-characters'
    });

    assert.deepEqual(config.GOOGLE_WALLET_ORIGINS, [
      'https://menu.example.test',
      'http://localhost:3001'
    ]);
    assert.equal(
      config.WALLET_IMAGE_PUBLIC_BASE_URL,
      'https://api.waflo.app/generated'
    );
    assert.equal(
      config.WALLET_SCAN_TOKEN_SECRET,
      'test-wallet-scan-token-secret-at-least-32-characters'
    );
  });

  it('rejects a non-HTTPS Wallet image public base URL', () => {
    assert.throws(
      () =>
        validateEnvironment({
          NODE_ENV: 'development',
          WALLET_IMAGE_PUBLIC_BASE_URL: 'http://api.example.test/generated'
        }),
      /WALLET_IMAGE_PUBLIC_BASE_URL must start with https:\/\//
    );
  });
});

describe('validateEnvironment Apple Wallet config', () => {
  it('defaults Apple Wallet to disabled without requiring certificates', () => {
    const config = validateEnvironment({
      NODE_ENV: 'development'
    });

    assert.equal(config.APPLE_WALLET_ENABLED, false);
    assert.equal(config.APPLE_WALLET_CERTIFICATE_PATH, '');
    assert.equal(config.APPLE_WALLET_WWDR_CERTIFICATE_PATH, '');
  });

  it('requires every Apple Wallet setting when enabled', () => {
    const requiredFields = [
      'APPLE_WALLET_TEAM_ID',
      'APPLE_WALLET_PASS_TYPE_IDENTIFIER',
      'APPLE_WALLET_ORGANIZATION_NAME',
      'APPLE_WALLET_CERTIFICATE_PATH',
      'APPLE_WALLET_CERTIFICATE_PASSWORD',
      'APPLE_WALLET_WWDR_CERTIFICATE_PATH'
    ] as const;

    for (const field of requiredFields) {
      const environment = validAppleWalletEnvironment();
      delete environment[field];

      assert.throws(
        () => validateEnvironment(environment),
        new RegExp(`${field} is required`)
      );
    }
  });

  it('accepts complete Apple Wallet config without exposing its password', () => {
    const config = validateEnvironment(validAppleWalletEnvironment());

    assert.equal(config.APPLE_WALLET_ENABLED, true);
    assert.equal(config.APPLE_WALLET_TEAM_ID, 'A1B2C3D4E5');
    assert.equal(
      config.APPLE_WALLET_PASS_TYPE_IDENTIFIER,
      'pass.app.waflo.loyalty'
    );
  });
});

describe('validateEnvironment Apple Wallet update web service config', () => {
  it('is opt-in and does not require update config for existing pass flows', () => {
    const disabled = validateEnvironment({ NODE_ENV: 'development' });
    const incomplete = validateEnvironment({
      NODE_ENV: 'development',
      APPLE_WALLET_WEB_SERVICE_ENABLED: 'true'
    });

    assert.equal(disabled.APPLE_WALLET_WEB_SERVICE_ENABLED, false);
    assert.equal(incomplete.APPLE_WALLET_WEB_SERVICE_ENABLED, true);
    assert.equal(incomplete.APPLE_WALLET_WEB_SERVICE_BASE_URL, '');
    assert.equal(incomplete.APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET, '');
  });

  it('accepts local HTTP only outside production and removes a trailing slash', () => {
    const config = validateEnvironment({
      NODE_ENV: 'development',
      APPLE_WALLET_WEB_SERVICE_ENABLED: 'true',
      APPLE_WALLET_WEB_SERVICE_BASE_URL:
        'http://localhost:3000/apple-wallet/v1/',
      APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET:
        'test-apple-update-token-secret-at-least-32-characters'
    });

    assert.equal(
      config.APPLE_WALLET_WEB_SERVICE_BASE_URL,
      'http://localhost:3000/apple-wallet/v1'
    );
  });

  it('rejects short secrets and unsafe production URLs', () => {
    assert.throws(
      () =>
        validateEnvironment({
          NODE_ENV: 'development',
          APPLE_WALLET_WEB_SERVICE_ENABLED: 'true',
          APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET: 'too-short'
        }),
      /APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET must be at least 32 characters/
    );

    const productionBase = {
      NODE_ENV: 'production',
      CLERK_JWT_ISSUER: 'https://clerk.example.test',
      APPLE_WALLET_WEB_SERVICE_ENABLED: 'true',
      APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET:
        'test-apple-update-token-secret-at-least-32-characters'
    };

    assert.throws(
      () =>
        validateEnvironment({
          ...productionBase,
          APPLE_WALLET_WEB_SERVICE_BASE_URL:
            'http://wallet.example.test/apple-wallet/v1'
        }),
      /must use HTTPS in production/
    );
    assert.throws(
      () =>
        validateEnvironment({
          ...productionBase,
          APPLE_WALLET_WEB_SERVICE_BASE_URL:
            'https://192.168.1.20/apple-wallet/v1'
        }),
      /cannot use a local or private host in production/
    );
  });

  it('accepts a public HTTPS production URL', () => {
    const config = validateEnvironment({
      NODE_ENV: 'production',
      CLERK_JWT_ISSUER: 'https://clerk.example.test',
      APPLE_WALLET_WEB_SERVICE_ENABLED: 'true',
      APPLE_WALLET_WEB_SERVICE_BASE_URL:
        'https://api.example.test/apple-wallet/v1',
      APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET:
        'test-apple-update-token-secret-at-least-32-characters'
    });

    assert.equal(
      config.APPLE_WALLET_WEB_SERVICE_BASE_URL,
      'https://api.example.test/apple-wallet/v1'
    );
  });
});

function validAppleWalletEnvironment() {
  return {
    NODE_ENV: 'development',
    APPLE_WALLET_ENABLED: 'true',
    APPLE_WALLET_TEAM_ID: 'A1B2C3D4E5',
    APPLE_WALLET_PASS_TYPE_IDENTIFIER: 'pass.app.waflo.loyalty',
    APPLE_WALLET_ORGANIZATION_NAME: 'Waflo',
    APPLE_WALLET_CERTIFICATE_PATH: 'outside-repo/certificate.p12',
    APPLE_WALLET_CERTIFICATE_PASSWORD: 'local-test-password',
    APPLE_WALLET_WWDR_CERTIFICATE_PATH: 'outside-repo/wwdr.cer',
    WALLET_SCAN_TOKEN_SECRET:
      'test-wallet-scan-token-secret-at-least-32-characters'
  };
}
