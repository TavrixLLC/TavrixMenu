'use client';

import { useState } from 'react';
import { buildLoyaltyTransferUrl } from '../lib/card-transfer';
import { createPublicLoyaltyCardTransfer } from '../lib/public-loyalty';

type CardTransferPanelProps = {
  slug: string;
  apiBaseUrl: string;
  cardToken: string;
};

type TransferState =
  | {
      status: 'idle' | 'loading';
    }
  | {
      status: 'error';
      message: string;
    }
  | {
      status: 'ready';
      transferToken: string;
      transferUrl: string;
      qrDataUrl: string;
      expiresAt: string;
    };

export function CardTransferPanel({
  slug,
  apiBaseUrl,
  cardToken
}: CardTransferPanelProps) {
  const [state, setState] = useState<TransferState>({ status: 'idle' });
  const [copyState, setCopyState] = useState<'idle' | 'copied' | 'error'>(
    'idle'
  );

  async function createTransfer() {
    setState({ status: 'loading' });
    setCopyState('idle');

    const result = await createPublicLoyaltyCardTransfer(
      cardToken,
      apiBaseUrl
    );

    if (result.status !== 'ok') {
      setState({
        status: 'error',
        message: result.message
      });
      return;
    }

    try {
      const transferUrl = buildLoyaltyTransferUrl(
        window.location.origin,
        slug,
        result.data.transferToken
      );
      const { default: QRCode } = await import('qrcode');
      const qrDataUrl = await QRCode.toDataURL(transferUrl, {
        errorCorrectionLevel: 'M',
        margin: 2,
        width: 240
      });

      setState({
        status: 'ready',
        transferToken: result.data.transferToken,
        transferUrl,
        qrDataUrl,
        expiresAt: result.data.expiresAt
      });
    } catch {
      setState({
        status: 'error',
        message: 'The transfer QR could not be prepared in this browser.'
      });
    }
  }

  async function copyTransferLink() {
    if (state.status !== 'ready') {
      return;
    }

    try {
      await navigator.clipboard.writeText(state.transferUrl);
      setCopyState('copied');
    } catch {
      setCopyState('error');
    }
  }

  return (
    <section
      className="mt-5 rounded-lg border border-neutral-200 bg-neutral-50 p-4"
      data-card-transfer
    >
      <h2 className="text-lg font-bold text-ink">
        Add card to another device
      </h2>
      <p className="mt-2 text-sm leading-6 text-neutral-600">
        Create a one-time QR from this trusted card. It expires after five
        minutes, cannot add stamps or redeem rewards, and keeps this device
        connected.
      </p>

      {state.status === 'idle' || state.status === 'error' ? (
        <button
          type="button"
          onClick={createTransfer}
          className="mt-4 inline-flex h-11 items-center justify-center rounded-md bg-ink px-4 text-sm font-semibold text-white"
        >
          Create add-device QR
        </button>
      ) : null}

      {state.status === 'loading' ? (
        <p role="status" className="mt-4 text-sm text-neutral-600">
          Creating a secure transfer...
        </p>
      ) : null}

      {state.status === 'error' ? (
        <p
          role="alert"
          className="mt-3 rounded-md border border-red-100 bg-red-50 p-3 text-sm leading-6 text-red-700"
        >
          {state.message}
        </p>
      ) : null}

      {state.status === 'ready' ? (
        <div className="mt-4 grid gap-4 sm:grid-cols-[240px_1fr] sm:items-start">
          <img
            src={state.qrDataUrl}
            alt="One-time loyalty card transfer QR code"
            className="h-60 w-60 rounded-md border border-neutral-200 bg-white"
          />
          <div className="grid gap-3">
            <p className="text-sm leading-6 text-neutral-700">
              On the new phone, scan this QR with the phone Camera. You can
              also enter the one-time code manually.
            </p>
            <label
              htmlFor="loyalty-transfer-code"
              className="text-sm font-semibold text-ink"
            >
              One-time transfer code
            </label>
            <input
              id="loyalty-transfer-code"
              readOnly
              value={state.transferToken}
              className="h-11 min-w-0 rounded-md border border-neutral-200 bg-white px-3 font-mono text-xs text-ink"
            />
            <button
              type="button"
              onClick={copyTransferLink}
              className="inline-flex h-11 items-center justify-center rounded-md border border-neutral-200 bg-white px-4 text-sm font-semibold text-ink"
            >
              {copyState === 'copied'
                ? 'Transfer link copied'
                : 'Copy transfer link'}
            </button>
            {copyState === 'error' ? (
              <p role="alert" className="text-sm text-red-700">
                Copy is unavailable. Enter the code manually on the new device.
              </p>
            ) : null}
            <p className="text-xs leading-5 text-neutral-500">
              Expires at {new Date(state.expiresAt).toLocaleTimeString()}.
              Successful use adds the new device without signing this device
              out.
            </p>
          </div>
        </div>
      ) : null}
    </section>
  );
}
