# Waflo V2 V1 Scope

Status: `PLANNED`. V1 is a secure, sellable loyalty loop; it is not the full
future loyalty catalog.

## V1 outcome

A business can onboard from Flutter, create at least one branch and one loyalty
program, customize a base card design, invite authorized staff, publish a real
customer join destination, issue a web/wallet card, record eligible activity,
earn value, create a reward entitlement, redeem it once, and see the operation
in customer history, reporting, and audit.

## Included in V1

### Account, tenant, and team

- Clerk-backed owner sign-in and session recovery.
- Business creation and authoritative workspace selection.
- First-class Branch creation; single-branch businesses still receive an
  explicit branch rather than an implicit null branch.
- Owner, Manager, and Staff memberships with server-enforced permissions.
- Real staff invite/activation flow or an honestly disabled entry until the
  invitation transport is implemented.
- Customer accounts scoped to the business, with verified identity/recovery
  policy.

### Earning scope

The Blueprint is the production authority for the V1 earning catalog:

1. `VISIT_STAMP` for an eligible visit.
2. `SPEND_BASED` using integer-safe IQD amounts and `floor` per confirmed
   transaction.
3. `ITEM_BASED` using an authoritative item identifier.
4. `CATEGORY_BASED` using an authoritative category identifier.
5. `COMPLETED_SERVICE` after verified completion.
6. `HYBRID` composition of bounded rules.
7. `WELCOME_EVENT` after enrollment/verification when no Scheduler is needed.

`MANUAL_ADJUSTMENT` is not an EarningRule. It is a protected administrative
operation requiring permission, Reason, AuditLog, and policy-based approval;
its operational implementation is deferred to Secure Operations. Phase 1
defines presentation contracts only and provides no earning mutation.

### Reward types

The full Blueprint Planned V1 catalog is Product Scope, not Phase 1 backend
functionality:

- Free item.
- Free service or add-on.
- Fixed-amount discount.
- Percentage discount with a required maximum.
- Item/category discount.
- Buy X get Y.
- Bundle/combo.
- Multi-milestone reward.
- Single-use voucher/entitlement.
- Welcome reward.

Reward configuration includes fulfillment instructions, eligibility threshold,
expiry policy if enabled, and staff-visible terms. Discount calculation is
informational to Waflo unless a real POS/order integration is explicitly added;
Waflo records the authorized redemption and does not fake a checkout discount.

### Customer and wallet journey

- Lightweight Customer Web join page.
- Verified safe handling of an existing identity; no card takeover by knowing a
  phone/email.
- Live web-card fallback.
- Apple Wallet and Google Wallet issuance through existing provider adapters
  after V2 contract adaptation.
- Customer-visible progress, reward entitlement, terms, and wallet sync state.
- Secure QR/card token suitable for staff scanning, with expiry/rotation policy.

### Staff operations

- Camera scan and manual lookup/code fallback.
- Customer search within the active business only.
- Select branch when the session is not already branch-bound.
- Enter amount for spend programs using integer-safe IQD parsing.
- Select product/service for product-based programs.
- Add stamp/visit/points only after a backend-confirmed, idempotent operation.
- Redeem a specific entitlement only after confirmation.
- Show recent operations scoped to the active business/branch/staff policy.

### Card Customization Studio — V1 baseline

- Logo and cover/hero media.
- Five independent colors: primary, secondary, accent, background, and text.
- Stamp shape/icon for stamp programs.
- Reward image/icon.
- Customer join page presentation.
- QR poster presentation suitable for export after real rendering is available.
- Provider-aware Apple Wallet and Google Wallet previews.
- Save and reuse a bounded base design template.
- Publish a design independently from program balances/rules.

V1 does not promise pixel-identical provider rendering. Previews declare their
provider constraints and live-device verification remains a release gate.
The Phase 1 Studio is preview-only: Waflo rendering is deterministic, while
Apple/Google surfaces are labeled `Platform approximation`. Phase 1 contains no
upload, save, publish, issuance, QR, or loyalty mutation path.

### Reporting and audit

- Customer list and customer detail.
- Program-level issued cards, active memberships, earned units, granted rewards,
  and redemptions.
- Recent immutable ledger entries.
- Actor, business, branch, program, customer, request idempotency key, and
  before/after references in security-safe audit metadata.
- CSV/export is deferred unless a real, tenant-safe backend export is scoped.

## V1.5 candidate: Seasonal Theme Engine

The V1 domain contains `VisualTheme`, assignment, base-design fallback, and
provider-neutral presentation contracts. These advanced operations may ship in
V1.5 if they delay the secure V1 loop:

