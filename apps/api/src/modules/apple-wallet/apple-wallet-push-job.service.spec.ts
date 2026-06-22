import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import {
  WalletPassPlatform,
  WalletRefreshJobProvider,
  WalletRefreshJobReason,
  WalletRefreshJobStatus
} from '../../generated/prisma';
import { AppleWalletApnsSendResult } from './apple-wallet-apns.client';
import { AppleWalletPushJobService } from './apple-wallet-push-job.service';

class MockAppleWalletApnsClient {
  enabled = true;
  results: AppleWalletApnsSendResult[] = [{ status: 'SENT' }];
  readonly calls: Array<{
    pushToken: string;
    passTypeIdentifier: string;
  }> = [];
  thrownError?: Error;
  onSend?: () => void;

  isEnabled() {
    return this.enabled;
  }

  async sendPassUpdate(input: {
    pushToken: string;
    passTypeIdentifier: string;
  }) {
    this.calls.push(input);
    this.onSend?.();

    if (this.thrownError) {
      throw this.thrownError;
    }

    return this.results.shift() ?? { status: 'SENT' as const };
  }
}

describe('AppleWalletPushJobService', () => {
  it('succeeds without APNs calls when no devices are registered', async () => {
    const setup = createSetup({ registrations: [] });
    const result = await setup.service.processDueJobs();

    assert.deepEqual(result, { processed: 1 });
    assert.equal(setup.apnsClient.calls.length, 0);
    assert.equal(setup.job.status, WalletRefreshJobStatus.SUCCEEDED);
  });

  it('sends each registered device a wake-up and marks the job succeeded', async () => {
    const setup = createSetup();
    const result = await setup.service.processDueJobs();

    assert.deepEqual(result, { processed: 1 });
    assert.equal(setup.apnsClient.calls.length, 1);
    assert.equal(
      setup.apnsClient.calls[0].passTypeIdentifier,
      'pass.app.waflo.loyalty'
    );
    assert.equal(setup.job.status, WalletRefreshJobStatus.SUCCEEDED);
    assert.equal(setup.job.lastError, null);
  });

  it('retries transient APNs failures with backoff', async () => {
    const setup = createSetup();
    const beforeProcessing = Date.now();
    setup.apnsClient.results = [
      {
        status: 'FAILED',
        error: 'Apple Wallet APNs transport failed',
        retryable: true
      }
    ];

    await setup.service.processDueJobs();

    assert.equal(setup.job.status, WalletRefreshJobStatus.PENDING);
    assert.equal(setup.job.attempts, 1);
    assert.ok(setup.job.nextRunAt.getTime() >= beforeProcessing + 30000);
    assert.equal(setup.job.lastError, 'Apple Wallet APNs transport failed');
  });

  it('requeues a newer loyalty update coalesced during APNs delivery', async () => {
    const setup = createSetup();
    setup.apnsClient.onSend = () => {
      setup.job.updatedAt = new Date(setup.job.updatedAt.getTime() + 1);
    };

    await setup.service.processDueJobs();

    assert.equal(setup.job.status, WalletRefreshJobStatus.PENDING);
    assert.equal(setup.job.completedAt, null);
    assert.equal(setup.job.lockedAt, null);
    assert.equal(setup.job.lockedUntil, null);
    assert.equal(setup.job.lockedBy, null);
  });

  it('unregisters invalid tokens, clears them, and does not retry', async () => {
    const setup = createSetup();
    setup.apnsClient.results = [
      {
        status: 'INVALID_TOKEN',
        error: 'Apple Wallet APNs device token is invalid'
      }
    ];

    await setup.service.processDueJobs();

    assert.equal(setup.registrationUpdates.length, 1);
    assert.equal(setup.registrationUpdates[0].data.pushToken, null);
    assert.equal(setup.registrationUpdates[0].data.pushTokenLast4, null);
    assert.ok(
      setup.registrationUpdates[0].data.unregisteredAt instanceof Date
    );
    assert.equal(setup.job.status, WalletRefreshJobStatus.SUCCEEDED);
    assert.equal(setup.job.attempts, 0);
  });

  it('skips claimed jobs safely if APNs is disabled', async () => {
    const setup = createSetup();
    setup.apnsClient.enabled = false;

    await setup.service.processDueJobs();

    assert.equal(setup.apnsClient.calls.length, 0);
    assert.equal(setup.walletPassQueries.length, 0);
    assert.equal(setup.job.status, WalletRefreshJobStatus.SKIPPED);
  });

  it('sanitizes token-shaped thrown errors without logging them', async () => {
    const unsafeValue = [
      'ApplePass',
      'test-auth-token-placeholder',
      ['waflo', 'scan', 'v1'].join('_'),
      'test-push-token-placeholder'
    ].join(' ');
    const setup = createSetup();
    setup.apnsClient.thrownError = new Error(unsafeValue);
    const calls: string[] = [];
    const originalLog = console.log;
    const originalError = console.error;
    console.log = (...values: unknown[]) => calls.push(values.join(' '));
    console.error = (...values: unknown[]) => calls.push(values.join(' '));

    try {
      await setup.service.processDueJobs();
    } finally {
      console.log = originalLog;
      console.error = originalError;
    }

    assert.equal(calls.join('\n').includes(unsafeValue), false);
    assert.equal(setup.job.lastError, 'Apple Wallet push failed');
    assert.equal(JSON.stringify(setup.job).includes(unsafeValue), false);
  });
});

