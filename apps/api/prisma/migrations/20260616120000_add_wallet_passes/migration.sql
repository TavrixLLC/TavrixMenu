-- Persist wallet pass sync state for real loyalty memberships.
CREATE TYPE "WalletPassPlatform" AS ENUM ('GOOGLE_WALLET');
CREATE TYPE "WalletPassStatus" AS ENUM ('PENDING', 'ACTIVE', 'ERROR');

CREATE TABLE "wallet_passes" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "membership_id" TEXT NOT NULL,
    "platform" "WalletPassPlatform" NOT NULL,
    "google_class_id" TEXT,
    "google_object_id" TEXT,
    "save_url" TEXT,
    "hero_image_url" TEXT,
    "status" "WalletPassStatus" NOT NULL DEFAULT 'PENDING',
    "last_synced_at" TIMESTAMP(3),
    "sync_error" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "wallet_passes_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "wallet_passes_membership_id_platform_key" ON "wallet_passes"("membership_id", "platform");
CREATE INDEX "wallet_passes_business_id_idx" ON "wallet_passes"("business_id");
CREATE INDEX "wallet_passes_membership_id_idx" ON "wallet_passes"("membership_id");

ALTER TABLE "wallet_passes" ADD CONSTRAINT "wallet_passes_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "wallet_passes" ADD CONSTRAINT "wallet_passes_membership_id_fkey" FOREIGN KEY ("membership_id") REFERENCES "loyalty_memberships"("id") ON DELETE CASCADE ON UPDATE CASCADE;
