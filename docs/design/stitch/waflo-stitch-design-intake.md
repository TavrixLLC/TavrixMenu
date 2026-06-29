# Waflo Stitch Design Intake Audit

Date: 2026-06-29

Decision: STITCH_DESIGN_INTAKE_READY

Scope: docs-only design intake. No API code, OpenAPI, schema, mobile runtime code, customer-web runtime code, admin-web runtime code, wallet signing, scanner-token validation, recovery/transfer security, billing, subscriptions, localization implementation, DNS, or runtime assets were changed.

The Stitch exports are reference material only. They are useful for visual direction, Arabic-first hierarchy, and acceptance criteria, but they must not be copied into Waflo as generated code or generated assets.

## A) Executive Verdict

The Stitch exports confirm the right direction for Waflo: Arabic-first, warm, premium, restaurant-specific, and guided instead of dashboard-heavy. The strongest parts are the quiet login/onboarding hierarchy, the owner setup flow, the image-led menu management screens, the staff scanner focus, and the customer loyalty card hierarchy.

The exports are not implementation-ready as code. They contain generated HTML, simulated wallet buttons, remote generated image references, QR-like mock imagery, broad customization screens, and recovery copy that would conflict with Waflo's secure recovery rules if copied literally.

Recommended use:

- Adopt the layout patterns, spacing rhythm, CTA hierarchy, Arabic-first copy direction, food-image treatment, and state hierarchy.
- Keep Waflo's existing brand palette and architecture.
- Implement small acceptance-criteria-driven slices in Flutter/customer-web, not a full redesign.

## B) Screens Reviewed

Mobile Stitch export source:

- `deisgn/mobile/login_screen/screen.png`
- `deisgn/mobile/waflo_splash_screen/screen.png`
- `deisgn/mobile/merchant_dashboard/screen.png`
- `deisgn/mobile/business_profile_setup/screen.png`
- `deisgn/mobile/menu_management/screen.png`
- `deisgn/mobile/menu_management/code.html`
- `deisgn/mobile/menu_management_grid_view/screen.png`
- `deisgn/mobile/menu_appearance_setup/screen.png`
- `deisgn/mobile/loyalty_setup/screen.png`
- `deisgn/mobile/advanced_color_customization_suite/screen.png`
- `deisgn/mobile/advanced_loyalty_card_customization/screen.png`
- `deisgn/mobile/loyalty_card_advanced_customization/screen.png`
- `deisgn/mobile/customer_qr_menu/screen.png`
- `deisgn/mobile/customer_qr_menu_grid_view/screen.png`
- `deisgn/mobile/customer_qr_menu_grid_view/code.html`
- `deisgn/mobile/staff_scanner_dashboard/screen.png`
- `deisgn/mobile/waflo_premium_merchant_system/DESIGN.md`

Web/customer Stitch export source:

- `deisgn/web/waflo_product_requirements_document.md`
- `deisgn/web/waflo_brand_identity/DESIGN.md`
- `deisgn/web/waflo_marketing_landing_page/screen.png`
- `deisgn/web/waflo_marketing_landing_page/code.html`
- `deisgn/web/waflo_public_qr_menu_mobile/screen.png`
- `deisgn/web/waflo_public_qr_menu_mobile/code.html`
- `deisgn/web/waflo_public_qr_menu_grid_layout/screen.png`
- `deisgn/web/waflo_public_qr_menu_grid_layout/code.html`
- `deisgn/web/waflo_loyalty_enrollment/screen.png`
- `deisgn/web/waflo_loyalty_enrollment/code.html`
- `deisgn/web/waflo_loyalty_card_web/screen.png`
- `deisgn/web/waflo_loyalty_card_web/code.html`
- `deisgn/web/waflo_wallet_handoff/screen.png`
- `deisgn/web/waflo_wallet_handoff/code.html`
- `deisgn/web/waflo_card_recovery/screen.png`
- `deisgn/web/waflo_card_recovery/code.html`
- `deisgn/web/waflo_status_errors/screen.png`
- `deisgn/web/waflo_status_errors/code.html`
- `deisgn/web/waflo_qr_print_preview/screen.png`
- `deisgn/web/waflo_qr_print_preview/code.html`

