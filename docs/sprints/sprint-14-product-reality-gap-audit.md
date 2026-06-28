# Sprint 14 Product Reality Gap Audit

Date: 2026-06-28

Decision: PRODUCT_NOT_SELLABLE_CONFIRMED

Scope: audit only. No API code, OpenAPI, schema, customer-web, admin-web, mobile, wallet signing, scanner validation, auth/security, DNS, billing, Stripe, subscription, localization, or multi-branch implementation was changed.

## A) Executive Verdict

Waflo is technically capable enough for an internal realistic pilot, but it is not ready to show to a real Iraqi restaurant/cafe merchant as a paid or near-paid product.

The blocker is no longer just backend capability. The gap is product reality: the owner and staff experience does not yet feel confident, local, Arabic-first, or operationally polished enough for a merchant to trust the system with their menu, staff, and customer loyalty flow.

Sprint 14 must pause real merchant outreach until the P0 blockers below are fixed and verified on real Android devices and real customer-web routes.

## B) Why Product Is Not Merchant-Sellable Yet

The current experience can pass technical E2E tests while still failing the merchant trust test.

Key reality gaps:

- The owner app still feels like an internal tool rather than a restaurant owner product.
- Authentication feels unfinished because Google Sign-In is missing or not enabled and session persistence needs proof.
- English-only owner/staff UI is a sales blocker in Iraq.
- Dashboard and setup screens do not clearly answer: "Is my menu ready?", "What do I do next?", and "What will customers see?"
- Menu Appearance and Menu Management are not yet comfortable on mobile, even though the backend and template system work.
- The owner flow still has too many free-text inputs where merchants expect guided choices.
- Media upload exists technically, but owner mobile flows must make upload from device the primary path.
- Loyalty and customer card screens still carry too much explanation and not enough confidence.
- Security may be technically stronger than it looks, but the current UI does not make the protection feel obvious or trustworthy.

## C) P0 Blockers Before Merchant Demo

P0 means the issue blocks showing Waflo to a real merchant.

| Area | P0 Blocker | Required Fix | Owner Surface | Notes |
| --- | --- | --- | --- | --- |
| Authentication/session | Google Sign-In is missing or not enabled; normal session persistence is not proven. | Enable or hide Google Sign-In cleanly, verify owner/staff session persistence after app restart, and document whether the issue is Clerk configuration, mobile persistence, or both. | Mobile | A merchant should not see an unfinished login option or be forced through repeated sign-in during normal use. |
| Arabic-first pilot | Owner/staff/customer UI is English-first. | Add a limited Arabic pilot copy pack for critical screens, or pull forward a scoped Sprint 15 Arabic-first subset. | Mobile/Web | Full Kurdish/Sorani/Badini localization remains out of scope; Arabic pilot readiness is not optional for Iraq. |
| Dashboard | Dashboard feels visually dead and shows readiness metrics that can confuse a merchant. | Redesign hierarchy around "Your menu is live", "Edit menu", "Scan loyalty", and "What customers see"; hide misleading zero-state readiness metrics until meaningful. | Mobile | Metrics should not make a newly created business feel broken. |
| Subscription/billing | Subscription UI appears before billing is active. | Hide or mark as unavailable internally; do not show subscription as an owner-facing action in Sprint 14. | Mobile/Admin | Billing belongs to Sprint 16. Showing it now damages trust. |
| Menu Appearance | Template cards and preview feel awkward on mobile. | Redesign mobile template selection cards, current/draft/save states, and preview explanation while preserving safe preview behavior. | Mobile | Preview must remain non-persistent until save. |
| Menu Management | Add category/add item flows feel unprofessional. | Group fields visually, add stronger validation, show save state clearly, and make the next action obvious. | Mobile/Admin | This is the merchant's daily workflow. It must feel calmer than a data form. |
| Price input | Price entry is not Iraq-friendly. | Default to IQD and support fast thousands entry without confusing decimals. | Mobile/Admin | Owner should not fight the currency input while entering a menu. |
| Business workspace | City, currency, and language are free text or insufficiently guided. | Use dropdowns/selectors for city, currency, and language; default currency to IQD for Iraq. | Mobile/Admin | Guided choices reduce errors and feel professional. |
| Media upload | Logo, cover, and item images must be upload-from-device first. | Make device upload the primary owner path; keep URL fields as advanced/fallback only. | Mobile/Admin | Media Upload API exists; the owner flow must expose it naturally. |
| Loyalty tools | Loyalty program editing is too limited and visually weak. | Clean hierarchy, show plain loyalty setup, and expose only safe pilot controls for card appearance/stamp style/theme. | Mobile/Admin/Web | Do not promise location reminders as guaranteed notifications. |
| Customer loyalty copy | Enrollment/recovery text is too long and exposes future-flow/internal concepts. | Shorten copy, make "old device transfer", "lost access", and "join with different phone" feel simple and secure. | Customer-web | No technical wording should appear. |
| Customer card visual | Live card still feels placeholder-like in some states. | Improve card hierarchy, progress, reward state, and empty/fallback visuals using existing Waflo colors. | Customer-web | The card should feel rewarding, not like an internal metrics panel. |
| Public menu QA | Public menu still needs real Arabic/image phone QA. | Test all chosen pilot templates with real Arabic content, real images, and 390px phone viewport. | Customer-web | Determine whether remaining issues are template-specific or global CSS. |
| Security confidence | The user does not yet trust the protection. | Add a concise internal security confidence note and avoid exposing implementation details in UI. | Docs/UI | The product should feel safe without showing secrets or technical terms. |

