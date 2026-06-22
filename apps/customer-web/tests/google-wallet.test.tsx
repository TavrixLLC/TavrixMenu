import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import { renderToStaticMarkup } from 'react-dom/server';
import { GoogleWalletButton } from '../app/components/GoogleWalletButton';
import {
  buildGoogleWalletUrl,
  getGoogleWalletButtonLabel,
  isGoogleWalletButtonDisabled,
  openGoogleWalletSaveUrl,
  requestGoogleWalletSaveUrl,
  shouldShowGoogleWalletButton
} from '../app/lib/google-wallet';

describe('GoogleWalletButton', () => {
  it('renders when the public card token exists', () => {
    const html = renderToStaticMarkup(
      <GoogleWalletButton apiBaseUrl="https://api.example.test" cardToken="public_card_token" />
    );

    assert.match(html, /Add to Google Wallet/);
  });

  it('shows a disabled clear message when the public card token is missing', () => {
    const html = renderToStaticMarkup(
      <GoogleWalletButton apiBaseUrl="https://api.example.test" cardToken={null} />
    );

    assert.match(html, /Add to Google Wallet/);
    assert.match(html, /Open this loyalty card from its card link/);
    assert.match(html, /disabled=""/);
  });

  it('does not show Apple Wallet, scanner, or QR UI', () => {
    const html = renderToStaticMarkup(
      <GoogleWalletButton apiBaseUrl="https://api.example.test" cardToken="public_card_token" />
    );

    assert.equal(/Apple Wallet/i.test(html), false);
    assert.equal(/scanner/i.test(html), false);
    assert.equal(/\bQR\b/i.test(html), false);
  });

  it('uses disabled loading state copy while request is running', () => {
    assert.equal(
      getGoogleWalletButtonLabel({
        isLoading: true,
        hasError: false
      }),
      'Opening Google Wallet...'
    );
    assert.equal(isGoogleWalletButtonDisabled({ isLoading: true, hasCardToken: true }), true);
    assert.equal(isGoogleWalletButtonDisabled({ isLoading: false, hasCardToken: false }), true);
  });

  it('uses retry copy after an error', () => {
    assert.equal(
      getGoogleWalletButtonLabel({
        isLoading: false,
        hasError: true
      }),
      'Try Google Wallet again'
    );
  });
});

describe('requestGoogleWalletSaveUrl', () => {
  it('does not POST until the click handler calls the request helper', async () => {
    const calls: string[] = [];
    const fetcher = async () => {
      calls.push('fetch');

      return okResponse();
    };

    assert.equal(calls.length, 0);

    const result = await requestGoogleWalletSaveUrl(
      {
        apiBaseUrl: 'https://api.example.test',
        cardToken: 'public_card_token'
      },
      fetcher
    );

    assert.equal(result.status, 'ok');
    assert.deepEqual(calls, ['fetch']);
  });

  it('calls the public token endpoint with POST only on request and no auth header', async () => {
    const calls: Array<{ url: string; method: string; headers: Record<string, string> }> = [];
    const result = await requestGoogleWalletSaveUrl(
      {
        apiBaseUrl: 'https://api.example.test/',
        cardToken: 'public token/1'
      },
      async (url, init) => {
        calls.push({
          url,
          method: init.method,
          headers: init.headers
        });

        return okResponse();
      }
    );

    assert.equal(result.status, 'ok');
    assert.deepEqual(calls, [
      {
          url: buildGoogleWalletUrl({
            apiBaseUrl: 'https://api.example.test/',
            cardToken: 'public token/1'
          }),
        method: 'POST',
        headers: {
          Accept: 'application/json'
        }
      }
    ]);
    assert.equal(calls[0].url.includes('/businesses/'), false);
    assert.equal(Object.hasOwn(calls[0].headers, 'Authorization'), false);
  });

  it('returns the Save URL after a successful response', async () => {
    const result = await requestGoogleWalletSaveUrl(
      {
        apiBaseUrl: 'https://api.example.test',
        cardToken: 'public_card_token'
      },
      async () => okResponse()
    );

    assert.equal(result.status, 'ok');

    if (result.status === 'ok') {
      assert.equal(result.data.saveUrl, 'https://pay.google.com/gp/v/save/signed.jwt');
    }
  });

  it('surfaces user-friendly errors', async () => {
    const result = await requestGoogleWalletSaveUrl(
      {
        apiBaseUrl: 'https://api.example.test',
        cardToken: 'public_card_token'
      },
      async () => ({
        ok: false,
        status: 502,
        json: async () => ({
          message: 'Google Wallet sync failed'
        })
      })
    );

    assert.deepEqual(result, {
      status: 'error',
      message: 'Google Wallet sync failed'
    });
  });

  it('recovers from network failures with a safe retryable error', async () => {
    const result = await requestGoogleWalletSaveUrl(
      {
        apiBaseUrl: 'https://api.example.test',
        cardToken: 'public_card_token'
      },
      async () => {
        throw new Error('network detail must not escape');
      }
    );

    assert.deepEqual(result, {
      status: 'error',
      message: 'Google Wallet could not be opened right now. Please try again.'
    });
  });

  it('does not expose raw auth errors to customers', async () => {
    const result = await requestGoogleWalletSaveUrl(
      {
        apiBaseUrl: 'https://api.example.test',
        cardToken: 'public_card_token'
      },
      async () => ({
        ok: false,
        status: 401,
        json: async () => ({
          message: 'Missing bearer token'
        })
      })
    );

    assert.deepEqual(result, {
      status: 'error',
      message: 'Google Wallet is not available for this card right now. Please try again or ask staff.'
    });
  });
});

describe('openGoogleWalletSaveUrl', () => {
  it('opens the Save URL after success', () => {
    const opened: Array<{ url: string; target: string; features: string }> = [];
    const assigned: string[] = [];

    openGoogleWalletSaveUrl('https://pay.google.com/gp/v/save/signed.jwt', {
      open: (url, target, features) => {
        opened.push({
          url,
          target,
          features
        });

        return {};
      },
      location: {
        assign: (url) => {
          assigned.push(url);
        }
      }
    });

    assert.deepEqual(opened, [
      {
        url: 'https://pay.google.com/gp/v/save/signed.jwt',
        target: '_blank',
        features: 'noopener,noreferrer'
      }
    ]);
    assert.deepEqual(assigned, []);
  });
});

describe('shouldShowGoogleWalletButton', () => {
  it('requires the public card token', () => {
    assert.equal(shouldShowGoogleWalletButton({ cardToken: 'public_card_token' }), true);
    assert.equal(shouldShowGoogleWalletButton({ cardToken: null }), false);
    assert.equal(shouldShowGoogleWalletButton({ cardToken: ' ' }), false);
  });
});

function okResponse() {
  return {
    ok: true,
    status: 200,
    json: async () => ({
      platform: 'GOOGLE_WALLET',
      saveUrl: 'https://pay.google.com/gp/v/save/signed.jwt',
      status: 'ACTIVE',
      businessName: 'Tavrix Cafe',
      programName: 'Tavrix Cafe Stamp Card',
      lastSyncedAt: '2026-06-16T09:00:00.000Z'
    })
  };
}
