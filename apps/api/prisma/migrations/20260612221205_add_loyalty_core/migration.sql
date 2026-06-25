-- CreateEnum
CREATE TYPE "LoyaltyMembershipStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateEnum
CREATE TYPE "LoyaltyTransactionType" AS ENUM ('STAMP_ADDED', 'REWARD_REDEEMED', 'ADJUSTMENT', 'VOID');

-- CreateTable
CREATE TABLE "loyalty_programs" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "stamp_goal" INTEGER NOT NULL,
    "reward_name" TEXT NOT NULL,
    "reward_description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "card_color" TEXT,
    "accent_color" TEXT,
    "logo_url" TEXT,
    "terms" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "loyalty_programs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customers" (
    "id" TEXT NOT NULL,
    "phone" TEXT,
    "email" TEXT,
    "name" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "customers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loyalty_memberships" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "loyalty_program_id" TEXT NOT NULL,
    "customer_id" TEXT NOT NULL,
    "stamp_count" INTEGER NOT NULL DEFAULT 0,
    "reward_ready" BOOLEAN NOT NULL DEFAULT false,
    "total_stamps_earned" INTEGER NOT NULL DEFAULT 0,
    "total_rewards_redeemed" INTEGER NOT NULL DEFAULT 0,
    "status" "LoyaltyMembershipStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "loyalty_memberships_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loyalty_transactions" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "loyalty_program_id" TEXT NOT NULL,
    "membership_id" TEXT NOT NULL,
    "customer_id" TEXT NOT NULL,
    "actor_user_id" TEXT,
    "type" "LoyaltyTransactionType" NOT NULL,
    "stamps_delta" INTEGER NOT NULL,
    "reason" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "loyalty_transactions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "loyalty_programs_business_id_idx" ON "loyalty_programs"("business_id");

-- CreateIndex
CREATE UNIQUE INDEX "customers_phone_key" ON "customers"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "customers_email_key" ON "customers"("email");

-- CreateIndex
CREATE INDEX "loyalty_memberships_business_id_idx" ON "loyalty_memberships"("business_id");

-- CreateIndex
CREATE INDEX "loyalty_memberships_loyalty_program_id_idx" ON "loyalty_memberships"("loyalty_program_id");

-- CreateIndex
CREATE INDEX "loyalty_memberships_customer_id_idx" ON "loyalty_memberships"("customer_id");

-- CreateIndex
CREATE UNIQUE INDEX "loyalty_memberships_customer_id_loyalty_program_id_key" ON "loyalty_memberships"("customer_id", "loyalty_program_id");

-- CreateIndex
CREATE INDEX "loyalty_transactions_business_id_idx" ON "loyalty_transactions"("business_id");

-- CreateIndex
CREATE INDEX "loyalty_transactions_loyalty_program_id_idx" ON "loyalty_transactions"("loyalty_program_id");

-- CreateIndex
CREATE INDEX "loyalty_transactions_membership_id_idx" ON "loyalty_transactions"("membership_id");

-- CreateIndex
CREATE INDEX "loyalty_transactions_customer_id_idx" ON "loyalty_transactions"("customer_id");

-- CreateIndex
CREATE INDEX "loyalty_transactions_actor_user_id_idx" ON "loyalty_transactions"("actor_user_id");

-- AddForeignKey
ALTER TABLE "loyalty_programs" ADD CONSTRAINT "loyalty_programs_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loyalty_memberships" ADD CONSTRAINT "loyalty_memberships_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loyalty_memberships" ADD CONSTRAINT "loyalty_memberships_loyalty_program_id_fkey" FOREIGN KEY ("loyalty_program_id") REFERENCES "loyalty_programs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loyalty_memberships" ADD CONSTRAINT "loyalty_memberships_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loyalty_transactions" ADD CONSTRAINT "loyalty_transactions_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loyalty_transactions" ADD CONSTRAINT "loyalty_transactions_loyalty_program_id_fkey" FOREIGN KEY ("loyalty_program_id") REFERENCES "loyalty_programs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loyalty_transactions" ADD CONSTRAINT "loyalty_transactions_membership_id_fkey" FOREIGN KEY ("membership_id") REFERENCES "loyalty_memberships"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loyalty_transactions" ADD CONSTRAINT "loyalty_transactions_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loyalty_transactions" ADD CONSTRAINT "loyalty_transactions_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
