# Waflo V2 Product Vision

Status: `PLANNED` product authority for the Mobile-first loyalty reset.
Inputs: verified Phase 0 audit, existing product doctrine, and the 2026-07-23
Waflo V2 decisions.

## Product definition

Waflo V2 is an Arabic-first, Mobile-first loyalty platform for Iraqi
restaurants and service businesses. It lets a business design a loyalty
program, issue a wallet card without forcing a customer app install, operate
earning and redemption at the counter, and understand the resulting customer
activity with a defensible audit trail.

Waflo V2 is not a stamp-card skin and is not a Web Dashboard redesign. Stamps
are one earning method inside a domain that also supports visits, points,
spend-based points, product/service rules, tiers, referrals, occasions,
cashback, and future hybrid programs.

## Problem

Small Iraqi businesses need a repeat-customer system that is:

- usable from a phone during real operations;
- Arabic-first and clear under time pressure;
- deployable to customers without another app download;
- flexible enough for different earning and reward strategies;
- brandable without changing financial/loyalty truth;
- secure across businesses, roles, wallets, scanners, and retries;
- honest about offline, billing, and provider limitations.

The current product proves several foundations but couples the loyalty model to
`stampGoal`, `stampCount`, and a single reward-ready flag. It also has unresolved
customer tenant ownership, no Branch entity, no complete multi-business
selector, incomplete Billing, and multiple Flutter UI generations.

## Users and value

| User | Primary value | Product boundary |
| --- | --- | --- |
| Owner | Configure business, branches, loyalty programs, rewards, card design, team, and reports | Full authorized merchant experience in Flutter |
| Manager | Operate and manage delegated programs/customers/staff within business policy | No ownership, billing, or destructive account controls unless explicitly granted |
| Staff | Scan/search, record amount or product, earn, redeem, and see recent operations | Focused operational UI; no configuration or owner settings |
| Customer | Join quickly, hold a live card, understand progress, and redeem | Lightweight Customer Web plus Apple/Google Wallet; no Waflo app required |
| Platform operator | Support, safety, diagnostics, and tenant-safe administration | Internal platform tooling only; not the merchant's main dashboard |

## Product surfaces

### Merchant Mobile App — primary administration surface

One Flutter application serves Owner, Manager, and Staff. Navigation and
actions are derived from authoritative membership and permission data. The app
must not infer a workspace or role from list position.

The canonical top-level intent is:

1. Home.
2. Loyalty Programs.
3. Scan.
4. Customers.
5. More.

Focused creation/editing screens do not retain bottom navigation. Staff gets a
simplified operational shell rather than a partially hidden owner dashboard.

### Customer Web — required customer surface

Customer Web owns join, verified recovery/transfer, live card fallback, wallet
handoff, terms, and any required customer-facing QR destination. It stays fast
and app-install-free.

### Platform Backend — authority

NestJS/PostgreSQL own authentication verification, membership, tenant
isolation, program rules, ledger, entitlement, idempotency, redemption, wallet
state, audit, rate limits, and billing enforcement. Client-side hiding is never
authorization.

### Admin Web — internal/legacy boundary

The existing Admin Web may remain for internal platform work or as a source of
reusable API patterns. It is not the primary merchant product and must not
drive Waflo V2 architecture. Mock billing/admin data is never product truth.

This decision supersedes the older `Web Studio-first` merchant-ownership rule
in `WAFLO_PRODUCT_SURFACE_SPLIT_V1.md` for Waflo V2. The old document remains
preserved as historical product context.

## Core product journey

```text
Account → Business → Branch → Loyalty goal → Program type
→ Earning rules → Reward → Card design and wallet previews
→ Staff invite → Join QR/poster → Customer join → Wallet card
→ Scan/search → Visit/purchase/product evidence → Earn
→ Reward entitlement → Redemption → Reports and audit
```

Each step is backed by real state. A loading failure is not an empty state, a
local optimistic state is not backend success, and an unavailable action is
disabled or omitted with an honest explanation.

## Loyalty model promise

Waflo separates four concerns:

1. `Earning Rule`: what customer behavior creates value.
2. `Reward Definition`: what value the customer can receive.
3. `Eligibility`: when a membership earns a reward entitlement.
4. `Redemption`: how an entitlement is consumed and fulfilled.

V1 implements:

- Stamp/Visit Program.
- Fixed Points Program.
- Spend-based Points Program.
- Product or Service-based Program.
- Free product/service, percentage discount, fixed-amount discount, and custom
  rewards.

The model must allow future tiers, referrals, welcome/birthday bonuses,
cashback/store credit, memberships, subscriptions, and hybrid programs without
rewriting the core ledger.

## Card Customization Studio

Card Customization Studio is a first-class merchant capability inside Flutter,
not a cosmetic field attached to `LoyaltyProgram`.

### V1 baseline customization

The merchant can:

- set logo and cover/hero image through real media upload;
- select primary, secondary, background, and text colors within accessible
  constraints;
- select stamp shape and icon for stamp programs;
- configure reward imagery/icons;
- customize the Customer Web join page and QR poster presentation;
- preview provider-aware Apple Wallet and Google Wallet representations;
- save and reuse a bounded base design template.

V1 preview must clearly distinguish a deterministic local preview from a
provider-confirmed live card. Publishing succeeds only after the backend saves
the design and required provider sync is queued/confirmed according to the
provider contract.

### Seasonal Theme Engine

The architecture supports Ramadan, Eid, New Year, Birthday, Black Friday,
business anniversary, and merchant-defined occasions.

A seasonal theme is a `Visual Theme`, not a loyalty program and not an earning
campaign. It can target one or more programs and has:

- `startAt` and `endAt` in an explicit business timezone;
- `DRAFT`, `SCHEDULED`, `ACTIVE`, and `EXPIRED` lifecycle;
- preview-before-publish;
- automatic activation and deactivation;
- deterministic fallback to the base design after expiry;
- no ability to mutate balances, earning rules, reward eligibility, or
  redemption state.

Advanced scheduling, reusable seasonal template libraries, conflict
resolution, and bulk multi-program publishing are V1.5 if they threaten the V1
release gate. The domain seams and provider-neutral presentation model are
required in V1 so V1.5 does not require a redesign.

## Program, Campaign/Event, and Visual Theme are separate

| Concept | Owns | Must not own |
| --- | --- | --- |
| Loyalty Program | membership, earning rules, reward definitions, eligibility policy | Seasonal visuals or calendar campaign messaging |
| Campaign/Event | bounded promotional trigger, audience, dates, bonus/communication intent | Base program balance or provider card presentation |
| Visual Theme | brand assets, colors, icons, join/poster/wallet presentation, schedule | Earning, balances, entitlements, or redemption |

A birthday campaign may grant bonus points and select a birthday visual theme,
but those are two referenced objects with independent lifecycle and audit.

## Mobile-first principles

- Arabic and RTL are the default design condition, not a translation pass.
- Sorani Kurdish is RTL; English is LTR.
- One clear primary action per step.
- 48dp minimum touch targets and safe-area-aware layouts.
- Loading, empty, error, offline, permission, disabled, and success states are
  designed explicitly.
- Offline reads may show clearly labeled cached data; value mutations do not
  claim success before backend confirmation.
- Owner, Manager, Staff, Customer, and Platform roles remain distinct.
- Unsupported Growth Menu, billing, notification, wallet, media, or campaign
  actions are omitted or disabled honestly.

## Waflo Loyalty vs Waflo Growth Menu

| Product | V1 role | Data boundary |
| --- | --- | --- |
| Waflo Loyalty | Core Waflo V2 product | Programs, customers, ledger, rewards, wallet, scanner, customization, reporting |
| Waflo Growth Menu | Future independent package | Menu/catalog, presentation, AI recommendations, growth automation |

Existing menu features remain preserved and may later provide product/service
references to earning rules. They do not dictate the loyalty architecture and
are not deleted in V1.

## Product success measures

V1 success is measured by verified journeys, not screen count:

- a new owner can reach an active program and real join QR from a phone;
- a customer can join and add a card without installing Waflo;
- a staff member can safely record an eligible action exactly once;
- reward entitlement and redemption are explainable from the ledger and audit;
- no query or UI state leaks customer data across businesses;
- card design changes never change loyalty value;
- wallet/provider failure leaves a truthful web-card fallback;
- Arabic/RTL and role-specific flows pass human acceptance on target devices.

## Non-negotiable human gates

Human approval is required for visual acceptance, migration execution, merge,
deployment, live financial actions, customer notifications, provider-store
submission, and pilot launch. Phase 0 makes no such approval claim.