## C) What Is Worth Adopting

| Area | Reusable Decision | Why It Fits Waflo | Implementation Note |
| --- | --- | --- | --- |
| Brand feeling | Warm, premium, hospitable, Arabic-first. | Matches Sprint 14 reality gap: merchant trust depends on local confidence, not technical proof. | Use existing Waflo palette, not generated Material-blue surfaces. |
| Login | Quiet card, one phone/auth path, one create-workspace path. | Reduces first-screen confusion. | Keep Google Sign-In hidden until configured; no fake social auth. |
| Splash/session restore | Minimal restoring state. | Supports Sprint 14A session persistence trust. | Add useful restoring copy; avoid blank screen if restore lasts more than a moment. |
| Owner dashboard | One guided setup card instead of raw metrics. | Helps owners answer "what do I do next?" | Use checklist language: menu, images, QR, loyalty, staff. |
| Business setup | Guided selectors and upload slots. | Reduces free-text setup mistakes. | Use dropdowns for business type/city/currency/language; upload-from-device remains primary in later slice. |
| Menu management | Image-led item cards with visible price, sold-out state, and add-item affordance. | Merchant daily workflow needs confidence and clarity. | Keep current architecture; improve hierarchy and validation, not data contracts. |
| Menu appearance | Template cards plus phone preview. | Owners choose by customer feel, not template IDs. | Preserve `previewTemplateId` non-persistent behavior. |
| Loyalty setup | Simple program name, stamp count, reward, stamp icon, preview. | Good pilot mental model. | Keep advanced appearance controls small and safe; defer full designer. |
| Staff scanner | Dark focused scan area, large scan action, recent activity style. | Staff need a fast counter tool. | Do not commit QR screenshots or token-like imagery; use live scanner widgets. |
| Public QR menu | Food-first hierarchy, sticky categories, visible loyalty CTA. | Customer first impression becomes appetizing and easy. | Keep CSS-first template contract. No cart/order scope. |
| Loyalty enrollment | Strong restaurant identity, short benefit copy, phone-first form. | Makes wallet add feel understandable. | Email remains optional where backend supports it; recovery must stay secure. |
| Loyalty card | Big progress statement, stamp slots, reward state, wallet action. | Feels like a customer card instead of analytics. | Do not expose card refs/tokens; live web card remains source of truth. |
| Wallet handoff | Platform-specific wallet CTA plus live-card fallback. | Aligns with current device-aware flow. | Use official wallet badge treatment where available; no simulated brand assets. |
| Error states | Friendly Arabic customer messages and obvious retry/home actions. | Keeps public edge cases from feeling broken. | Keep security-sensitive errors generic. |

## D) What Must Not Be Copied

- Generated HTML structure and Tailwind classes from Stitch.
- Remote generated image references from the exports.
- QR-like mock images, QR screenshots, or any QR payload representation.
- Simulated Apple Wallet or Google Wallet badges.
- Any copy implying phone-only recovery can unlock a card.
- Any copy implying the system will reveal or send an existing card based only on phone number.
- Generated mock restaurant/customer names as real pilot data.
- Stale copyright/year text.
- Cart, ordering, checkout, delivery, or pickup affordances.
- Advanced color-suite/card-designer controls as a Sprint 14 default.
- Full localization, Kurdish/Sorani/Badini, or template marketplace scope.
- Material-style cold blue palette as a replacement for Waflo's existing brand.

## E) Mobile Implementation Candidates

