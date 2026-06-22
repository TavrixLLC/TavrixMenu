import { strict as assert } from 'assert';
import { ConfigService } from '@nestjs/config';
import { describe, it } from 'node:test';
import {
  WalletPassPlatform,
  WalletRefreshJobProvider,
  WalletRefreshJobReason,
  WalletRefreshJobStatus
} from '../../generated/prisma';
import { WalletRefreshJobService } from './wallet-refresh-job.service';

class MockGoogleWalletService {
  enabled = true;

  isEnabled() {
    return this.enabled;
  }
}

class MockWalletPassService {
  readonly refreshCalls: string[] = [];
  result: unknown = {
    status: 'REFRESHED'
  };
  thrownError?: Error;

  async refreshGoogleWalletPassForMembership(membershipId: string) {
    this.refreshCalls.push(membershipId);

    if (this.thrownError) {
      throw this.thrownError;
    }

    return this.result;
  }
}

describe('WalletRefreshJobService enqueue', () => {
  it('enqueues a refresh job when a Google Wallet pass exists without calling the API inline', async () => {
    const setup = createJobService();

    const response = await setup.service.enqueueWalletRefreshForMembership({
      businessId: 'business_1',
      membershipId: 'membership_1',
      reason: WalletRefreshJobReason.STAMP_ADDED
    });

    assert.equal(response.status, 'QUEUED');
    assert.equal(setup.jobs.length, 1);
    assert.equal(setup.jobs[0].status, WalletRefreshJobStatus.PENDING);
    assert.equal(setup.jobs[0].provider, WalletRefreshJobProvider.GOOGLE_WALLET);
    assert.equal(setup.jobs[0].reason, WalletRefreshJobReason.STAMP_ADDED);
    assert.deepEqual(setup.walletPassService.refreshCalls, []);
  });

  it('skips enqueue when no Google Wallet pass exists', async () => {
    const setup = createJobService({
      hasPass: false
    });

    const response = await setup.service.enqueueWalletRefreshForMembership({
      businessId: 'business_1',
      membershipId: 'membership_1',
      reason: WalletRefreshJobReason.STAMP_ADDED
    });

    assert.equal(response.status, 'SKIPPED_NO_PASS');
    assert.equal(setup.jobs.length, 0);
  });

  it('skips the Google lookup when Google Wallet is disabled', async () => {
    const setup = createJobService({
      walletEnabled: false
    });

    const response = await setup.service.enqueueWalletRefreshForMembership({
      businessId: 'business_1',
      membershipId: 'membership_1',
      reason: WalletRefreshJobReason.STAMP_ADDED
    });

    assert.equal(response.status, 'SKIPPED_DISABLED');
    assert.equal(
      setup.walletPassQueries.some(
        (query: any) =>
          query.where.platform === WalletPassPlatform.GOOGLE_WALLET
      ),
      false
    );
    assert.equal(setup.jobs.length, 0);
  });

  it('marks an Apple pass updated and queues Apple push work when APNs is enabled', async () => {
    const setup = createJobService({
      walletEnabled: false,
      hasApplePass: true,
      apnsEnabled: true
    });

    await setup.service.enqueueWalletRefreshForMembership({
      businessId: 'business_1',
      membershipId: 'membership_1',
      reason: WalletRefreshJobReason.STAMP_ADDED
    });

    assert.equal(setup.walletPassUpdates.length, 1);
    assert.ok(setup.walletPassUpdates[0].data.applePassUpdatedAt instanceof Date);
    assert.equal(setup.jobs.length, 1);
    assert.equal(setup.jobs[0].provider, WalletRefreshJobProvider.APPLE_WALLET);
    assert.equal(setup.jobs[0].reason, WalletRefreshJobReason.STAMP_ADDED);
  });

  it('coalesces Apple push work and retains the latest loyalty reason', async () => {
    const setup = createJobService({
      walletEnabled: false,
      hasApplePass: true,
      apnsEnabled: true
    });

    await setup.service.enqueueWalletRefreshForMembership({
      businessId: 'business_1',
      membershipId: 'membership_1',
      reason: WalletRefreshJobReason.STAMP_ADDED
    });
    await setup.service.enqueueWalletRefreshForMembership({
      businessId: 'business_1',
      membershipId: 'membership_1',
      reason: WalletRefreshJobReason.REWARD_REDEEMED
    });

    assert.equal(setup.jobs.length, 1);
    assert.equal(setup.jobs[0].provider, WalletRefreshJobProvider.APPLE_WALLET);
    assert.equal(setup.jobs[0].reason, WalletRefreshJobReason.REWARD_REDEEMED);
  });

  it('marks an Apple pass updated without creating a job when APNs is disabled', async () => {
    const setup = createJobService({
      walletEnabled: false,
      hasApplePass: true
    });

    await setup.service.enqueueWalletRefreshForMembership({
      businessId: 'business_1',
      membershipId: 'membership_1',
      reason: WalletRefreshJobReason.STAMP_ADDED
    });

    assert.equal(setup.walletPassUpdates.length, 1);
    assert.equal(setup.jobs.length, 0);
  });

  it('does not create Apple push work when no Apple pass exists', async () => {
    const setup = createJobService({
      walletEnabled: false,
      apnsEnabled: true
    });

    await setup.service.enqueueWalletRefreshForMembership({
      businessId: 'business_1',
      membershipId: 'membership_1',
      reason: WalletRefreshJobReason.STAMP_ADDED
    });

    assert.equal(setup.walletPassUpdates.length, 0);
    assert.equal(setup.jobs.length, 0);
  });

  it('coalesces duplicate pending refresh jobs for the same membership/provider', async () => {
    const setup = createJobService();

    await setup.service.enqueueWalletRefreshForMembership({
      businessId: 'business_1',
      membershipId: 'membership_1',
      reason: WalletRefreshJobReason.STAMP_ADDED
    });
    const second = await setup.service.enqueueWalletRefreshForMembership({
      businessId: 'business_1',
      membershipId: 'membership_1',
      reason: WalletRefreshJobReason.REWARD_REDEEMED
    });

    assert.equal(second.status, 'QUEUED');
    assert.equal(setup.jobs.length, 1);
    assert.equal(setup.jobs[0].reason, WalletRefreshJobReason.REWARD_REDEEMED);
    assert.equal(setup.jobs[0].status, WalletRefreshJobStatus.PENDING);
  });
});

