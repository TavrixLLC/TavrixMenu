export type GoogleWalletContext = {
  businessId: string;
  membershipId: string;
};

export type GoogleWalletSaveUrlResponse = {
  platform: 'GOOGLE_WALLET';
  membershipId: string;
  googleClassId: string;
  googleObjectId: string;
  saveUrl: string;
  status: string;
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
  businessId?: string | null;
  membershipId?: string | null;
}) {
  return Boolean(context.businessId?.trim() && context.membershipId?.trim());
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

export function isGoogleWalletButtonDisabled(state: { isLoading: boolean }) {
  return state.isLoading;
}

export function buildGoogleWalletUrl(input: {
  apiBaseUrl: string;
  businessId: string;
  membershipId: string;
}) {
  const apiBaseUrl = input.apiBaseUrl.replace(/\/+$/, '');

  return `${apiBaseUrl}/businesses/${encodeURIComponent(input.businessId)}/loyalty/memberships/${encodeURIComponent(
    input.membershipId
  )}/google-wallet`;
}

export async function requestGoogleWalletSaveUrl(
  input: {
    apiBaseUrl: string;
    businessId: string;
    membershipId: string;
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

function parseGoogleWalletResponse(value: unknown): GoogleWalletSaveUrlResponse | null {
  const record = asRecord(value);
  const platform = readString(record?.platform);
  const membershipId = readString(record?.membershipId);
  const googleClassId = readString(record?.googleClassId);
  const googleObjectId = readString(record?.googleObjectId);
  const saveUrl = readString(record?.saveUrl);
  const status = readString(record?.status);
  const lastSyncedAt = readString(record?.lastSyncedAt);

  if (
    platform !== 'GOOGLE_WALLET' ||
    !membershipId ||
    !googleClassId ||
    !googleObjectId ||
    !saveUrl ||
    !status ||
    !lastSyncedAt
  ) {
    return null;
  }

  return {
    platform,
    membershipId,
    googleClassId,
    googleObjectId,
    saveUrl,
    status,
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