| Candidate | Classification | Acceptance Criteria |
| --- | --- | --- |
| Arabic-first login card | Safe for Sprint 14B/14C mobile | Login screen uses Arabic-first heading, no broken Google Sign-In, one clear sign-in path, one create-workspace path, no debug/auth jargon. |
| Restoring session state | Safe for Sprint 14B/14C mobile | App shows a calm restoring state during session restore and does not flash login for authenticated owner/staff. |
| Guided owner dashboard | Safe for Sprint 14B/14C mobile | Dashboard shows "prepare your restaurant" style checklist before metrics; Subscription remains hidden; no billing wording. |
| Role-specific workspace | Safe for Sprint 14B/14C mobile | Owner sees setup/menu/QR/loyalty/staff guidance; staff sees scanner-first path; roles are not guessed or mislabeled. |
| Business setup selectors | Safe for Sprint 14D mobile uploads/IQD UX | Business type, city, currency, and language are constrained choices; IQD is default for Iraq; no raw free-text currency. |
| Upload-from-device visual pattern | Safe for Sprint 14D mobile uploads/IQD UX | Logo, cover, and item image upload controls are primary; URL fallback is secondary/advanced only if retained. |
| Menu item card hierarchy | Safe for Sprint 14D mobile uploads/IQD UX | Item card shows image, Arabic name, price, availability, and edit state clearly at 390px; sold-out state is visible but not broken. |
| Template picker phone preview | Safe for Sprint 14B/14C mobile | Current, draft, preview, and save states are separate; preview copy does not expose query strings or implementation URLs. |
| Loyalty setup basic controls | Useful later / selective Sprint 14 | Name, stamp count, reward, and simple stamp icon are safe; broad color designer is deferred. |
| Staff scanner dark focus screen | Safe for Sprint 14B/14C mobile | Primary copy says scan customer card; invalid/wrong-business states stay staff-friendly; no token wording appears. |

## F) Customer-Web Implementation Candidates

| Candidate | Classification | Acceptance Criteria |
| --- | --- | --- |
| Food-first public menu hero | Safe for customer-web later | Logo, cover, category, and item hierarchy use real restaurant images gracefully; no horizontal overflow at 390px. |
| Sticky category navigation with active state | Safe for customer-web later | Active/current category is visible and touch-friendly; RTL remains usable. |
| Loyalty CTA in menu | Safe for customer-web later | CTA is integrated into menu, not an ad block; one primary action, one fallback. |
| Loyalty enrollment hierarchy | Safe for customer-web later | Short benefit copy, phone-first form, clear validation, device-aware wallet CTA after success. |
| Wallet handoff copy | Safe for customer-web later | Copy says wallet updates may sync shortly; live web card is source of truth; no instant refresh promise. |
| Loyalty card visual hierarchy | Safe for customer-web later | Progress, next reward, stamp slots, and wallet actions are primary; no token/card-ref wording. |
| Public error states | Safe for customer-web later | Public errors are friendly and generic; no API/internal wording; clear retry or home action. |
| QR print/share preview | Useful later | Only after QR generation/print rules are approved; never include QR payloads in docs/screenshots. |
| Marketing landing page | Useful later | Strong Arabic-first positioning is useful, but Sprint 14 is ops/product readiness, not a marketing-site sprint. |

## G) Out-Of-Scope Ideas

- Billing, Stripe, subscriptions, plans, or premium upsell.
- Cart/order/checkout/delivery/pickup features shown in some public-menu concepts.
- Full self-service hosted admin dashboard.
- Full localization v1 or Kurdish language support.
- Advanced card designer, color suite, stamp icon marketplace, or arbitrary theme editor.
- Media library, cropper, gallery, or asset manager.
- Template marketplace or downloadable preview assets.
- Location reminders as guaranteed notifications.
- New wallet signing/APNs/device-registration behavior.
- Any recovery flow that uses phone/email alone as authentication.

## H) Risks

| Risk | Severity | Mitigation |
| --- | --- | --- |
| Generated code copied directly | High | Rebuild using existing Flutter/Clean Architecture and customer-web CSS-first contracts. |
| Phone-only recovery reintroduced | High | Keep current secure recovery rules: old-device transfer or staff help, no phone/email unlock. |
| Fake wallet badges copied | High | Use official/platform-compliant wallet buttons already approved by product constraints. |
| QR imagery committed | High | Do not commit QR screenshots, mock QR payloads, or scanner images. |
| Remote generated image URLs copied | Medium | Use only merchant-uploaded or approved local/runtime assets. |
| Scope balloons into redesign | High | Split work into Sprint 14B/14C/14D acceptance-criteria slices. |
| Arabic copy becomes "full localization" | Medium | Keep limited Arabic-first pilot copy; full localization remains Sprint 15. |
| Cold Material palette replaces Waflo | Medium | Preserve Waflo core colors: `#FF6B4A`, `#101820`, `#FFF8F2`, `#FFFFFF`, `#1F2933`, `#6B7280`. |
| UI implies unsupported features | High | Remove cart, checkout, subscription, and broad self-service claims. |

