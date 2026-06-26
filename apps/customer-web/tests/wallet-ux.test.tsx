import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import { renderToStaticMarkup } from 'react-dom/server';
import { CardTransferPanel } from '../app/components/CardTransferPanel';
import { WalletActions } from '../app/components/WalletActions';
import {
  clearStoredToken,
  loadStoredLoyaltyCard,
  LoyaltyEnrollmentSuccess,
  LoyaltyIdentityForm,
  readStoredToken,
  redeemAndStoreLoyaltyTransfer,
  ReturningLoyaltyCardView,
  storeCardToken
} from '../app/m/[slug]/loyalty/LoyaltyEnrollmentClient';
import { AppleWalletRefreshNotice } from '../app/m/[slug]/loyalty/card/LoyaltyCardClient';
import {
  normalizeIraqiPhone,
  validateIraqiPhone,
  validateOptionalEmail
} from '../app/lib/customer-identity';
import {
  buildLoyaltyTransferUrl,
  extractLoyaltyTransferToken
} from '../app/lib/card-transfer';
import {
  enrollPublicLoyaltyCustomer,
  type PublicLoyaltyCard,
  type PublicLoyaltyEnrollment
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
    assert.match(html, /Phone is required for the membership record/);
    assert.match(html, /<input[^>]*required=""[^>]*name="phone"/);
    assert.match(html, /Email <span[^>]*>\(optional\)/);
    assert.match(html, /I already joined/);
  });

  it('explains that cross-device recovery requires verification', () => {
    const html = renderIdentityForm('recover');
    const trustedDeviceStart = html.indexOf(
      'data-recovery-path="trusted-device"'
    );
    const lostAllDevicesStart = html.indexOf(
      'data-recovery-path="lost-all-devices"'
    );
    const differentPhoneStart = html.indexOf(
      'data-recovery-path="different-phone"'
    );
    const trustedDeviceSection = html.slice(
      trustedDeviceStart,
      lostAllDevicesStart
    );
    const lostAllDevicesSection = html.slice(
      lostAllDevicesStart,
      differentPhoneStart
    );
    const differentPhoneSection = html.slice(differentPhoneStart);

    assert.match(html, /Recovery needs verification/);
    assert.match(html, /phone or email alone cannot unlock/i);
    assert.match(html, /ask staff for help/i);
    assert.equal(/name="phone"/.test(html), false);
    assert.equal(/name="email"/.test(html), false);
    assert.equal(/add-to-apple-wallet\.svg/.test(html), false);
    assert.equal(/add-to-google-wallet\.svg/.test(html), false);
    assert.ok(trustedDeviceStart >= 0);
    assert.ok(lostAllDevicesStart > trustedDeviceStart);
    assert.ok(differentPhoneStart > lostAllDevicesStart);
    assert.match(
      trustedDeviceSection,
      /I have the card on another device/
    );
    assert.match(
      trustedDeviceSection,
      /Scan transfer QR \/ Enter transfer code/
    );
    assert.match(trustedDeviceSection, /name="transferCode"/);
    assert.match(lostAllDevicesSection, /I lost access to all devices/);
    assert.match(lostAllDevicesSection, /Ask staff for help/);
    assert.match(lostAllDevicesSection, /verify the customer in person/);
    assert.match(lostAllDevicesSection, /short-lived, single-use/);
    assert.match(lostAllDevicesSection, /log the staff action/);
    assert.equal(/name="transferCode"/.test(lostAllDevicesSection), false);
    assert.match(differentPhoneSection, /Join with a different phone/);
    assert.match(differentPhoneSection, /not already attached to a card for this business/);
  });

  it('loads a valid same-device opaque card reference and clears it on request', async () => {
    const originalWindow = Object.getOwnPropertyDescriptor(globalThis, 'window');
    const originalFetch = globalThis.fetch;
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
    globalThis.fetch = (async () =>
      new Response(JSON.stringify(returningCardFixture), {
        status: 200,
        headers: {
          'Content-Type': 'application/json'
        }
      })) as typeof fetch;

    try {
      assert.equal(storeCardToken('sample-cafe', 'opaque-card-reference'), true);
      assert.equal(readStoredToken('sample-cafe'), 'opaque-card-reference');
      assert.deepEqual([...values.keys()], ['tavrix.loyalty.sample-cafe.token']);

      const loaded = await loadStoredLoyaltyCard(
        'sample-cafe',
        'https://api.example.test'
      );
      assert.equal(loaded?.card.business.slug, 'sample-cafe');
      assert.equal(loaded?.token, 'opaque-card-reference');

      clearStoredToken('sample-cafe');
      assert.equal(readStoredToken('sample-cafe'), null);
    } finally {
      globalThis.fetch = originalFetch;
      if (originalWindow) {
        Object.defineProperty(globalThis, 'window', originalWindow);
      } else {
        delete (globalThis as { window?: unknown }).window;
      }
    }
  });

  it('maps unverified recovery responses without exposing card data', async () => {
    const originalFetch = globalThis.fetch;
    globalThis.fetch = (async () =>
      new Response(
        JSON.stringify({
          statusCode: 403,
          code: 'RECOVERY_REQUIRES_VERIFICATION',
          message: 'Recovery requires phone verification or staff help.'
        }),
        {
          status: 403,
          headers: {
            'Content-Type': 'application/json'
          }
        }
      )) as typeof fetch;

    try {
      const result = await enrollPublicLoyaltyCustomer(
        'sample-cafe',
        {
          phone: '+9647701234567',
          intent: 'RECOVER'
        },
        'https://api.example.test'
      );

      assert.equal(result.status, 'verification-required');
      assert.equal(
        JSON.stringify(result).includes('cardAccess'),
        false
      );
    } finally {
      globalThis.fetch = originalFetch;
    }
  });
});