function createSetup(overrides: {
  registrations?: Array<ReturnType<typeof registration>>;
  hasPass?: boolean;
} = {}) {
  const claimed = claimedJob();
  const job: any = jobFromClaim(claimed);
  const apnsClient = new MockAppleWalletApnsClient();
  const registrationUpdates: any[] = [];
  const walletPassQueries: any[] = [];
  const registrations = overrides.registrations ?? [registration()];
  const prisma = {
    $queryRaw: async () => [claimed],
    walletPass: {
      findFirst: async (query: any) => {
        walletPassQueries.push(query);
        return overrides.hasPass === false
          ? null
          : {
              id: 'apple_pass_1',
              platform: WalletPassPlatform.APPLE_WALLET,
              appleDeviceRegistrations: registrations
            };
      }
    },
    appleWalletDeviceRegistration: {
      update: async (args: any) => {
        registrationUpdates.push(args);
        return args;
      }
    },
    walletRefreshJob: {
      update: async (args: any) => {
        Object.assign(job, args.data, { updatedAt: new Date() });
        return job;
      },
      updateMany: async (args: any) => {
        if (
          args.where.updatedAt &&
          args.where.updatedAt.getTime() !== job.updatedAt.getTime()
        ) {
          return { count: 0 };
        }

        Object.assign(job, args.data, { updatedAt: new Date() });
        return { count: 1 };
      }
    }
  };

  return {
    service: new AppleWalletPushJobService(
      prisma as never,
      apnsClient as never
    ),
    apnsClient,
    job,
    registrationUpdates,
    walletPassQueries
  };
}

function claimedJob() {
  return {
    id: 'apple_push_job_1',
    membership_id: 'membership_1',
    business_id: 'business_1',
    provider: WalletRefreshJobProvider.APPLE_WALLET,
    reason: WalletRefreshJobReason.STAMP_ADDED,
    status: WalletRefreshJobStatus.PROCESSING,
    attempts: 0,
    max_attempts: 3,
    updated_at: new Date('2026-06-20T18:00:00.000Z')
  };
}

function jobFromClaim(job: ReturnType<typeof claimedJob>) {
  return {
    id: job.id,
    membershipId: job.membership_id,
    businessId: job.business_id,
    provider: job.provider,
    reason: job.reason,
    status: job.status,
    attempts: job.attempts,
    maxAttempts: job.max_attempts,
    nextRunAt: new Date('2026-06-20T18:00:00.000Z'),
    lockedAt: new Date('2026-06-20T18:00:00.000Z'),
    lockedUntil: new Date('2026-06-20T18:02:00.000Z'),
    lockedBy: 'apple_worker_1',
    lastError: null,
    completedAt: null,
    createdAt: new Date('2026-06-20T18:00:00.000Z'),
    updatedAt: job.updated_at
  };
}

function registration() {
  return {
    id: 'registration_1',
    passTypeIdentifier: 'pass.app.waflo.loyalty',
    pushToken: 'test-push-token-placeholder'
  };
}
