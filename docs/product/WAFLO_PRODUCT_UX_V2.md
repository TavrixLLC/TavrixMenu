# Waflo Product UX V2 Blueprint

Status: source of truth for UI/UX V2 reset.

This document defines the product experience Waflo must become before any new UI implementation begins. It is not an implementation plan for auth, backend, billing, or database changes. It is a product and UX blueprint for rebuilding the mobile owner experience and related surfaces from a clean visual foundation.

## 1. Product Promise

Waflo is a premium restaurant SaaS for Iraq.

It helps restaurant owners launch a QR digital menu, customize how customers see that menu, manage loyalty, add staff access, and later manage paid subscriptions. Waflo should feel like a focused business tool made for restaurants, not a generic admin panel.

The promise to a restaurant owner:

- Create a professional digital menu quickly.
- Show customers a clean web menu from a QR code without app download.
- Manage food categories, products, prices in IQD, images, and menu appearance.
- Give staff a limited scanner workflow for loyalty operations.
- Activate loyalty when the restaurant is ready.
- Understand subscription value before being asked to pay.

## 2. Core Principle

Do not polish the old UI.

Do not reuse the old admin-panel visual language. Treat the current UI as disposable. Reuse only the existing foundations that represent real product capability:

- Business logic.
- API integration.
- Auth/session foundations.
- Menu management foundations.
- Loyalty foundations.
- Staff scanner foundations.
- Billing foundations when they are explicitly scoped.

UI/UX V2 must be rebuilt as a premium restaurant SaaS experience from the product story outward. The old layout, card style, navigation assumptions, and dashboard structure are not the starting point.

## 3. User Roles

### Platform Owner / Waflo Team

What they want:

- See Waflo become sellable to Iraqi restaurants.
- Keep product quality, safety, auth, billing, and rollout discipline under control.
- Review staging-safe builds before commits.
- Avoid fake features, demo-only flows, or broken promises.

What they should see:

- Internal documentation, safety reports, staging APK handoffs, and product status.
- Clear sprint boundaries.
- Honest notes about what is real, what is staged, and what is blocked.

What they must not see:

- Hidden secrets in docs or diffs.
- Fake billing, fake Google auth, fake uploads, fake scanner success, or demo-only data presented as product.
- AI commits without human visual review.

### Restaurant Owner

What they want:

- Launch a customer menu fast.
- Make the menu look professional.
- Add products, images, categories, and prices in IQD.
- Share a QR code with customers.
- Add staff for daily operations.
- Use loyalty to bring customers back.
- Understand subscription plans when value is clear.

What they should see:

- Arabic-first RTL owner app.
- A guided setup path with clear next actions.
- Restaurant-focused language and visuals.
- Menu, QR, staff, loyalty, and settings surfaces that feel connected.
- Honest empty states that explain the next useful action.

What they must not see:

- Developer wording, internal config names, raw API errors, or technical auth language.
- Admin-panel clutter.
- Features that look enabled but do not work.
- Google Sign-In unless it is real, configured, implemented, and tested.
- Staff-only scanner shortcuts from unauthenticated owner login.

### Staff / Cashier

What they want:

- Open a simple scanner flow.
- Scan a loyalty card or enter a code.
- Know whether the scan succeeded or failed.
- Return to the next customer quickly.

What they should see:

- Only the staff scanner flow and any minimal account/logout controls required.
- Clear success, failure, and retry states.
- No owner dashboard complexity.

What they must not see:

- Menu editing.
- Business settings.
- Billing.
- Owner subscription prompts.
- Platform/admin tools.

### Customer

What they want:

- Scan a QR code and see the restaurant menu instantly.
- Browse categories and products.
- Understand prices in IQD.
- See product details and images when available.
- Use loyalty if the restaurant offers it.

What they should see:

- A fast web menu without app download.
- Restaurant branding and menu appearance chosen by the owner.
- Clear categories, products, prices, descriptions, and images.
- Simple loyalty entry points if enabled.

What they must not see:

- Owner admin screens.
- Staff scanner tools.
- Billing prompts.
- App setup complexity.
- Broken upload placeholders or fake food images.

## 4. Restaurant Owner Story

The owner journey starts with first launch and ends with a restaurant that can sell through a polished QR menu.