describe('WalletRefreshJobService worker', () => {
  it('processes a due job and marks it SUCCEEDED', async () => {
    const setup = createJobService({
      claimedJobs: [claimedJob()]
    });

    const response = await setup.service.processDueJobs();

    assert.deepEqual(response, {
      processed: 1
    });
    assert.deepEqual(setup.walletPassService.refreshCalls, ['membership_1']);
    assert.equal(setup.jobs[0].status, WalletRefreshJobStatus.SUCCEEDED);
    assert.ok(setup.jobs[0].completedAt);
    assert.equal(setup.jobs[0].lastError, null);
  });

  it('marks a due job SKIPPED when Google Wallet is disabled during processing', async () => {
    const setup = createJobService({
      claimedJobs: [claimedJob()],
      walletEnabled: false
    });

    await setup.service.processDueJobs();

    assert.deepEqual(setup.walletPassService.refreshCalls, []);
    assert.equal(setup.jobs[0].status, WalletRefreshJobStatus.SKIPPED);
    assert.equal(setup.jobs[0].lastError, 'Google Wallet integration is disabled');
  });

  it('marks a due job SKIPPED when the pass no longer exists', async () => {
    const setup = createJobService({
      claimedJobs: [claimedJob()]
    });
    setup.walletPassService.result = {
      status: 'SKIPPED_NO_PASS'
    };

    await setup.service.processDueJobs();

    assert.equal(setup.jobs[0].status, WalletRefreshJobStatus.SKIPPED);
    assert.equal(setup.jobs[0].lastError, 'Google Wallet pass not found');
  });

  it('retries failed jobs with sanitized error and backoff', async () => {
    const unsafeToken = `${['waflo', 'scan', 'v1'].join(
      '_'
    )}.1.1781704800000.payload.signature`;
    const unsafeSaveUrl = `https://${['pay.google.com', 'gp', 'v', 'save'].join(
      '/'
    )}/signed.jwt`;
    const setup = createJobService({
      claimedJobs: [claimedJob()]
    });
    setup.walletPassService.result = {
      status: 'FAILED',
      error: `failed ${unsafeToken} ${unsafeSaveUrl}`
    };

    await setup.service.processDueJobs();

    assert.equal(setup.jobs[0].status, WalletRefreshJobStatus.PENDING);
    assert.equal(setup.jobs[0].attempts, 1);
    assert.equal(setup.jobs[0].lastError, 'Google Wallet refresh failed');
    assert.ok(setup.jobs[0].nextRunAt > new Date('2026-06-17T09:00:00.000Z'));
    assert.equal(JSON.stringify(setup.jobs[0]).includes(unsafeToken), false);
  });

  it('marks failed jobs FAILED after max attempts', async () => {
    const setup = createJobService({
      claimedJobs: [
        claimedJob({
          attempts: 2,
          max_attempts: 3
        })
      ]
    });
    setup.walletPassService.thrownError = new Error(
      'D:\\secret\\wallet-service.json'
    );

    await setup.service.processDueJobs();

    assert.equal(setup.jobs[0].status, WalletRefreshJobStatus.FAILED);
    assert.equal(setup.jobs[0].attempts, 3);
    assert.equal(setup.jobs[0].lastError, 'Google Wallet refresh failed');
    assert.ok(setup.jobs[0].completedAt);
  });

  it('does not log sensitive token or save URL shaped failures', async () => {
    const unsafeValue =
      `${['waflo', 'scan', 'v1'].join(
        '_'
      )}.1.1781704800000.payload.signature https://${[
        'pay.google.com',
        'gp',
        'v',
        'save'
      ].join('/')}/signed.jwt`;
    const setup = createJobService({
      claimedJobs: [claimedJob()]
    });
    setup.walletPassService.thrownError = new Error(unsafeValue);
    const originalLog = console.log;
    const originalError = console.error;
    const calls: string[] = [];

    console.log = (...args: unknown[]) => {
      calls.push(args.join(' '));
    };
    console.error = (...args: unknown[]) => {
      calls.push(args.join(' '));
    };

    try {
      await setup.service.processDueJobs();
    } finally {
      console.log = originalLog;
      console.error = originalError;
    }

    assert.equal(calls.join(' ').includes(unsafeValue), false);
    assert.equal(JSON.stringify(setup.jobs[0]).includes(unsafeValue), false);
  });
});

