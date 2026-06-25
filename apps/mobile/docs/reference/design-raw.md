# Waflo Product Design System & Menu Template Engine

## Purpose

This document is the source of truth for Waflo product design direction across customer web, admin web, Flutter staff/business app, public menu templates, and loyalty/wallet surfaces.

Waflo is a Business Loyalty Platform. The restaurant and cafe QR menu plus loyalty experience is the first vertical. Waflo is not currently an ordering, cart, checkout, or delivery product unless those capabilities are explicitly enabled in a later scope.

Use this document to align:

- Waflo brand direction and product tone
- Core color, typography, spacing, radius, and shadow rules
- Customer public menu website behavior
- Admin/owner dashboard behavior
- Flutter staff/business app behavior
- Loyalty and wallet visual behavior
- Public menu template engine expectations
- RTL, Arabic, accessibility, and implementation boundaries

## Product Direction

Waflo should feel warm, useful, modern, and trustworthy for business owners and customers. The product should not look like a single coffeehouse clone, and it should not look like a generic blue corporate SaaS product. Waflo owns a flexible loyalty platform identity that can adapt to many merchants while keeping a recognizable coral, green, and warm cream foundation.

The first vertical is restaurants and cafes:

- Public QR menu browsing
- Menu categories, items, prices, and images
- Loyalty enrollment and reward calls to action when enabled
- Staff scanning for stamps, rewards, and customer wallet passes
- Admin tools for menu, loyalty, QR/public link, and appearance setup

Out of scope unless explicitly enabled later:

- Customer cart
- Checkout
- Order placement
- Order history
- Product customization checkout flow
- Delivery or pickup fulfillment
- Nutrition-first ordering app assumptions

## Product Surfaces

### 1. Customer Public Menu Website

The public menu website is mobile-first, template-driven, and optimized for fast QR menu browsing. It is the customer's primary public experience.

Required behavior:

- Mobile-first layout with strong small-screen readability
- Fast category, item, price, and image scanning
- Template-driven visual presentation
- Loyalty or join CTA when loyalty is enabled for the business
- Arabic and RTL support
- Existing public menu URLs remain stable
- No checkout, cart, or order placement scope creep

Visual priorities:

- Make menu content readable before decorative styling
- Keep category navigation easy to reach on mobile
- Use item cards or item rows according to the selected template
- Use merchant imagery without over-cropping important food details
- Use coral for key CTAs such as join, continue, or claim
- Use green for success, progress, loyalty growth, and earned rewards

### 2. Admin/Owner Dashboard

The admin/owner dashboard is a calm professional workspace for business owners. It should feel SaaS-grade, organized, and efficient.

Core areas:

- Business setup
- Menu manager
- Category and item management
- QR code and public link management
- Loyalty settings
- Menu appearance and template picker
- Account and permission-aware settings

Visual priorities:

- Use white surfaces on neutral or warm backgrounds
- Use coral only for important primary actions
- Use green for saved/success/progress states
- Avoid heavy decorative gradients or visual noise
- Use dense but readable controls for repeated business workflows
- Make destructive actions visually distinct and hard to trigger accidentally

### 3. Flutter Staff/Business App

The Flutter app is for staff and business operations. It should prioritize speed, scanner readability, and confidence during in-person customer interactions.

Core areas:

- Staff/business dashboard
- Wallet pass or customer QR scanner
- Add stamp action
- Redeem reward action
- Customer loyalty status summary
- Basic business operational views as already scoped

Visual priorities:

- Scanner readability first
- High-contrast scan surfaces
- Coral for scan, add, continue, and primary staff actions
- Green for success, progress, redeemed, and earned states
- Clear loading, error, and permission states
- No scanner logic changes from design work alone

### 4. Loyalty and Wallet Experience

Waflo loyalty should feel rewarding without becoming visually noisy. Wallet passes and loyalty screens may use Waflo's coral, green, and cream defaults, but merchant customization must remain possible.

Rules:

- Default Waflo loyalty visuals can use coral, green, cream, and selective reward gold
- Merchant-specific brand color and pass appearance customization must remain possible
- Reward gold is reserved for premium, milestone, and reward moments
- Apple Wallet and Google Wallet official badges must not be recolored or restyled
- Signing, APNs, and wallet pass delivery infrastructure are out of scope for this document

## Brand Direction

Waflo's brand should communicate:

