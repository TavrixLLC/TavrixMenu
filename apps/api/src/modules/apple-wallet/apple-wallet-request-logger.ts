import { Logger } from '@nestjs/common';

type AppleWalletRequest = {
  method: string;
  originalUrl: string;
};

type AppleWalletResponse = {
  statusCode: number;
  once(event: 'finish', listener: () => void): void;
};

type Next = () => void;

const appleWalletStaticSegments = new Set([
  'apple-wallet',
  'v1',
  'devices',
  'registrations',
  'passes',
  'log'
]);

export function createAppleWalletRequestLogger(
  logger = new Logger('AppleWalletRequestLogger')
) {
  return (
    request: AppleWalletRequest,
    response: AppleWalletResponse,
    next: Next
  ) => {
    const url = safeUrl(request.originalUrl);

    if (!url || !isAppleWalletPath(url.pathname)) {
      next();
      return;
    }

    const startedAt = Date.now();
    const pathShape = redactAppleWalletPath(url.pathname);
    const hasDuplicatedVersionPrefix =
      /\/apple-wallet\/v1\/v1(?:\/|$)/i.test(url.pathname);

    response.once('finish', () => {
      logger.log(
        JSON.stringify({
          event: 'apple_wallet.http_request',
          method: request.method.toUpperCase(),
          pathShape,
          statusCode: response.statusCode,
          hasDuplicatedVersionPrefix,
          passesUpdatedSincePresent: url.searchParams.has(
            'passesUpdatedSince'
          ),
          queryParameterCount: [...url.searchParams.keys()].length,
          durationMs: Math.max(Date.now() - startedAt, 0)
        })
      );
    });

    next();
  };
}

function safeUrl(value: string) {
  try {
    return new URL(value, 'http://localhost');
  } catch {
    return null;
  }
}

function isAppleWalletPath(pathname: string) {
  return (
    pathname.toLowerCase() === '/apple-wallet' ||
    pathname.toLowerCase().startsWith('/apple-wallet/')
  );
}

function redactAppleWalletPath(pathname: string) {
  const segments = pathname.split('/').filter(Boolean);

  return `/${segments
    .map((segment) =>
      appleWalletStaticSegments.has(segment.toLowerCase())
        ? segment.toLowerCase()
        : ':value'
    )
    .join('/')}`;
}
