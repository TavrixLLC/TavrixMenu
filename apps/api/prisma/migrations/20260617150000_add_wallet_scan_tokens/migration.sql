ALTER TABLE "wallet_passes"
ADD COLUMN "scan_token_hash" TEXT,
ADD COLUMN "scan_token_version" INTEGER,
ADD COLUMN "scan_token_issued_at" TIMESTAMP(3),
ADD COLUMN "scan_token_last4" TEXT;

CREATE UNIQUE INDEX "wallet_passes_scan_token_hash_key" ON "wallet_passes"("scan_token_hash");
