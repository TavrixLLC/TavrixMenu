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
