import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import { renderToStaticMarkup } from 'react-dom/server';
import { AppleWalletButton } from '../app/components/AppleWalletButton';
import {
  APPLE_WALLET_PASS_CONTENT_TYPE,
  APPLE_WALLET_UNAVAILABLE_MESSAGE,
  addToAppleWallet,
  buildAppleWalletProxyUrl,
  isAppleWalletButtonEnabled,
  openAppleWalletPass,
  requestAppleWalletPass
} from '../app/lib/apple-wallet';
import { proxyAppleWalletPass } from '../app/lib/apple-wallet-proxy';

describe('Apple Wallet feature gate', () => {
  it('defaults off and enables only for an explicit true value', () => {
    assert.equal(isAppleWalletButtonEnabled(undefined), false);
    assert.equal(isAppleWalletButtonEnabled('false'), false);
    assert.equal(isAppleWalletButtonEnabled(' true '), true);
  });

  it('hides the button when disabled and shows it when enabled', () => {
    const hidden = renderToStaticMarkup(
      <AppleWalletButton enabled={false} cardToken="public-card-placeholder" />
    );
    const visible = renderToStaticMarkup(
      <AppleWalletButton enabled cardToken="public-card-placeholder" />
    );

    assert.equal(hidden, '');
    assert.match(visible, /Add to Apple Wallet/);
  });

  it('does not request a pass during page rendering', () => {
    const originalFetch = globalThis.fetch;
    const calls: unknown[] = [];
    globalThis.fetch = (async (...args: unknown[]) => {
      calls.push(args);
      throw new Error('render must not fetch');
    }) as typeof fetch;

    try {
      renderToStaticMarkup(
        <AppleWalletButton enabled cardToken="public-card-placeholder" />
      );
    } finally {
      globalThis.fetch = originalFetch;
    }

    assert.equal(calls.length, 0);
  });
});

describe('Apple Wallet click action', () => {
  it('requests and opens the pass only when the click action runs', async () => {
    const calls: string[] = [];
    const pass = new Blob(['signed-pass'], {
      type: APPLE_WALLET_PASS_CONTENT_TYPE
    });

    assert.equal(calls.length, 0);

    const result = await addToAppleWallet(
      'public-card-placeholder',
      async (token) => {
        calls.push(`request:${token}`);
        return {
          status: 'ok',
          pass,
          fileName: 'waflo-loyalty.pkpass'
        };
      },
      (openedPass, fileName) => {
        assert.equal(openedPass, pass);
        calls.push(`open:${fileName}`);
      }
    );

    assert.deepEqual(result, { status: 'ok' });
    assert.deepEqual(calls, [
      'request:public-card-placeholder',
      'open:waflo-loyalty.pkpass'
    ]);
  });

  it('uses the same-origin POST proxy without an authorization header', async () => {
    const calls: Array<{
      url: string;
      method: string;
      headers: Record<string, string>;
    }> = [];
    const result = await requestAppleWalletPass(
      'public card/placeholder',
      async (url, init) => {
        calls.push({
          url,
          method: init.method,
          headers: init.headers
        });
        return passResponse();
      }
    );

    assert.equal(result.status, 'ok');
    assert.deepEqual(calls, [
      {
        url: buildAppleWalletProxyUrl('public card/placeholder'),
        method: 'POST',
        headers: {
          Accept: APPLE_WALLET_PASS_CONTENT_TYPE
        }
      }
    ]);
    assert.equal(Object.hasOwn(calls[0].headers, 'Authorization'), false);
  });

  it('handles a successful pass as a temporary download', async () => {
    const result = await requestAppleWalletPass(
      'public-card-placeholder',
      async () => passResponse()
    );

    assert.equal(result.status, 'ok');

    if (result.status !== 'ok') {
      return;
    }

    const links: Array<{
      href: string;
      download: string;
      rel: string;
      clicked: boolean;
    }> = [];
    const revoked: string[] = [];
    const scheduled: Array<() => void> = [];

    openAppleWalletPass(result.pass, result.fileName, {
      createObjectUrl: () => 'blob:apple-pass-placeholder',
      revokeObjectUrl: (url) => revoked.push(url),
      createLink: () => {
        const link = {
          href: '',
          download: '',
          rel: '',
          clicked: false,
          click() {
            link.clicked = true;
          }
        };
        links.push(link);
        return link;
      },
      schedule: (callback) => scheduled.push(callback)
    });

    assert.equal(links.length, 1);
    assert.deepEqual(
      {
        href: links[0].href,
        download: links[0].download,
        rel: links[0].rel,
        clicked: links[0].clicked
      },
      {
        href: 'blob:apple-pass-placeholder',
        download: 'waflo-loyalty.pkpass',
        rel: 'noopener',
        clicked: true
      }
    );
    assert.deepEqual(revoked, []);
    scheduled[0]();
    assert.deepEqual(revoked, ['blob:apple-pass-placeholder']);
  });

  for (const status of [404, 503]) {
    it(`shows the same safe error for backend HTTP ${status}`, async () => {
      const result = await requestAppleWalletPass(
        'public-card-placeholder',
        async () => ({
          ok: false,
          status,
          headers: new Headers({
            'Content-Type': 'application/json'
          }),
          blob: async () => {
            throw new Error('error bodies must not be opened');
          }
        })
      );

      assert.deepEqual(result, {
        status: 'error',
        message: APPLE_WALLET_UNAVAILABLE_MESSAGE
      });
    });
  }
});