- Warmth for customers
- Trust and clarity for business owners
- Momentum around loyalty growth
- Flexibility for different restaurant and cafe identities
- A SaaS platform foundation, not a one-off restaurant app

Design language:

- Coral for action and energy
- Green for loyalty, progress, and success
- Cream for warmth in customer-facing menu surfaces
- White for readable cards, admin surfaces, and form areas
- Gold only for reward or premium moments
- Red only for errors and destructive actions

Do not:

- Make the whole interface orange
- Keep Waflo as a purely blue/corporate product
- Keep Starbucks-like green as the only identity
- Build a single fixed visual template into menu data
- Let ordering/cart assumptions drive menu, loyalty, or template design

## Core Color System

| Token | Hex | Primary use |
| --- | --- | --- |
| Primary Coral | `#FF6B4A` | Primary actions, join, scan, claim, continue |
| Primary Coral Dark | `#D94B2B` | Pressed/hover states, high-emphasis coral accents |
| Fresh Green | `#43A047` | Success, growth, loyalty progress, reward progress |
| Fresh Green Dark | `#2E7D32` | Strong success states, accessible green text or icons |
| Warm Cream | `#FFF8F2` | Warm public menu backgrounds |
| Surface White | `#FFFFFF` | Cards, readable areas, admin surfaces |
| Text Dark | `#1F2933` | Primary text |
| Muted Text | `#6B7280` | Secondary text and helper text |
| Soft Border | `#F1E2D6` | Borders, dividers, subtle outlines |
| Reward Gold | `#F59E0B` | Reward and premium moments only |
| Danger Red | `#DC2626` | Errors and destructive actions only |

Color usage rules:

- Coral is for primary actions and customer movement: join, scan, claim, continue, save.
- Green is for success, growth, loyalty progress, stamps, earned rewards, and positive status.
- Cream is for warm public menu backgrounds and customer-facing empty states.
- White is for cards, panels, forms, menus, and readable content areas.
- Gold is only for reward, premium, milestone, or celebration moments.
- Red is only for errors, destructive actions, failed states, and warnings that require attention.
- Blue may appear only where an existing platform pattern requires it, such as links or external service conventions.

## Typography

Waflo should use clean, readable product typography. Typography must support English, Arabic, and mixed-language content without layout breakage.

Recommended direction:

- Use a modern sans-serif family for product UI.
- Use a font stack or loaded font family that supports Arabic properly.
- Use clear hierarchy for menu categories, item names, prices, and loyalty state.
- Keep admin dashboard typography compact enough for repeated work.
- Avoid decorative fonts for operational UI.

Suggested scale:

| Role | Size | Weight | Use |
| --- | --- | --- | --- |
| Display | 32-40 | 700 | Public menu merchant name or major page heading |
| H1 | 28-32 | 700 | Main page title |
| H2 | 22-24 | 650-700 | Section title |
| H3 | 18-20 | 650 | Card or panel title |
| Body | 15-16 | 400-500 | Menu descriptions and normal UI text |
| Small | 13-14 | 400-500 | Helper text, metadata, secondary labels |
| Label | 13-15 | 600 | Buttons, tabs, category labels |

Rules:

- Do not use negative letter spacing as a default.
- Do not scale font size directly with viewport width.
- Preserve readable line height for Arabic and mixed English/Arabic text.
- Prices must remain legible and aligned with the chosen layout direction.

## Spacing, Radius, and Shadows

Spacing tokens:

| Token | Value | Use |
| --- | --- | --- |
| `xxs` | 4 | Tight icon/text gaps |
| `xs` | 8 | Compact control gaps |
| `sm` | 12 | Small card and row gaps |
| `md` | 16 | Standard screen and card padding |
| `lg` | 24 | Section padding and panel gaps |
| `xl` | 32 | Large section gaps |
| `xxl` | 48 | Major page rhythm |

Radius tokens:

| Token | Value | Use |
| --- | --- | --- |
| `sm` | 6 | Small controls and tags |
| `md` | 8 | Admin cards, inputs, compact panels |
| `lg` | 12 | Public menu item cards and loyalty cards |
| `xl` | 18 | Featured customer-facing panels |
| `pill` | 999 | Pills, chips, segmented controls |

Shadow rules:

- Public menu item cards may use soft, shallow shadows when the template calls for it.
- Admin dashboard surfaces should usually rely on borders and spacing, not heavy shadows.
- Floating mobile controls may use a small shadow for separation.
- Avoid dramatic shadows that make the product feel like a landing page instead of a tool.

