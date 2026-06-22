import { execFileSync } from 'child_process';
import { existsSync } from 'fs';
import { resolve } from 'path';

type SafePassPayload = {
  webServiceURL?: unknown;
  authenticationToken?: unknown;
  passTypeIdentifier?: unknown;
  serialNumber?: unknown;
  barcodes?: Array<{
    format?: unknown;
  }>;
  storeCard?: {
    headerFields?: Array<{
      key?: unknown;
      value?: unknown;
    }>;
    primaryFields?: Array<{
      key?: unknown;
      value?: unknown;
    }>;
  };
};

function main() {
  const configuredPath = process.argv[2]?.trim();

  if (!configuredPath) {
    throw new Error('Provide a .pkpass path to inspect');
  }

  const passPath = resolve(configuredPath);

  if (!passPath.toLowerCase().endsWith('.pkpass') || !existsSync(passPath)) {
    throw new Error('The provided .pkpass file does not exist');
  }

  const payload = JSON.parse(
    execFileSync('tar', ['-xOf', passPath, 'pass.json'], {
      encoding: 'utf8',
      maxBuffer: 1024 * 1024
    })
  ) as SafePassPayload;
  const assets = execFileSync('tar', ['-tf', passPath], {
    encoding: 'utf8',
    maxBuffer: 1024 * 1024
  }).split(/\r?\n/);
  const barcode = payload.barcodes?.[0];

  console.log(
    JSON.stringify(
      {
        webServiceURL:
          typeof payload.webServiceURL === 'string'
            ? payload.webServiceURL
            : null,
        authenticationTokenPresent:
          typeof payload.authenticationToken === 'string' &&
          payload.authenticationToken.length > 0,
        passTypeIdentifierSuffix: identifierSuffix(
          payload.passTypeIdentifier
        ),
        serialNumberSuffix: valueSuffix(payload.serialNumber, 8),
        barcodePresent: Boolean(barcode),
        barcodeFormat:
          typeof barcode?.format === 'string' ? barcode.format : null,
        stampHeader: safeFieldValue(
          payload.storeCard?.headerFields,
          'stamps'
        ),
        rewardStatus: safeFieldValue(
          payload.storeCard?.primaryFields,
          'rewardStatus'
        ),
        progressAssetPresent: assets.includes('strip.png')
      },
      null,
      2
    )
  );
}

function safeFieldValue(
  fields: Array<{ key?: unknown; value?: unknown }> | undefined,
  key: string
) {
  const value = fields?.find((field) => field.key === key)?.value;
  return typeof value === 'string' || typeof value === 'number'
    ? value
    : null;
}

function identifierSuffix(value: unknown) {
  return typeof value === 'string'
    ? value.split('.').filter(Boolean).at(-1)?.slice(-24) ?? null
    : null;
}

function valueSuffix(value: unknown, length: number) {
  return typeof value === 'string' ? value.trim().slice(-length) : null;
}

try {
  main();
} catch {
  console.error('Apple Wallet pass inspection failed');
  process.exitCode = 1;
}
