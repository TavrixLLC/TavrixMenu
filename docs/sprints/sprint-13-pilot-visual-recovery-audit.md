# Sprint 13 Pilot Visual Recovery Audit

Date: 2026-06-28

Decision: PILOT_VISUAL_RECOVERY_AUDIT_READY

Scope: audit and planning only. No API, OpenAPI, schema, mobile, admin-web,
wallet signing, scanner validation, recovery, transfer, DNS, or staging-service
behavior was changed.

## Context

Sprint 13 First Restaurant Pilot is active. The template pack, media upload API,
and admin media upload UI are available, but the public customer experience
still needs a small visual recovery pass before a real restaurant owner points
customers at the QR menu.

This audit uses Waflo's design docs as the source of truth:

- `docs/design/waflo-ui-ux-principles.md`
- `docs/design/sprint-12-ui-ux-launch-polish-audit.md`
- `docs/design/sprint-12-ui-ux-reality-audit.md`

External UI/UX skills were used only as review guidance: mobile-first hierarchy,
clear touch feedback, restrained motion, visible state changes, and the idea
that small details compound into trust. No external code, assets, colors, or
component implementations were copied.

## Screens And Routes Tested

Live route checks were sanitized. No customer personal data, uploaded media
URLs, access values, scan contents, database IDs, or private identifiers were
recorded.

| Surface | Route / check | Result | Notes |
| --- | --- | --- | --- |
| Public menu | `/m/happy-birthday-2` | 200 | Public menu loads. Current effective template reports `waflo-warm`. |
| Public menu | `/m/tavrix-cafe` | 200 | Secondary known public route loads. |
| Loyalty enrollment | `/m/happy-birthday-2/loyalty` | 200 | Enrollment page loads. |
| Loyalty enrollment | `/m/tavrix-cafe/loyalty` | 200 | Secondary loyalty route loads. |
| Loyalty card missing-access state | `/m/happy-birthday-2/loyalty/card` | 200 | Safe unavailable state loads without a customer card value. |
| Item detail | `/m/happy-birthday-2/item/<redacted-item-id>` | 200 | Detail route loads for a real active item; item id not recorded. |
| Template preview | `/m/happy-birthday-2?previewTemplateId=waflo-warm` | 200 | `data-template` marker present; no `/dev/menu-templates` leak. |
| Template preview | `/m/happy-birthday-2?previewTemplateId=coffeehouse-premium` | 200 | `data-template` marker present; no `/dev/menu-templates` leak. |
| Template preview | `/m/happy-birthday-2?previewTemplateId=street-bites` | 200 | `data-template` marker present; no `/dev/menu-templates` leak. |
| Template preview | `/m/happy-birthday-2?previewTemplateId=minimal-modern` | 200 | `data-template` marker present; no `/dev/menu-templates` leak. |
| Template preview | `/m/happy-birthday-2?previewTemplateId=luxury-dining` | 200 | `data-template` marker present; no `/dev/menu-templates` leak. |
| Template preview | `/m/happy-birthday-2?previewTemplateId=artisan-cafe` | 200 | `data-template` marker present; no `/dev/menu-templates` leak. |
| Template preview | `/m/happy-birthday-2?previewTemplateId=quick-serve-bold` | 200 | `data-template` marker present; no `/dev/menu-templates` leak. |
| Template catalog | `GET /menu-templates` | 200 | Seven enabled templates; preview asset URL fields remain `null`. |

Public payload summary for the pilot sample:

- One active category.
- One active item.
- Item image is present.
- Logo is present.
- Cover image is not present.
- Language reports Arabic/RTL.
- No sold-out item existed in this sample, so sold-out behavior was audited
  from code/CSS rather than a live staging item.

## Current Visual Problems

