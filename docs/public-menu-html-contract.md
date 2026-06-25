# Public Menu HTML Contract

This document defines the stable semantic DOM contract for Waflo public menus. All public menu templates must target this contract with CSS. A template may not require a new React renderer or duplicate menu business logic.

## Root Contract

Every rendered public menu page starts with:

```html
<main
  class="waflo-menu waflo-template-waflo-warm"
  data-template="waflo-warm"
  data-business-slug="merchant-slug"
  data-component="public-menu"
  data-state="ready"
  data-dir="ltr"
  data-loyalty-enabled="true"
  lang="en"
  dir="ltr"
>
  ...
</main>
```

Required root attributes:

- `class="waflo-menu"`: stable root class.
- `data-template`: selected resolved template ID.
- `data-business-slug`: public business slug only.
- `data-component="public-menu"`: stable component identifier.
- `data-state`: `ready`, `empty`, `loading`, `error`, or `not-found`.
- `data-dir`: `ltr` or `rtl`.
- `data-loyalty-enabled`: `true` or `false`.
- `lang`: business language when available.
- `dir`: document direction for the public menu.

Do not place business database IDs, QR payloads, scan tokens, card references, transfer tokens, JWTs, phone numbers, emails, or customer PII on the root or any descendant.

## Required Slots

The public menu renderer emits one predictable set of slots. Templates target these slots with CSS.

| Slot | Selector | Purpose |
| --- | --- | --- |
| Merchant shell | `[data-slot="merchant-shell"]` | Page width, padding, and section flow |
| Merchant hero | `[data-slot="merchant-hero"]` | Merchant header area |
| Merchant cover | `[data-slot="merchant-cover"]` | Cover image or placeholder |
| Merchant logo | `[data-slot="merchant-logo"]` | Logo image or placeholder |
| Merchant identity | `[data-slot="merchant-identity"]` | Logo plus merchant text |
| Merchant name | `[data-slot="merchant-name"]` | Business display name |
| Merchant metadata | `[data-slot="merchant-metadata"]` | City, public slug fallback, currency |
| Merchant status | `[data-slot="merchant-status"]` | Public status/hours slot when available |
| Loyalty block | `[data-slot="loyalty-block"]` | Loyalty CTA when enabled |
| Category navigation | `[data-slot="category-navigation"]` | Sticky or inline category nav |
| Category section | `[data-slot="category-section"]` | One menu category |
| Item list | `[data-slot="item-list"]` | Items inside a category |
| Menu item | `[data-slot="menu-item"]` | One menu item |
| Item image | `[data-slot="item-image"]` | Item image or placeholder |
| Item copy | `[data-slot="item-copy"]` | Name, description, badges |
| Item name | `[data-slot="item-name"]` | Menu item display name |
| Item description | `[data-slot="item-description"]` | Menu item description when available |
| Item price | `[data-slot="item-price"]` | Formatted item price |
| Item badges | `[data-slot="item-badges"]` | Availability and future badges |
| Item status | `[data-slot="item-status"]` | Available or sold-out state |
| AI recommendation | `[data-slot="ai-recommendation"]` | Reserved optional future slot |
| Empty state | `[data-slot="empty-state"]` | Empty menu or empty category |
| Error state | `[data-slot="error-state"]` | Public error/not-found state |
| Skeleton state | `[data-slot="skeleton-state"]` | Loading state blocks |
| Footer branding | `[data-slot="footer-branding"]` | Waflo footer branding |

## Component Attributes

Use `data-component` for stable component-level selectors:

- `public-menu`
- `menu-shell`
- `merchant-header`
- `merchant-identity`
- `merchant-media`
- `metadata-list`
- `metadata-item`
- `merchant-status`
- `loyalty-block`
- `category-navigation`
- `category-link`
- `category-section`
- `item-list`
- `menu-item`
- `item-image`
- `item-status`
- `menu-state`
- `ai-recommendation`
- `footer-branding`

Use `data-state` for state styling:

- Root: `ready`, `empty`, `loading`, `error`, `not-found`
- Media: `image`, `placeholder`, `loading`
- Category: `ready`, `empty`
- Item: `available`, `sold-out`
- Menu state: `empty-menu`, `empty-category`, `loading`, `error`, `not-found`
- AI recommendation: `not-configured` until a real AI payload exists

Use public data attributes only when safe:

- `data-category-id`: public menu category ID used for anchors.
- `data-item-id`: public menu item ID used by the public item URL.
- `data-has-image`: `true` or `false`.
- `data-loyalty-enabled`: `true` or `false`.
- `data-dir`: `ltr` or `rtl`.

Do not expose private IDs, tokens, QR payloads, card references, transfer tokens, JWTs, phone numbers, emails, or customer PII.

## Accessibility Rules

