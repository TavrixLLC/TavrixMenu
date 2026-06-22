export const APPLE_WALLET_PASS_CONTENT_TYPE =
  'application/vnd.apple.pkpass';
export const APPLE_WALLET_UNAVAILABLE_MESSAGE =
  'Apple Wallet is not available yet.';

export type AppleWalletPassResult =
  | {
      status: 'ok';
      pass: Blob;
      fileName: string;
    }
  | {
      status: 'error';
      message: typeof APPLE_WALLET_UNAVAILABLE_MESSAGE;
    };

export type AppleWalletActionResult =
  | {
      status: 'ok';
    }
  | {
      status: 'error';
      message: typeof APPLE_WALLET_UNAVAILABLE_MESSAGE;
    };

type AppleWalletFetch = (
  input: string,
  init: {
    method: 'POST';
    headers: {
      Accept: typeof APPLE_WALLET_PASS_CONTENT_TYPE;
    };
  }
) => Promise<{
  ok: boolean;
  status: number;
  headers: {
    get: (name: string) => string | null;
  };
  blob: () => Promise<Blob>;
}>;

type AppleWalletOpenTarget = {
  createObjectUrl: (pass: Blob) => string;
  revokeObjectUrl: (url: string) => void;
  createLink: () => {
    href: string;
    download: string;
    rel: string;
    click: () => void;
  };
  schedule: (callback: () => void, delayMs: number) => unknown;
};

export function isAppleWalletButtonEnabled(
  value = process.env.NEXT_PUBLIC_ENABLE_APPLE_WALLET_BUTTON
) {
  return value?.trim().toLowerCase() === 'true';
}

export function buildAppleWalletProxyUrl(cardToken: string) {
  return `/api/loyalty/cards/${encodeURIComponent(cardToken)}/apple-wallet`;
}

export async function requestAppleWalletPass(
  cardToken: string,
  fetcher: AppleWalletFetch = fetch
): Promise<AppleWalletPassResult> {
  const normalizedToken = cardToken.trim();

  if (!normalizedToken) {
    return unavailableResult();
  }

  try {
    const response = await fetcher(buildAppleWalletProxyUrl(normalizedToken), {
      method: 'POST',
      headers: {
        Accept: APPLE_WALLET_PASS_CONTENT_TYPE
      }
    });

    if (!response.ok) {
      return unavailableResult();
    }

    const contentType = response.headers.get('Content-Type')?.split(';')[0];

    if (contentType !== APPLE_WALLET_PASS_CONTENT_TYPE) {
      return unavailableResult();
    }

    return {
      status: 'ok',
      pass: await response.blob(),
      fileName: readSafeFileName(
        response.headers.get('Content-Disposition')
      )
    };
  } catch {
    return unavailableResult();
  }
}

export function openAppleWalletPass(
  pass: Blob,
  fileName: string,
  target: AppleWalletOpenTarget = browserOpenTarget()
) {
  const objectUrl = target.createObjectUrl(pass);
  const link = target.createLink();
  link.href = objectUrl;
  link.download = readSafeFileName(`attachment; filename="${fileName}"`);
  link.rel = 'noopener';
  link.click();
  target.schedule(() => target.revokeObjectUrl(objectUrl), 60000);
}

export async function addToAppleWallet(
  cardToken: string,
  requestPass: typeof requestAppleWalletPass = requestAppleWalletPass,
  openPass: typeof openAppleWalletPass = openAppleWalletPass
): Promise<AppleWalletActionResult> {
  const result = await requestPass(cardToken);

  if (result.status === 'error') {
    return result;
  }

  try {
    openPass(result.pass, result.fileName);
    return {
      status: 'ok'
    };
  } catch {
    return unavailableResult();
  }
}

function unavailableResult(): AppleWalletPassResult {
  return {
    status: 'error',
    message: APPLE_WALLET_UNAVAILABLE_MESSAGE
  };
}

function readSafeFileName(contentDisposition: string | null) {
  const match =
    /^attachment;\s*filename="([A-Za-z0-9][A-Za-z0-9._-]{0,99}\.pkpass)"$/i.exec(
      contentDisposition?.trim() ?? ''
    );

  return match?.[1] ?? 'waflo-loyalty.pkpass';
}

function browserOpenTarget(): AppleWalletOpenTarget {
  return {
    createObjectUrl: (pass) => URL.createObjectURL(pass),
    revokeObjectUrl: (url) => URL.revokeObjectURL(url),
    createLink: () => document.createElement('a'),
    schedule: (callback, delayMs) => window.setTimeout(callback, delayMs)
  };
}