1. First launch
   The owner opens Waflo and immediately understands the product: a premium way to launch and manage a restaurant QR menu in Iraq.

2. Sign in / create account
   The owner can sign in to an existing workspace or create a new account. Auth UI is clean, Arabic-first, and trust-building. No dev auth appears. Google does not appear unless fully working.

3. Create restaurant workspace
   The owner starts a new restaurant workspace with a guided, short setup.

4. Enter restaurant name/type
   The owner enters the restaurant name and selects or enters the type, such as cafe, fast food, casual dining, bakery, sweets, or other local restaurant category.

5. Select menu template
   The owner chooses a customer menu appearance template. The choice should feel like selecting a public restaurant style, not changing an admin theme.

6. Add first category
   Waflo prompts the owner to create the first category, for example mains, drinks, breakfast, desserts, or offers.

7. Add first product
   Waflo prompts the owner to add the first product with name, category, price, description, and optional image.

8. Add price in IQD
   Price entry must be clear and localized for Iraqi dinar. The UI should prevent confusion around decimals, currency symbols, or unsupported currencies.

9. Add product image when available
   Product images should be supported only when real upload exists. If image upload is not available in a given phase, the UI must be honest and neutral. No mock food images and no fake upload promises.

10. Preview customer menu
   The owner sees the menu as a customer would see it. Preview must clearly show categories, product cards, prices in IQD, images if present, and the selected appearance template.

11. Publish menu
   Publishing should feel like moving from setup to live customer use. The owner should understand whether the menu is public, draft, or needs more setup.

12. Download/share QR
   The owner can access a QR code for the restaurant menu and share/download it when the public menu is ready.

13. Dashboard guided setup
   The dashboard should not be a statistics dump on first launch. It should guide the owner through remaining setup tasks: menu basics, preview, QR, staff, loyalty, and subscription readiness.

14. Add staff
   The owner can invite or create staff access for scanner use. Staff permissions must be limited and clear.

15. Activate loyalty
   The owner can understand what loyalty does, configure baseline rewards if available, and enable it only when real functionality is ready.

16. Manage subscription later
   Billing appears when value is clear. The owner should see plans and benefits, but onboarding should not be blocked too early unless the business model explicitly requires it.

## 5. Customer Story

The customer journey must be simpler than the owner journey.

1. Scan QR
   The customer scans the restaurant QR code from a table, counter, poster, receipt, or social post.

2. Open web menu without app download
   The customer opens a public web menu directly. No app install is required.

3. Browse categories/products
   The customer can browse restaurant categories and product lists quickly.

4. See IQD prices
   Prices are shown clearly in Iraqi dinar. Formatting must be consistent and readable.

5. View product details/images
   Product detail states should support descriptions and images when available. Missing images should use honest neutral placeholders, not fake food images.

6. Use loyalty card if available
   If loyalty is enabled, the customer can understand how to use it. If loyalty is disabled, there should be no fake loyalty promise.

7. Avoid owner/admin complexity
   Customers never see admin settings, owner setup, staff scanner controls, billing, or internal system language.

## 6. Staff Story

The staff journey is intentionally narrow.

1. Owner creates staff access
   The restaurant owner creates staff access from staff management.

2. Staff gets invite/PIN/link
   Staff access may be delivered through an invite, PIN, or link, depending on implementation phase. The method must be real and secure for the current phase.

3. Staff sees only scanner flow
   Staff enters a limited scanner experience. It should not expose menu editing, restaurant setup, billing, or owner settings.

4. Staff scans loyalty card
   Staff scans a customer loyalty card or enters a code through the same safe scanner flow.

5. Staff sees success/failure
   The result is clear, fast, and safe: success, invalid code, already rewarded, permission issue, network error, or retry state.

6. Staff cannot edit menu/settings/billing
   Permission boundaries must be visible in the UX and enforced by product logic. Staff should never feel like a partial owner.

## 7. Billing Story

Billing is a future subscription UX and must be handled honestly.

### Trial/value-first approach

Waflo should show value before forcing payment. Owners should be able to understand the product by creating a workspace, building enough of a menu, previewing it, and seeing why Waflo matters.

### Plans

Plans should be presented as:

