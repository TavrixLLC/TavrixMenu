-- AlterTable
ALTER TABLE "loyalty_memberships"
ADD COLUMN "public_access_token_hash" TEXT,
ADD COLUMN "public_access_token_issued_at" TIMESTAMP(3),
ADD COLUMN "public_access_token_last_viewed_at" TIMESTAMP(3);

-- CreateIndex
CREATE UNIQUE INDEX "loyalty_memberships_public_access_token_hash_key" ON "loyalty_memberships"("public_access_token_hash");
