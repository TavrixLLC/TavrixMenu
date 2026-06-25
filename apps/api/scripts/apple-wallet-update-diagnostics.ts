import { existsSync, readFileSync } from 'fs';
import { resolve } from 'path';
import {
  PrismaClient,
  WalletPassPlatform,
  WalletRefreshJobProvider
} from '../src/generated/prisma';
import { validateEnvironment } from '../src/env.validation';

loadEnvFile();

const prisma = new PrismaClient();

async function main() {
  const config = validateEnvironment(process.env);
  const [registrations, passes, jobs] = await Promise.all([
    prisma.appleWalletDeviceRegistration.findMany({
      select: {
        serialNumber: true,
        createdAt: true,
        updatedAt: true,
        unregisteredAt: true,
        pushTokenLast4: true
      },
      orderBy: {
        updatedAt: 'desc'
      }
    }),
    prisma.walletPass.findMany({
      where: {
        platform: WalletPassPlatform.APPLE_WALLET
      },
      select: {
        appleSerialNumber: true,
        applePassUpdatedAt: true,
        lastSyncedAt: true,
        status: true,
        membership: {
          select: {
            stampCount: true,
            updatedAt: true
          }
        }
      },
      orderBy: {
        updatedAt: 'desc'
      }
    }),
    prisma.walletRefreshJob.groupBy({
      by: ['status'],
      where: {
        provider: WalletRefreshJobProvider.APPLE_WALLET
      },
      _count: {
        _all: true
      }
    })
  ]);
  const activeRegistrations = registrations.filter(
    (registration) =>
      registration.unregisteredAt === null &&
      Boolean(registration.pushTokenLast4)
  );

  console.log(
    JSON.stringify(
      {
        configuration: {
          appleWalletEnabled: config.APPLE_WALLET_ENABLED,
          updateWebServiceEnabled:
            config.APPLE_WALLET_WEB_SERVICE_ENABLED,
          webServiceURL:
            config.APPLE_WALLET_WEB_SERVICE_BASE_URL || null,
          passTypeIdentifierSuffix: identifierSuffix(
            config.APPLE_WALLET_PASS_TYPE_IDENTIFIER
          ),
          updateAuthenticationConfigured: Boolean(
            config.APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET
          ),
          apnsEnabled: config.APPLE_WALLET_APNS_ENABLED,
          apnsEnvironment: config.APPLE_WALLET_APNS_ENVIRONMENT
        },
        registrations: {
          total: registrations.length,
          active: activeRegistrations.length,
          byPassSerialSuffix: summarizeRegistrations(registrations)
        },
        passes: {
          total: passes.length,
          latest: passes.slice(0, 20).map((pass) => ({
            serialNumberSuffix: valueSuffix(pass.appleSerialNumber, 8),
            status: pass.status,
            stampCount: pass.membership?.stampCount ?? null,
            membershipUpdatedAt: pass.membership?.updatedAt ?? null,
            applePassUpdatedAt: pass.applePassUpdatedAt,
            lastSyncedAt: pass.lastSyncedAt
          }))
        },
        applePushJobs: jobs.map((job) => ({
          status: job.status,
          count: job._count._all
        })),
        registrationState:
          registrations.length === 0
            ? 'NO_DEVICE_REGISTRATIONS_FOUND'
            : activeRegistrations.length === 0
              ? 'NO_ACTIVE_DEVICE_REGISTRATIONS'
              : 'ACTIVE_DEVICE_REGISTRATIONS_FOUND',
        manualFallback:
          'Open the current web card and use its Apple Wallet action to request a fresh pass.'
      },
      null,
      2
    )
  );
}

function summarizeRegistrations(
  registrations: Array<{
    serialNumber: string;
    createdAt: Date;
    updatedAt: Date;
    unregisteredAt: Date | null;
    pushTokenLast4: string | null;
  }>
) {
  const summaries = new Map<
    string,
    {
      total: number;
      active: number;
      latestCreatedAt: Date;
      latestUpdatedAt: Date;
    }
  >();

  for (const registration of registrations) {
    const serialNumberSuffix =
      valueSuffix(registration.serialNumber, 8) ?? 'missing';
    const current = summaries.get(serialNumberSuffix);
    summaries.set(serialNumberSuffix, {
      total: (current?.total ?? 0) + 1,
      active:
        (current?.active ?? 0) +
        (registration.unregisteredAt === null &&
        Boolean(registration.pushTokenLast4)
          ? 1
          : 0),
      latestCreatedAt:
        current && current.latestCreatedAt > registration.createdAt
          ? current.latestCreatedAt
          : registration.createdAt,
      latestUpdatedAt:
        current && current.latestUpdatedAt > registration.updatedAt
          ? current.latestUpdatedAt
          : registration.updatedAt
    });
  }

  return [...summaries.entries()].map(
    ([serialNumberSuffix, summary]) => ({
      serialNumberSuffix,
      ...summary
    })
  );
}

function identifierSuffix(value: string) {
  return value.split('.').filter(Boolean).at(-1)?.slice(-24) ?? null;
}

function valueSuffix(value: string | null, length: number) {
  return value?.trim().slice(-length) || null;
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

main()
  .catch(() => {
    console.error('Apple Wallet update diagnostics failed');
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