function createJobService(overrides: {
  claimedJobs?: Array<ReturnType<typeof claimedJob>>;
  hasPass?: boolean;
  hasApplePass?: boolean;
  apnsEnabled?: boolean;
  walletEnabled?: boolean;
} = {}) {
  const jobs: any[] = [];
  const walletPassQueries: unknown[] = [];
  const wallet = new MockGoogleWalletService();
  wallet.enabled = overrides.walletEnabled ?? true;
  const walletPassService = new MockWalletPassService();
  const claimedJobs = overrides.claimedJobs ?? [];
  const walletPassUpdates: any[] = [];

  for (const job of claimedJobs) {
    jobs.push(jobFromClaim(job));
  }

  const prisma = {
    walletPass: {
      findFirst: async (query: any) => {
        walletPassQueries.push(query);

        if (query.where.platform === WalletPassPlatform.APPLE_WALLET) {
          return overrides.hasApplePass
            ? {
                id: 'apple_pass_1',
                platform: WalletPassPlatform.APPLE_WALLET
              }
            : null;
        }

        return overrides.hasPass === false
          ? null
          : {
              id: 'pass_1',
              platform: WalletPassPlatform.GOOGLE_WALLET
            };
      },
      update: async (args: any) => {
        walletPassUpdates.push(args);
        return args;
      }
    },
    walletRefreshJob: {
      findFirst: async (query: any) =>
        jobs.find(
          (job) =>
            job.membershipId === query.where.membershipId &&
            job.provider === query.where.provider &&
            query.where.status.in.includes(job.status)
        ) ?? null,
      create: async (args: { data: Record<string, unknown> }) => {
        const job = {
          id: `job_${jobs.length + 1}`,
          completedAt: null,
          createdAt: new Date('2026-06-17T09:00:00.000Z'),
          updatedAt: new Date('2026-06-17T09:00:00.000Z'),
          lockedAt: null,
          lockedUntil: null,
          lockedBy: null,
          ...args.data
        };
        jobs.push(job);

        return job;
      },
      update: async (args: { where: { id: string }; data: Record<string, any> }) => {
        const index = jobs.findIndex((job) => job.id === args.where.id);

        assert.notEqual(index, -1);
        jobs[index] = {
          ...jobs[index],
          ...args.data,
          updatedAt: new Date()
        };

        return jobs[index];
      }
    },
    $queryRaw: async () => claimedJobs
  };

  return {
    service: new WalletRefreshJobService(
      prisma as never,
      wallet as never,
      walletPassService as never,
      new ConfigService({
        APPLE_WALLET_APNS_ENABLED: overrides.apnsEnabled ?? false
      })
    ),
    jobs,
    walletPassQueries,
    walletPassUpdates,
    walletPassService
  };
}

function claimedJob(overrides: Record<string, unknown> = {}) {
  return {
    id: 'job_1',
    membership_id: 'membership_1',
    business_id: 'business_1',
    provider: WalletRefreshJobProvider.GOOGLE_WALLET,
    reason: WalletRefreshJobReason.STAMP_ADDED,
    status: WalletRefreshJobStatus.PROCESSING,
    attempts: 0,
    max_attempts: 3,
    ...overrides
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
    nextRunAt: new Date('2026-06-17T09:00:00.000Z'),
    lockedAt: new Date('2026-06-17T09:00:00.000Z'),
    lockedUntil: new Date('2026-06-17T09:02:00.000Z'),
    lockedBy: 'worker_1',
    lastError: null,
    completedAt: null,
    createdAt: new Date('2026-06-17T09:00:00.000Z'),
    updatedAt: new Date('2026-06-17T09:00:00.000Z')
  };
}
