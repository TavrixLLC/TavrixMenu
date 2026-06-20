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
