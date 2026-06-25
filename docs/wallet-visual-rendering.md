# Wallet visual rendering

Apple Wallet strip images and Google Wallet hero images share the loyalty
stamp renderer and resolved visual theme.

## Fonts

Generated SVG uses this server-safe fallback stack:

```text
DejaVu Sans, Noto Sans, Arial, sans-serif
```

No Apple proprietary fonts are bundled. Production images should include
DejaVu Sans or Noto Sans in the runtime image. Rendering tests verify that
Sharp can rasterize the exact SVG output, but the deployed Linux image still
needs visual confirmation after each runtime-image change.

## Emoji and icons

Business-controlled text is sanitized before SVG rendering. Emoji,
variation selectors, and zero-width joiners are removed so unsupported color
emoji cannot appear as blank white glyphs or tofu boxes.

Stamp presets use deterministic SVG paths for STAR, COOKIE, COFFEE, BOWL,
BURGER, PIZZA, HEART, and CUPCAKE. They do not depend on native emoji fonts.

## Preview output

Run:

```bash
pnpm --filter tavrix-menu-api wallet:render-stamp-preview
```

Generated previews are written beneath
`apps/api/public/generated/wallet-previews/`, which is ignored by Git.
Previews contain no QR codes or token values.