## Public Menu Template Engine

The public menu must use a registry-based CSS-first template system. A selected template changes presentation, theme tokens, layout behavior, and component styling without rewriting menu data or adding template-specific React render branches.

Template selection belongs to business appearance settings, not to menu item content. Menu data remains compatible across templates.

Template registry requirements:

- Each template has a stable `id`.
- Each template has admin-facing metadata for display and preview.
- The public menu renderer resolves the selected template through a central registry.
- The public menu renderer emits one fixed semantic HTML contract for every template.
- Template CSS targets `main.waflo-menu`, `data-template`, `data-slot`, `data-component`, and `data-state`.
- Existing businesses receive a safe default template.
- Invalid, missing, or disabled template IDs fall back safely.
- Future templates can be added by Waflo SaaS owners without rewriting the menu data model.
- Template rendering must preserve existing public menu URLs.

Template definition shape:

```text
id
displayName
description
bestFor
cssClass
cssFile
version
status
theme tokens
supported features
item card style
category navigation style
loyalty block style
empty/loading/error state style
preview metadata or placeholder
```

### Initial Template: `waflo-warm`

| Field | Value |
| --- | --- |
| `id` | `waflo-warm` |
| `displayName` | Waflo Warm |
| `description` | Warm coral, cream, and green public menu style for most restaurants and cafes. |
| `bestFor` | General restaurants, cafes, bakeries, casual dining |
| Theme tokens | Coral primary, cream page background, white cards, green loyalty progress, soft cream border |
| CSS layout behavior | Mobile-first category sections with featured merchant header |
| Item card style | Rounded food cards with image, name, description, price, and optional loyalty marker |
| Category navigation style | Sticky horizontal chips or tabs with coral active state |
| Loyalty block style | Warm cream or white panel with coral join CTA and green progress state |
| Empty/loading/error state style | Friendly cream states, skeleton cards, concise retry action |
| Preview metadata | Placeholder preview showing cream background, coral CTA, rounded menu cards |

### Initial Template: `coffeehouse-premium`

| Field | Value |
| --- | --- |
| `id` | `coffeehouse-premium` |
| `displayName` | Coffeehouse Premium |
| `description` | Dark green, gold, and cream style for premium cafe and dessert menus. |
| `bestFor` | Specialty coffee, dessert shops, premium bakeries, boutique cafes |
| Theme tokens | Dark green primary surfaces, cream background, gold reward accents, white cards |
| CSS layout behavior | Editorial merchant header with grouped menu sections |
| Item card style | Polished cards or rows with strong imagery and restrained gold accents |
| Category navigation style | Dark green active tabs or compact section jump links |
| Loyalty block style | Premium reward card with gold milestone details and green progress |
| Empty/loading/error state style | Quiet premium empty states, low-motion loading, clear retry |
| Preview metadata | Placeholder preview showing dark header, cream body, gold reward highlight |

### Initial Template: `street-bites`

| Field | Value |
| --- | --- |
| `id` | `street-bites` |
| `displayName` | Street Bites |
| `description` | Bold coral, orange, and red-accented style for energetic fast-food and street-food menus. |
| `bestFor` | Burgers, shawarma, fried chicken, food trucks, street-food brands |
| Theme tokens | Coral primary, energetic warm accents, white cards, red only for errors or strong brand accents |
| CSS layout behavior | Compact high-energy menu with quick category switching |
| Item card style | Bold item rows or cards with prominent price and image thumbnail |
| Category navigation style | Sticky punchy tabs with strong active indicator |
| Loyalty block style | Direct earn/redeem panel with coral CTA and green success state |
| Empty/loading/error state style | Simple high-contrast states, fast skeleton loading, direct retry |
| Preview metadata | Placeholder preview showing bold category tabs and prominent prices |

### Initial Template: `minimal-modern`

| Field | Value |
| --- | --- |
| `id` | `minimal-modern` |
| `displayName` | Minimal Modern |
| `description` | Clean white and neutral style with subtle accents for premium or simple restaurants. |
| `bestFor` | Fine casual restaurants, modern cafes, simple menus, premium dining |
| Theme tokens | White background, neutral borders, dark text, subtle coral primary action, green success |
| CSS layout behavior | Spacious list layout with minimal decoration |
| Item card style | Border-first cards or rows with restrained images and clear price hierarchy |
| Category navigation style | Underlined tabs or simple segmented control |
| Loyalty block style | Quiet inline loyalty panel with subtle coral CTA and green progress |
| Empty/loading/error state style | Minimal empty states, neutral skeletons, unobtrusive errors |
| Preview metadata | Placeholder preview showing clean white menu with subtle coral action |