- scheduling by `startAt`/`endAt` and business timezone;
- `DRAFT → SCHEDULED → ACTIVE → EXPIRED` automation;
- Ramadan, Eid, New Year, Birthday, Black Friday, business anniversary, and
  custom occasion templates;
- reusable seasonal template library;
- targeting one or many programs;
- overlap/conflict resolution and bulk activation;
- automatic provider refresh and automatic base-design restoration.

Manual activation of one saved visual theme can be included in V1 only if it
uses the same audited publish/fallback path and does not weaken launch gates.

## Explicitly outside V1

- Cashback or store credit as a monetary liability.
- Paid memberships/subscriptions for customers.
- Referral rewards.
- Birthday/anniversary scheduling and automated occasion campaigns.
- Full tiers (`Silver`, `Gold`, `VIP`) and tier migration UI.
- Unbounded arbitrary rule scripting outside the validated Hybrid builder.
- POS/e-commerce/payment processing integration.
- Advanced CRM segmentation, campaigns, notifications, and automation.
- Dark mode unless required by a platform/accessibility gate.
- Merchant Web Dashboard as the primary administration surface.
- Growth Menu, AI recommendations, and menu-led architecture changes.
- Full Billing/Stripe launch unless checkout, signed webhooks, entitlement
  evaluation, recovery, and policy review are separately completed.
- Offline value mutation. Offline queueing is deferred until conflict,
  idempotency, device trust, and abuse controls are designed and audited.

## Canonical V1 journey

1. Create account/sign in.
2. Create or authoritatively select business.
3. Add branch.
4. Choose loyalty goal.
5. Choose a Blueprint V1 earning configuration, including bounded Hybrid.
6. Configure earning rule and evidence requirements.
7. Configure one or more supported rewards.
8. Customize the base card/join/poster design.
9. Preview Apple Wallet, Google Wallet, web card, and join page.
10. Save and activate the program after backend validation.
11. Invite/activate Staff.
12. Generate a real join QR/poster.
13. Customer joins and receives a membership/card.
14. Staff scans/searches and records visit, spend, or product/service evidence.
15. Backend evaluates earning once and appends ledger entries.
16. Backend grants an explicit reward entitlement.
17. Staff redeems that entitlement once.
18. Reports, customer history, wallet refresh, and audit reflect the operation.

## Acceptance criteria

### Tenant and identity

- Every business-owned row has an explicit `businessId` and every relevant
  query includes it.
- Every branch-owned operation verifies that branch belongs to the active
  business.
- Phone/email uniqueness is scoped to business or handled through a separately
  approved verified-identity service; no global Customer row leaks ownership.
- Multi-business state never selects by list position and fails closed when
  ambiguous.

### Loyalty correctness

- Every Blueprint V1 earning kind passes positive, boundary, and negative
  tests before production enablement.
- Earning and reward definitions are separate persisted concepts.
- Ledger entries are immutable; corrections use reversal/adjustment entries.
- The same idempotency key cannot apply value twice.
- Concurrent earning/redemption cannot over-credit or double-redeem.
- Visual theme changes have zero ledger, balance, eligibility, or entitlement
  side effects.

### Product honesty

- Backend failure is never rendered as empty or zero.
- Success appears only after persistence confirmation.
- Provider preview, queued sync, provider confirmation, and device verification
  are distinct states.
- Unsupported media, QR, billing, notification, export, or campaign actions are
  disabled/omitted and never simulated.

### Mobile quality

- Owner/Manager/Staff shells expose only authorized actions.
- Arabic and Sorani are RTL; English is LTR.
- Critical flows work from 360–430dp, respect safe areas and dynamic text, and
  use 48dp touch targets.
- Loading, empty, error, offline, permission, and retry states are tested.
- Human visual and linguistic acceptance is recorded separately; Codex cannot
  issue it.

### Release gates

- Customer tenant isolation closed.
- Scanner/Loyalty threat model and negative E2E complete.
- Real-device Apple/Google Wallet issuance and update verified.
- Rate limits, token rotation/replay policy, audit, and incident diagnostics
  verified without logging raw tokens or PII.
- Migration/backfill dry-run, reconciliation, backup, and rollback approved by a
  human before production execution.

## Scope-control rules

- A V1 item that depends on a deferred capability is simplified or disabled;
  the deferred capability is not pulled into V1 silently.
- New program/reward types require domain tests before UI work.
- No application screen creates fake data to complete onboarding.
- No legacy feature is deleted during V1 foundation work.
- Growth Menu remains a separate roadmap and package decision.
