'use client';

import { FormEvent, useEffect, useState } from 'react';
import { WalletActions } from '../../../components/WalletActions';
import { extractLoyaltyTransferToken } from '../../../lib/card-transfer';
import {
  normalizeIraqiPhone,
  validateIraqiPhone,
  validateOptionalEmail
} from '../../../lib/customer-identity';
import {
  enrollPublicLoyaltyCustomer,
  fetchPublicLoyaltyCard,
  redeemPublicLoyaltyCardTransfer,
  type PublicLoyaltyCard,
  type PublicLoyaltyEnrollment
} from '../../../lib/public-loyalty';
import { useWalletPlatform } from '../../../lib/use-wallet-platform';
import type { WalletPlatform } from '../../../lib/wallet-platform';

type LoyaltyEnrollmentClientProps = {
  slug: string;
  apiBaseUrl: string;
  appleWalletEnabled: boolean;
};

type IdentityMode = 'join' | 'recover';

export function getTokenStorageKey(slug: string) {
  return `tavrix.loyalty.${slug}.token`;
}

export function readStoredToken(slug: string): string | null {
  try {
    return window.localStorage.getItem(getTokenStorageKey(slug));
  } catch {
    return null;
  }
}

export function storeCardToken(slug: string, token: string): boolean {
  try {
    window.localStorage.setItem(getTokenStorageKey(slug), token);
    return true;
  } catch {
    return false;
  }
}

export function clearStoredToken(slug: string): void {
  try {
    window.localStorage.removeItem(getTokenStorageKey(slug));
  } catch {
    // Browser storage is best-effort.
  }
}

export async function loadStoredLoyaltyCard(
  slug: string,
  apiBaseUrl: string
): Promise<{ card: PublicLoyaltyCard; token: string } | null> {
  const token = readStoredToken(slug);

  if (!token) {
    return null;
  }

  const result = await fetchPublicLoyaltyCard(token, apiBaseUrl);

  if (result.status === 'ok') {
    return {
      card: result.data,
      token
    };
  }

  if (result.status === 'bad-request' || result.status === 'not-found') {
    clearStoredToken(slug);
  }

  return null;
}

export async function redeemAndStoreLoyaltyTransfer(
  slug: string,
  apiBaseUrl: string,
  value: string
): Promise<
  | {
      status: 'ok';
      enrollment: PublicLoyaltyEnrollment;
      storageUnavailable: boolean;
    }
  | {
      status: 'error';
      message: string;
    }
> {
  const transferToken = extractLoyaltyTransferToken(value);

  if (!transferToken) {
    return {
      status: 'error',
      message: 'Enter a valid one-time transfer code or link.'
    };
  }

  const result = await redeemPublicLoyaltyCardTransfer(
    transferToken,
    apiBaseUrl
  );

  if (result.status !== 'ok') {
    return {
      status: 'error',
      message: result.message
    };
  }

  return {
    status: 'ok',
    enrollment: result.data,
    storageUnavailable: !storeCardToken(
      slug,
      result.data.cardAccess.token
    )
  };
}

type LoyaltyEnrollmentSuccessProps = LoyaltyEnrollmentClientProps & {
  enrollment: PublicLoyaltyEnrollment;
  platform: WalletPlatform;
  storageUnavailable: boolean;
  variant?: 'joined' | 'transferred';
};

export function LoyaltyEnrollmentSuccess({
  slug,
  apiBaseUrl,
  appleWalletEnabled,
  enrollment,
  platform,
  storageUnavailable,
  variant = 'joined'
}: LoyaltyEnrollmentSuccessProps) {
  const cardHref = `/m/${encodeURIComponent(slug)}/loyalty/card?token=${encodeURIComponent(enrollment.cardAccess.token)}`;

  return (
    <section className="grid gap-5">
      <div className="rounded-lg border border-emerald-100 bg-emerald-50 p-4">
        <p className="text-sm font-semibold text-emerald-800">
          {variant === 'transferred'
            ? 'Card added securely'
            : 'Your loyalty card is ready'}
        </p>
        <p className="mt-2 text-sm leading-6 text-emerald-900">
          {enrollment.customer.name ? `${enrollment.customer.name}, add` : 'Add'} it to Wallet now so it is easy to find on your next visit.
        </p>
      </div>

      <CardProgress
        stampCount={enrollment.cardState.stampCount}
        stampGoal={enrollment.cardState.stampGoal}
        progressPercent={enrollment.cardState.progressPercent}
        rewardName={enrollment.program.rewardName}
        rewardReady={enrollment.cardState.rewardReady}
      />

      <WalletActions
        platform={platform}
        appleWalletEnabled={appleWalletEnabled}
        apiBaseUrl={apiBaseUrl}
        cardToken={enrollment.cardAccess.token}
        cardHref={cardHref}
      />

      {storageUnavailable ? (
        <p className="rounded-md border border-amber-100 bg-amber-50 p-3 text-sm leading-6 text-amber-700">
          This browser could not remember the card for later. Keep the card link available on this device.
        </p>
      ) : null}
    </section>
  );
}

