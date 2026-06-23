CREATE TYPE "LoyaltyCardAccessSource" AS ENUM (
    'JOIN',
    'TRANSFER',
    'STAFF_RECOVERY'
);

CREATE TABLE "loyalty_card_accesses" (
    "id" TEXT NOT NULL,
    "membership_id" TEXT NOT NULL,
    "token_hash" TEXT NOT NULL,
    "source" "LoyaltyCardAccessSource" NOT NULL,
    "last_used_at" TIMESTAMP(3),
    "revoked_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "loyalty_card_accesses_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "loyalty_card_accesses_token_hash_key"
ON "loyalty_card_accesses"("token_hash");

CREATE INDEX "loyalty_card_accesses_membership_id_revoked_at_idx"
ON "loyalty_card_accesses"("membership_id", "revoked_at");

CREATE INDEX "loyalty_card_accesses_token_hash_revoked_at_idx"
ON "loyalty_card_accesses"("token_hash", "revoked_at");

ALTER TABLE "loyalty_card_accesses"
ADD CONSTRAINT "loyalty_card_accesses_membership_id_fkey"
FOREIGN KEY ("membership_id") REFERENCES "loyalty_memberships"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

INSERT INTO "loyalty_card_accesses" (
    "id",
    "membership_id",
    "token_hash",
    "source",
    "last_used_at",
    "created_at"
)
SELECT
    CONCAT('legacy_', "id"),
    "id",
    "public_access_token_hash",
    'JOIN'::"LoyaltyCardAccessSource",
    "public_access_token_last_viewed_at",
    COALESCE("public_access_token_issued_at", "created_at")
FROM "loyalty_memberships"
WHERE "public_access_token_hash" IS NOT NULL
ON CONFLICT ("token_hash") DO NOTHING;
