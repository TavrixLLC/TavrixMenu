CREATE TYPE "LoyaltyWalletThemePreset" AS ENUM ('DEFAULT', 'COFFEE', 'RESTAURANT', 'DESSERT', 'MINIMAL', 'CUSTOM');

CREATE TYPE "LoyaltyWalletColorMode" AS ENUM ('PRESET', 'CUSTOM');

ALTER TABLE "loyalty_stamp_styles"
ADD COLUMN "wallet_background_color" TEXT NOT NULL DEFAULT '#2563eb',
ADD COLUMN "image_background_color" TEXT NOT NULL DEFAULT '#7c2d12',
ADD COLUMN "image_surface_color" TEXT NOT NULL DEFAULT '#92400e',
ADD COLUMN "image_accent_color" TEXT NOT NULL DEFAULT '#facc15',
ADD COLUMN "image_text_color" TEXT NOT NULL DEFAULT '#ffffff',
ADD COLUMN "stamp_filled_color" TEXT NOT NULL DEFAULT '#facc15',
ADD COLUMN "stamp_empty_color" TEXT NOT NULL DEFAULT '#d6d3d1',
ADD COLUMN "reward_banner_color" TEXT NOT NULL DEFAULT '#a16207',
ADD COLUMN "theme_preset" "LoyaltyWalletThemePreset" NOT NULL DEFAULT 'DEFAULT',
ADD COLUMN "color_mode" "LoyaltyWalletColorMode" NOT NULL DEFAULT 'PRESET';

UPDATE "loyalty_stamp_styles"
SET
  "wallet_background_color" = COALESCE(NULLIF(TRIM("background_color"), ''), '#2563eb'),
  "image_background_color" = COALESCE(NULLIF(TRIM("background_color"), ''), '#7c2d12'),
  "image_surface_color" = COALESCE(NULLIF(TRIM("background_color"), ''), '#92400e'),
  "image_accent_color" = COALESCE(NULLIF(TRIM("accent_color"), ''), '#facc15'),
  "image_text_color" = COALESCE(NULLIF(TRIM("text_color"), ''), '#ffffff'),
  "stamp_filled_color" = COALESCE(NULLIF(TRIM("accent_color"), ''), '#facc15'),
  "stamp_empty_color" = COALESCE(NULLIF(TRIM("text_color"), ''), '#d6d3d1'),
  "reward_banner_color" = COALESCE(NULLIF(TRIM("text_color"), ''), '#a16207');
