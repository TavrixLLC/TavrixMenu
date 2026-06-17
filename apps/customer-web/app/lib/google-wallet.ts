export type GoogleWalletContext = {
  cardToken: string;
};

export type GoogleWalletSaveUrlResponse = {
  platform: 'GOOGLE_WALLET';
  saveUrl: string;
  status: string;
  businessName: string;
  programName: string;
  lastSyncedAt: string;
};

export type GoogleWalletSaveUrlResult =
  | {
      status: 'ok';
      data: GoogleWalletSaveUrlResponse;
    }
  | {
      status: 'error';
      message: string;
    };

type WalletFetch = (
  input: string,
  init: {
    method: 'POST';
    headers: {
      Accept: 'application/json';
    };
  }
) => Promise<{
  ok: boolean;
  status: number;
  json: () => Promise<unknown>;
}>;

export function shouldShowGoogleWalletButton(context: {
  cardToken?: string | null;
}) {
  return Boolean(context.cardToken?.trim());
}

export function getGoogleWalletButtonLabel(state: {
  isLoading: boolean;
  hasError: boolean;
}) {
  if (state.isLoading) {
    return 'Opening Google Wallet...';
  }

  return state.hasError ? 'Try Google Wallet again' : 'Add to Google Wallet';
}

export function isGoogleWalletButtonDisabled(state: {
  isLoading: boolean;
  hasCardToken?: boolean;
}) {
  return state.isLoading || state.hasCardToken === false;
}

export function buildGoogleWalletUrl(input: {
  apiBaseUrl: string;
  cardToken: string;
}) {
  const apiBaseUrl = input.apiBaseUrl.replace(/\/+$/, '');

  return `${apiBaseUrl}/public/loyalty/cards/${encodeURIComponent(
    input.cardToken
  )}/google-wallet`;
}

export async function requestGoogleWalletSaveUrl(
  input: {
    apiBaseUrl: string;
    cardToken: string;
  },
  fetcher: WalletFetch = fetch
): Promise<GoogleWalletSaveUrlResult> {
  const response = await fetcher(buildGoogleWalletUrl(input), {
    method: 'POST',
    headers: {
      Accept: 'application/json'
    }
  });
  const body = await response.json().catch(() => null);

  if (!response.ok) {
    return {
      status: 'error',
      message: parseApiMessage(body, response.status)
    };
  }

  const data = parseGoogleWalletResponse(body);

  if (!data) {
    return {
      status: 'error',
      message: 'Google Wallet did not return a valid save link. Please try again.'
    };
  }

  return {
    status: 'ok',
    data
  };
}

export function openGoogleWalletSaveUrl(
  saveUrl: string,
  target: {
    open: (url: string, target: string, features: string) => unknown;
    location: {
      assign: (url: string) => void;
    };
  } = window
) {
  const openedWindow = target.open(saveUrl, '_blank', 'noopener,noreferrer');

  if (!openedWindow) {
    target.location.assign(saveUrl);
  }
}

function parseGoogleWalletResponse(value: unknown): GoogleWalletSaveUrlResponse | null {
  const record = asRecord(value);
  const platform = readString(record?.platform);
  const saveUrl = readString(record?.saveUrl);
  const status = readString(record?.status);
  const businessName = readString(record?.businessName);
  const programName = readString(record?.programName);
  const lastSyncedAt = readString(record?.lastSyncedAt);

  if (
    platform !== 'GOOGLE_WALLET' ||
    !saveUrl ||
    !status ||
    !businessName ||
    !programName ||
    !lastSyncedAt
  ) {
    return null;
  }

  return {
    platform,
    saveUrl,
    status,
    businessName,
    programName,
    lastSyncedAt
  };
}

function parseApiMessage(value: unknown, status?: number) {
  if (status === 401 || status === 403) {
    return 'Google Wallet is not available for this card right now. Please try again or ask staff.';
  }

  const record = asRecord(value);
  const message = record?.message;

  if (typeof message === 'string' && message.trim()) {
    return message;
  }

  if (Array.isArray(message) && message.every((item) => typeof item === 'string')) {
    return message.join(' ');
  }

  return 'Google Wallet could not be opened right now. Please try again.';
}

function asRecord(value: unknown): Record<string, unknown> | null {
  return typeof value === 'object' && value !== null ? (value as Record<string, unknown>) : null;
}

function readString(value: unknown) {
  return typeof value === 'string' ? value : null;
}
