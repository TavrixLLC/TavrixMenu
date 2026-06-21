'use client';

import { FormEvent, useState } from 'react';
import { WalletActions } from '../../../components/WalletActions';
import { enrollPublicLoyaltyCustomer, type PublicLoyaltyEnrollment } from '../../../lib/public-loyalty';
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

export function LoyaltyEnrollmentClient({
  slug,
  apiBaseUrl,
  appleWalletEnabled
}: LoyaltyEnrollmentClientProps) {
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [name, setName] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [storageUnavailable, setStorageUnavailable] = useState(false);
  const [enrollment, setEnrollment] = useState<PublicLoyaltyEnrollment | null>(null);
  const platform = useWalletPlatform();

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const trimmedPhone = phone.trim();
    const trimmedEmail = email.trim();
    const trimmedName = name.trim();

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
          value={phone}
          onChange={(event) => setPhone(event.target.value)}
          placeholder="Your phone number"
          autoComplete="tel"
          className="h-12 rounded-md border border-neutral-200 bg-white px-3 text-base text-ink outline-none transition focus:border-mint"
          maxLength={40}
        />
      </div>

      <div className="grid gap-1">
        <label htmlFor="loyalty-email" className="text-sm font-semibold text-ink">
          Email
        </label>
        <input
          id="loyalty-email"
          name="email"
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
