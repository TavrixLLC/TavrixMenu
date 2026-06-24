ALTER TABLE "businesses"
  ADD COLUMN "menu_template_id" TEXT NOT NULL DEFAULT 'waflo-warm',
  ADD COLUMN "menu_theme_overrides" JSONB;