## I) Recommended Next Implementation Slice

First finish the real Android smoke for the existing Sprint 14B Arabic guided shell branch. If it passes, the next implementation slice should be:

`codex/sprint-14c-mobile-owner-foundation-stitch-polish`

Goal:

- Apply only the safe mobile owner/staff decisions from the Stitch intake.
- Keep it mobile-only unless tests require mobile package changes.
- Do not implement uploads, broad designer controls, billing, customer-web, admin-web, API, OpenAPI, or schema changes.

Recommended 14C scope:

- Login/session restore visual hierarchy.
- Owner dashboard guided checklist hierarchy.
- Business setup copy/field grouping without new API behavior.
- Menu appearance picker hierarchy and preview explanation.
- Staff scanner copy/hierarchy cleanup.

Then Sprint 14D should handle:

- Upload-from-device primary flow.
- IQD price entry.
- city/currency/language selectors.
- menu item image/editing comfort.

## J) Design Acceptance Criteria For The Next Slice

### Global

- Uses existing Waflo palette and tokens, not raw Stitch colors unless already part of Waflo.
- Arabic-first critical copy appears on pilot-critical screens, but full i18n is not attempted.
- Touch targets are at least 48dp on Android mobile.
- Main actions have pressed/loading/disabled states.
- No screen exposes token, JWT, API, card ref, QR payload, recovery token, transfer token, database IDs, Clerk IDs, phone/email PII, or debug wording.
- No subscription, billing, Stripe, premium plan, or future-flow wording appears.
- No generated images, remote image URLs, or QR mock screenshots are committed.

### Login And Session Restore

- Login opens with an Arabic-first welcome and a clear reason to sign in.
- Existing workspace sign-in and create-workspace entry are visually distinct.
- Google Sign-In remains hidden unless real Clerk/native configuration is complete.
- Restoring session state appears before route decisions and avoids login flash for a valid session.
- Sign-out still clears session.

### Owner Dashboard

- Owner dashboard prioritizes a guided setup checklist over raw metrics.
- Checklist includes menu/products, QR/public menu, loyalty card, and staff/cashier guidance.
- Empty menu/business states explain the next action without making the business feel broken.
- Subscription quick action remains hidden.
- The UI does not claim merchant self-service is fully ready.

### Business Setup

- Inputs are grouped as business identity, location/contact, defaults, and media.
- Currency defaults to IQD where applicable.
- City/currency/language are presented as constrained choices when the current UI supports it; if not implemented in this slice, it is explicitly deferred to 14D.
- Logo/cover upload slots are shown only as planned/disabled if upload is not implemented in this slice.

### Menu Appearance

- Template cards use restaurant-language descriptions, not implementation IDs.
- Current template, selected draft, preview, and save states are visually separate.
- Preview copy says it opens the public menu without saving.
- Staff/no-permission users receive friendly permission copy.
- Existing `/m/:slug?previewTemplateId=<template-id>` behavior remains unchanged.

### Staff Scanner

- Staff entry says scan customer loyalty card, not token/manual token.
- Camera scanner is the primary mental model; manual entry is a fallback.
- Invalid, expired, wrong-business, offline, and permission states use staff-friendly language.
- Add stamp/redeem actions are visually distinct and large enough for counter use.
- Wallet update copy says live card updates online first and Wallet may sync shortly.

### Verification

- Flutter format/analyze/test/build pass.
- Manual Android smoke verifies owner and staff paths after app restart.
- Subscription remains hidden.
- Google Sign-In is not overclaimed.
- No sensitive text appears in UI or logs.
- Screenshots used for QA are sanitized and not committed.
