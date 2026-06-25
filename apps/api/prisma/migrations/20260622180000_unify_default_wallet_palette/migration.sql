ALTER TABLE "loyalty_stamp_styles"
ALTER COLUMN "image_background_color" SET DEFAULT '#1d4ed8',
ALTER COLUMN "image_surface_color" SET DEFAULT '#2563eb',
ALTER COLUMN "stamp_empty_color" SET DEFAULT '#93c5fd',
ALTER COLUMN "reward_banner_color" SET DEFAULT '#1e40af';

UPDATE "loyalty_stamp_styles"
SET
  "image_background_color" = '#1d4ed8',
  "image_surface_color" = '#2563eb',
  "stamp_empty_color" = '#93c5fd',
  "reward_banner_color" = '#1e40af'
WHERE
  "theme_preset" = 'DEFAULT'
  AND "wallet_background_color" = '#2563eb'
  AND "image_background_color" = '#7c2d12'
  AND "image_surface_color" = '#92400e'
  AND "image_accent_color" = '#facc15'
  AND "image_text_color" = '#ffffff'
  AND "stamp_filled_color" = '#facc15'
  AND "stamp_empty_color" = '#d6d3d1'
  AND "reward_banner_color" = '#a16207';