- Basic: simple QR menu and essential menu management.
- Pro: deeper customization, loyalty, staff tools, and growth features.
- Premium: advanced appearance, larger operations, priority support, and future premium capabilities.

Exact entitlements must match backend and billing implementation. Do not invent plan benefits in UI unless they are implemented or explicitly staged as future.

### Billing screen requirements

- Arabic-first plan names, benefits, and price explanations.
- Clear current plan and trial state.
- Clear upgrade and downgrade paths when implemented.
- Clear renewal, cancellation, and payment method behavior.
- Stripe-backed actions only when real.
- No hidden fees.

### Upgrade prompts

Upgrade prompts must be honest. They should explain the benefit and what is locked. They must not pretend a disabled feature is active.

### No fake billing UI

No fake checkout, fake active subscription, fake invoices, fake payment methods, or fake Stripe status. If billing is staged, the UI must say it is being prepared or hide the flow until ready.

### Do not block basic onboarding too early

The owner should not hit a paywall before understanding Waflo's value unless the business decision explicitly scopes that behavior.

## 8. UI/UX V2 Principles

- Arabic-first.
- RTL always.
- Premium SaaS, not generic dashboard.
- Restaurant-focused in language, hierarchy, and visual choices.
- Warm Waflo colors.
- Clear hierarchy: primary action, secondary action, supporting details.
- No clutter.
- No English except the Waflo brand and unavoidable technical necessities.
- No developer wording.
- No fake features.
- No fake Google button.
- No Google "coming soon".
- No fake upload action.
- No fake billing.
- No mock/random food images.
- Empty states must teach the next action.
- Every screen must answer: what do I do next?
- Every important flow must have loading, empty, success, failure, and retry states where relevant.
- Mobile owner UI must feel intentional on a real phone, not like a resized web admin panel.

## 9. Design Reset Rules for AI

These rules apply to Codex, Antigravity, DeepSeek, and any other AI agent working on Waflo UI/UX V2.

- Do not preserve old layout.
- Do not reuse old dashboard structure.
- Do not reuse old login structure.
- Do not reuse old bottom nav blindly.
- Do not polish old AppCard/admin visual style.
- Do not make a generic admin dashboard.
- Do not add broad redesigns inside auth, backend, API, billing, or scanner work unless explicitly scoped.
- Build UI V2 patterns from scratch.
- Preserve business logic only.
- Preserve existing API/auth/menu/loyalty/scanner foundations unless a sprint explicitly scopes backend changes.
- Keep visual work separate from auth/security work.
- Keep Google auth paused until the Clerk/Google configuration mismatch is resolved and retested.
- Human visual review is required before commit.
- Codex safety guard is required before staging acceptance.
- No commit before human PASS.

## 10. Screen Inventory V2

Required V2 screens:

- Welcome / auth.
- Owner onboarding.
- Workspace setup.
- Dashboard guided setup.
- Menu builder.
- Category manager.
- Product add/edit.
- Menu appearance/templates.
- Customer menu preview.
- QR publish/share.
- Loyalty dashboard.
- Staff management.
- Staff scanner.
- Business profile/settings.
- Billing/subscription.
- Account/logout.

Each screen must define:

- Primary user role.
- Primary next action.
- Empty state.
- Loading state.
- Error state.
- Permission boundaries.
- What must not appear on that screen.

## 11. Implementation Phases

### V2-0 Blueprint

Define the product promise, journeys, screen inventory, design reset rules, phases, and acceptance criteria.

### V2-1 Design System

Create the visual foundation for Waflo V2: typography, color, spacing, radius, elevation, buttons, fields, cards, badges, empty states, banners, navigation patterns, and RTL behavior.

### V2-2 App Shell/Nav

Define the mobile app shell and navigation model from scratch. Do not blindly reuse the old bottom nav. Navigation must support owner, staff, and setup contexts without exposing the wrong tools.

### V2-3 Owner Onboarding

Build the first-launch and workspace setup journey: account entry, restaurant name/type, initial template, first category, first product, and setup progress.

### V2-4 Dashboard Guided Setup

Build a restaurant owner dashboard that teaches the next action instead of showing generic panels. It should reflect setup progress, menu status, QR readiness, staff, loyalty, and subscription readiness.