## Owner/Admin Template Behavior

Owner/admin behavior:

- Owner/admin can select a public menu template from appearance settings.
- The selected template applies to the customer public menu.
- Existing businesses get the safe default template, `waflo-warm`.
- Invalid template IDs fall back safely to `waflo-warm`.
- Staff without the required permission cannot change the template.
- Future templates can be added by Waflo SaaS owners without rewriting menu data.
- Template selection should not duplicate menu items, categories, prices, images, or loyalty data.
- Visual-only template changes should add metadata and CSS against the public menu HTML contract, not React branches.

Admin template picker expectations:

- Show template display name, description, best-for metadata, and preview.
- Make current selection clear.
- Confirm unsaved changes before navigation if needed.
- Provide a safe fallback when a preview image is missing.
- Avoid exposing internal registry implementation details to normal business users.

## RTL and Arabic Rules

Waflo must support Arabic and RTL layouts across public menu, admin dashboard where applicable, and Flutter staff/business app.

Rules:

- Layout direction must flip for RTL languages.
- Category navigation must scroll and align correctly in RTL.
- Prices, numbers, and currency formatting must follow locale expectations.
- Item names and descriptions may be Arabic, English, or mixed.
- Avoid hardcoded English strings in reusable UI.
- Icons that imply direction must mirror when appropriate.
- Do not mirror official brand logos, QR codes, barcodes, or wallet badges.
- Text containers must allow Arabic line height without clipping.
- Search and form inputs must handle Arabic text naturally.

## Accessibility Rules

Minimum requirements:

- Text contrast must be readable on coral, green, cream, and white surfaces.
- Do not rely on color alone for errors, success, or loyalty state.
- Touch targets should be at least 44px high on mobile surfaces.
- Public menu category controls must be reachable by keyboard and screen readers.
- Buttons need clear accessible labels.
- Product images need useful alt text where the image conveys content.
- Loading states should communicate progress without trapping focus.
- Error states need concise messages and a retry path where possible.
- Dynamic text size must not break cards, buttons, scanner controls, or loyalty blocks.
- QR and scanner surfaces must preserve high contrast.

## Implementation Boundaries

This document is design and product source-of-truth only.

Do not implement in this step:

- Ordering
- Cart
- Checkout
- Order placement
- Order history
- Product customization checkout flow
- Backend behavior changes
- OpenAPI changes
- Prisma schema changes
- Apple Wallet signing changes
- Google Wallet signing changes
- APNs changes
- Recovery or transfer logic changes
- Staff scanner logic changes

Future implementation should follow these boundaries:

- Do not rewrite the app for the template system.
- Use additive migration-based changes later if schema support is needed.
- Keep existing public menu URLs working.
- Keep existing menu data compatible with every template.
- Do not print QR codes, tokens, PII, wallet payloads, or sensitive customer identifiers in logs.
- Keep wallet signing and push notification infrastructure separate from visual template work.

## Recommended Future Implementation Plan

### Phase 1

- Replace source-of-truth docs.
- Audit current UI, theme, and template hardcoding.
- Identify current ordering/cart assumptions in UI copy or navigation.
- Document existing public menu URL and data compatibility constraints.

### Phase 2

- Define centralized design tokens.
- Add public menu template registry.
- Add default template fallback.
- Keep public rendering compatible with existing menu data.

### Phase 3

- Add admin template picker.
- Render public menu through selected template.
- Add preview metadata and safe missing-preview behavior.
- Enforce permission checks for template changes.

### Phase 4

- Align Flutter staff/business app theme with Waflo tokens.
- QA public menu templates on mobile, desktop, and RTL.
- Verify accessibility contrast, focus, keyboard, and screen-reader basics.
- Confirm scanner readability and loyalty/wallet visual consistency.

## Verification for Sprint 12B Step 0

Required verification:

- Documentation updated.
- No backend code changed.
- No Prisma changed.
- No OpenAPI changed.
- No wallet signing or APNs changed.
- `git diff --check` passes.

Expected branch:

```text
codex/sprint-12b-replace-design-source-of-truth
```