describe('Apple Wallet customer-web proxy', () => {
  it('stays disabled without calling the backend', async () => {
    let called = false;
    const response = await proxyAppleWalletPass(
      {
        token: 'public-card-placeholder',
        enabled: false,
        apiBaseUrl: 'https://api.example.test'
      },
      (async () => {
        called = true;
        throw new Error('disabled proxy must not fetch');
      }) as typeof fetch
    );

    assert.equal(called, false);
    assert.equal(response.status, 503);
    assert.deepEqual(await response.json(), {
      message: APPLE_WALLET_UNAVAILABLE_MESSAGE
    });
  });

  it('streams a valid backend pass and preserves safe content headers', async () => {
    const calls: Array<{ url: string; init?: RequestInit }> = [];
    const response = await proxyAppleWalletPass(
      {
        token: 'public card/placeholder',
        enabled: true,
        apiBaseUrl: 'https://api.example.test/'
      },
      async (url, init) => {
        calls.push({ url: String(url), init });
        return new Response('signed-pass', {
          status: 200,
          headers: {
            'Content-Disposition':
              'attachment; filename="waflo-loyalty.pkpass"',
            'Content-Length': '11',
            'Content-Type': APPLE_WALLET_PASS_CONTENT_TYPE
          }
        });
      }
    );

    assert.equal(response.status, 200);
    assert.equal(
      response.headers.get('Content-Type'),
      APPLE_WALLET_PASS_CONTENT_TYPE
    );
    assert.equal(
      response.headers.get('Content-Disposition'),
      'attachment; filename="waflo-loyalty.pkpass"'
    );
    assert.equal(await response.text(), 'signed-pass');
    assert.equal(
      calls[0].url,
      'https://api.example.test/public/loyalty/cards/public%20card%2Fplaceholder/apple-wallet'
    );
    assert.equal(calls[0].init?.method, 'POST');
    assert.equal(
      (calls[0].init?.headers as Record<string, string>).Accept,
      APPLE_WALLET_PASS_CONTENT_TYPE
    );
  });

  for (const status of [404, 503]) {
    it(`forwards safe HTTP ${status} without exposing the backend body`, async () => {
      const response = await proxyAppleWalletPass(
        {
          token: 'public-card-placeholder',
          enabled: true,
          apiBaseUrl: 'https://api.example.test'
        },
        async () =>
          Response.json(
            {
              message: 'internal detail must not escape'
            },
            { status }
          )
      );

      assert.equal(response.status, status);
      assert.deepEqual(await response.json(), {
        message: APPLE_WALLET_UNAVAILABLE_MESSAGE
      });
    });
  }

  it('does not log card tokens or pass bodies', async () => {
    const logs: string[] = [];
    const originalLog = console.log;
    const originalError = console.error;
    console.log = (...values: unknown[]) => logs.push(values.join(' '));
    console.error = (...values: unknown[]) => logs.push(values.join(' '));

    try {
      const response = await proxyAppleWalletPass(
        {
          token: 'sensitive-card-placeholder',
          enabled: true,
          apiBaseUrl: 'https://api.example.test'
        },
        async () =>
          new Response('sensitive-pass-body-placeholder', {
            status: 200,
            headers: {
              'Content-Type': APPLE_WALLET_PASS_CONTENT_TYPE
            }
          })
      );
      await response.arrayBuffer();
    } finally {
      console.log = originalLog;
      console.error = originalError;
    }

    assert.deepEqual(logs, []);
  });
});

function passResponse() {
  const pass = new Blob(['signed-pass'], {
    type: APPLE_WALLET_PASS_CONTENT_TYPE
  });

  return {
    ok: true,
    status: 200,
    headers: new Headers({
      'Content-Disposition': 'attachment; filename="waflo-loyalty.pkpass"',
      'Content-Type': APPLE_WALLET_PASS_CONTENT_TYPE
    }),
    blob: async () => pass
  };
}
