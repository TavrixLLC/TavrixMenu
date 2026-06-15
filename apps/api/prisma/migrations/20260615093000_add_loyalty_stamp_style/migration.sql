-- CreateEnum
CREATE TYPE "LoyaltyStampStyleType" AS ENUM ('PRESET');

-- CreateEnum
CREATE TYPE "LoyaltyStampPresetKey" AS ENUM (
    'STAR',
    'COOKIE',
    'COFFEE',
    'BOWL',
    'BURGER',
    'PIZZA',
    'HEART',
    'CUPCAKE'
);

-- CreateEnum
CREATE TYPE "LoyaltyStampLayoutVariant" AS ENUM ('MODERN', 'COMPACT');

-- CreateTable
CREATE TABLE "loyalty_stamp_styles" (
    "id" TEXT NOT NULL,
    "loyalty_program_id" TEXT NOT NULL,
    "style_type" "LoyaltyStampStyleType" NOT NULL DEFAULT 'PRESET',
    "preset_key" "LoyaltyStampPresetKey" NOT NULL DEFAULT 'STAR',
    "background_color" TEXT NOT NULL,
    "accent_color" TEXT NOT NULL,
    "text_color" TEXT NOT NULL DEFAULT '#ffffff',
    "layout_variant" "LoyaltyStampLayoutVariant" NOT NULL DEFAULT 'MODERN',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "loyalty_stamp_styles_pkey" PRIMARY KEY ("id")
);

-- Backfill existing loyalty programs with the default preset style.
INSERT INTO "loyalty_stamp_styles" (
    "id",
    "loyalty_program_id",
    "style_type",
    "preset_key",
    "background_color",
    "accent_color",
    "text_color",
    "layout_variant",
    "created_at",
    "updated_at"
)
SELECT
    'stamp_style_' || "id",
    "id",
    'PRESET',
    'STAR',
    CASE
        WHEN "card_color" ~ '^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$' THEN "card_color"
        ELSE '#111827'
    END,
    CASE
        WHEN "accent_color" ~ '^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$' THEN "accent_color"
        ELSE '#f59e0b'
    END,
    '#ffffff',
    'MODERN',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM "loyalty_programs";

-- CreateIndex
CREATE UNIQUE INDEX "loyalty_stamp_styles_loyalty_program_id_key" ON "loyalty_stamp_styles"("loyalty_program_id");

-- AddForeignKey
ALTER TABLE "loyalty_stamp_styles" ADD CONSTRAINT "loyalty_stamp_styles_loyalty_program_id_fkey" FOREIGN KEY ("loyalty_program_id") REFERENCES "loyalty_programs"("id") ON DELETE CASCADE ON UPDATE CASCADE;
