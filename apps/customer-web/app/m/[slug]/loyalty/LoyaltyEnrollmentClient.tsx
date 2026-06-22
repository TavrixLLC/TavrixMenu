'use client';

import { FormEvent, useEffect, useState } from 'react';
import Link from 'next/link';
import { WalletActions } from '../../../components/WalletActions';
import { GoogleWalletButton } from '../../../components/GoogleWalletButton';
import {
  enrollPublicLoyaltyCustomer,
  fetchPublicLoyaltyCard,
  type PublicLoyaltyCard,
  type PublicLoyaltyEnrollment
} from '../../../lib/public-loyalty';
import { useWalletPlatform } from '../../../lib/use-wallet-platform';
import type { WalletPlatform } from '../../../lib/wallet-platform';

type LoyaltyEnrollmentClientProps = {
  slug: string;
  apiBaseUrl: string;
  appleWalletEnabled: boolean;
};

function getTokenStorageKey(slug: string) {
  return `tavrix.loyalty.${slug}.token`;
}

function readStoredToken(slug: string): string | null {
  try {
    return window.localStorage.getItem(getTokenStorageKey(slug));
  } catch {
    return null;
  }
}

function storeCardToken(slug: string, token: string): boolean {
  try {
    window.localStorage.setItem(getTokenStorageKey(slug), token);
    return true;
  } catch {
    return false;
  }
}

type LoyaltyEnrollmentSuccessProps = LoyaltyEnrollmentClientProps & {
  enrollment: PublicLoyaltyEnrollment;
  platform: WalletPlatform;
  storageUnavailable: boolean;
};

export function LoyaltyEnrollmentSuccess({
  slug,
  apiBaseUrl,
  appleWalletEnabled,
  enrollment,
  platform,
  storageUnavailable
}: LoyaltyEnrollmentSuccessProps) {
  const cardHref = `/m/${encodeURIComponent(slug)}/loyalty/card?token=${encodeURIComponent(enrollment.cardAccess.token)}`;

  return (
    <section className="grid gap-5">
      <div className="rounded-lg border border-emerald-100 bg-emerald-50 p-4">
        <p className="text-sm font-semibold text-emerald-800">You joined {enrollment.program.name}</p>
        <p className="mt-2 text-sm leading-6 text-emerald-900">
          {enrollment.customer.name ? `${enrollment.customer.name}, your` : 'Your'} card is ready.
        </p>
      </div>

      <div className="grid gap-3 rounded-lg border border-neutral-200 bg-neutral-50 p-4">
        <div>
          <p className="text-sm font-semibold text-neutral-500">Reward</p>
          <p className="mt-1 text-lg font-bold text-ink">{enrollment.program.rewardName}</p>
        </div>
        <div className="h-3 overflow-hidden rounded-full bg-white">
          <div
            className="h-full rounded-full bg-mint"
            style={{ width: `${enrollment.cardState.progressPercent}%` }}
          />
        </div>
        <p className="text-sm font-semibold text-neutral-700">
          {enrollment.cardState.stampCount} / {enrollment.cardState.stampGoal} stamps
        </p>
      </div>

      <WalletActions
        platform={platform}
        appleWalletEnabled={appleWalletEnabled}
        apiBaseUrl={apiBaseUrl}
        cardToken={enrollment.cardAccess.token}
        cardHref={cardHref}
      />

      {storageUnavailable ? (
        <p className="rounded-md border border-amber-100 bg-amber-50 p-3 text-sm leading-6 text-amber-700">
          This browser could not save the card for later, but the card link above will still open now.
        </p>
      ) : null}
    </section>
  );
}

function clearStoredToken(slug: string): void {
  try {
    window.localStorage.removeItem(getTokenStorageKey(slug));
  } catch {
    // ignore — best-effort
  }
}

/**
 * Validates that the value looks like a phone number and not an email.
 * Accepts:
 *   - International format: starts with + followed by digits/spaces/hyphens
 *   - Iraqi local format:   starts with 07 followed by digits
 *   - Empty (field is optional)
 * Returns a user-facing error string, or null if valid.
 */
