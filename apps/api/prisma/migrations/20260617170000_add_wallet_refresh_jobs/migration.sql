CREATE TYPE "WalletRefreshJobProvider" AS ENUM ('GOOGLE_WALLET');

CREATE TYPE "WalletRefreshJobReason" AS ENUM ('STAMP_ADDED', 'REWARD_REDEEMED');

CREATE TYPE "WalletRefreshJobStatus" AS ENUM ('PENDING', 'PROCESSING', 'SUCCEEDED', 'FAILED', 'SKIPPED');

CREATE TABLE "wallet_refresh_jobs" (
  "id" TEXT NOT NULL,
  "membership_id" TEXT NOT NULL,
  "business_id" TEXT NOT NULL,
  "provider" "WalletRefreshJobProvider" NOT NULL,
  "reason" "WalletRefreshJobReason" NOT NULL,
  "status" "WalletRefreshJobStatus" NOT NULL DEFAULT 'PENDING',
  "attempts" INTEGER NOT NULL DEFAULT 0,
  "max_attempts" INTEGER NOT NULL DEFAULT 3,
  "next_run_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "locked_at" TIMESTAMP(3),
  "locked_until" TIMESTAMP(3),
  "locked_by" TEXT,
  "last_error" TEXT,
  "completed_at" TIMESTAMP(3),
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "wallet_refresh_jobs_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "wallet_refresh_jobs_status_next_run_at_idx" ON "wallet_refresh_jobs"("status", "next_run_at");
CREATE INDEX "wallet_refresh_jobs_membership_id_provider_status_idx" ON "wallet_refresh_jobs"("membership_id", "provider", "status");
CREATE INDEX "wallet_refresh_jobs_locked_until_idx" ON "wallet_refresh_jobs"("locked_until");

CREATE UNIQUE INDEX "wallet_refresh_jobs_active_membership_provider_key"
ON "wallet_refresh_jobs"("membership_id", "provider")
WHERE "status" IN ('PENDING', 'PROCESSING');

ALTER TABLE "wallet_refresh_jobs"
ADD CONSTRAINT "wallet_refresh_jobs_business_id_fkey"
FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "wallet_refresh_jobs"
ADD CONSTRAINT "wallet_refresh_jobs_membership_id_fkey"
FOREIGN KEY ("membership_id") REFERENCES "loyalty_memberships"("id") ON DELETE CASCADE ON UPDATE CASCADE;
