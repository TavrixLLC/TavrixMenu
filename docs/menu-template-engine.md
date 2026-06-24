# Waflo Public Menu Template Engine

The Waflo public menu template engine is CSS-first. A business stores a selected template ID, customer-web resolves that ID through a registry, and the public menu renderer emits one stable semantic HTML contract for every template.

Templates must not duplicate menu fetching, normalized menu data, or React layout branches. A template changes the visual result by CSS selectors, CSS variables, grid/flex rules, and data attributes on the fixed DOM contract.

## Architecture

Runtime flow:

1. The public menu API returns menu data and the business appearance fields.
2. Customer-web resolves `business.menuTemplateId` through `apps/customer-web/app/lib/menu-templates.ts`.
3. Invalid, missing, disabled, or unknown template IDs fall back to `waflo-warm`.
4. `PublicMenuTemplateView` renders the same `main.waflo-menu` DOM contract for every template.
5. Template CSS loaded from `apps/customer-web/app/styles/menu-templates/*.css` changes layout and visual style through `data-template`.

The renderer is allowed to choose content from data, such as merchant name, category names, item names, loyalty availability, image presence, sold-out state, and RTL direction. It is not allowed to branch into a different React layout for each template.

## Data And Fallback

- Business field: `menuTemplateId`
- Optional future field: `menuThemeOverrides`
- Default template: `waflo-warm`
- Existing public menu URLs remain `/m/:slug`.
- Existing menu categories, items, prices, images, availability, and loyalty CTA behavior remain data-compatible.
- Missing or invalid template IDs fall back to `waflo-warm`.
- Existing businesses are safe because the database default is `waflo-warm`.

## Template Manifest

Customer-web template manifest:

```text
apps/customer-web/app/lib/menu-templates.ts
```

Admin picker metadata:

```text
apps/admin-web/app/lib/menu-templates.ts
```

Each template definition includes:

- `id`
- `displayName`
- `description`
- `bestFor`
- `cssClass`
- `cssFile`
- `version`
- `status`
- `themeTokens`
- `supportedFeatures`
- `preview`

Template CSS files:

```text
apps/customer-web/app/styles/menu-templates/waflo-warm.css
apps/customer-web/app/styles/menu-templates/coffeehouse-premium.css
apps/customer-web/app/styles/menu-templates/street-bites.css
apps/customer-web/app/styles/menu-templates/minimal-modern.css
```

## Initial Templates

- `waflo-warm`: default cream background, coral CTAs, rounded item cards, green loyalty/progress accents.
- `coffeehouse-premium`: dark green hero, gold reward accents, premium editorial layout, calm image-led cards.
- `street-bites`: bold energetic layout, punchy category tabs, prominent prices, compact fast-food browsing.
- `minimal-modern`: white/neutral background, border-first rows, subtle coral action, spacious typography.

The four templates use the same HTML structure and differ through CSS only.

## Adding A Template

1. Add the new template ID to the API allowlist in `apps/api/src/modules/businesses/menu-appearance.constants.ts`.
2. Add template metadata in `apps/customer-web/app/lib/menu-templates.ts`.
3. Add matching admin picker metadata in `apps/admin-web/app/lib/menu-templates.ts`.
4. Add a CSS file under `apps/customer-web/app/styles/menu-templates/`.
5. Import the CSS file from `apps/customer-web/app/layout.tsx`.
6. Style only the fixed public menu contract documented in `docs/public-menu-html-contract.md`.
7. Verify `/dev/menu-templates` renders the same menu data with the new template.

Do not add a new React branch to `PublicMenuTemplateView` for a visual-only template.

## Admin Behavior

- Owners can save the selected template through `PATCH /businesses/:id/menu-appearance`.
- Staff can view the current appearance but cannot save changes.
- The admin picker displays template name, description, best-for copy, a CSS-reflective mini preview, current badge, and select action.
- The picker includes an open-public-menu action using the existing public URL.
- Saving a template changes the public menu after the appearance setting is updated.

## Preview QA

Development preview route:

```text
/dev/menu-templates
```

The preview page shows every initial template using the same demo menu data and the same single-template route in iframes. It includes mobile-width and desktop-width previews.

Single-template preview route:

```text
/dev/menu-templates/:templateId
```

The demo data is local and contains no QR payloads, scan tokens, card references, transfer tokens, JWTs, phone numbers, emails, or customer PII.

## Accessibility And RTL

- `main.waflo-menu` sets `lang`, `dir`, and `data-dir`.
- Arabic, Kurdish, Persian, and Hebrew language codes render with RTL direction.
- Category and item display names prefer Arabic copy in RTL contexts and English copy otherwise.
- Template CSS must preserve focus outlines, readable text contrast, visible prices, mobile tap targets, and sold-out/error states.
- Template CSS may reorder visual slots, but must not reorder source content in a way that breaks keyboard or screen reader flow.

## Boundaries

This template engine must not implement cart, checkout, ordering, delivery, pickup, or order history.

Wallet signing, APNs, recovery/transfer logic, and staff scanner token behavior are outside this scope.

Do not log or render QR payloads, scan tokens, card references, transfer tokens, JWTs, phone numbers, emails, or customer PII.