| Priority | Surface | Problem | Why it matters | Evidence | Suggested fix |
| --- | --- | --- | --- | --- | --- |
| P0 | Public QR menu | Sparse real pilot content can still feel unfinished when there is no cover image. | The first pilot may start with a short menu. If the hero looks like an empty placeholder, customers feel the product is not ready even when the menu works. | `happy-birthday-2` has logo and item image but no cover image; the shared cover fallback is neutral and large. | Add a richer restaurant-safe cover fallback that uses template colors, business name, logo when present, and subtle food/menu framing without fake photos. |
| P0 | Public QR menu mobile | The logo is hidden at small screen widths across the base contract and the new templates. | On a scanned phone menu, the logo is one of the strongest trust anchors. Removing it makes the page feel generic, especially with sparse content. | Base CSS and `luxury-dining`, `artisan-cafe`, and `quick-serve-bold` set `.waflo-menu__logo { display: none; }` on mobile. | Keep a compact mobile logo/avatar or branded mark in the hero. Use safe sizing so it does not crowd the title. |
| P0 | Public QR menu | Hero metadata reads operational rather than appetizing. | "Location", "Currency", and "Menu available" are useful but not enough to sell the restaurant experience. | Merchant header emphasizes type, route/city, currency, and availability. | Reframe hero around restaurant identity: name, short menu cue, loyalty cue, and optional location/currency as secondary chips. |
| P0 | Public QR menu | Category navigation has hover/focus styling but no current-category state. | On longer pilot menus, customers lose orientation while scrolling. | Category links are sticky and scrollable, but there is no active marker tied to selected or viewed category. | Add a lightweight active state after tap or scroll observation. Keep it CSS-first where possible and avoid saving any preview state. |
| P0 | Public QR menu | Item card image treatment is functional but not yet appetizing enough across all templates. | Media upload now works; the product should make real food photos feel valuable immediately. | Templates use image slots, but some mobile layouts shrink images to 5-5.75rem rows. | Make images feel intentional: stronger crop rules, consistent radius, better spacing, and template-specific image emphasis for visual templates. |
| P0 | Public QR menu | Sold-out design exists but needs live sample QA before pilot. | Sold-out must feel unavailable, not broken or hidden. | Code keeps sold-out items visible in the template view and item detail; the tested staging sample had no sold-out item. | Add a staging sold-out sample or seed-safe fixture for visual smoke, then verify list and detail states. |
| P0 | Loyalty enrollment | The join/recovery form is secure but visually text-heavy. | Customers scanning a restaurant QR decide quickly. A dense security explanation can feel like a support page. | Recovery flow has three safe choices with long explanatory copy. | Keep the same secure choices, but compress hierarchy: "Join", "I have my card on another device", "I lost access". Use shorter body copy and stronger primary CTA. |
| P0 | Loyalty card | Live card progress reads like a utility dashboard instead of a customer reward card. | The customer should feel "I am close to my reward", not "I am reading metrics". | Card metrics include stamps, progress percent, total stamps earned, rewards redeemed, then a progress bar. | Make progress and next reward the visual center. Move lifetime stats below or collapse them behind secondary context. |
| P0 | Loyalty/card wallet actions | Wallet CTAs are correct but visually detached from the menu template system. | The customer moves from menu to loyalty; a hard visual switch makes the flow feel less premium. | Loyalty/card pages use Waflo system surfaces, not template-aware restaurant styling. | Borrow the active menu template's colors lightly for loyalty shells while keeping official wallet badges unchanged. |
| P0 | Brand consistency | Waflo system UI and restaurant templates are not clearly separated. | Owners should understand that restaurant templates can vary while Waflo actions stay trustworthy and consistent. | Public menu templates vary strongly; loyalty pages use system colors; hero/footer copy mixes product and restaurant identity. | Define a simple boundary: restaurant template styles menu content, Waflo system styles wallet/security/action panels, with shared spacing and typography rules. |

## Pilot-Critical Fixes

These are the smallest safe fixes recommended before the first real restaurant
pilot. They are visual/customer-web only unless tests reveal otherwise.

