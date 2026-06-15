import { ConfigService } from '@nestjs/config';
import { existsSync, readFileSync } from 'fs';
import { resolve } from 'path';
import { validateEnvironment } from '../src/env.validation';
import { GoogleWalletRestClient } from '../src/modules/google-wallet/google-wallet-api.client';
import { GoogleWalletService } from '../src/modules/google-wallet/google-wallet.service';

loadEnvFile();

async function main() {
  const validatedConfig = validateEnvironment(process.env);

  if (!validatedConfig.GOOGLE_WALLET_ENABLED) {
    throw new Error(
      'GOOGLE_WALLET_ENABLED must be true to run the Wallet smoke test'
    );
  }

  const configService = new ConfigService(validatedConfig);
  const walletService = new GoogleWalletService(
    configService,
    new GoogleWalletRestClient(configService)
  );

  const classSuffix =
    process.env.GOOGLE_WALLET_SMOKE_CLASS_SUFFIX ??
    'waflo_loyalty_smoke_class';
  const objectSuffix =
    process.env.GOOGLE_WALLET_SMOKE_OBJECT_SUFFIX ??
    'waflo_loyalty_smoke_object';

  const classPayload = walletService.buildLoyaltyClassPayload({
    classSuffix,
    issuerName: 'Waflo',
    programName: 'Waflo Loyalty',
    logoUrl: process.env.GOOGLE_WALLET_SMOKE_LOGO_URL,
    rewardDescription: 'Smoke test card for Waflo loyalty rewards.',
    hexBackgroundColor: '#2463eb'
  });
  const objectPayload = walletService.buildLoyaltyObjectPayload({
    classSuffix,
    objectSuffix,
    accountName: 'Waflo Test Account',
    accountId: 'WAFLO-SMOKE-001',
    stampCount: 3,
    stampGoal: 5,
    rewardName: 'Test reward',
    barcodeValue: 'WAFLO-SMOKE-001'
  });

  await walletService.upsertLoyaltyClass(classPayload);
  await walletService.upsertLoyaltyObject(objectPayload);

  const saveUrl = walletService.generateSaveUrl({
    loyaltyObject: {
      id: objectPayload.id,
      classId: objectPayload.classId
    }
  });

  if (!saveUrl.startsWith('https://pay.google.com/gp/v/save/')) {
    throw new Error('Google Wallet save URL was not generated correctly');
  }

  console.log(
    JSON.stringify(
      {
        passed: true,
        classId: classPayload.id,
        objectId: objectPayload.id,
        saveUrl
      },
      null,
      2
    )
  );
}

function loadEnvFile() {
  const envPath = resolve(__dirname, '..', '.env');

  if (!existsSync(envPath)) {
    return;
  }

  const envFile = readFileSync(envPath, 'utf8');

  for (const rawLine of envFile.split(/\r?\n/)) {
    const line = rawLine.trim();

    if (!line || line.startsWith('#')) {
      continue;
    }

    const separatorIndex = line.indexOf('=');

    if (separatorIndex === -1) {
      continue;
    }

    const key = line.slice(0, separatorIndex).trim();
    const rawValue = line.slice(separatorIndex + 1).trim();
    const value = rawValue.replace(/^['"]|['"]$/g, '');

    if (key && process.env[key] === undefined) {
      process.env[key] = value;
    }
  }
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
