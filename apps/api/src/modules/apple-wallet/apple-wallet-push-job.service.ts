import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import {
  WalletPassPlatform,
  WalletPassStatus,
  WalletRefreshJobProvider,
  WalletRefreshJobReason,
  WalletRefreshJobStatus
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import { AppleWalletApnsClient } from './apple-wallet-apns.client';

type ClaimedAppleWalletPushJob = {
  id: string;
  membership_id: string;
  business_id: string;
  provider: WalletRefreshJobProvider;
  reason: WalletRefreshJobReason;
  status: WalletRefreshJobStatus;
  attempts: number;
  max_attempts: number;
  updated_at: Date;
};

@Injectable()
export class AppleWalletPushJobService
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(AppleWalletPushJobService.name);
  private readonly workerId = `apple-wallet-push-${randomUUID()}`;
  private readonly lockTtlMs = 2 * 60 * 1000;
  private readonly pollIntervalMs = 5000;
  private intervalHandle: NodeJS.Timeout | null = null;

  constructor(
    private readonly prisma: PrismaService,
    private readonly apnsClient: AppleWalletApnsClient
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

  async processDueJobs(limit = 10) {
    const jobs = await this.claimDueJobs(limit);

    for (const job of jobs) {
      await this.processClaimedJob(job);
    }

    return {
      processed: jobs.length
    };
  }

  private async claimDueJobs(limit: number) {
    const now = new Date();
    const lockedUntil = new Date(now.getTime() + this.lockTtlMs);

    return this.prisma.$queryRaw<ClaimedAppleWalletPushJob[]>`
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
        WHERE "provider" = 'APPLE_WALLET'::"WalletRefreshJobProvider"
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
        "max_attempts",
        "updated_at"
    `;
  }

  private async processClaimedJob(job: ClaimedAppleWalletPushJob) {
    if (!this.apnsClient.isEnabled()) {
      this.logPushEvent('job_skipped', job, {
        reason: 'APNS_DISABLED'
      });
      await this.markSkipped(job.id, 'Apple Wallet APNs is disabled');
      return;
    }

    try {
      const pass = await this.prisma.walletPass.findFirst({
        where: {
          membershipId: job.membership_id,
          platform: WalletPassPlatform.APPLE_WALLET,
          status: WalletPassStatus.ACTIVE
        },
        include: {
          appleDeviceRegistrations: {
            where: {
              unregisteredAt: null,
              pushToken: {
                not: null
              }
            },
            select: {
              id: true,
              passTypeIdentifier: true,
              pushToken: true
            }
          }
        }
      });

      if (!pass) {
        this.logPushEvent('job_skipped', job, {
          reason: 'PASS_NOT_FOUND'
        });
        await this.markSkipped(job.id, 'Apple Wallet pass not found');
        return;
      }

      if (pass.appleDeviceRegistrations.length === 0) {
        this.logPushEvent('no_active_registrations', job, {
          serialNumberSuffix: this.valueSuffix(
            pass.appleSerialNumber,
            8
          )
        });
        await this.markSucceededOrRequeue(job);
        return;
      }

      this.logPushEvent('dispatch_started', job, {
        serialNumberSuffix: this.valueSuffix(pass.appleSerialNumber, 8),
        registrationCount: pass.appleDeviceRegistrations.length
      });
      let retryableError: string | null = null;
      let permanentError: string | null = null;

      for (const registration of pass.appleDeviceRegistrations) {
        if (!registration.pushToken) {
          continue;
        }

        const result = await this.apnsClient.sendPassUpdate({
          pushToken: registration.pushToken,
          passTypeIdentifier: registration.passTypeIdentifier
        });
        const registrationContext = {
          registrationIdSuffix: this.valueSuffix(registration.id, 8),
          passTypeIdentifierSuffix: this.identifierSuffix(
            registration.passTypeIdentifier
          )
        };

        if (result.status === 'INVALID_TOKEN') {
          this.logPushEvent(
            'invalid_device_token',
            job,
            registrationContext,
            'warn'
          );
          await this.unregisterInvalidDevice(registration.id);
          continue;
        }

        if (result.status === 'SKIPPED_DISABLED') {
          this.logPushEvent('job_skipped', job, {
            ...registrationContext,
            reason: 'APNS_DISABLED'
          });
          await this.markSkipped(job.id, 'Apple Wallet APNs is disabled');
          return;
        }

        if (result.status === 'FAILED') {
          this.logPushEvent(
            'dispatch_failed',
            job,
            {
              ...registrationContext,
              retryable: result.retryable,
              error: this.sanitizeError(result.error)
            },
            'warn'
          );
          if (result.retryable) {
            retryableError ??= result.error;
          } else {
            permanentError ??= result.error;
          }
          continue;
        }

        this.logPushEvent('dispatch_sent', job, registrationContext);
      }

      if (permanentError) {
        await this.markPermanentlyFailed(job, permanentError);
        return;
      }

      if (retryableError) {
        await this.markFailedOrRetry(job, retryableError);
        return;
      }

      await this.markSucceededOrRequeue(job);
    } catch (error) {
      const sanitizedError = this.sanitizeError(error);
      this.logPushEvent(
        'dispatch_failed',
        job,
        {
          retryable: true,
          error: sanitizedError
        },
        'warn'
      );
      await this.markFailedOrRetry(job, sanitizedError);
    }
  }

  private async unregisterInvalidDevice(registrationId: string) {
    await this.prisma.appleWalletDeviceRegistration.update({
      where: {
        id: registrationId
      },
      data: {
        pushToken: null,
        pushTokenLast4: null,
        unregisteredAt: new Date()
      }
    });
  }

  private async markSucceededOrRequeue(job: ClaimedAppleWalletPushJob) {
    const completed = await this.prisma.walletRefreshJob.updateMany({
      where: {
        id: job.id,
        status: WalletRefreshJobStatus.PROCESSING,
        lockedBy: this.workerId,
        updatedAt: job.updated_at
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

    if (completed.count === 1) {
      return;
    }

    await this.prisma.walletRefreshJob.updateMany({
      where: {
        id: job.id,
        status: WalletRefreshJobStatus.PROCESSING,
        lockedBy: this.workerId
      },
      data: {
        status: WalletRefreshJobStatus.PENDING,
        nextRunAt: new Date(),
        lockedAt: null,
        lockedUntil: null,
        lockedBy: null,
        lastError: null,
        completedAt: null
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

  private async markPermanentlyFailed(
    job: ClaimedAppleWalletPushJob,
    unsafeError: string
  ) {
    await this.prisma.walletRefreshJob.update({
      where: {
        id: job.id
      },
      data: {
        status: WalletRefreshJobStatus.FAILED,
        attempts: job.max_attempts,
        lockedAt: null,
        lockedUntil: null,
        lockedBy: null,
        lastError: this.sanitizeError(unsafeError),
        completedAt: new Date()
      }
    });
  }

  private async markFailedOrRetry(
    job: ClaimedAppleWalletPushJob,
    unsafeError: string
  ) {
    const attempts = job.attempts + 1;
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
            lastError: this.sanitizeError(unsafeError),
            completedAt: new Date()
          }
        : {
            status: WalletRefreshJobStatus.PENDING,
            attempts,
            nextRunAt: new Date(Date.now() + this.backoffMs(attempts)),
            lockedAt: null,
            lockedUntil: null,
            lockedBy: null,
            lastError: this.sanitizeError(unsafeError)
          }
    });
  }

  private backoffMs(attempts: number) {
    return Math.min(30 * 1000 * 2 ** Math.max(attempts - 1, 0), 30 * 60 * 1000);
  }

  private sanitizeError(error: unknown) {
    const message =
      error instanceof Error ? error.message.trim() : String(error).trim();
    const unsafePatterns = [
      /private[_ -]?key/i,
      /begin\s+private\s+key/i,
      /certificate/i,
      /applepass/i,
      /push[_ -]?token/i,
      /authentication[_ -]?token/i,
      /waflo[_-]?scan[_-]?v1/i,
      /waflo[_-]?apple[_-]?update[_-]?v1/i,
      /\.p12|\.pem|\.cer/i,
      /[A-Za-z]:\\/,
      /\/(?:home|users|var|tmp|etc)\//i,
      /[A-Za-z0-9_-]{64,}/
    ];

    if (!message || unsafePatterns.some((pattern) => pattern.test(message))) {
      return 'Apple Wallet push failed';
    }

    return message.slice(0, 500);
  }

  private identifierSuffix(value: string) {
    return value.split('.').filter(Boolean).at(-1)?.slice(-24) ?? 'unknown';
  }

  private valueSuffix(value: string | null, length: number) {
    return value?.trim().slice(-length) || null;
  }

  private logPushEvent(
    event: string,
    job: ClaimedAppleWalletPushJob,
    details: Record<string, unknown>,
    level: 'log' | 'warn' = 'log'
  ) {
    this.logger[level](
      JSON.stringify({
        event: `apple_wallet.apns_${event}`,
        jobIdSuffix: this.valueSuffix(job.id, 8),
        attempt: job.attempts + 1,
        ...details
      })
    );
  }
}
