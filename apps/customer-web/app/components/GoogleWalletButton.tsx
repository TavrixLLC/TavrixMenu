'use client';

import { useState } from 'react';
import {
  getGoogleWalletButtonLabel,
  isGoogleWalletButtonDisabled,
  openGoogleWalletSaveUrl,
  requestGoogleWalletSaveUrl,
  shouldShowGoogleWalletButton
} from '../lib/google-wallet';

type GoogleWalletButtonProps = {
  apiBaseUrl: string;
  cardToken?: string | null;
};

export function GoogleWalletButton({ apiBaseUrl, cardToken }: GoogleWalletButtonProps) {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const normalizedCardToken = cardToken?.trim() || null;
  const hasCardToken = shouldShowGoogleWalletButton({
    cardToken: normalizedCardToken
  });

  if (!hasCardToken) {
    return (
      <div className="mt-5 rounded-lg border border-neutral-200 bg-neutral-50 p-4">
        <button
          type="button"
          disabled
          className="h-12 w-full cursor-not-allowed rounded-md bg-neutral-300 px-5 text-sm font-semibold text-white"
        >
          Add to Google Wallet
        </button>
        <p role="status" className="mt-3 rounded-md border border-amber-100 bg-amber-50 p-3 text-sm leading-6 text-amber-700">
          Open this loyalty card from its card link to add it to Google Wallet.
        </p>
      </div>
    );
  }

  async function handleClick() {
    if (isLoading || !hasCardToken || !normalizedCardToken) {
      return;
    }

    setIsLoading(true);
    setError(null);

    const result = await requestGoogleWalletSaveUrl({
      apiBaseUrl,
      cardToken: normalizedCardToken
    });

    setIsLoading(false);

    if (result.status === 'error') {
      setError(result.message);
      return;
    }

    openGoogleWalletSaveUrl(result.data.saveUrl);
  }

  return (
    <div className="mt-5 rounded-lg border border-neutral-200 bg-neutral-50 p-4">
      <button
        type="button"
        onClick={handleClick}
        disabled={isGoogleWalletButtonDisabled({ isLoading, hasCardToken })}
        className="h-12 w-full rounded-md bg-ink px-5 text-sm font-semibold text-white transition hover:bg-neutral-800 disabled:cursor-not-allowed disabled:bg-neutral-400"
      >
        {getGoogleWalletButtonLabel({
          isLoading,
          hasError: Boolean(error)
        })}
      </button>
      {error ? (
        <p role="alert" className="mt-3 rounded-md border border-red-100 bg-red-50 p-3 text-sm leading-6 text-red-700">
          {error}
        </p>
      ) : null}
    </div>
  );
}