| Priority | Fix | Owner | Why now |
| --- | --- | --- | --- |
| P0 | Keep a compact logo visible on mobile public menus. | Web | Improves trust immediately and uses existing uploaded logo data. |
| P0 | Improve the cover fallback for businesses without cover images. | Web | Prevents a blank-looking hero on real pilot menus. |
| P0 | Strengthen item card hierarchy for real photos, names, descriptions, and prices at 390px. | Web | Customers need fast menu scanning on phone. |
| P0 | Add a current/tapped category state in the sticky category nav. | Web | Prevents disorientation on real menus with several categories. |
| P0 | Make loyalty enrollment above-the-fold simpler: one short promise, one primary join CTA, one recovery entry. | Web | Reduces friction while preserving secure recovery rules. |
| P0 | Redesign live loyalty card hierarchy around reward progress first, secondary metrics later. | Web | Makes loyalty feel rewarding and pilot-ready. |
| P0 | Verify sold-out list/detail states using a safe staging item before merge of the visual recovery implementation. | Web | Avoids shipping an untested unavailable-state look. |

## P1 Professional Polish

| Priority | Fix | Owner | Why it can follow P0 |
| --- | --- | --- | --- |
| P1 | Add template-aware empty states for no cover, no item image, empty category, and empty menu. | Web | Improves perceived quality, but P0 hero/card fixes should land first. |
| P1 | Tune all seven templates for distinct but intentional moods: warm default, premium cafe, street food, minimal, luxury, artisan, fast-service. | Web | The catalog is live; subtle tuning can make each option feel less generic. |
| P1 | Add safe mobile visual QA notes for RTL Arabic text wrapping and price placement. | Web | Current RTL markers exist, but full Arabic typography work belongs to Sprint 15. |
| P1 | Make item detail feel like an extension of the selected template, especially image/price/reward cross-links. | Web | Detail route works; stronger polish improves confidence after tapping an item. |
| P1 | Add a customer-facing "live card is current" visual cue on loyalty card that is calmer than an alert. | Web | Existing copy is correct; visual treatment can be less warning-like. |
| P1 | Add test coverage for preview route rendering all seven template markers and not persisting preview appearance. | Web | Contract appears correct; tests reduce regression risk. |

## Deferred Redesign Items

| Priority | Item | Sprint | Reason |
| --- | --- | --- | --- |
| P2 | Full Arabic/Kurdish localization, font selection, pluralization, and locale QA. | 15 | Current work should stay RTL-safe, but full localization is larger than pilot visual recovery. |
| P2 | Template marketplace, template thumbnails, merchant-custom themes, and custom CSS upload. | 19 | The pilot needs curated templates, not an open design system. |
| P2 | Hosted admin dashboard, admin staging service, and DNS setup. | 22 | Current pilot can use local admin-web against staging API; this is ops/product scope, not public visual recovery. |
| P2 | Media library, cropper, gallery, and image management workflow. | 22 | Upload MVP is enough for the pilot; image management can harden later. |
| P2 | Automated visual regression gates and accessibility screenshot matrix. | 22 | Useful, but manual browser QA is acceptable for this small pre-pilot recovery pass. |
| P2 | Nearby wallet reminders or wallet platform behavior changes. | Later | Not related to visual recovery and must not touch wallet signing or platform integrations here. |

## Files Likely Affected In The Follow-Up Branch

Expected implementation branch:

`codex/sprint-13-pilot-visual-recovery-web`

Likely files:

- `apps/customer-web/app/components/PublicMenuTemplateView.tsx`
- `apps/customer-web/app/components/PlaceholderImage.tsx`
- `apps/customer-web/app/components/PublicMenuStates.tsx`
- `apps/customer-web/app/m/[slug]/loyalty/LoyaltyEnrollmentClient.tsx`
- `apps/customer-web/app/m/[slug]/loyalty/card/LoyaltyCardClient.tsx`
- `apps/customer-web/app/styles/public-menu-contract.css`
- `apps/customer-web/app/styles/menu-templates/waflo-warm.css`
- `apps/customer-web/app/styles/menu-templates/coffeehouse-premium.css`
- `apps/customer-web/app/styles/menu-templates/street-bites.css`
- `apps/customer-web/app/styles/menu-templates/minimal-modern.css`
- `apps/customer-web/app/styles/menu-templates/luxury-dining.css`
- `apps/customer-web/app/styles/menu-templates/artisan-cafe.css`
- `apps/customer-web/app/styles/menu-templates/quick-serve-bold.css`
- Customer-web tests for public menu, loyalty, preview, sold-out, and no-internal-copy states.

