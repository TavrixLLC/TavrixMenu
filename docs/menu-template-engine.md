# Waflo Public Menu Template Engine

The public menu uses a registry-based template system. A business stores a selected template ID, and the customer web app resolves that ID through a central registry before rendering the existing menu data.

## Data And Fallback

- Business field: `menuTemplateId`
- Optional future override field: `menuThemeOverrides`
- Default template: `waflo-warm`
- Missing or invalid template IDs fall back to `waflo-warm`.
- Existing public menu URLs remain `/m/:slug`.
- Menu categories, items, prices, images, availability flags, and loyalty CTA behavior remain data-compatible across templates.

## Implemented Registry

Customer web registry:

```text
apps/customer-web/app/lib/menu-templates.ts
```

Admin picker metadata:

```text
apps/admin-web/app/lib/menu-templates.ts
```

Initial templates:

- `waflo-warm`
- `coffeehouse-premium`
- `street-bites`
- `minimal-modern`

Each template defines ID, display name, description, best-for metadata, theme tokens, layout variant, item style, category navigation style, loyalty block style, state style, and preview metadata.

## Adding A Template

1. Add the new ID to the API allowlist in `apps/api/src/modules/businesses/menu-appearance.constants.ts`.
2. Add customer rendering metadata in `apps/customer-web/app/lib/menu-templates.ts`.
3. Add admin picker metadata in `apps/admin-web/app/lib/menu-templates.ts`.
4. Add or extend a presentational branch in `apps/customer-web/app/components/PublicMenuTemplateView.tsx`.
5. Verify fallback behavior and RTL rendering.
6. Update this document if the template introduces a new layout variant.

## Admin Behavior

- Owners can save the selected template through `PATCH /businesses/:id/menu-appearance`.
- Staff can view the current appearance but cannot save changes.
- The admin picker displays name, description, best-for copy, color preview, current badge, and select action.
- The picker includes an open-public-menu action using the existing public URL.

## Preview QA

Customer web includes a development preview route:

```text
/dev/menu-templates
```

It renders all four initial templates from the same demo menu data, including Arabic/RTL content and a loyalty block.

## Accessibility And RTL

- Public menu rendering sets `dir="rtl"` for Arabic, Kurdish, Persian, and Hebrew language codes.
- Category names and item names prefer Arabic copy in RTL contexts and English copy otherwise.
- Template visuals must preserve contrast for text, prices, sold-out state, and loyalty CTAs.
- Touch targets must remain mobile-friendly.

## Boundaries

This template engine must not implement cart, checkout, ordering, delivery, pickup, or order history. Wallet signing, APNs, recovery/transfer logic, and staff scanner token behavior remain outside this scope.
