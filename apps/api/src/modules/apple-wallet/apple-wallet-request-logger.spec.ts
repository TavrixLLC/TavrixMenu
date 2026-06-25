import { strict as assert } from 'assert';
import { EventEmitter } from 'events';
import { describe, it } from 'node:test';
import { createAppleWalletRequestLogger } from './apple-wallet-request-logger';

describe('Apple Wallet request logger', () => {
  it('logs duplicated and unmatched Apple paths without identifiers or query values', () => {
    const logs: string[] = [];
    const middleware = createAppleWalletRequestLogger({
      log: (message: string) => logs.push(message)
    } as never);
    const response = new RecordingResponse(404);
    let nextCalled = false;

    middleware(
      {
        method: 'post',
        originalUrl:
          '/apple-wallet/v1/v1/devices/private-device-identifier/registrations/pass.app.waflo.loyalty/private-serial?passesUpdatedSince=private-tag&email=private@example.test'
      },
      response,
      () => {
        nextCalled = true;
      }
    );
    response.emit('finish');

    assert.equal(nextCalled, true);
    assert.equal(logs.length, 1);
    assert.match(logs[0], /apple_wallet\.http_request/);
    assert.match(
      logs[0],
      /"pathShape":"\/apple-wallet\/v1\/v1\/devices\/:value\/registrations\/:value\/:value"/
    );
    assert.match(logs[0], /"statusCode":404/);
    assert.match(logs[0], /"hasDuplicatedVersionPrefix":true/);
    assert.match(logs[0], /"passesUpdatedSincePresent":true/);
    assert.equal(logs[0].includes('private-device-identifier'), false);
    assert.equal(logs[0].includes('pass.app.waflo.loyalty'), false);
    assert.equal(logs[0].includes('private-serial'), false);
    assert.equal(logs[0].includes('private-tag'), false);
    assert.equal(logs[0].includes('private@example.test'), false);
  });

  it('ignores non-Apple request paths', () => {
    const logs: string[] = [];
    const middleware = createAppleWalletRequestLogger({
      log: (message: string) => logs.push(message)
    } as never);
    const response = new RecordingResponse(200);

    middleware(
      {
        method: 'get',
        originalUrl: '/health'
      },
      response,
      () => undefined
    );
    response.emit('finish');

    assert.equal(logs.length, 0);
  });
});

class RecordingResponse extends EventEmitter {
  constructor(readonly statusCode: number) {
    super();
  }

  once(event: 'finish', listener: () => void) {
    return super.once(event, listener);
  }
}
