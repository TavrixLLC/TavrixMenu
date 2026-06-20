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
    <div className="mt-3 rounded-lg border border-neutral-200 bg-neutral-50 p-4">
      <button
        type="button"
        onClick={handleClick}
        disabled={isLoading}
        className="h-12 w-full rounded-md border border-ink bg-white px-5 text-sm font-semibold text-ink transition hover:bg-neutral-100 disabled:cursor-not-allowed disabled:border-neutral-300 disabled:text-neutral-400"
      >
        {isLoading ? 'Adding to Apple Wallet...' : 'Add to Apple Wallet'}
      </button>
      {error ? (
        <p
          role="alert"
          className="mt-3 rounded-md border border-red-100 bg-red-50 p-3 text-sm leading-6 text-red-700"
        >
          {error}
        </p>
      ) : null}
    </div>
  );
}