function validatePhone(value: string): string | null {
  const v = value.trim();
  if (!v) return null;

  if (v.includes('@')) {
    return 'That looks like an email address. Enter a phone number here (e.g. +9647700000000) or use the Email field below.';
  }

  // International: +<digits with optional spaces and hyphens>, min 7 digits total
  const isInternational = /^\+[\d\s\-()]{6,}$/.test(v);
  // Iraqi local: 07xx-xxxxxxx, 7 digits+
  const isIraqiLocal = /^0?7\d{8,9}$/.test(v.replace(/[\s\-]/g, ''));

  if (!isInternational && !isIraqiLocal) {
    return 'Enter a valid phone number (e.g. +9647700000000 or 07701234567). Do not use spaces or letters.';
  }

  return null;
}

export function LoyaltyEnrollmentClient({
  slug,
  apiBaseUrl,
  appleWalletEnabled
}: LoyaltyEnrollmentClientProps) {
  const [phone, setPhone] = useState('');
  const [phoneError, setPhoneError] = useState<string | null>(null);
  const [email, setEmail] = useState('');
  const [name, setName] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [storageUnavailable, setStorageUnavailable] = useState(false);
  const [enrollment, setEnrollment] = useState<PublicLoyaltyEnrollment | null>(null);
  const platform = useWalletPlatform();

  // ── Returning-customer check ──────────────────────────────────────────────
  const [isCheckingToken, setIsCheckingToken] = useState(true);
  const [returningCard, setReturningCard] = useState<PublicLoyaltyCard | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function checkStoredToken() {
      const stored = readStoredToken(slug);
      if (!stored) {
        if (!cancelled) setIsCheckingToken(false);
        return;
      }

      const result = await fetchPublicLoyaltyCard(stored, apiBaseUrl);
      if (cancelled) return;

      if (result.status === 'ok') {
        setReturningCard(result.data);
      } else {
        // Token is stale (expired, 404, 400) — clear it and show Join form
        clearStoredToken(slug);
      }
      setIsCheckingToken(false);
    }

    checkStoredToken();
    return () => { cancelled = true; };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [slug]);
  // ─────────────────────────────────────────────────────────────────────────

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const trimmedPhone = phone.trim();
    const trimmedEmail = email.trim();
    const trimmedName = name.trim();

    // Per-field phone validation
    const phoneValidationError = validatePhone(trimmedPhone);
    if (phoneValidationError) {
      setPhoneError(phoneValidationError);
      return;
    }
    setPhoneError(null);

    if (!trimmedPhone && !trimmedEmail) {
      setError('Enter a phone number or email address to join this loyalty card.');
      return;
    }

    setError(null);
    setStorageUnavailable(false);
    setIsSubmitting(true);

    const result = await enrollPublicLoyaltyCustomer(
      slug,
      {
        phone: trimmedPhone || undefined,
        email: trimmedEmail || undefined,
        name: trimmedName || undefined
      },
      apiBaseUrl
    );

    setIsSubmitting(false);

    if (result.status !== 'ok') {
      setError(result.message);
      return;
    }

    const token = result.data.cardAccess.token;
    const stored = storeCardToken(slug, token);

    if (!stored) {
      setStorageUnavailable(true);
    }

    setEnrollment(result.data);
  }

  // ── Returning customer state ──────────────────────────────────────────────
  if (isCheckingToken) {
    return (
      <div className="flex items-center gap-2 text-sm text-neutral-500">
        <span className="inline-block h-4 w-4 animate-spin rounded-full border-2 border-neutral-300 border-t-transparent" />
        Loading your card…
      </div>
    );
  }

  if (returningCard) {
    const cardHref = `/m/${encodeURIComponent(slug)}/loyalty/card?token=${encodeURIComponent(readStoredToken(slug) ?? '')}`;
    const cardState = returningCard.cardState;

    return (
      <section className="grid gap-4">
        <div className="rounded-lg border border-emerald-100 bg-emerald-50 p-4">
          <p className="text-sm font-semibold text-emerald-800">
            {returningCard.customer.name ? `Welcome back, ${returningCard.customer.name}!` : 'Welcome back!'}
          </p>
          <p className="mt-1 text-sm leading-6 text-emerald-900">
            You already have a loyalty card for this program.
          </p>
        </div>

        <div className="grid gap-3 rounded-lg border border-neutral-200 bg-neutral-50 p-4">
          <div>
            <p className="text-sm font-semibold text-neutral-500">Progress</p>
            <p className="mt-1 text-lg font-bold text-ink">
              {cardState.stampCount} / {cardState.stampGoal} stamps
            </p>
          </div>
          <div className="h-3 overflow-hidden rounded-full bg-white">
            <div
              className="h-full rounded-full bg-mint"
              style={{ width: `${cardState.progressPercent}%` }}
            />
          </div>
          <p className="text-sm font-semibold text-neutral-700">
            {cardState.rewardReady ? `🎉 ${cardState.rewardName} is ready to redeem!` : cardState.rewardName}
          </p>
        </div>

        <Link
          href={cardHref}
          className="inline-flex h-12 items-center justify-center rounded-md bg-ink px-5 text-sm font-semibold text-white transition hover:bg-neutral-800"
        >
          View your card →
        </Link>

        <button
          type="button"
          onClick={() => {
            clearStoredToken(slug);
            setReturningCard(null);
          }}
          className="text-sm text-neutral-500 underline hover:text-neutral-700"
        >
          Not you? Join with a different contact
        </button>
      </section>
    );
  }
  // ─────────────────────────────────────────────────────────────────────────

  // ── Post-enrollment success state ─────────────────────────────────────────
  if (enrollment) {
    if (!platform) {
      return (
        <section className="rounded-lg border border-emerald-100 bg-emerald-50 p-4">
          <p className="text-sm font-semibold text-emerald-800">Your card is ready</p>
          <p role="status" className="mt-2 text-sm leading-6 text-emerald-900">
            Preparing the best wallet option for this device...
          </p>
        </section>
      );
    }

    return (
      <LoyaltyEnrollmentSuccess
        slug={slug}
        apiBaseUrl={apiBaseUrl}
        appleWalletEnabled={appleWalletEnabled}
        enrollment={enrollment}
        platform={platform}
        storageUnavailable={storageUnavailable}
      />
    );
  }
  // ─────────────────────────────────────────────────────────────────────────

  return (
    <form onSubmit={handleSubmit} className="grid gap-4">
      <p className="rounded-md bg-neutral-50 p-3 text-sm leading-6 text-neutral-600">
        Use either a phone number or email so staff can find your card. Your name is optional.
      </p>
      <div className="grid gap-1">
        <label htmlFor="loyalty-phone" className="text-sm font-semibold text-ink">
          Phone number
        </label>
        <input
          id="loyalty-phone"
          name="phone"
          type="tel"
          value={phone}
          onChange={(event) => {
            setPhone(event.target.value);
            if (phoneError) setPhoneError(null);
          }}
          placeholder="+9647700000000"
          autoComplete="tel"
          className="h-12 rounded-md border border-neutral-200 bg-white px-3 text-base text-ink outline-none transition focus:border-mint aria-[invalid=true]:border-red-400"
          aria-invalid={phoneError ? 'true' : undefined}
          maxLength={40}
        />
        {phoneError ? (
          <p id="loyalty-phone-error" className="text-sm leading-5 text-red-600">
            {phoneError}
          </p>
        ) : null}
      </div>

      <div className="grid gap-1">
        <label htmlFor="loyalty-email" className="text-sm font-semibold text-ink">
          Email
        </label>
        <input
          id="loyalty-email"
          name="email"
          type="email"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          placeholder="you@example.com"
          autoComplete="email"
          className="h-12 rounded-md border border-neutral-200 bg-white px-3 text-base text-ink outline-none transition focus:border-mint"
          maxLength={200}
        />
      </div>

      <div className="grid gap-1">
        <label htmlFor="loyalty-name" className="text-sm font-semibold text-ink">
          Name <span className="font-normal text-neutral-500">(optional)</span>
        </label>
        <input
          id="loyalty-name"
          name="name"
          type="text"
          value={name}
          onChange={(event) => setName(event.target.value)}
          placeholder="Your name"
          autoComplete="name"
          className="h-12 rounded-md border border-neutral-200 bg-white px-3 text-base text-ink outline-none transition focus:border-mint"
          maxLength={160}
        />
      </div>

      {error ? (
        <p className="rounded-md border border-red-100 bg-red-50 p-3 text-sm leading-6 text-red-700">{error}</p>
      ) : null}

      {storageUnavailable ? (
        <p className="rounded-md border border-amber-100 bg-amber-50 p-3 text-sm leading-6 text-amber-700">
          This browser could not save the card token for later, but this card link will still open now.
        </p>
      ) : null}

      <button
        type="submit"
        disabled={isSubmitting}
        className="h-12 rounded-md bg-ink px-5 text-sm font-semibold text-white transition hover:bg-neutral-800 disabled:cursor-not-allowed disabled:bg-neutral-400"
      >
        {isSubmitting ? 'Creating your card...' : 'Join and get your card'}
      </button>
    </form>
  );
}
