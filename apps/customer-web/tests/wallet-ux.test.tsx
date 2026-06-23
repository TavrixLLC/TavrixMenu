import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import { renderToStaticMarkup } from 'react-dom/server';
import { WalletActions } from '../app/components/WalletActions';
import {
  clearStoredToken,
  LoyaltyEnrollmentSuccess,
  LoyaltyIdentityForm,
  readStoredToken,
  ReturningLoyaltyCardView,
  storeCardToken
} from '../app/m/[slug]/loyalty/LoyaltyEnrollmentClient';
import {
  normalizeIraqiPhone,
  validateIraqiPhone,
  validateOptionalEmail
} from '../app/lib/customer-identity';
import type {
  PublicLoyaltyCard,
  PublicLoyaltyEnrollment
} from '../app/lib/public-loyalty';
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

const returningCardFixture: PublicLoyaltyCard = {
  business: {
    id: null,
    name: 'Sample cafe',
    slug: 'sample-cafe',
    logoUrl: null,
    coverUrl: null
  },
  program: {
    name: 'Sample rewards',
    stampGoal: 8,
    rewardName: 'Sample reward',
    rewardDescription: null,
    terms: null
  },
  customer: {
    name: 'Sample customer'
  },
  cardState: enrollmentFixture.cardState
};

describe('customer identity validation', () => {
  it('normalizes supported Iraqi local and international phone formats', () => {
    assert.equal(normalizeIraqiPhone('07701234567'), '+9647701234567');
    assert.equal(normalizeIraqiPhone('+9647701234567'), '+9647701234567');
    assert.equal(normalizeIraqiPhone('0770 123 4567'), '+9647701234567');
  });

  it('rejects invalid phone and malformed email values', () => {
    assert.match(validateIraqiPhone('') ?? '', /phone number/i);
    assert.match(validateIraqiPhone('12345') ?? '', /Iraqi number/i);
    assert.match(validateOptionalEmail('not-an-email') ?? '', /valid email/i);
    assert.equal(validateOptionalEmail(''), null);
    assert.equal(validateOptionalEmail('customer@example.com'), null);
  });
});

describe('loyalty identity states', () => {
  it('shows first-time enrollment with required phone and optional email', () => {
    const html = renderIdentityForm('join');

    assert.match(html, /Join this loyalty program/);
    assert.match(html, /Phone is required/);
    assert.match(html, /<input[^>]*required=""[^>]*name="phone"/);
    assert.match(html, /Email <span[^>]*>\(optional\)/);
    assert.match(html, /I already joined/);
  });

  it('shows phone-only recovery without creating a new-card promise', () => {
    const html = renderIdentityForm('recover');

    assert.match(html, /Find your existing card/);
    assert.match(html, /will not create a new card/i);
    assert.match(html, /Recover my card/);
    assert.equal(/name="email"/.test(html), false);
    assert.match(html, /Join as a new customer/);
  });

  it('stores only the opaque card reference for same-device return and clears it', () => {
    const originalWindow = Object.getOwnPropertyDescriptor(globalThis, 'window');
    const values = new Map<string, string>();

    Object.defineProperty(globalThis, 'window', {
      configurable: true,
      value: {
        localStorage: {
          getItem: (key: string) => values.get(key) ?? null,
          setItem: (key: string, value: string) => values.set(key, value),
          removeItem: (key: string) => values.delete(key)
        }
      }
    });

    try {
      assert.equal(storeCardToken('sample-cafe', 'opaque-card-reference'), true);
      assert.equal(readStoredToken('sample-cafe'), 'opaque-card-reference');
      assert.deepEqual([...values.keys()], ['tavrix.loyalty.sample-cafe.token']);

      clearStoredToken('sample-cafe');
      assert.equal(readStoredToken('sample-cafe'), null);
    } finally {
      if (originalWindow) {
        Object.defineProperty(globalThis, 'window', originalWindow);
      } else {
        delete (globalThis as { window?: unknown }).window;
      }
    }
  });
});

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

describe('returning customer wallet handoff', () => {
  it('shows Apple first on the returning iPhone view', () => {
    const html = renderReturningCard('ios');

    assert.match(html, /Welcome back/);
    assert.match(html, /add-to-apple-wallet\.svg/);
    assert.equal(/add-to-google-wallet\.svg/.test(html), false);
  });

  it('shows Google first on the returning Android view', () => {
    const html = renderReturningCard('android');

    assert.match(html, /add-to-google-wallet\.svg/);
    assert.equal(/add-to-apple-wallet\.svg/.test(html), false);
  });

  it('shows phone guidance on the returning desktop view', () => {
    const html = renderReturningCard('desktop');

    assert.match(html, /Open this link on your phone/);
    assert.match(html, /Not you\? Use another phone or card/);
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

function renderIdentityForm(mode: 'join' | 'recover') {
  return renderToStaticMarkup(
    <LoyaltyIdentityForm
      mode={mode}
      phone=""
      email=""
      name=""
      phoneError={null}
      emailError={null}
      error={null}
      isSubmitting={false}
      onSubmit={() => undefined}
      onPhoneChange={() => undefined}
      onEmailChange={() => undefined}
      onNameChange={() => undefined}
      onModeChange={() => undefined}
    />
  );
}

function renderReturningCard(platform: WalletPlatform) {
  return renderToStaticMarkup(
    <ReturningLoyaltyCardView
      slug="sample-cafe"
      apiBaseUrl="https://api.example.test"
      appleWalletEnabled
      card={returningCardFixture}
      cardToken="opaque-card-reference"
      platform={platform}
      onUseAnotherCard={() => undefined}
    />
  );
}
