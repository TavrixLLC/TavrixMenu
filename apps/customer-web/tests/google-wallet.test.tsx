import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import { renderToStaticMarkup } from 'react-dom/server';
import { GoogleWalletButton } from '../app/components/GoogleWalletButton';
import {
  buildGoogleWalletUrl,
  getGoogleWalletButtonLabel,
  isGoogleWalletButtonDisabled,
  requestGoogleWalletSaveUrl,
  shouldShowGoogleWalletButton
} from '../app/lib/google-wallet';

describe('GoogleWalletButton', () => {
  it('renders when businessId and membershipId exist', () => {
    const html = renderToStaticMarkup(
      <GoogleWalletButton apiBaseUrl="https://api.example.test" businessId="business_1" membershipId="membership_1" />
    );

    assert.match(html, /Add to Google Wallet/);
  });

  it('does not render when wallet identifiers are missing', () => {
    const html = renderToStaticMarkup(
      <GoogleWalletButton apiBaseUrl="https://api.example.test" businessId="business_1" membershipId={null} />
    );

    assert.equal(html, '');
  });

  it('does not show Apple Wallet, scanner, or QR UI', () => {
    const html = renderToStaticMarkup(
      <GoogleWalletButton apiBaseUrl="https://api.example.test" businessId="business_1" membershipId="membership_1" />
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
    assert.equal(isGoogleWalletButtonDisabled({ isLoading: true }), true);
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
        businessId: 'business_1',
        membershipId: 'membership_1'
      },
      fetcher
    );

    assert.equal(result.status, 'ok');
    assert.deepEqual(calls, ['fetch']);
  });

  it('calls the Google Wallet endpoint with POST only on request', async () => {
    const calls: Array<{ url: string; method: string }> = [];
    const result = await requestGoogleWalletSaveUrl(
      {
        apiBaseUrl: 'https://api.example.test/',
        businessId: 'business 1',
        membershipId: 'membership/1'
      },
      async (url, init) => {
        calls.push({
          url,
          method: init.method
        });

        return okResponse();
      }
    );

    assert.equal(result.status, 'ok');
    assert.deepEqual(calls, [
      {
        url: buildGoogleWalletUrl({
          apiBaseUrl: 'https://api.example.test/',
          businessId: 'business 1',
          membershipId: 'membership/1'
        }),
        method: 'POST'
      }
    ]);
  });

  it('returns the Save URL after a successful response', async () => {
    const result = await requestGoogleWalletSaveUrl(
      {
        apiBaseUrl: 'https://api.example.test',
        businessId: 'business_1',
        membershipId: 'membership_1'
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
        businessId: 'business_1',
        membershipId: 'membership_1'
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

  it('does not expose raw auth errors to customers', async () => {
    const result = await requestGoogleWalletSaveUrl(
      {
        apiBaseUrl: 'https://api.example.test',
        businessId: 'business_1',
        membershipId: 'membership_1'
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

describe('shouldShowGoogleWalletButton', () => {
  it('requires both businessId and membershipId', () => {
    assert.equal(shouldShowGoogleWalletButton({ businessId: 'business_1', membershipId: 'membership_1' }), true);
    assert.equal(shouldShowGoogleWalletButton({ businessId: 'business_1', membershipId: null }), false);
    assert.equal(shouldShowGoogleWalletButton({ businessId: ' ', membershipId: 'membership_1' }), false);
  });
});

function okResponse() {
  return {
    ok: true,
    status: 200,
    json: async () => ({
      platform: 'GOOGLE_WALLET',
      membershipId: 'membership_1',
      googleClassId: 'issuer.class',
      googleObjectId: 'issuer.object',
      saveUrl: 'https://pay.google.com/gp/v/save/signed.jwt',
      status: 'ACTIVE',
      lastSyncedAt: '2026-06-16T09:00:00.000Z'
    })
  };
}