type ReturningLoyaltyCardViewProps = LoyaltyEnrollmentClientProps & {
  card: PublicLoyaltyCard;
  cardToken: string;
  platform: WalletPlatform | null;
  onUseAnotherCard: () => void;
};

export function ReturningLoyaltyCardView({
  slug,
  apiBaseUrl,
  appleWalletEnabled,
  card,
  cardToken,
  platform,
  onUseAnotherCard
}: ReturningLoyaltyCardViewProps) {
  const cardHref = `/m/${encodeURIComponent(slug)}/loyalty/card?token=${encodeURIComponent(cardToken)}`;

  return (
    <section className="grid gap-5">
      <div className="rounded-lg border border-emerald-100 bg-emerald-50 p-4">
        <p className="text-sm font-semibold text-emerald-800">
          {card.customer.name ? `Welcome back, ${card.customer.name}` : 'Welcome back'}
        </p>
        <p className="mt-1 text-sm leading-6 text-emerald-900">
          Your card is ready. Add it to Wallet on this phone or open the live
          card for the latest progress.
        </p>
      </div>

      <CardProgress
        stampCount={card.cardState.stampCount}
        stampGoal={card.cardState.stampGoal}
        progressPercent={card.cardState.progressPercent}
        rewardName={card.cardState.rewardName}
        rewardReady={card.cardState.rewardReady}
      />

      {platform ? (
        <WalletActions
          platform={platform}
          appleWalletEnabled={appleWalletEnabled}
          apiBaseUrl={apiBaseUrl}
          cardToken={cardToken}
          cardHref={cardHref}
        />
      ) : (
        <p role="status" className="text-sm leading-6 text-neutral-600">
          Preparing the best wallet option for this device...
        </p>
      )}

      <button
        type="button"
        onClick={onUseAnotherCard}
        className="text-sm font-medium text-neutral-500 underline hover:text-neutral-700"
      >
        Not you? Use another phone or card
      </button>
    </section>
  );
}

type LoyaltyIdentityFormProps = {
  mode: IdentityMode;
  phone: string;
  email: string;
  name: string;
  phoneError: string | null;
  emailError: string | null;
  error: string | null;
  isSubmitting: boolean;
  onSubmit: (event: FormEvent<HTMLFormElement>) => void;
  onPhoneChange: (value: string) => void;
  onEmailChange: (value: string) => void;
  onNameChange: (value: string) => void;
  onModeChange: (mode: IdentityMode) => void;
  recoveryMessage: string;
  transferCode: string;
  transferError: string | null;
  isTransferSubmitting: boolean;
  onTransferCodeChange: (value: string) => void;
  onTransferSubmit: (event: FormEvent<HTMLFormElement>) => void;
};