describe('secure card transfer UX', () => {
  it('shows transfer creation only on a trusted card view', () => {
    const html = renderToStaticMarkup(
      <CardTransferPanel
        slug="sample-cafe"
        apiBaseUrl="https://api.example.test"
        cardToken="trusted-card-reference"
      />
    );

    assert.match(html, /Add card to another device/);
    assert.match(html, /Create add-device QR/);
    assert.match(html, /expires after five minutes/i);
    assert.match(html, /keeps this device connected/i);
  });

  it('builds fragment-only transfer links and extracts links or manual codes', () => {
    const transferUrl = buildLoyaltyTransferUrl(
      'https://card.example.test',
      'sample-cafe',
      'one-time-transfer-code'
    );

    assert.equal(
      transferUrl,
      'https://card.example.test/m/sample-cafe/loyalty#transfer=one-time-transfer-code'
    );
    assert.equal(
      extractLoyaltyTransferToken(transferUrl),
      'one-time-transfer-code'
    );
    assert.equal(
      extractLoyaltyTransferToken('one-time-transfer-code'),
      'one-time-transfer-code'
    );
  });

  it('redeems a transfer into the new device local opaque reference', async () => {
    const originalWindow = Object.getOwnPropertyDescriptor(globalThis, 'window');
    const originalFetch = globalThis.fetch;
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
    globalThis.fetch = (async () =>
      new Response(JSON.stringify(enrollmentFixture), {
        status: 200,
        headers: {
          'Content-Type': 'application/json'
        }
      })) as typeof fetch;

    try {
      const result = await redeemAndStoreLoyaltyTransfer(
        'sample-cafe',
        'https://api.example.test',
        'https://card.example.test/m/sample-cafe/loyalty#transfer=one-time-transfer-code'
      );

      assert.equal(result.status, 'ok');
      assert.equal(
        values.get('tavrix.loyalty.sample-cafe.token'),
        enrollmentFixture.cardAccess.token
      );
    } finally {
      globalThis.fetch = originalFetch;
      if (originalWindow) {
        Object.defineProperty(globalThis, 'window', originalWindow);
      } else {
        delete (globalThis as { window?: unknown }).window;
      }
    }
  });

  it('shows a friendly failure for invalid, expired, or used transfer codes', async () => {
    const originalFetch = globalThis.fetch;
    globalThis.fetch = (async () =>
      new Response(
        JSON.stringify({
          statusCode: 410,
          code: 'LOYALTY_TRANSFER_UNAVAILABLE',
          message: 'This transfer code is invalid, expired, or already used.'
        }),
        {
          status: 410,
          headers: {
            'Content-Type': 'application/json'
          }
        }
      )) as typeof fetch;

    try {
      const result = await redeemAndStoreLoyaltyTransfer(
        'sample-cafe',
        'https://api.example.test',
        'unavailable-transfer-code-placeholder'
      );

      assert.deepEqual(result, {
        status: 'error',
        message: 'This transfer code is invalid, expired, or already used.'
      });
    } finally {
      globalThis.fetch = originalFetch;
    }
  });

  it('shows the transferred card with the correct wallet action', () => {
    const html = renderToStaticMarkup(
      <LoyaltyEnrollmentSuccess
        slug="sample-cafe"
        apiBaseUrl="https://api.example.test"
        appleWalletEnabled
        enrollment={enrollmentFixture}
        platform="ios"
        storageUnavailable={false}
        variant="transferred"
      />
    );

    assert.match(html, /Card added securely/);
    assert.match(html, /add-to-apple-wallet\.svg/);
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
    assert.ok(html.indexOf('add-to-apple-wallet.svg') < html.indexOf('Open live card'));
  });

  it('shows Google first on Android and keeps the web card secondary', () => {
    const html = renderActions('android');

    assert.match(html, /add-to-google-wallet\.svg/);
    assert.equal(/add-to-apple-wallet\.svg/.test(html), false);
    assert.ok(html.indexOf('add-to-google-wallet.svg') < html.indexOf('Open live card'));
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
    assert.match(html, /Open live card/);
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

describe('Apple Wallet refresh delay mitigation copy', () => {
  it('points customers to the live web card without suggesting settings toggles', () => {
    const html = renderToStaticMarkup(<AppleWalletRefreshNotice />);

    assert.match(html, /Your live web card is the source of truth/);
    assert.match(html, /Apple Wallet may refresh shortly/);
    assert.equal(/Automatic Updates/i.test(html), false);
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
      recoveryMessage="Choose the path that matches your situation. Transfer is available only when at least one trusted old device still has the card. Phone or email alone cannot unlock it."
      transferCode=""
      transferError={null}
      isTransferSubmitting={false}
      onTransferCodeChange={() => undefined}
      onTransferSubmit={() => undefined}
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