## D) P1 Improvements After First Demo

P1 means the issue improves merchant confidence, but can follow the first controlled demo if P0 is done.

| Area | P1 Improvement | Why It Matters |
| --- | --- | --- |
| Owner setup progress | Replace raw readiness counts with a simple setup checklist. | Helps owner understand what remains before QR printing. |
| Template mood labels | Explain each template in restaurant language. | Owners choose by feeling, not implementation names. |
| Save/publish feedback | Add clearer "saved", "live", and "preview only" states. | Reduces fear of accidentally changing the public menu. |
| Staff scanner guidance | Add clearer first-use camera permission and invalid-card recovery copy. | Staff training becomes easier. |
| Loyalty appearance controls | Add small safe style controls for card/stamp feel. | Merchants expect their loyalty card to match their brand. |
| Customer web card fallback | Improve missing-image and no-card states further. | Makes edge cases feel intentional. |
| Accessibility pass | Review focus order, tap targets, and color contrast on critical flows. | Quality and usability improve without new product scope. |

## E) Deferred Items

P2 means defer unless a real merchant demo proves it is blocking.

- Full localization v1 across all screens.
- Kurdish/Sorani/Badini support.
- Template marketplace.
- Advanced color/theme designer.
- Media library, cropper, gallery, or asset manager.
- Billing, Stripe, subscriptions, invoices, and entitlements.
- Multi-branch business support.
- Loyalty v2.
- Location reminders as a promised notification system.
- Hosted admin dashboard implementation unless merchant self-service becomes required.
- Visual regression automation and full accessibility automation.

## F) Screens/Routes Reviewed

Evidence source:

- Real-device Android review notes from the owner.
- Current Sprint 13/Sprint 14 closeout docs.
- Existing Waflo UI/UX principles and prior reality audit.
- Current route and feature inventory from the repository.

Screens and routes in audit scope:

- Mobile authentication and session entry.
- Mobile owner dashboard.
- Mobile business setup/workspace.
- Mobile Menu Appearance/template picker.
- Mobile Menu Management category/item flows.
- Mobile loyalty tools and staff scanner entry points.
- Public menu: `/m/:slug`.
- Public loyalty enrollment: `/m/:slug/loyalty`.
- Public loyalty card: `/m/:slug/loyalty/card`.
- Public preview flow: `/m/:slug?previewTemplateId=<template-id>`.
- Admin/local owner setup surfaces where used for pilot setup.

Do not commit screenshots to this repo. If screenshots are used for implementation, store them privately with QR codes, tokens, customer data, upload URLs, and merchant PII covered or redacted.

## G) Recommended Implementation Order

Work in small branches. Do not combine all P0 fixes into one risky rewrite.

1. `codex/sprint-14-auth-session-p0`
   - Verify Google Sign-In state.
   - Fix or hide unfinished Google Sign-In.
   - Verify owner/staff session persistence after app restart.

2. `codex/sprint-14-arabic-pilot-copy-p0`
   - Add limited Arabic-first copy for login, dashboard, scanner, menu setup, loyalty enrollment, and key customer states.
   - Do not attempt full localization v1.

3. `codex/sprint-14-mobile-owner-foundation-p0`
   - Dashboard hierarchy cleanup.
   - Hide subscription.
   - Business workspace selectors for city/currency/language.
   - IQD default and Iraq-friendly price input.