export function LoyaltyIdentityForm({
  mode,
  phone,
  email,
  name,
  phoneError,
  emailError,
  error,
  isSubmitting,
  onSubmit,
  onPhoneChange,
  onEmailChange,
  onNameChange,
  onModeChange,
  recoveryMessage,
  transferCode,
  transferError,
  isTransferSubmitting,
  onTransferCodeChange,
  onTransferSubmit
}: LoyaltyIdentityFormProps) {
  const isRecovery = mode === 'recover';

  if (isRecovery) {
    return (
      <section className="grid gap-4" data-loyalty-recovery="verification-required">
        <div className="rounded-lg border border-amber-100 bg-amber-50 p-4">
          <p className="text-sm font-semibold text-amber-900">Recovery needs verification</p>
          <p className="mt-2 text-sm leading-6 text-amber-800">
            {recoveryMessage}
          </p>
        </div>

        <form
          onSubmit={onTransferSubmit}
          className="grid gap-3 rounded-lg border border-neutral-200 bg-white p-4"
          data-recovery-path="trusted-device"
        >
          <div>
            <h3 className="text-base font-bold text-ink">
              1. I have the card on another device
            </h3>
            <p className="mt-1 text-sm leading-6 text-neutral-600">
              Transfer works only while a trusted old device can still open
              the card. On that device, choose "Add card to another device,"
              then scan its QR or enter the one-time code below.
            </p>
          </div>
          <label
            htmlFor="loyalty-transfer-redeem"
            className="text-sm font-semibold text-ink"
          >
            Scan transfer QR / Enter transfer code
          </label>
          <input
            id="loyalty-transfer-redeem"
            name="transferCode"
            value={transferCode}
            onChange={(event) => onTransferCodeChange(event.target.value)}
            autoComplete="off"
            spellCheck={false}
            className="h-12 rounded-md border border-neutral-200 bg-white px-3 font-mono text-sm text-ink outline-none focus:border-mint"
          />
          {transferError ? (
            <p role="alert" className="text-sm leading-6 text-red-700">
              {transferError}
            </p>
          ) : null}
          <button
            type="submit"
            disabled={isTransferSubmitting}
            className="h-12 rounded-md bg-ink px-5 text-sm font-semibold text-white disabled:bg-neutral-400"
          >
            {isTransferSubmitting ? 'Adding card...' : 'Add card to this device'}
          </button>
        </form>

        <div
          className="rounded-lg border border-neutral-200 bg-neutral-50 p-4"
          data-recovery-path="lost-all-devices"
        >
          <h3 className="text-base font-bold text-ink">
            2. I lost access to all devices
          </h3>
          <p className="mt-1 text-sm leading-6 text-neutral-600">
            A transfer QR is not possible when no trusted device still has the
            card. Ask staff for help. A phone number or email alone cannot
            unlock an existing card.
          </p>
          <div className="mt-3 rounded-md border border-dashed border-neutral-300 bg-white p-3">
            <p className="text-sm font-semibold text-ink">
              Staff-assisted recovery is planned
            </p>
            <p className="mt-1 text-sm leading-6 text-neutral-600">
              Staff will verify the customer in person. A future authorized
              staff flow will generate a short-lived, single-use recovery QR or
              code and log the staff action. It will never use phone-only
              recovery.
            </p>
          </div>
        </div>

        <div
          className="rounded-lg border border-neutral-200 bg-white p-4"
          data-recovery-path="different-phone"
        >
          <h3 className="text-base font-bold text-ink">
            3. Join with a different phone
          </h3>
          <p className="mt-1 text-sm leading-6 text-neutral-600">
            Start a new enrollment only with a phone that is not already
            attached to a card for this business. An existing card here remains
            blocked until recovery is verified.
          </p>
          <button
            type="button"
            onClick={() => onModeChange('join')}
            className="mt-3 h-12 w-full rounded-md border border-neutral-200 bg-white px-5 text-sm font-semibold text-ink transition hover:bg-neutral-50"
          >
            Join with a different phone
          </button>
        </div>
      </section>
    );
  }

  return (
    <form onSubmit={onSubmit} noValidate className="grid gap-4">
      <div className="rounded-lg border border-neutral-200 bg-neutral-50 p-4">
        <p className="text-sm font-semibold text-ink">Join this loyalty program</p>
        <p className="mt-1 text-sm leading-6 text-neutral-600">
          Enter your phone once. We will create your card and then show the
          right Wallet button for this device. A phone number alone cannot open
          an existing card.
        </p>
      </div>

      <div className="grid gap-1">
        <label htmlFor="loyalty-phone" className="text-sm font-semibold text-ink">
          Phone number
        </label>
        <input
          id="loyalty-phone"
          name="phone"
          type="tel"
          value={phone}
          onChange={(event) => onPhoneChange(event.target.value)}
          placeholder="07701234567"
          autoComplete="tel"
          required
          className="h-12 rounded-md border border-neutral-200 bg-white px-3 text-base text-ink outline-none transition focus:border-mint aria-[invalid=true]:border-red-400"
          aria-invalid={phoneError ? 'true' : undefined}
          aria-describedby={phoneError ? 'loyalty-phone-error' : undefined}
          maxLength={24}
        />
        <p className="text-xs leading-5 text-neutral-500">
          Use 07xxxxxxxxx or +9647xxxxxxxxx. Staff may use this to help in
          person later.
        </p>
        {phoneError ? (
          <p id="loyalty-phone-error" role="alert" className="text-sm leading-5 text-red-600">
            {phoneError}
          </p>
        ) : null}
      </div>

      <div className="grid gap-1">
        <label htmlFor="loyalty-email" className="text-sm font-semibold text-ink">
          Email <span className="font-normal text-neutral-500">(optional)</span>
        </label>
        <input
          id="loyalty-email"
          name="email"
          type="email"
          value={email}
          onChange={(event) => onEmailChange(event.target.value)}
          placeholder="you@example.com"
          autoComplete="email"
          className="h-12 rounded-md border border-neutral-200 bg-white px-3 text-base text-ink outline-none transition focus:border-mint aria-[invalid=true]:border-red-400"
          aria-invalid={emailError ? 'true' : undefined}
          aria-describedby={emailError ? 'loyalty-email-error' : undefined}
          maxLength={200}
        />
        {emailError ? (
          <p id="loyalty-email-error" role="alert" className="text-sm leading-5 text-red-600">
            {emailError}
          </p>
        ) : null}
      </div>

      <div className="grid gap-1">
        <label htmlFor="loyalty-name" className="text-sm font-semibold text-ink">
          Name <span className="font-normal text-neutral-500">(optional)</span>
        </label>
        <input
          id="loyalty-name"
          name="name"
          type="text"
          value={name}
          onChange={(event) => onNameChange(event.target.value)}
          placeholder="Your name"
          autoComplete="name"
          className="h-12 rounded-md border border-neutral-200 bg-white px-3 text-base text-ink outline-none transition focus:border-mint"
          maxLength={160}
        />
      </div>

      {error ? (
        <p role="alert" className="rounded-md border border-red-100 bg-red-50 p-3 text-sm leading-6 text-red-700">
          {error}
        </p>
      ) : null}

      <button
        type="submit"
        disabled={isSubmitting}
        className="h-12 rounded-md bg-ink px-5 text-sm font-semibold text-white transition hover:bg-neutral-800 disabled:cursor-not-allowed disabled:bg-neutral-400"
      >
        {isSubmitting ? 'Creating your card...' : 'Join and get your card'}
      </button>

      <button
        type="button"
        onClick={() => onModeChange('recover')}
        className="text-sm font-medium text-neutral-600 underline hover:text-ink"
      >
        I already joined
      </button>
    </form>
  );
}

