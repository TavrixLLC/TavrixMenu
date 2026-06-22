'use client';

import { useState } from 'react';
import { addToAppleWallet } from '../lib/apple-wallet';

type AppleWalletButtonProps = {
  enabled: boolean;
  cardToken: string;
};

export function AppleWalletButton({
  enabled,
  cardToken
}: AppleWalletButtonProps) {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const normalizedToken = cardToken.trim();

  if (!enabled || !normalizedToken) {
    return null;
  }

  async function handleClick() {
    if (isLoading) {
      return;
    }

    setIsLoading(true);
    setError(null);
    const result = await addToAppleWallet(normalizedToken);

    if (result.status === 'error') {
      setError(result.message);
      setIsLoading(false);
      return;
    }

    setIsLoading(false);
  }

  return (
    <div className="grid justify-items-center gap-3">
      <button
        type="button"
        onClick={handleClick}
        disabled={isLoading}
        aria-label={isLoading ? 'Adding to Apple Wallet' : 'Add to Apple Wallet'}
        aria-busy={isLoading}
        className="inline-flex rounded-lg bg-black p-0 transition hover:opacity-90 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ink disabled:cursor-wait disabled:opacity-60"
      >
        <img
          src="/add-to-apple-wallet.svg"
          alt="Add to Apple Wallet"
          width={162}
          height={50}
          className="h-[50px] w-auto"
        />
      </button>
      {error ? (
        <p
          role="alert"
          className="w-full rounded-md border border-red-100 bg-red-50 p-3 text-sm leading-6 text-red-700"
        >
          {error}
        </p>
      ) : null}
    </div>
  );
}
