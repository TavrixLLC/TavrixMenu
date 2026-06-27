'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { CardTransferPanel } from '../../../../components/CardTransferPanel';
import { WalletActions } from '../../../../components/WalletActions';
import { fetchPublicLoyaltyCard, type PublicLoyaltyCard } from '../../../../lib/public-loyalty';
import { useWalletPlatform } from '../../../../lib/use-wallet-platform';
import type { WalletPlatform } from '../../../../lib/wallet-platform';

type CardStatus =
  | {
      state: 'bootstrapping' | 'loading-card';
    }
  | {
      state: 'missing-token' | 'storage-unavailable';
      message: string;
    }
  | {
      state: 'error';
      message: string;
    }
  | {
      state: 'ok';
      card: PublicLoyaltyCard;
      token: string;
    };

type LoyaltyCardClientProps = {
  slug: string;
  initialToken: string | null;
  apiBaseUrl: string;
  appleWalletEnabled: boolean;
};

function getTokenStorageKey(slug: string) {
  return `tavrix.loyalty.${slug}.token`;
}

function readStoredToken(slug: string): { token: string | null; storageAvailable: boolean } {
  try {
    return {
      token: window.localStorage.getItem(getTokenStorageKey(slug)),
      storageAvailable: true
    };
  } catch {
    return {
      token: null,
      storageAvailable: false
    };
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

function LoyaltyCardShell({
  slug,
  title,
  children
}: {
  slug: string;
  title: string;
  children: React.ReactNode;
}) {
  return (
    <main className="mx-auto min-h-screen w-full max-w-3xl bg-[#fafaf7] px-4 py-6">
      <Link href={`/m/${slug}`} className="text-sm font-semibold text-neutral-600">
        Back to menu
      </Link>
      <section className="mt-5 rounded-lg border border-neutral-200 bg-white p-6 shadow-sm">
        <p className="text-sm font-semibold uppercase text-mint">Loyalty card</p>
        <h1 className="mt-2 text-3xl font-bold text-ink">{title}</h1>
        {children}
      </section>
    </main>
  );
}

function CardMetrics({ card }: { card: PublicLoyaltyCard }) {
  const state = card.cardState;
  const stampsRemaining = Math.max(state.stampGoal - state.stampCount, 0);

  return (
    <div className="mt-5 grid gap-3 sm:grid-cols-2">
      <div className="rounded-lg border border-neutral-200 bg-neutral-50 p-4">
        <p className="text-sm font-semibold text-neutral-500">Stamps</p>
        <p className="mt-1 text-2xl font-bold text-ink">
          {state.stampCount} / {state.stampGoal}
        </p>
      </div>
      <div className="rounded-lg border border-neutral-200 bg-neutral-50 p-4">
        <p className="text-sm font-semibold text-neutral-500">Progress</p>
        <p className="mt-1 text-2xl font-bold text-ink">{state.progressPercent}%</p>
      </div>
      <div className="rounded-lg border border-neutral-200 bg-neutral-50 p-4">
        <p className="text-sm font-semibold text-neutral-500">Total stamps earned</p>
        <p className="mt-1 text-2xl font-bold text-ink">{state.totalStampsEarned}</p>
      </div>
      <div className="rounded-lg border border-neutral-200 bg-neutral-50 p-4">
        <p className="text-sm font-semibold text-neutral-500">Rewards redeemed</p>
        <p className="mt-1 text-2xl font-bold text-ink">{state.totalRewardsRedeemed}</p>
      </div>
      <div className="sm:col-span-2">
        <div className="h-3 overflow-hidden rounded-full bg-neutral-100">
          <div className="h-full rounded-full bg-mint" style={{ width: `${state.progressPercent}%` }} />
        </div>
        <p className="mt-3 rounded-md bg-emerald-50 p-3 text-sm font-semibold text-emerald-800">
          {state.rewardReady
            ? 'Reward ready. Ask staff to redeem it.'
            : `You need ${stampsRemaining} more ${stampsRemaining === 1 ? 'stamp' : 'stamps'}.`}
        </p>
      </div>
    </div>
  );
}

export function AppleWalletRefreshNotice() {
  return (
    <p className="mt-5 rounded-md bg-sky-50 p-3 text-sm leading-6 text-sky-800">
      Your live web card is the source of truth and updates online first. Apple Wallet and Google Wallet may sync shortly after stamps are added.
    </p>
  );
}

function getCardUnavailableCopy(state: CardStatus['state'], message?: string) {
  if (state === 'missing-token') {
    return 'We could not open a saved loyalty card on this browser. Join loyalty, transfer from a trusted old device, or ask staff for help.';
  }

  if (state === 'storage-unavailable') {
    return 'This browser could not read the saved loyalty card. Open the card from your original link or ask staff for help.';
  }

  if (state === 'error') {
    return message && /invalid|expired|already used/i.test(message)
      ? 'This card link is no longer available. Ask staff for help or transfer the card from a trusted old device.'
      : 'We could not load this card right now. Please try again in a moment.';
  }

  return 'We could not open this card right now. Please try again in a moment.';
}

function CardView({
  slug,
  card,
  cardToken,
  apiBaseUrl,
  appleWalletEnabled,
  platform
}: {
  slug: string;
  card: PublicLoyaltyCard;
  cardToken: string;
  apiBaseUrl: string;
  appleWalletEnabled: boolean;
  platform: WalletPlatform;
}) {
  const cardHref = `/m/${encodeURIComponent(slug)}/loyalty/card?token=${encodeURIComponent(cardToken)}`;

  return (
    <main className="min-h-screen bg-[#fafaf7] pb-10">
      <section className="mx-auto w-full max-w-3xl px-4 pt-5">
        <Link href={`/m/${slug}`} className="text-sm font-semibold text-neutral-600">
          Back to menu
        </Link>

        <article className="mt-5 overflow-hidden rounded-lg border border-neutral-200 bg-white shadow-sm">
          {card.business.coverUrl ? (
            <img
              src={card.business.coverUrl}
              alt={`${card.business.name} cover`}
              className="h-36 w-full object-cover sm:h-48"
            />
          ) : (
            <div className="h-24 bg-neutral-100 sm:h-32" />
          )}
          <div className="p-5">
            <div className="flex items-start gap-4">
              {card.business.logoUrl ? (
                <img
                  src={card.business.logoUrl}
                  alt={`${card.business.name} logo`}
                  className="h-16 w-16 shrink-0 rounded-lg object-cover"
                />
              ) : (
                <div className="flex h-16 w-16 shrink-0 items-center justify-center rounded-lg border border-dashed border-neutral-300 bg-neutral-50 text-xs font-semibold text-neutral-500">
                  Logo
                </div>
              )}
              <div className="min-w-0">
                <p className="text-sm font-semibold text-mint">{card.business.name}</p>
                <h1 className="mt-1 text-3xl font-bold text-ink">{card.program.name}</h1>
                {card.customer.name ? <p className="mt-1 text-sm text-neutral-500">{card.customer.name}</p> : null}
              </div>
            </div>

            <div className="mt-5 rounded-lg border border-neutral-200 bg-neutral-50 p-4">
              <p className="text-sm font-semibold text-neutral-500">Reward</p>
              <p className="mt-1 text-xl font-bold text-ink">{card.program.rewardName}</p>
              {card.program.rewardDescription ? (
                <p className="mt-2 text-sm leading-6 text-neutral-700">{card.program.rewardDescription}</p>
              ) : null}
            </div>

            <CardMetrics card={card} />

            <AppleWalletRefreshNotice />

            <div className="mt-5 border-t border-neutral-200 pt-5">
              <h2 className="text-lg font-bold text-ink">Add to Wallet</h2>
              <p className="mt-1 text-sm leading-6 text-neutral-600">
                Use the recommended Wallet button for this device, or keep the
                live web card open for the latest progress.
              </p>
              <div className="mt-3">
                <WalletActions
                  platform={platform}
                  appleWalletEnabled={appleWalletEnabled}
                  apiBaseUrl={apiBaseUrl}
                  cardToken={cardToken}
                  cardHref={cardHref}
                />
              </div>
            </div>

            <CardTransferPanel
              slug={slug}
              apiBaseUrl={apiBaseUrl}
              cardToken={cardToken}
            />

            {card.program.terms ? (
              <p className="mt-5 rounded-md bg-neutral-50 p-4 text-sm leading-6 text-neutral-600">
                {card.program.terms}
              </p>
            ) : null}
          </div>
        </article>
      </section>
    </main>
  );
}

export function LoyaltyCardClient({
  slug,
  initialToken,
  apiBaseUrl,
  appleWalletEnabled
}: LoyaltyCardClientProps) {
  const [status, setStatus] = useState<CardStatus>({ state: 'bootstrapping' });
  const [retryNonce, setRetryNonce] = useState(0);
  const platform = useWalletPlatform();

  useEffect(() => {
    let isActive = true;

    async function loadCard() {
      const queryToken = initialToken?.trim() || null;
      const stored = queryToken ? { token: queryToken, storageAvailable: true } : readStoredToken(slug);
      const token = stored.token?.trim() || null;

      if (queryToken) {
        storeCardToken(slug, queryToken);
      }

      if (!stored.storageAvailable && !queryToken) {
        setStatus({
          state: 'storage-unavailable',
          message: 'This browser could not read the saved loyalty card.'
        });
        return;
      }

      if (!token) {
        setStatus({
          state: 'missing-token',
          message: 'No saved loyalty card was found for this business.'
        });
        return;
      }

      setStatus({ state: 'loading-card' });
      const result = await fetchPublicLoyaltyCard(token, apiBaseUrl);

      if (!isActive) {
        return;
      }

      if (result.status === 'ok') {
        setStatus({
          state: 'ok',
          card: result.data,
          token
        });
        return;
      }

      setStatus({
        state: 'error',
        message: result.message
      });
    }

    void loadCard();

    return () => {
      isActive = false;
    };
  }, [apiBaseUrl, initialToken, retryNonce, slug]);

  switch (status.state) {
    case 'bootstrapping':
      return (
        <LoyaltyCardShell slug={slug} title="Opening card">
          <p className="mt-3 text-base leading-7 text-neutral-600">Checking this browser for a saved loyalty card...</p>
        </LoyaltyCardShell>
      );
    case 'loading-card':
      return (
        <LoyaltyCardShell slug={slug} title="Loading card">
          <p className="mt-3 text-base leading-7 text-neutral-600">Loading your web loyalty card...</p>
        </LoyaltyCardShell>
      );
    case 'missing-token':
    case 'storage-unavailable':
    case 'error':
      return (
        <LoyaltyCardShell slug={slug} title="Card unavailable">
          <p className="mt-3 text-base leading-7 text-neutral-600">
            {getCardUnavailableCopy(status.state, status.message)}
          </p>
          <Link
            href={`/m/${slug}/loyalty`}
            className="mt-5 inline-flex rounded-md bg-ink px-5 py-3 text-sm font-semibold text-white"
          >
            Join loyalty
          </Link>
          {status.state === 'error' ? (
            <button
              type="button"
              onClick={() => setRetryNonce((value) => value + 1)}
              className="ml-3 mt-5 inline-flex rounded-md border border-neutral-200 bg-white px-5 py-3 text-sm font-semibold text-ink"
            >
              Try again
            </button>
          ) : null}
        </LoyaltyCardShell>
      );
    case 'ok':
      if (!platform) {
        return (
          <LoyaltyCardShell slug={slug} title="Loading wallet options">
            <p role="status" className="mt-3 text-base leading-7 text-neutral-600">
              Preparing the best wallet option for this device...
            </p>
          </LoyaltyCardShell>
        );
      }

      return (
        <CardView
          slug={slug}
          card={status.card}
          cardToken={status.token}
          apiBaseUrl={apiBaseUrl}
          appleWalletEnabled={appleWalletEnabled}
          platform={platform}
        />
      );
  }
}
