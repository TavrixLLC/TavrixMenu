import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import { renderToStaticMarkup } from 'react-dom/server';
import { WalletActions } from '../app/components/WalletActions';
import { LoyaltyEnrollmentSuccess } from '../app/m/[slug]/loyalty/LoyaltyEnrollmentClient';
import type { PublicLoyaltyEnrollment } from '../app/lib/public-loyalty';
import { detectWalletPlatform, type WalletPlatform } from '../app/lib/wallet-platform';

const enrollmentFixture: PublicLoyaltyEnrollment = {
  customer: {
    name: 'Sample customer'
  },
  business: {
    name: 'Sample cafe',
    slug: 'sample-cafe',
    logoUrl: null,
    coverUrl: null
  },
  program: {
    name: 'Sample rewards',
    stampGoal: 8,
    rewardName: 'Sample reward',
    rewardDescription: null
  },
  cardState: {
    stampCount: 2,
    stampGoal: 8,
    rewardReady: false,
    progressPercent: 25,
    rewardName: 'Sample reward',
    programName: 'Sample rewards',
    totalStampsEarned: 2,
    totalRewardsRedeemed: 0
  },
  cardAccess: {
    token: 'card-token-placeholder',
    cardUrlPath: '/public/loyalty/cards/card-token-placeholder'
  }
};

describe('wallet platform detection', () => {
  it('detects iPhone and iPad-class devices as iOS', () => {
    assert.equal(
      detectWalletPlatform({
        userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 Version/18.0 Mobile/15E148 Safari/604.1'
      }),
      'ios'
    );
    assert.equal(
      detectWalletPlatform({
        userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15)',
        platform: 'MacIntel',
        maxTouchPoints: 5
      }),
      'ios'
    );
  });

  it('detects Android and desktop browsers separately', () => {
    assert.equal(
      detectWalletPlatform({
        userAgent:
          'Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 Chrome/131.0 Mobile Safari/537.36'
      }),
      'android'
    );
    assert.equal(
      detectWalletPlatform({
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0'
      }),
      'desktop'
    );
  });
});

describe('device-aware wallet actions', () => {
  it('shows Apple first on iPhone and keeps the web card secondary', () => {
    const html = renderActions('ios');

    assert.match(html, /add-to-apple-wallet\.svg/);
    assert.equal(/add-to-google-wallet\.svg/.test(html), false);
    assert.ok(html.indexOf('add-to-apple-wallet.svg') < html.indexOf('Open web card'));
  });

  it('shows Google first on Android and keeps the web card secondary', () => {
    const html = renderActions('android');

    assert.match(html, /add-to-google-wallet\.svg/);
    assert.equal(/add-to-apple-wallet\.svg/.test(html), false);
    assert.ok(html.indexOf('add-to-google-wallet.svg') < html.indexOf('Open web card'));
  });

  it('shows a copy-to-phone flow on desktop without a wallet default', () => {
    const html = renderActions('desktop');

    assert.match(html, /Open this link on your phone/);
    assert.match(html, /Copy card link/);
    assert.equal(/add-to-apple-wallet\.svg/.test(html), false);
    assert.equal(/add-to-google-wallet\.svg/.test(html), false);
  });

  it('hides the Apple action safely when the build-time flag is disabled', () => {
    const html = renderActions('ios', false);

    assert.equal(/add-to-apple-wallet\.svg/.test(html), false);
    assert.match(html, /Open web card/);
    assert.match(html, /Apple Wallet is not available for this card right now/);
  });

  it('does not request either wallet pass during render', () => {
    const originalFetch = globalThis.fetch;
    const calls: unknown[] = [];
    globalThis.fetch = (async (...args: unknown[]) => {
      calls.push(args);
      throw new Error('wallet actions must remain click-only');
    }) as typeof fetch;

    try {
      renderActions('ios');
      renderActions('android');
    } finally {
      globalThis.fetch = originalFetch;
    }

    assert.equal(calls.length, 0);
  });
});

describe('enrollment success wallet handoff', () => {
  it('shows the iPhone customer the Apple action immediately', () => {
    const html = renderEnrollmentSuccess('ios');

    assert.match(html, /your card is ready/i);
    assert.match(html, /add-to-apple-wallet\.svg/);
    assert.equal(/add-to-google-wallet\.svg/.test(html), false);
  });

  it('keeps the Google Wallet handoff working on Android', () => {
    const html = renderEnrollmentSuccess('android');

    assert.match(html, /your card is ready/i);
    assert.match(html, /add-to-google-wallet\.svg/);
    assert.equal(/add-to-apple-wallet\.svg/.test(html), false);
  });
});

function renderActions(platform: WalletPlatform, appleWalletEnabled = true) {
  return renderToStaticMarkup(
    <WalletActions
      platform={platform}
      appleWalletEnabled={appleWalletEnabled}
      apiBaseUrl="https://api.example.test"
      cardToken="card-token-placeholder"
      cardHref="/m/sample-cafe/loyalty/card?token=card-token-placeholder"
    />
  );
}

function renderEnrollmentSuccess(platform: WalletPlatform) {
  return renderToStaticMarkup(
    <LoyaltyEnrollmentSuccess
      slug="sample-cafe"
      apiBaseUrl="https://api.example.test"
      appleWalletEnabled
      enrollment={enrollmentFixture}
      platform={platform}
      storageUnavailable={false}
    />
  );
}
