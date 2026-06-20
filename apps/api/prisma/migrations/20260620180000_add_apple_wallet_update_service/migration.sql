ALTER TABLE "wallet_passes"
ADD COLUMN "apple_pass_type_identifier" TEXT,
ADD COLUMN "apple_serial_number" TEXT,
ADD COLUMN "apple_update_auth_token_hash" TEXT,
ADD COLUMN "apple_update_auth_token_version" INTEGER,
ADD COLUMN "apple_update_auth_token_issued_at" TIMESTAMP(3),
ADD COLUMN "apple_update_auth_token_last4" TEXT,
ADD COLUMN "apple_pass_updated_at" TIMESTAMP(3);

CREATE UNIQUE INDEX "wallet_passes_apple_update_auth_token_hash_key"
ON "wallet_passes"("apple_update_auth_token_hash");

CREATE UNIQUE INDEX "wallet_passes_platform_apple_pass_type_identifier_apple_serial_number_key"
ON "wallet_passes"("platform", "apple_pass_type_identifier", "apple_serial_number");

CREATE TABLE "apple_wallet_device_registrations" (
    "id" TEXT NOT NULL,
    "wallet_pass_id" TEXT NOT NULL,
    "pass_type_identifier" TEXT NOT NULL,
    "serial_number" TEXT NOT NULL,
    "device_library_identifier_hash" TEXT NOT NULL,
    "device_library_identifier_last4" TEXT NOT NULL,
    "push_token" TEXT,
    "push_token_last4" TEXT,
    "unregistered_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "apple_wallet_device_registrations_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "apple_wallet_device_registrations_wallet_pass_id_device_library_identifier_hash_key"
ON "apple_wallet_device_registrations"("wallet_pass_id", "device_library_identifier_hash");

CREATE INDEX "apple_wallet_device_registrations_device_library_identifier_hash_pass_type_identifier_unregistered_at_idx"
ON "apple_wallet_device_registrations"("device_library_identifier_hash", "pass_type_identifier", "unregistered_at");

CREATE INDEX "apple_wallet_device_registrations_wallet_pass_id_unregistered_at_idx"
ON "apple_wallet_device_registrations"("wallet_pass_id", "unregistered_at");

ALTER TABLE "apple_wallet_device_registrations"
ADD CONSTRAINT "apple_wallet_device_registrations_wallet_pass_id_fkey"
FOREIGN KEY ("wallet_pass_id") REFERENCES "wallet_passes"("id")
ON DELETE CASCADE ON UPDATE CASCADE;