### V2-5 Menu Builder/Product Editor

Rebuild menu management around restaurant workflows: categories, products, IQD prices, image state, availability, edit flow, and honest upload behavior.

### V2-6 Customer Preview/QR

Build the customer menu preview and QR publish/share experience. Preview must reflect the real customer web menu as closely as possible.

### V2-7 Staff/Scanner

Build staff management and scanner experience with strict permission boundaries. Staff scanner must stay focused and cannot become an owner dashboard.

### V2-8 Loyalty

Build loyalty dashboard, status, setup, customer card visibility, scan outcomes, and honest disabled states if a capability is not ready.

### V2-9 Billing/Stripe

Build subscription UX when Stripe-backed behavior is ready. Plans, checkout, invoices, trial state, and upgrade prompts must be real and honest.

## 12. Acceptance Criteria

Every phase must satisfy these criteria before commit:

- Human visual review required.
- Codex safety guard required.
- No commit before human PASS.
- Staging-safe APK required for mobile UI phases.
- No dev auth.
- No fake features.
- No fake Google button.
- No fake upload.
- No fake billing.
- No backend drift unless explicitly scoped.
- No auth/Clerk/Google changes unless explicitly scoped.
- No secrets, tokens, local config, `.env`, real Dart define files, or PII in diffs.
- No `git add .`.

### V2-0 Blueprint Acceptance

- Product promise is clear.
- Role journeys are defined.
- Reset rules are explicit.
- Screen inventory and phases are complete.
- No app code changed.

### V2-1 Design System Acceptance

- Design tokens and components are V2-specific.
- Arabic/RTL behavior is verified.
- Components support loading, disabled, error, and empty states.
- Old admin-panel styling is not the foundation.

### V2-2 App Shell/Nav Acceptance

- Navigation matches real roles and workflows.
- No unauthenticated staff scanner path from owner login.
- Owner and staff surfaces are separated.
- Bottom navigation is used only if it fits the V2 model.

### V2-3 Owner Onboarding Acceptance

- Owner can start and understand workspace setup.
- Next action is always clear.
- Auth logic is not changed unless scoped.
- Google remains hidden unless real and approved.

### V2-4 Dashboard Guided Setup Acceptance

- Dashboard is not a generic admin panel.
- It guides setup and live operations.
- It explains menu, QR, staff, loyalty, and subscription readiness.

### V2-5 Menu Builder/Product Editor Acceptance

- Owner can manage categories and products.
- IQD price entry is clear.
- Image behavior is honest.
- No mock food images.
- No fake upload promise.

### V2-6 Customer Preview/QR Acceptance

- Preview is customer-oriented.
- QR publish/share flow is clear.
- Customer menu complexity is hidden from owner setup screens.

### V2-7 Staff/Scanner Acceptance

- Staff sees only scanner workflow.
- Scan states are safe and clear.
- Staff cannot edit owner settings, menu, or billing.

### V2-8 Loyalty Acceptance

- Loyalty state is understandable.
- Enabled, disabled, empty, success, and failure states are honest.
- No fake rewards or fake card status.

### V2-9 Billing/Stripe Acceptance

- Stripe-backed behavior is real.
- Plans and upgrade prompts are honest.
- No fake checkout, fake invoices, or fake payment method state.
- Billing does not block basic onboarding too early unless explicitly decided.

## 13. Definition of Sellable MVP

Waflo is not sellable until these are true:

- Owner can create and manage a restaurant workspace.
- Owner can build and edit a menu.
- Public customer menu looks good and is Arabic/RTL acceptable.
- QR code opens the correct public menu.
- Owner understands what to do from the dashboard.
- Staff scanner works with clear permission boundaries.
- Loyalty baseline works or is honestly disabled.
- Billing/subscription is ready or clearly staged without fake UI.
- No broken Google button.
- No fake upload.
- No mock food images.
- Arabic UI is acceptable to Iraqi restaurant owners.
- Staging-safe APK passes Codex safety guard.
- Human visual review passes before commit.

## Final Guardrail

If a future implementation starts by polishing the existing UI, it is the wrong sprint. Stop, return to this blueprint, and rebuild from the Waflo V2 product story.
