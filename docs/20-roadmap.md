# Roadmap

Do not start AI, loyalty, wallet integration, or custom domains before Sprint 1 and Sprint 2 acceptance criteria are done.

## Sprint 0: Foundation

Status: done.

Completed:

- Monorepo structure.
- API shell.
- Prisma schema.
- Customer web mock pages.
- Admin web mock pages.
- Flutter placeholder app.
- Docker Compose.
- Initial documentation.

## Sprint 1: Auth, Business, Menu, Public Menu

Goals:

- Clerk auth for business users and admins.
- Internal user sync.
- Business creation.
- Business membership and roles.
- Menu category CRUD.
- Menu item CRUD.
- Public menu API.
- Customer web consumes real public menu.
- Demo seed data.

Acceptance:

- Owner can sign in and create a business.
- Owner or manager can create categories and items.
- Staff cannot edit menu.
- Public menu route loads from API.
- Customer can browse without login.

## Sprint 2: QR, Images, Menu Polish, Stripe Basic/Pro

Goals:

- QR generation for public menu.
- Image upload foundation.
- Better menu UI.
- Stripe Basic and Pro checkout.
- Stripe webhook subscription updates.
- Subscription screen in Flutter.

Acceptance:

- Business can download a menu QR.
- Business can subscribe to Basic or Pro in Stripe test mode.
- Subscription state comes from webhook.
- Public menu supports images.

## Sprint 3: AI Pairings

Goals:

- AI pairing generation for existing menu items.
- Store pairings.
- Owner/manager approval flow.
- Customer web displays approved pairings.

Acceptance:

- AI never invents products.
- Unavailable items are not shown.
- Pairings can be approved or rejected.

## Sprint 4: Loyalty Core and Staff Scanner

Goals:

- Loyalty program model.
- Customer join flow from web.
- Customer card page.
- Staff scanner in Flutter.
- Loyalty transactions.

Acceptance:

- Customer can join without app download.
- Staff can scan card and apply allowed action.
- All actions create transactions.

## Sprint 5: Admin Dashboard Real Monitoring

Goals:

- Real business list.
- Real subscription list.
- Logs view.
- Business suspend/reactivate.
- AI and loyalty usage visibility.

Acceptance:

- Admin access is backend enforced.
- Sensitive admin actions are audited.

## Sprint 6: Production Hardening and Deployment

Goals:

- Staging.
- Production deployment.
- Backups.
- Logging.
- Error tracking.
- Rate limiting.
- Security review.

Acceptance:

- First paid business can safely onboard.
- Rollback and backup plans exist.

## Sprint 7: Wallet and Custom Domains

Goals:

- Apple Wallet and Google Wallet passes.
- Custom domain support.
- Advanced loyalty and analytics.

Acceptance:

- Wallet passes work for supported platforms.
- Custom domains are validated and secure.

## Sprint 11: Apple Wallet Visual and APNs Updates

Status: Sprint 11 closed with staff scanner runtime caveat.

Known caveat:
Real authenticated Flutter staff scanner E2E was not executed on a physical device/emulator. Local bloc/widget tests pass and backend/APNs pipeline passed through controlled DB script.

## Sprint 12: Launch Readiness, BTAQA Parity & Market-readiness

Status: Scope locked. Implementation not started.

Goal: Prepare Waflo for the first real restaurant pilot by adding market-readiness work, BTAQA visual parity, and safety safeguards, while preserving Waflo's restaurant-first differentiation.

Full scope: [21-sprint-12-launch-readiness.md](21-sprint-12-launch-readiness.md)

### Required Sprint 12 Structure

#### 1. Sprint 12A — Safety and Runtime
* **Fix unverified cross-device recovery security:** Hardens customer card token recovery against unauthorized access.
* **Real Flutter staff scanner E2E smoke:** Proves the authenticated staff Add Stamp scan workflow works end-to-end on a physical device/emulator.

#### 2. Sprint 12B — Premium Card Designer v1 (BTAQA Parity)
* **Owner can customize card color**
* **Upload/use logo**
* **Select stamp icon/template**
* **Select background/image/preset**
* **Preview Apple Wallet and Google Wallet**
* **Goal:** Produce card designs that look sellable, premium, and distinct, not developer demos.

#### 3. Sprint 12C — Bilingual Landing and Demo (BTAQA Parity)
* **Arabic/English landing page**
* **Features section** (QR menus + loyalty)
* **How it works**
* **Pricing placeholder or plan proposal**
* **Demo card carousel**
* **FAQ**
* **CTA for first pilot**

#### 4. Sprint 12D — Engagement MVP (BTAQA Parity)
* **Branch/location coordinates**
* **Apple Wallet relevant locations** (GPS coordinate tags)
* **Google Wallet merchant locations** if available
* **Inactive customer reminder rule** (automated push/email triggers)
* **Reward-ready reminder**
* **Notification throttling/frequency safety**

#### 5. Sprint 12E — Pilot Sales Kit
* **Printable QR/PDF kit**
* **First restaurant onboarding checklist**
* **Staff training checklist**
* **Owner demo script**
* **Pilot go/no-go checklist**

### Waflo Differentiation
* **Restaurant/cafe first:** Highly integrated table QR menu + Wallet loyalty together.
* **Iraq-first localized support:** Seamless Arabic/Kurdish/English localization for customers.
* **Local pricing & onboarding:** Tailored pricing/onboarding models optimized for local merchants.
* **Restaurant cashier workflow:** Custom cashier-friendly staff scanner workflow built to match high-volume POS situations.

### Out of Scope
* Loyalty v2 (multi-tier rewards, advanced analytics)
* Multi-branch v2
* Global pricing
* AI recommendations
* Custom domains
* Advanced analytics

### First Acceptance Gate
Staff scanner E2E smoke must pass before pilot restaurant onboarding begins.
