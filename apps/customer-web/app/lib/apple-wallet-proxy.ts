import {
  APPLE_WALLET_PASS_CONTENT_TYPE,
  APPLE_WALLET_UNAVAILABLE_MESSAGE,
  isAppleWalletButtonEnabled
} from './apple-wallet';
import { getApiBaseUrl } from './public-menu';

type AppleWalletProxyInput = {
  token: string;
  enabled?: boolean;
  apiBaseUrl?: string;
};

export async function proxyAppleWalletPass(
  input: AppleWalletProxyInput,
  fetcher: typeof fetch = fetch
) {
  if ((input.enabled ?? isAppleWalletButtonEnabled()) === false) {
    return safeErrorResponse(503);
  }

  const token = input.token.trim();

  if (!token || token.length > 512) {
    return safeErrorResponse(404);
  }

  const apiBaseUrl = (input.apiBaseUrl ?? getApiBaseUrl()).replace(/\/+$/, '');

  try {
    const upstream = await fetcher(
      `${apiBaseUrl}/public/loyalty/cards/${encodeURIComponent(token)}/apple-wallet`,
      {
        method: 'POST',
        cache: 'no-store',
        headers: {
          Accept: APPLE_WALLET_PASS_CONTENT_TYPE
        }
      }
    );

    if (!upstream.ok) {
      return safeErrorResponse(safeUpstreamStatus(upstream.status));
    }

    const contentType = upstream.headers.get('Content-Type')?.split(';')[0];

    if (contentType !== APPLE_WALLET_PASS_CONTENT_TYPE || !upstream.body) {
      return safeErrorResponse(502);
    }

    const headers = new Headers({
      'Cache-Control': 'private, no-store',
      'Content-Disposition': safeContentDisposition(
        upstream.headers.get('Content-Disposition')
      ),
      'Content-Type': APPLE_WALLET_PASS_CONTENT_TYPE
    });
    const contentLength = upstream.headers.get('Content-Length');

    if (contentLength && /^\d+$/.test(contentLength)) {
      headers.set('Content-Length', contentLength);
    }

    return new Response(upstream.body, {
      status: 200,
      headers
    });
  } catch {
    return safeErrorResponse(502);
  }
}

function safeUpstreamStatus(status: number) {
  return status === 404 || status === 503 ? status : 502;
}

function safeContentDisposition(value: string | null) {
  return /^attachment;\s*filename="[A-Za-z0-9][A-Za-z0-9._-]{0,99}\.pkpass"$/i.test(
    value?.trim() ?? ''
  )
    ? value!.trim()
    : 'attachment; filename="waflo-loyalty.pkpass"';
}

function safeErrorResponse(status: number) {
  return Response.json(
    {
      message: APPLE_WALLET_UNAVAILABLE_MESSAGE
    },
    {
      status,
      headers: {
        'Cache-Control': 'private, no-store'
      }
    }
  );
}
