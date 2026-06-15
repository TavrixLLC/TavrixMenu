'use client';

import { FormEvent, useState } from 'react';
import { useRouter } from 'next/navigation';
import { enrollPublicLoyaltyCustomer } from '../../../lib/public-loyalty';

type LoyaltyEnrollmentClientProps = {
  slug: string;
  apiBaseUrl: string;
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

export function LoyaltyEnrollmentClient({ slug, apiBaseUrl }: LoyaltyEnrollmentClientProps) {
  const router = useRouter();
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [name, setName] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [storageUnavailable, setStorageUnavailable] = useState(false);

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

    router.push(`/m/${encodeURIComponent(slug)}/loyalty/card?token=${encodeURIComponent(token)}`);
  }

  return (
    <form onSubmit={handleSubmit} className="grid gap-4">
      <div className="grid gap-1">
        <label htmlFor="loyalty-phone" className="text-sm font-semibold text-ink">
          Phone
        </label>
        <input
          id="loyalty-phone"
          name="phone"
          value={phone}
          onChange={(event) => setPhone(event.target.value)}
          placeholder="+9647700000000"
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
          placeholder="customer@example.com"
          autoComplete="email"
          className="h-12 rounded-md border border-neutral-200 bg-white px-3 text-base text-ink outline-none transition focus:border-mint"
          maxLength={200}
        />
      </div>

      <div className="grid gap-1">
        <label htmlFor="loyalty-name" className="text-sm font-semibold text-ink">
          Name
        </label>
        <input
          id="loyalty-name"
          name="name"
          value={name}
          onChange={(event) => setName(event.target.value)}
          placeholder="Demo Customer"
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
        {isSubmitting ? 'Joining...' : 'Join loyalty'}
      </button>
    </form>
  );
}
