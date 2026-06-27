'use client';

import Link from 'next/link';
import { useState } from 'react';
import type { WalletPlatform } from '../lib/wallet-platform';
import { AppleWalletButton } from './AppleWalletButton';
import { GoogleWalletButton } from './GoogleWalletButton';

type WalletActionsProps = {
  platform: WalletPlatform;
  appleWalletEnabled: boolean;
  apiBaseUrl: string;
  cardToken: string;
  cardHref: string;
};

export function WalletActions({
  platform,
  appleWalletEnabled,
  apiBaseUrl,
  cardToken,
  cardHref
}: WalletActionsProps) {
  const [copyState, setCopyState] = useState<'idle' | 'copied' | 'error'>('idle');

  async function copyCardLink() {
    try {
      const cardUrl = new URL(cardHref, window.location.origin).toString();
      await navigator.clipboard.writeText(cardUrl);
      setCopyState('copied');
    } catch {
      setCopyState('error');
    }
  }

  if (platform === 'ios') {
    return (
      <section
        className="grid gap-4 rounded-lg border border-neutral-200 bg-white p-4"
        data-wallet-platform="ios"
      >
        <div>
          <p className="text-xs font-semibold uppercase tracking-wide text-mint">
            Best for this iPhone
          </p>
          <h3 className="mt-1 text-lg font-bold text-ink">
            Add this card to Apple Wallet
          </h3>
          <p className="mt-2 text-sm leading-6 text-neutral-600">
            Keep it ready for your next visit. The live web card below stays
            current, and Wallet updates may sync shortly after staff add stamps.
          </p>
        </div>
        {appleWalletEnabled ? (
          <AppleWalletButton enabled cardToken={cardToken} />
        ) : (
          <p className="rounded-md bg-neutral-50 p-3 text-sm leading-6 text-neutral-600">
            Apple Wallet is not available for this card right now. Your web card is ready to use.
          </p>
        )}
        <Link
          href={cardHref}
          className={`inline-flex h-12 items-center justify-center rounded-md px-5 text-sm font-semibold transition ${
            appleWalletEnabled
              ? 'border border-neutral-200 bg-white text-ink hover:bg-neutral-50'
              : 'bg-ink text-white hover:bg-neutral-800'
          }`}
        >
          Open live card
        </Link>
      </section>
    );
  }

  if (platform === 'android') {
    return (
      <section
        className="grid gap-4 rounded-lg border border-neutral-200 bg-white p-4"
        data-wallet-platform="android"
      >
        <div>
          <p className="text-xs font-semibold uppercase tracking-wide text-mint">
            Best for this Android phone
          </p>
          <h3 className="mt-1 text-lg font-bold text-ink">
            Add this card to Google Wallet
          </h3>
          <p className="mt-2 text-sm leading-6 text-neutral-600">
            Keep it ready for your next visit. The live web card below stays
            current, and Wallet updates may sync shortly after staff add stamps.
          </p>
        </div>
        <GoogleWalletButton apiBaseUrl={apiBaseUrl} cardToken={cardToken} />
        <Link
          href={cardHref}
          className="inline-flex h-12 items-center justify-center rounded-md border border-neutral-200 bg-white px-5 text-sm font-semibold text-ink transition hover:bg-neutral-50"
        >
          Open live card
        </Link>
      </section>
    );
  }

  return (
    <section
      className="grid gap-3 rounded-lg border border-neutral-200 bg-neutral-50 p-4"
      data-wallet-platform="desktop"
    >
      <div>
        <h3 className="text-base font-bold text-ink">Open this link on your phone</h3>
        <p className="mt-1 text-sm leading-6 text-neutral-600">
          Wallet passes are designed for phones. Copy the card link, then open it on your iPhone or Android device.
        </p>
      </div>
      <button
        type="button"
        onClick={copyCardLink}
        className="inline-flex h-12 items-center justify-center rounded-md bg-ink px-5 text-sm font-semibold text-white transition hover:bg-neutral-800"
      >
        {copyState === 'copied' ? 'Card link copied' : 'Copy card link'}
      </button>
      {copyState === 'error' ? (
        <p role="alert" className="text-sm leading-6 text-red-700">
          Copy is unavailable in this browser. Open the web card and copy its address instead.
        </p>
      ) : null}
      <Link
        href={cardHref}
        className="inline-flex h-12 items-center justify-center rounded-md border border-neutral-200 bg-white px-5 text-sm font-semibold text-ink transition hover:bg-neutral-50"
      >
        Open live card in this browser
      </Link>
    </section>
  );
}