function CardProgress({
  stampCount,
  stampGoal,
  progressPercent,
  rewardName,
  rewardReady
}: {
  stampCount: number;
  stampGoal: number;
  progressPercent: number;
  rewardName: string;
  rewardReady: boolean;
}) {
  return (
    <div className="grid gap-3 rounded-lg border border-neutral-200 bg-neutral-50 p-4">
      <div>
        <p className="text-sm font-semibold text-neutral-500">Progress</p>
        <p className="mt-1 text-lg font-bold text-ink">
          {stampCount} / {stampGoal} stamps
        </p>
      </div>
      <div className="h-3 overflow-hidden rounded-full bg-white">
        <div className="h-full rounded-full bg-mint" style={{ width: `${progressPercent}%` }} />
      </div>
      <p className="text-sm font-semibold text-neutral-700">
        {rewardReady ? `${rewardName} is ready to redeem` : rewardName}
      </p>
    </div>
  );
}

export function LoyaltyEnrollmentClient({
  slug,
  apiBaseUrl,
  appleWalletEnabled
}: LoyaltyEnrollmentClientProps) {
  const [mode, setMode] = useState<IdentityMode>('join');
  const [phone, setPhone] = useState('');
  const [phoneError, setPhoneError] = useState<string | null>(null);
  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState<string | null>(null);
  const [name, setName] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [storageUnavailable, setStorageUnavailable] = useState(false);
  const [enrollment, setEnrollment] = useState<PublicLoyaltyEnrollment | null>(null);
  const [successVariant, setSuccessVariant] = useState<'joined' | 'transferred'>('joined');
  const [isCheckingToken, setIsCheckingToken] = useState(true);
  const [returningCard, setReturningCard] = useState<PublicLoyaltyCard | null>(null);
  const [returningToken, setReturningToken] = useState<string | null>(null);
  const [recoveryMessage, setRecoveryMessage] = useState(
    'Choose the path that matches your situation. Transfer is available only when at least one trusted old device still has the card. Phone or email alone cannot unlock it.'
  );
  const [transferCode, setTransferCode] = useState('');
  const [transferError, setTransferError] = useState<string | null>(null);
  const [isTransferSubmitting, setIsTransferSubmitting] = useState(false);
  const platform = useWalletPlatform();

  useEffect(() => {
    let cancelled = false;

    async function checkStoredToken() {
      const result = await loadStoredLoyaltyCard(slug, apiBaseUrl);

      if (cancelled) {
        return;
      }

      if (result) {
        setReturningCard(result.card);
        setReturningToken(result.token);
        setIsCheckingToken(false);
        return;
      }

      const hashTransfer = extractLoyaltyTransferToken(window.location.hash);

      if (hashTransfer) {
        const transfer = await redeemAndStoreLoyaltyTransfer(
          slug,
          apiBaseUrl,
          hashTransfer
        );

        if (cancelled) {
          return;
        }

        if (transfer.status === 'ok') {
          setStorageUnavailable(transfer.storageUnavailable);
          setSuccessVariant('transferred');
          setEnrollment(transfer.enrollment);
          window.history.replaceState(
            null,
            '',
            `${window.location.pathname}${window.location.search}`
          );
        } else {
          setMode('recover');
          setTransferError(transfer.message);
        }
      }

      setIsCheckingToken(false);
    }

    void checkStoredToken();

    return () => {
      cancelled = true;
    };
  }, [apiBaseUrl, slug]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const nextPhoneError = validateIraqiPhone(phone);
    const nextEmailError = validateOptionalEmail(email);

    setPhoneError(nextPhoneError);
    setEmailError(nextEmailError);

    if (nextPhoneError || nextEmailError) {
      return;
    }

    const normalizedPhone = normalizeIraqiPhone(phone);

    if (!normalizedPhone) {
      return;
    }

    setError(null);
    setStorageUnavailable(false);
    setIsSubmitting(true);

    const result = await enrollPublicLoyaltyCustomer(
      slug,
      {
        phone: normalizedPhone,
        email: email.trim() || undefined,
        name: name.trim() || undefined,
        intent: 'JOIN'
      },
      apiBaseUrl
    );

    setIsSubmitting(false);

    if (result.status !== 'ok') {
      if (result.status === 'verification-required') {
        setRecoveryMessage(
          'This phone is already attached to a card for this business. If a trusted old device still has access, add this device from there. Otherwise, ask staff for help.'
        );
        changeMode('recover');
        return;
      }

      setError(result.message);
      return;
    }

    const stored = storeCardToken(slug, result.data.cardAccess.token);

    if (!stored) {
      setStorageUnavailable(true);
    }

    setEnrollment(result.data);
  }

  async function handleTransferSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setTransferError(null);
    setIsTransferSubmitting(true);

    const result = await redeemAndStoreLoyaltyTransfer(
      slug,
      apiBaseUrl,
      transferCode
    );

    setIsTransferSubmitting(false);

    if (result.status === 'error') {
      setTransferError(result.message);
      return;
    }

    setStorageUnavailable(result.storageUnavailable);
    setSuccessVariant('transferred');
    setEnrollment(result.enrollment);
  }

  function changeMode(nextMode: IdentityMode) {
    setMode(nextMode);
    setError(null);
    setPhoneError(null);
    setEmailError(null);
  }

  if (isCheckingToken) {
    return (
      <div className="flex items-center gap-2 text-sm text-neutral-500">
        <span className="inline-block h-4 w-4 animate-spin rounded-full border-2 border-neutral-300 border-t-transparent" />
        Loading your card...
      </div>
    );
  }

  if (returningCard && returningToken) {
    return (
      <ReturningLoyaltyCardView
        slug={slug}
        apiBaseUrl={apiBaseUrl}
        appleWalletEnabled={appleWalletEnabled}
        card={returningCard}
        cardToken={returningToken}
        platform={platform}
        onUseAnotherCard={() => {
          clearStoredToken(slug);
          setReturningCard(null);
          setReturningToken(null);
          changeMode('recover');
        }}
      />
    );
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
        variant={successVariant}
      />
    );
  }

  return (
    <LoyaltyIdentityForm
      mode={mode}
      phone={phone}
      email={email}
      name={name}
      phoneError={phoneError}
      emailError={emailError}
      error={error}
      isSubmitting={isSubmitting}
      onSubmit={handleSubmit}
      onPhoneChange={(value) => {
        setPhone(value);
        setPhoneError(null);
      }}
      onEmailChange={(value) => {
        setEmail(value);
        setEmailError(null);
      }}
      onNameChange={setName}
      onModeChange={(nextMode) => {
        if (nextMode === 'recover') {
          setRecoveryMessage(
            'Transfer is only for customers who still have the card on a trusted old device. If all device access is lost, ask staff for help. Phone recovery is unavailable without verification.'
          );
        }
        changeMode(nextMode);
      }}
      recoveryMessage={recoveryMessage}
      transferCode={transferCode}
      transferError={transferError}
      isTransferSubmitting={isTransferSubmitting}
      onTransferCodeChange={(value) => {
        setTransferCode(value);
        setTransferError(null);
      }}
      onTransferSubmit={handleTransferSubmit}
    />
  );
}
