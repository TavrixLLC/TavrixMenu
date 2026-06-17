import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { randomUUID } from 'crypto';
import {
  Prisma,
  WalletPassPlatform,
  WalletRefreshJobProvider,
  WalletRefreshJobReason,
  WalletRefreshJobStatus
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import { GoogleWalletService } from './google-wallet.service';
import { WalletPassService } from './wallet-pass.service';

type EnqueueWalletRefreshInput = {
  businessId: string;
  membershipId: string;
  reason: WalletRefreshJobReason;
};

export type EnqueueWalletRefreshResult =
  | {
      status: 'QUEUED';
      jobId: string;
    }
  | {
      status: 'SKIPPED_DISABLED' | 'SKIPPED_NO_PASS';
    };

type ClaimedWalletRefreshJob = {
  id: string;
  membership_id: string;
  business_id: string;
  provider: WalletRefreshJobProvider;
  reason: WalletRefreshJobReason;
  status: WalletRefreshJobStatus;
  attempts: number;
  max_attempts: number;
};

@Injectable()
export class WalletRefreshJobService implements OnModuleInit, OnModuleDestroy {
  private readonly workerId = `wallet-refresh-${randomUUID()}`;
  private readonly lockTtlMs = 2 * 60 * 1000;
  private readonly pollIntervalMs = 5000;
  private intervalHandle: NodeJS.Timeout | null = null;

  constructor(
    private readonly prisma: PrismaService,
    private readonly googleWalletService: GoogleWalletService,
    private readonly walletPassService: WalletPassService
  ) {}

  onModuleInit() {
    this.intervalHandle = setInterval(() => {
      void this.processDueJobs().catch(() => {
        undefined;
      });
    }, this.pollIntervalMs);
    this.intervalHandle.unref?.();
  }

  onModuleDestroy() {
    if (this.intervalHandle) {
      clearInterval(this.intervalHandle);
      this.intervalHandle = null;
    }
  }

  async enqueueWalletRefreshForMembership(
    input: EnqueueWalletRefreshInput
  ): Promise<EnqueueWalletRefreshResult> {
    if (!this.googleWalletService.isEnabled()) {
      return {
        status: 'SKIPPED_DISABLED'
      };
    }

    const pass = await this.prisma.walletPass.findFirst({
      where: {
        businessId: input.businessId,
        membershipId: input.membershipId,
        platform: WalletPassPlatform.GOOGLE_WALLET
      },
      select: {
        id: true
      }
    });

    if (!pass) {
      return {
        status: 'SKIPPED_NO_PASS'
      };
    }

    return this.createOrReusePendingJob(input);
  }

  async processDueJobs(limit = 10) {
    const jobs = await this.claimDueJobs(limit);

    for (const job of jobs) {
      await this.processClaimedJob(job);
    }

    return {
      processed: jobs.length
    };
  }

  private async createOrReusePendingJob(input: EnqueueWalletRefreshInput) {
    const now = new Date();
    const existingJob = await this.findActiveJob(input.membershipId);

    if (existingJob) {
      const job = await this.prisma.walletRefreshJob.update({
        where: {
          id: existingJob.id
        },
        data: {
          businessId: input.businessId,
          reason: input.reason,
          ...(existingJob.status === WalletRefreshJobStatus.PENDING
            ? {
                nextRunAt: now,
                lastError: null
              }
            : {})
        }
      });

      return {
        status: 'QUEUED',
        jobId: job.id
      } as const;
    }

    try {
      const job = await this.prisma.walletRefreshJob.create({
        data: {
          businessId: input.businessId,
          membershipId: input.membershipId,
          provider: WalletRefreshJobProvider.GOOGLE_WALLET,
          reason: input.reason,
          status: WalletRefreshJobStatus.PENDING,
          attempts: 0,
          maxAttempts: 3,
          nextRunAt: now,
          lastError: null
        }
      });

      return {
        status: 'QUEUED',
        jobId: job.id
      } as const;
    } catch (error) {
      if (this.isUniqueConstraintError(error)) {
        const racedJob = await this.findActiveJob(input.membershipId);

        if (racedJob) {
          return {
            status: 'QUEUED',
            jobId: racedJob.id
          } as const;
        }
      }

      throw error;
    }
  }

  private findActiveJob(membershipId: string) {
    return this.prisma.walletRefreshJob.findFirst({
      where: {
        membershipId,
        provider: WalletRefreshJobProvider.GOOGLE_WALLET,
        status: {
          in: [
            WalletRefreshJobStatus.PENDING,
            WalletRefreshJobStatus.PROCESSING
          ]
        }
      },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }]
    });
  }

  private async claimDueJobs(limit: number) {
    const now = new Date();
    const lockedUntil = new Date(now.getTime() + this.lockTtlMs);

    return this.prisma.$queryRaw<ClaimedWalletRefreshJob[]>`
      UPDATE "wallet_refresh_jobs"
      SET
        "status" = 'PROCESSING'::"WalletRefreshJobStatus",
        "locked_at" = ${now},
        "locked_until" = ${lockedUntil},
        "locked_by" = ${this.workerId},
        "updated_at" = ${now}
      WHERE "id" IN (
        SELECT "id"
        FROM "wallet_refresh_jobs"
        WHERE "provider" = 'GOOGLE_WALLET'::"WalletRefreshJobProvider"
          AND "status" IN (
            'PENDING'::"WalletRefreshJobStatus",
            'PROCESSING'::"WalletRefreshJobStatus"
          )
          AND "next_run_at" <= ${now}
          AND (
            "status" = 'PENDING'::"WalletRefreshJobStatus"
            OR "locked_until" IS NULL
            OR "locked_until" <= ${now}
          )
        ORDER BY "next_run_at" ASC, "created_at" ASC, "id" ASC
        LIMIT ${limit}
        FOR UPDATE SKIP LOCKED
      )
      RETURNING
        "id",
        "membership_id",
        "business_id",
        "provider",
        "reason",
        "status",
        "attempts",
        "max_attempts"
    `;
  }

  private async processClaimedJob(job: ClaimedWalletRefreshJob) {
    if (!this.googleWalletService.isEnabled()) {
      await this.markSkipped(job.id, 'Google Wallet integration is disabled');

      return;
    }

    try {
      const result =
        await this.walletPassService.refreshGoogleWalletPassForMembership(
          job.membership_id
        );

      if (result.status === 'REFRESHED') {
        await this.markSucceeded(job.id);

        return;
      }

      if (result.status === 'SKIPPED_DISABLED') {
        await this.markSkipped(job.id, 'Google Wallet integration is disabled');

        return;
      }

      if (result.status === 'SKIPPED_NO_PASS') {
        await this.markSkipped(job.id, 'Google Wallet pass not found');

        return;
      }

      if (result.status === 'FAILED') {
        await this.markFailedOrRetry(job, result.error);
      }
    } catch (error) {
      await this.markFailedOrRetry(job, this.sanitizeError(error));
    }
  }

  private async markSucceeded(jobId: string) {
    await this.prisma.walletRefreshJob.update({
      where: {
        id: jobId
      },
      data: {
        status: WalletRefreshJobStatus.SUCCEEDED,
        lockedAt: null,
        lockedUntil: null,
        lockedBy: null,
        lastError: null,
        completedAt: new Date()
      }
    });
  }

  private async markSkipped(jobId: string, reason: string) {
    await this.prisma.walletRefreshJob.update({
      where: {
        id: jobId
      },
      data: {
        status: WalletRefreshJobStatus.SKIPPED,
        lockedAt: null,
        lockedUntil: null,
        lockedBy: null,
        lastError: this.sanitizeError(reason),
        completedAt: new Date()
      }
    });
  }

  private async markFailedOrRetry(
    job: ClaimedWalletRefreshJob,
    unsafeError: string
  ) {
    const attempts = job.attempts + 1;
    const lastError = this.sanitizeError(unsafeError);
    const exhausted = attempts >= job.max_attempts;

    await this.prisma.walletRefreshJob.update({
      where: {
        id: job.id
      },
      data: exhausted
        ? {
            status: WalletRefreshJobStatus.FAILED,
            attempts,
            lockedAt: null,
            lockedUntil: null,
            lockedBy: null,
            lastError,
            completedAt: new Date()
          }
        : {
            status: WalletRefreshJobStatus.PENDING,
            attempts,
            nextRunAt: new Date(Date.now() + this.backoffMs(attempts)),
            lockedAt: null,
            lockedUntil: null,
            lockedBy: null,
            lastError
          }
    });
  }

  private backoffMs(attempts: number) {
    return Math.min(30 * 1000 * 2 ** Math.max(attempts - 1, 0), 30 * 60 * 1000);
  }

  private sanitizeError(error: unknown) {
    const message =
      error instanceof Error ? error.message.trim() : String(error).trim();

    if (!message) {
      return 'Google Wallet refresh failed';
    }

    const unsafePatterns = [
      /private[_ -]?key/i,
      /begin\s+private\s+key/i,
      /service[_ -]?account/i,
      /google[_-]?wallet[_-]?sa/i,
      /client[_ -]?email/i,
      /pay\.google\.com\/gp\/v\/save/i,
      /waflo[_-]?scan[_-]?v1/i,
      /scan[_ -]?token/i,
      /[A-Za-z]:\\/,
      /\/(?:home|users|var|tmp|etc)\//i,
      /[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}/
    ];

    if (unsafePatterns.some((pattern) => pattern.test(message))) {
      return 'Google Wallet refresh failed';
    }

    return message.slice(0, 500);
  }

  private isUniqueConstraintError(error: unknown) {
    return (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === 'P2002'
    );
  }
}