Files that should not be touched for the visual recovery implementation unless a
real blocker appears:

- API source, Prisma schema, migrations, OpenAPI docs.
- Mobile Flutter app.
- Admin-web implementation.
- Wallet signing, wallet update, scanner validation, transfer, and recovery
  security code.

## Risk Assessment

| Risk | Level | Mitigation |
| --- | --- | --- |
| Visual changes accidentally break the public menu HTML contract. | Medium | Keep markup stable where possible; prefer CSS and small component copy/layout changes; add preview tests. |
| Template-specific CSS fixes create horizontal overflow on 390px phones. | Medium | Run mobile browser smoke for all seven templates before merge. |
| Loyalty visual polish accidentally weakens recovery security copy. | Medium | Preserve the three secure choices; do not allow phone-only card access. |
| Official wallet button spacing or brand treatment regresses. | Low | Keep existing Apple/Google button components and only adjust surrounding hierarchy. |
| Arabic/RTL regressions. | Medium | Verify `data-dir="rtl"` routes for all seven templates and check price alignment on mobile. |
| Pilot owner expects hosted admin dashboard. | Product risk | Keep docs clear: hosted admin remains deferred; local admin-web against staging API is the current pilot path. |

## Exact Follow-Up Implementation Plan

1. Create branch `codex/sprint-13-pilot-visual-recovery-web` from latest `dev`.
2. Keep scope customer-web only.
3. Public menu hero pass:
   - Keep compact logo visible on mobile.
   - Replace neutral cover fallback with template-aware branded fallback.
   - Rebalance merchant metadata so identity and menu confidence come first.
4. Public menu item pass:
   - Improve 390px item card spacing, image crop, price placement, and tap feedback.
   - Keep sold-out visible with clearer unavailable treatment.
   - Verify item detail still renders unavailable items as unavailable, not broken.
5. Category navigation pass:
   - Add a current/tapped category state without persisting anything.
   - Preserve keyboard focus and horizontal scroll behavior.
6. Loyalty enrollment pass:
   - Shorten first-time join copy.
   - Keep recovery choices secure and separate.
   - Keep live card and Wallet handoff copy non-technical.
7. Loyalty card pass:
   - Move reward progress to the top visual priority.
   - Move lifetime stats below the reward card.
   - Keep "live web card is current; Wallet may sync shortly" without promising instant updates.
8. Tests:
   - Customer-friendly menu states.
   - Sold-out list/detail rendering.
   - Preview route uses `previewTemplateId` but does not persist appearance.
   - Seven template ids render and catalog preview asset fields remain absent.
   - Loyalty copy avoids internal access wording.
9. Verification:
   - `pnpm --filter @tavrix-menu/customer-web test`
   - `pnpm --filter @tavrix-menu/customer-web lint`
   - `pnpm --filter @tavrix-menu/customer-web build`
   - `git diff --check`
   - Targeted sensitive-value scan on changed files.
10. Runtime smoke before merge:
   - `/m/happy-birthday-2`
   - `/m/tavrix-cafe`
   - All seven preview template routes.
   - `/m/happy-birthday-2/loyalty`
   - `/m/happy-birthday-2/loyalty/card` unavailable state without any card access value.
   - 390px mobile width check for horizontal overflow.
   - RTL sanity with Arabic-language route.

## Recommended Decision

Proceed with the follow-up implementation branch only after this audit is
accepted.

Recommended next decision: `PILOT_VISUAL_RECOVERY_AUDIT_READY`.
