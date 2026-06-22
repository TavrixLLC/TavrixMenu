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
      <div className="grid justify-items-center gap-3">
        <button
          type="button"
          disabled
          aria-label="Add to Google Wallet"
          className="inline-flex cursor-not-allowed rounded-full bg-[#1f1f1f] p-0 opacity-50"
        >
          <img
            src="/add-to-google-wallet.svg"
            alt="Add to Google Wallet"
            width={181}
            height={50}
            className="h-[50px] w-auto"
          />
        </button>
        <p role="status" className="w-full rounded-md border border-amber-100 bg-amber-50 p-3 text-sm leading-6 text-amber-700">
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
    <div className="grid justify-items-center gap-3">
      <button
        type="button"
        onClick={handleClick}
        disabled={isGoogleWalletButtonDisabled({ isLoading, hasCardToken })}
        aria-label={getGoogleWalletButtonLabel({
          isLoading,
          hasError: Boolean(error)
        })}
        aria-busy={isLoading}
        className="inline-flex rounded-full bg-[#1f1f1f] p-0 transition hover:opacity-90 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ink disabled:cursor-wait disabled:opacity-60"
      >
        <img
          src="/add-to-google-wallet.svg"
          alt="Add to Google Wallet"
          width={181}
          height={50}
          className="h-[50px] w-auto"
        />
      </button>
      {error ? (
        <p role="alert" className="w-full rounded-md border border-red-100 bg-red-50 p-3 text-sm leading-6 text-red-700">
          {error}
        </p>
      ) : null}
    </div>
  );
}