4. `codex/sprint-14-mobile-menu-management-p0`
   - Redesign mobile category/item entry hierarchy.
   - Make device image upload primary.
   - Improve validation and save states.

5. `codex/sprint-14-mobile-menu-appearance-p0`
   - Redesign template cards, preview, selected state, and save flow.
   - Preserve safe preview behavior.

6. `codex/sprint-14-loyalty-customer-copy-p0`
   - Shorten customer loyalty/recovery copy.
   - Improve customer card progress/reward placeholders.
   - Verify no technical words appear.

7. `codex/sprint-14-real-content-qa-p0`
   - Real Arabic menu content.
   - Real images.
   - Real Android owner/staff smoke.
   - Public customer phone QA.

## H) Managed Setup Vs Self-Service SaaS Decision

Sprint 14 must choose a pilot operating model before any merchant demo.

Recommended decision for first controlled pilot:

- Use managed setup by the Waflo team.
- Keep hosted admin dashboard deferred.
- Use local admin/owner tools only with internal operators.
- Do not ask the merchant owner to self-manage until the owner mobile/admin experience passes the P0 fixes.

Self-service SaaS becomes acceptable only if:

- Hosted admin dashboard exists or mobile owner app fully covers setup.
- Arabic-first owner/staff copy is ready.
- Upload, menu editing, template selection, and loyalty setup feel merchant-safe.
- Support and rollback paths are ready.

## I) Risks If Ignored

If Waflo is shown to a real merchant before P0 fixes:

- Merchant may judge the product as unfinished even if the backend works.
- English-only flows may create immediate sales friction in Iraq.
- Repeated or confusing login may reduce trust before the demo starts.
- Free-text currency/city/language fields may create obvious setup mistakes.
- Weak menu item/media entry may make onboarding feel slow and manual.
- Subscription/billing UI may create awkward commercial questions before Sprint 16.
- Long loyalty recovery copy may make customers feel blocked or unsafe.
- Security perception may remain low even if actual token protection is strong.
- The team may collect money before it has a supportable pilot operating model.

## J) Files Likely Affected In Implementation Branches

Likely mobile files:

- `apps/mobile/lib/features/auth/`
- `apps/mobile/lib/features/dashboard/`
- `apps/mobile/lib/features/business_setup/`
- `apps/mobile/lib/features/menu_appearance/`
- `apps/mobile/lib/features/menu_management/`
- `apps/mobile/lib/features/staff_scanner/`
- `apps/mobile/lib/shared/widgets/`

Likely customer-web files:

- `apps/customer-web/app/m/[slug]/loyalty/LoyaltyEnrollmentClient.tsx`
- `apps/customer-web/app/m/[slug]/loyalty/card/LoyaltyCardClient.tsx`
- `apps/customer-web/app/components/PublicMenuTemplateView.tsx`
- `apps/customer-web/app/styles/public-menu-contract.css`
- `apps/customer-web/app/styles/menu-templates/*.css`
- `apps/customer-web/tests/`

Likely admin/local setup files if managed setup remains in use:

- `apps/admin-web/app/components/OwnerWorkflowPanel.tsx`
- `apps/admin-web/app/lib/admin-api.ts`
- `apps/admin-web/app/globals.css`

Likely docs/runbook files:

- `docs/sprints/sprint-14-paid-readiness-minimum-ops-plan.md`
- `docs/runbooks/first-restaurant-pilot-api-checklist.md`
- `docs/design/waflo-ui-ux-principles.md`

## K) Security Confidence Notes

Documented guarantees from prior closeouts that should be revalidated before demo:

- Staging must not allow dev auth.
- Raw tokens must not appear in UI or logs.
- Customer phone/email must not be printed in reports.
- Owner, manager, and staff roles must enforce different permissions.
- Media upload must validate file type and size.
- Wallet scan validation must reject malformed and wrong-business codes.
- Phone-only and email-only recovery must remain blocked.
- Add-device transfer must stay short-lived, single-use, and not based on staff/cashier QR.

Current gap:

- No new confirmed data leak is identified by this audit.
- The bigger issue is confidence: rough UI, technical wording, and unfinished flows make protection feel less trustworthy than it may actually be.

## L) Closeout Gate For This Audit

This audit can close when:

- The P0 list is accepted by the owner.
- Implementation branches are created in the recommended order.
- No merchant outreach or paid-readiness execution starts before P0 completion.
- Real-device review evidence remains private and redacted.
