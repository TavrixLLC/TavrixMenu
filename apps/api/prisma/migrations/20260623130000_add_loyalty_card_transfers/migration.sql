CREATE TABLE "loyalty_card_transfers" (
    "id" TEXT NOT NULL,
    "membership_id" TEXT NOT NULL,
    "token_hash" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "used_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "loyalty_card_transfers_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "loyalty_card_transfers_token_hash_key"
ON "loyalty_card_transfers"("token_hash");

CREATE INDEX "loyalty_card_transfers_membership_id_created_at_idx"
ON "loyalty_card_transfers"("membership_id", "created_at");

CREATE INDEX "loyalty_card_transfers_token_hash_used_at_expires_at_idx"
ON "loyalty_card_transfers"("token_hash", "used_at", "expires_at");

ALTER TABLE "loyalty_card_transfers"
ADD CONSTRAINT "loyalty_card_transfers_membership_id_fkey"
FOREIGN KEY ("membership_id") REFERENCES "loyalty_memberships"("id")
ON DELETE CASCADE ON UPDATE CASCADE;
