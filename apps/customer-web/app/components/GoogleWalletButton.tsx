'use client';

import { useState } from 'react';
import {
  getGoogleWalletButtonLabel,
  isGoogleWalletButtonDisabled,
  requestGoogleWalletSaveUrl,
  shouldShowGoogleWalletButton
} from '../lib/google-wallet';

type GoogleWalletButtonProps = {
  apiBaseUrl: string;
  businessId?: string | null;
  membershipId?: string | null;
};

export function GoogleWalletButton({ apiBaseUrl, businessId, membershipId }: GoogleWalletButtonProps) {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!shouldShowGoogleWalletButton({ businessId, membershipId })) {
    return null;
  }

  async function handleClick() {
    if (isLoading || !businessId || !membershipId) {
      return;
    }

    setIsLoading(true);
    setError(null);

    const result = await requestGoogleWalletSaveUrl({
      apiBaseUrl,
      businessId,
      membershipId
    });

    setIsLoading(false);

    if (result.status === 'error') {
      setError(result.message);
      return;
    }

    const openedWindow = window.open(result.data.saveUrl, '_blank', 'noopener,noreferrer');

    if (!openedWindow) {
      window.location.assign(result.data.saveUrl);
    }
  }

  return (
    <div className="mt-5 rounded-lg border border-neutral-200 bg-neutral-50 p-4">
      <button
        type="button"
        onClick={handleClick}
        disabled={isGoogleWalletButtonDisabled({ isLoading })}
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
