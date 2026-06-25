import { ConfigService } from '@nestjs/config';
import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import { AppleWalletApnsClient } from './apple-wallet-apns.client';
import {
  AppleWalletApnsTransport,
  AppleWalletApnsTransportInput,
  AppleWalletApnsTransportResult
} from './apple-wallet-apns.transport';

class RecordingTransport implements AppleWalletApnsTransport {
  readonly inputs: AppleWalletApnsTransportInput[] = [];
  result: AppleWalletApnsTransportResult = {
    statusCode: 200
  };

  async send(input: AppleWalletApnsTransportInput) {
    this.inputs.push(input);
    return this.result;
  }
}

describe('AppleWalletApnsClient', () => {
  it('is disabled by default and does not call the transport', async () => {
    const setup = createClient({ APPLE_WALLET_APNS_ENABLED: false });
    const result = await setup.client.sendPassUpdate(pushInput());

    assert.deepEqual(result, { status: 'SKIPPED_DISABLED' });
    assert.equal(setup.transport.inputs.length, 0);
  });

  it('sends an empty Wallet wake-up payload with the pass type topic', async () => {
    const setup = createClient();
    const result = await setup.client.sendPassUpdate(pushInput());
    const transportInput = setup.transport.inputs[0];

    assert.deepEqual(result, { status: 'SENT' });
    assert.equal(transportInput.endpoint, 'https://api.push.apple.com');
    assert.equal(transportInput.payload, '{}');
    assert.equal(
      transportInput.passTypeIdentifier,
      'pass.app.waflo.loyalty'
    );
    assert.equal(transportInput.timeoutMs, 5000);
    assert.equal(
      JSON.stringify(result).includes(transportInput.pushToken),
      false
    );
  });

  it('supports the sandbox APNs endpoint', async () => {
    const setup = createClient({
      APPLE_WALLET_APNS_ENVIRONMENT: 'sandbox'
    });

    await setup.client.sendPassUpdate(pushInput());

    assert.equal(
      setup.transport.inputs[0].endpoint,
      'https://api.sandbox.push.apple.com'
    );
  });

  it('maps invalid device tokens without returning the token', async () => {
    const setup = createClient();
    setup.transport.result = {
      statusCode: 410,
      reason: 'Unregistered'
    };
    const result = await setup.client.sendPassUpdate(pushInput());

    assert.deepEqual(result, {
      status: 'INVALID_TOKEN',
      error: 'Apple Wallet APNs device token is invalid'
    });
    assert.equal(JSON.stringify(result).includes(pushInput().pushToken), false);
  });

  it('marks timeouts and APNs server failures retryable', async () => {
    const timeout = createClient();
    timeout.transport.result = {
      statusCode: 0,
      transportError: 'TIMEOUT'
    };
    const unavailable = createClient();
    unavailable.transport.result = {
      statusCode: 503,
      reason: 'Shutdown'
    };

    const timeoutResult = await timeout.client.sendPassUpdate(pushInput());
    const unavailableResult = await unavailable.client.sendPassUpdate(
      pushInput()
    );

    assert.equal(timeoutResult.status, 'FAILED');
    assert.equal(
      timeoutResult.status === 'FAILED' && timeoutResult.retryable,
      true
    );
    assert.equal(unavailableResult.status, 'FAILED');
    assert.equal(
      unavailableResult.status === 'FAILED' && unavailableResult.retryable,
      true
    );
  });

  it('fails safely without configured signing credentials', async () => {
    const setup = createClient({
      APPLE_WALLET_CERTIFICATE_PATH: '',
      APPLE_WALLET_CERTIFICATE_PASSWORD: ''
    });
    const result = await setup.client.sendPassUpdate(pushInput());

    assert.deepEqual(result, {
      status: 'FAILED',
      error: 'Apple Wallet APNs credentials are unavailable',
      retryable: false
    });
    assert.equal(setup.transport.inputs.length, 0);
  });
});

function createClient(overrides: Record<string, unknown> = {}) {
  const transport = new RecordingTransport();
  const config = new ConfigService({
    APPLE_WALLET_ENABLED: true,
    APPLE_WALLET_APNS_ENABLED: true,
    APPLE_WALLET_APNS_ENVIRONMENT: 'production',
    APPLE_WALLET_APNS_TIMEOUT_MS: 5000,
    APPLE_WALLET_CERTIFICATE_PATH: 'outside-repo/pass-certificate.p12',
    APPLE_WALLET_CERTIFICATE_PASSWORD: 'test-only-placeholder',
    ...overrides
  });

  return {
    client: new AppleWalletApnsClient(config, transport),
    transport
  };
}

function pushInput() {
  return {
    pushToken: 'test-push-token-placeholder',
    passTypeIdentifier: 'pass.app.waflo.loyalty'
  };
}
