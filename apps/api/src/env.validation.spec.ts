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
  });

  it('normalizes comma-separated Wallet origins', () => {
    const config = validateEnvironment({
      NODE_ENV: 'development',
      GOOGLE_WALLET_ENABLED: 'true',
      GOOGLE_WALLET_ISSUER_ID: '3388000000023161301',
      GOOGLE_WALLET_CREDENTIALS_PATH: 'service-account.json',
      GOOGLE_WALLET_ORIGINS:
        'https://menu.example.test/, http://localhost:3001/path'
    });

    assert.deepEqual(config.GOOGLE_WALLET_ORIGINS, [
      'https://menu.example.test',
      'http://localhost:3001'
    ]);
  });
});
