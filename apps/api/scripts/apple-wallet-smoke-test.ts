import { ConfigService } from '@nestjs/config';
import { execFileSync } from 'child_process';
import { randomUUID } from 'crypto';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'fs';
import { isAbsolute, join, relative, resolve, sep } from 'path';
import { validateEnvironment } from '../src/env.validation';
import { AppleWalletPassBuilderService } from '../src/modules/apple-wallet/apple-wallet-pass-builder.service';
import { AppleWalletSignerService } from '../src/modules/apple-wallet/apple-wallet-signer.service';
import { AppleWalletService } from '../src/modules/apple-wallet/apple-wallet.service';
import { WalletScanTokenService } from '../src/modules/google-wallet/wallet-scan-token.service';

loadEnvFile();

async function main() {
  const validatedConfig = validateEnvironment(process.env);

  if (!validatedConfig.APPLE_WALLET_ENABLED) {
    throw new Error(
      'APPLE_WALLET_ENABLED must be true to run the Apple Wallet smoke test'
    );
  }

  verifyCertificatePath(
    validatedConfig.APPLE_WALLET_CERTIFICATE_PATH,
    'APPLE_WALLET_CERTIFICATE_PATH'
  );
  verifyCertificatePath(
    validatedConfig.APPLE_WALLET_WWDR_CERTIFICATE_PATH,
    'APPLE_WALLET_WWDR_CERTIFICATE_PATH'
  );
  const outputDirectory = resolve(
    __dirname,
    '..',
    'public',
    'generated',
    'apple-wallet'
  );

  verifyOutputDirectoryIsSafe(outputDirectory);

  const configService = new ConfigService(validatedConfig);
  const service = new AppleWalletService(
    configService,
    new AppleWalletPassBuilderService(),
    new AppleWalletSignerService(configService),
    new WalletScanTokenService(configService)
  );
  const serialNumber = `waflo-smoke-${randomUUID()}`;
  const result = await service.generatePass({
    serialNumber,
    programName: 'Waflo Loyalty',
    stampCount: 3,
    stampGoal: 10,
    rewardDescription: 'Reward after 10 stamps',
    scanTokenPass: {
      id: `apple-smoke-pass-${randomUUID()}`,
      businessId: 'internal-smoke-business',
      membershipId: 'internal-smoke-membership',
      scanTokenHash: null,
      scanTokenVersion: null,
      scanTokenIssuedAt: null,
      scanTokenLast4: null
    }
  });
  const outputPath = join(outputDirectory, `${serialNumber}.pkpass`);

  mkdirSync(outputDirectory, { recursive: true });
  writeFileSync(outputPath, result.pass, { flag: 'wx' });

  console.log(
    JSON.stringify(
      {
        passTypeIdentifierSuffix: summarizePassTypeIdentifier(
          result.metadata.passTypeIdentifier
        ),
        teamIdPresent: validatedConfig.APPLE_WALLET_TEAM_ID ? 'yes' : 'no',
        serialNumberSuffix: result.metadata.serialNumber.slice(-6),
        outputByteSize: result.metadata.fileSize
      },
      null,
      2
    )
  );
}

function verifyCertificatePath(path: string, fieldName: string) {
  if (!existsSync(resolve(path))) {
    throw new Error(`${fieldName} does not point to an existing file`);
  }
}

function verifyOutputDirectoryIsSafe(outputDirectory: string) {
  const repositoryRoot = resolve(__dirname, '..', '..', '..');
  const relativeOutput = relative(repositoryRoot, outputDirectory);
  const isInsideRepository =
    relativeOutput === '' ||
    (relativeOutput !== '..' &&
      !relativeOutput.startsWith(`..${sep}`) &&
      !isAbsolute(relativeOutput));

  if (!isInsideRepository) {
    return;
  }

  const ignoreProbe = relative(
    repositoryRoot,
    join(outputDirectory, 'apple-wallet-smoke-output.pkpass')
  );

  try {
    execFileSync(
      'git',
      ['check-ignore', '--quiet', '--no-index', '--', ignoreProbe],
      {
        cwd: repositoryRoot,
        stdio: 'ignore'
      }
    );
  } catch {
    throw new Error(
      'Apple Wallet smoke output must be outside the repository or ignored by git'
    );
  }
}

function summarizePassTypeIdentifier(passTypeIdentifier: string) {
  const suffix = passTypeIdentifier.split('.').filter(Boolean).at(-1);
  return suffix?.slice(-24) || 'configured';
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
  const message = error instanceof Error ? error.message : 'Smoke test failed';
  console.error(
    /waflo_scan_v1|private key|certificate password/i.test(message)
      ? 'Apple Wallet smoke test failed'
      : message
  );
  process.exitCode = 1;
});