- Keep semantic headings: merchant name is `h1`, category names are `h2`, item names are `h3`.
- Category navigation uses `nav` with `aria-label="Menu categories"`.
- Category and item collections use ordered lists where the source order matters.
- Image alt text must describe the merchant cover/logo or item name.
- Placeholder media must have an accessible image label.
- Focus outlines must remain visible in every template.
- Touch targets should be at least 44px tall on mobile.
- Text contrast must remain readable over template backgrounds.
- CSS may change visual order, but source order should remain understandable without CSS.

## RTL Rules

- `main.waflo-menu` receives `dir="rtl"` and `data-dir="rtl"` for Arabic, Kurdish, Persian, and Hebrew.
- Merchant names, category names, item names, descriptions, and loyalty titles receive the correct `dir`.
- Template CSS should use logical properties where practical: `margin-inline`, `padding-inline`, `inset-inline`, `border-inline`.
- If a template uses `justify-self`, margins, or grid placement for price treatment, add `[data-dir="rtl"]` selectors where needed.

Example:

```css
[data-dir="rtl"].waflo-menu[data-template="minimal-modern"] [data-slot="item-price"] {
  justify-self: start;
}
```

## Allowed CSS Customization Points

Templates may customize:

- CSS variables for color, radius, spacing, shadow, typography, and max width.
- Merchant hero layout through grid areas.
- Cover/logo shape, crop, visibility, and placement.
- Category navigation presentation.
- Loyalty block placement and visual prominence.
- Item list layout as grid, cards, rows, or compact list.
- Item image shape, visibility, and aspect ratio.
- Price placement and emphasis.
- Empty/loading/error state appearance.
- Desktop and mobile behavior.
- RTL-specific visual adjustments.

Templates should prefer:

- CSS variables
- CSS Grid
- Flexbox
- `grid-template-areas`
- logical properties
- media queries
- container queries where supported
- `data-template`, `data-slot`, `data-component`, and `data-state` selectors

## Forbidden Changes

Do not:

- Add a React branch per template.
- Duplicate menu fetching or normalized menu data handling per template.
- Require a schema change for a visual-only template.
- Implement cart, checkout, ordering, delivery, pickup, or order history.
- Recolor official Apple Wallet or Google Wallet badges.
- Touch wallet signing, APNs, recovery/transfer logic, or staff scanner token behavior.
- Log or render QR payloads, scan tokens, card references, transfer tokens, JWTs, phone numbers, emails, or customer PII.
- Let normal business owners upload arbitrary CSS in this sprint.

## Example: Create A New CSS Template

1. Add a template ID to the backend allowlist.
2. Add metadata to the customer-web and admin registries.
3. Add `apps/customer-web/app/styles/menu-templates/new-template.css`.
4. Import the CSS file from `apps/customer-web/app/layout.tsx`.
5. Target the HTML contract:

```css
.waflo-menu[data-template="new-template"] {
  --waflo-template-bg: #ffffff;
  --waflo-template-primary: #ff6b4a;
  --waflo-template-border: #e5e7eb;
  --waflo-menu-radius: 12px;
}

.waflo-menu[data-template="new-template"] [data-slot="item-list"] {
  display: grid;
  gap: 0.75rem;
}
```

## Example: Move Loyalty Block Visually

This changes only visual order. The source order remains stable.

```css
.waflo-menu[data-template="loyalty-forward"] [data-slot="merchant-shell"] {
  display: grid;
}

.waflo-menu[data-template="loyalty-forward"] [data-slot="loyalty-block"] {
  order: -1;
  margin-bottom: 1rem;
}
```

## Example: Card Grid To Compact List

```css
.waflo-menu[data-template="compact-list"] [data-slot="item-list"] {
  display: grid;
  gap: 0;
}

.waflo-menu[data-template="compact-list"] [data-slot="item-link"] {
  grid-template-areas: "copy price";
  grid-template-columns: minmax(0, 1fr) auto;
  border-width: 0 0 1px;
  border-radius: 0;
  box-shadow: none;
}

.waflo-menu[data-template="compact-list"] [data-slot="item-image"] {
  display: none;
}
```

## Example: Street-Food Style

```css
.waflo-menu[data-template="street-style"] [data-slot="category-link"] {
  border-radius: 8px;
  background: #1f2933;
  color: white;
  box-shadow: 0 4px 0 #ff6b4a;
  text-transform: uppercase;
}

.waflo-menu[data-template="street-style"] [data-slot="item-price"] {
  border-radius: 10px;
  background: #ff6b4a;
  color: white;
  font-weight: 900;
}
```

## Example: Minimal Style

```css
.waflo-menu[data-template="minimal-style"] [data-slot="merchant-cover"],
.waflo-menu[data-template="minimal-style"] [data-slot="item-image"] {
  display: none;
}

.waflo-menu[data-template="minimal-style"] [data-slot="item-link"] {
  grid-template-areas: "copy price";
  grid-template-columns: minmax(0, 1fr) auto;
  padding: 1rem 0;
  border-width: 0 0 1px;
  border-radius: 0;
  background: transparent;
  box-shadow: none;
}
```
