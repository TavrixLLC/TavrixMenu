# Waflo V2 Loyalty Domain

Status: `PLANNED` domain proposal aligned to the approved Blueprint. This
document proposes entities and invariants; **Phase 1 does not change Prisma,
run a migration, or provide loyalty mutations**.

## Why the current model cannot be extended in place

The current authority is:

- `LoyaltyProgram.stampGoal`;
- `LoyaltyMembership.stampCount` and `rewardReady`;
- `LoyaltyTransaction.stampsDelta`;
- stamp-specific transaction and wallet-refresh enums.

Adding optional point/spend/product columns to those tables would keep stamps
as the hidden center, mix reward eligibility with balance, and make
idempotency, reversal, tiers, and hybrid programs fragile. V2 needs a new model
alongside the legacy one, with compatibility/backfill handled separately.

## Domain boundaries

```text
Business ─ Branch
   ├─ CustomerAccount ─ LoyaltyMembership ─ LoyaltyLedgerEntry
   ├─ LoyaltyProgram ─ EarningRule
   │                 ├─ RewardDefinition ─ RewardEligibilityRule
   │                 └─ TierDefinition
   ├─ Campaign/Event (promotion and trigger lifecycle)
   └─ VisualTheme (presentation lifecycle) ─ VisualThemeAssignment
```

The hard boundary is:

- `LoyaltyProgram` owns economic/loyalty policy.
- `Campaign/Event` owns time-bounded promotion intent and triggers.
- `VisualTheme` owns presentation only.

No theme activation code may call earning, ledger, eligibility, balance, or
redemption mutation code.

## Core aggregates

### Business and Branch

`Business` is the tenant. `Branch` is a first-class, business-owned operating
location. Every staff operation records a branch when policy requires it.

Proposed `Branch` fields:

- `id`, `businessId`, `name`, `code`, `city`, `timezone`;
- `status: ACTIVE | INACTIVE`;
- `isPrimary`, timestamps;
- unique `[businessId, code]` and index `[businessId, status]`.

V2 does not use a null/implicit branch to claim branch support. Existing
businesses receive an explicit primary branch during an approved backfill.

### CustomerAccount

`CustomerAccount` is business-owned. It represents how one business knows a
customer, not a platform-global person.

Proposed fields:

- `id`, `businessId`, `displayName`;
- `phoneNormalized`, `emailNormalized`, each nullable;
- verification timestamps and recovery policy metadata;
- `status: ACTIVE | BLOCKED | ANONYMIZED`;
- consent/source timestamps where required;
- unique `[businessId, phoneNormalized]` and
  `[businessId, emailNormalized]`, never global uniqueness;
- composite tenant index `[businessId, id]`.

If Waflo later needs a cross-business verified identity, it must be a separate,
privacy-reviewed identity service that grants business-specific links. It must
not turn `CustomerAccount` into a shared mutable tenant record.

### LoyaltyProgram

`LoyaltyProgram` is a versioned policy aggregate.

Proposed fields:

- `id`, `businessId`, `name`, `description`;
- `kind/configuration` resolves Blueprint earning rules rather than making one
  stamp-shaped program type the aggregate authority;
- lifecycle: `DRAFT | VALIDATED | PUBLISHED | PAUSED | ARCHIVED`;
- `version`, `startsAt`, `endsAt`, timestamps;
- wallet/display reference to a base design, not embedded theme fields;
- unique `[businessId, id]` for composite tenant relations.

V1 supports one `PUBLISHED` program per Business, with multiple Draft and
Archived programs. “Active” is derived from `PUBLISHED` plus temporal and
operational conditions; it is not a parallel lifecycle state. The published
program may contain several EarningRules and RewardDefinitions, including a
bounded Hybrid configuration. Presentation/API shapes remain list-based so
future multi-active support is not blocked.

Activated policy is versioned. Material earning changes create a new version or
an audited effective-dated rule set; they do not reinterpret historical ledger
entries.

### EarningRule

`EarningRule` answers: what evidence earns which unit?

Proposed common fields:

- `id`, `businessId`, `programId`, `programVersion`;
- V1 `kind: VISIT_STAMP | SPEND_BASED | ITEM_BASED | CATEGORY_BASED |
  COMPLETED_SERVICE | HYBRID | WELCOME_EVENT`;
- `unit: STAMP | VISIT | POINT | CREDIT`;
- `status`, `priority`, effective timestamps;
- `fixedUnits` for visit/fixed-point rules;
- `spendBlockMinor` and `unitsPerBlock` for spend rules;
- `minimumSpendMinor`, `maximumUnitsPerEvent`;
- `visitCooldownSeconds`/daily cap where applicable;
- evidence requirements and branch applicability.

For V1, typed columns and validated child records are preferred over an opaque
`configJson`. A JSON extension field may carry forward-compatible metadata, but
it cannot bypass validation. Welcome is V1 only where no Scheduler is required;
Birthday, Referral, slow-hour, and tier automation remain V1.5 or later.

Manual Adjustment is not an EarningRule kind. It is a Secure Operations command
with explicit permission, Reason, AuditLog, and policy-based approval. It
creates audited ledger facts only after later backend implementation.

`ProductServiceTarget` links a rule to a catalog reference:

- `source: WAFLO_MENU_ITEM | EXTERNAL_SKU | MANUAL_SERVICE`;
- `sourceId`/SKU plus an immutable display snapshot;
- composite ownership validation when the source belongs to Waflo Menu;
- quantity/minimum conditions.

This allows Growth Menu to supply references without owning the loyalty model.

### RewardDefinition and RewardEligibilityRule

`RewardDefinition` answers: what can the customer receive?

Blueprint Planned V1 types:

- `FREE_ITEM`;
- `FREE_SERVICE_ADD_ON`;
- `FIXED_AMOUNT_DISCOUNT`;
- `PERCENTAGE_DISCOUNT`;
- `ITEM_CATEGORY_DISCOUNT`;
- `BUY_X_GET_Y`;
- `BUNDLE_COMBO`;
- `MULTI_MILESTONE`;
- `VOUCHER`;
- `WELCOME_REWARD`.

These are Product Scope contracts. Phase 1 does not implement eligibility,
granting, redemption, inventory, discount calculation, or persistence.

Proposed fields:

- `id`, `businessId`, `programId`, `name`, `description`;
- `type`, `status`, fulfillment instructions;
- product/service target when applicable;
- `percentBasisPoints` (for example 1250 = 12.50%), never binary floating point;
- `amountMinor`, `currency` for fixed discounts;
- validity/expiry policy and per-membership limits;
- visual asset reference independent from value fields.

`RewardEligibilityRule` answers when an entitlement is granted:

- threshold unit and amount;
- optional tier, branch, program-version, time, or rolling-window conditions;
- consume-on-grant policy versus consume-on-redemption policy;
- deterministic rule version used by evaluation.

Earning and reward are many-to-many through explicit eligibility policy when
future hybrid programs need it. V1 may expose a simple one-threshold builder.

### LoyaltyMembership

Proposed fields:

- `id`, `businessId`, `programId`, `customerAccountId`;
- `status: ACTIVE | SUSPENDED | CLOSED`;
- `joinedAt`, `closedAt`, optional `currentTierId`;
- wallet/card presentation assignment reference;
- unique `[businessId, programId, customerAccountId]` for the active membership
  policy;
- no authoritative `stampCount` or `rewardReady` boolean.

A balance snapshot may exist for fast reads, but it is rebuildable and checked
against the immutable ledger. It is not an independent source of truth.

### LoyaltyEvent / Transaction

`LoyaltyEvent` records the business fact submitted for evaluation:

- `id`, `businessId`, `branchId`, `programId`, `membershipId`;
- `actorUserId`, trusted device/session reference;
- `source: SCAN | MANUAL_LOOKUP | API | IMPORT | SYSTEM`;
- `type: VISIT | PURCHASE | PRODUCT_SERVICE | ADJUSTMENT | REVERSAL`;
- integer-safe `amountMinor` and `currency` when applicable;
- product/service evidence lines;
- `occurredAt`, `recordedAt`, payload hash;
- idempotency record reference;
- status and rejection reason without raw secrets.

One event may evaluate against one or more rules in a future hybrid program.
Every evaluation records the exact program/rule version.

### LoyaltyLedgerEntry

The ledger is append-only.

Proposed fields:

- `id`, `businessId`, `programId`, `membershipId`, `eventId`;
- `unit`, signed integer/decimal-safe `delta`;
- `entryType: EARN | CONSUME | EXPIRE | ADJUST | REVERSE | MIGRATION`;
- `ruleId`, `ruleVersion`, `reversesEntryId`;
- `availableAt`, `expiresAt`, `createdAt`;
- actor/audit correlation IDs.

Rules:

- no update/delete of posted value entries;
- correction creates a linked reversal/adjustment;
- the sum by membership/program/unit is reproducible;
- a transaction and its ledger entries commit atomically;
- expired units are represented explicitly;
- Store Credit uses a separately approved monetary ledger in the future and is
  not smuggled into generic points.

### RewardEntitlement

Eligibility produces a durable entitlement rather than toggling
`rewardReady`.

Proposed fields:

- `id`, `businessId`, `programId`, `membershipId`, `rewardDefinitionId`;
- `eligibilityRuleId`, `sourceEventId`, rule/reward version snapshot;
- `status: AVAILABLE | RESERVED | REDEEMED | EXPIRED | REVOKED`;
- `grantedAt`, `expiresAt`, `redeemedAt`;
- unique grant key preventing duplicate entitlement creation.

This supports multiple simultaneous rewards and clear historical explanations.

### Redemption

`Redemption` consumes one entitlement through a controlled state change.

Proposed fields:

- `id`, `businessId`, `branchId`, `membershipId`, `entitlementId`;
- `actorUserId`, idempotency record, fulfillment note;
- `status: PENDING | CONFIRMED | REVERSED | CANCELLED`;
- timestamps and reversal link;
- unique `[businessId, entitlementId]` for one confirmed consumption, with a
  separately modeled reversal if business policy allows it.

The entitlement lock, ledger consumption, redemption, audit event, and outbox
messages commit atomically.

### Tiers

`TierDefinition` and `MembershipTierHistory` are part of the extensible model:

- business/program scoped tiers with ordered thresholds;
- effective-dated entry/exit policy;
- history records rather than overwriting tier truth;
- reward/earning rules may reference a tier.

Tier authoring and automated upgrades are deferred beyond V1, but the model
must not reserve `Silver/Gold/VIP` as hardcoded columns.

## Idempotency

Every value mutation requires a client-generated idempotency key.

Proposed `IdempotencyRecord` fields:

- `id`, `businessId`, `operationType`, `key`, `requestHash`;
- actor/principal and branch context;
- `status: IN_PROGRESS | SUCCEEDED | FAILED_RETRYABLE | FAILED_FINAL`;
- safe response reference/status, timestamps, expiry;
- unique `[businessId, operationType, key]`.

Behavior:

1. Same key + same request returns the prior successful result.
2. Same key + different request is a conflict and never mutates value.
3. Concurrent same-key requests serialize.
4. Network retry cannot append a second ledger entry or redemption.
5. Offline clients do not invent success; V1 has no offline value-write queue.

Wallet/card scan tokens identify a membership/card. They are not the
idempotency key for a purchase/visit and do not authorize value mutation alone.

## Campaign/Event domain

`Campaign` is a time-bounded promotional configuration:

- `id`, `businessId`, name, audience/filter reference;
- `type: BONUS_EARNING | OCCASION | REFERRAL | MESSAGE_ONLY | CUSTOM`;
- `status: DRAFT | SCHEDULED | ACTIVE | PAUSED | COMPLETED | CANCELLED`;
- `startAt`, `endAt`, business timezone;
- optional references to extra earning/reward rules;
- optional `visualThemeId` reference;
- explicit activation and audit history.

A Campaign can reference a Visual Theme but cannot own its style fields. A
Campaign ending does not delete or rewrite loyalty history.

Automated campaigns are post-V1 unless separately scoped. The entity boundary
is defined now to prevent seasonal visuals from becoming reward rules.

## Card Design and Visual Theme domain

### CardDesign

`CardDesign` is the stable base presentation for one business/program family:

- versioned logo, cover/hero, color tokens, text contrast choice;
- stamp shape/icon and reward media references;
- Customer Web join-page content/style;
- QR poster layout/content;
- provider-neutral wallet field hierarchy;
- `DRAFT | PUBLISHED | ARCHIVED` status;
- immutable published snapshots for provider/audit reproducibility.

`DesignTemplate` stores reusable merchant-owned design input. Applying a
template creates a draft snapshot; later edits to the template do not mutate
already published cards.

### VisualTheme

`VisualTheme` is an overlay on a base `CardDesign`:

- `id`, `businessId`, name, occasion type;
- `startAt`, `endAt`, `timezone`;
- `status: DRAFT | SCHEDULED | ACTIVE | EXPIRED`;
- only allowlisted presentation overrides;
- preview snapshot and publish metadata;
- `fallbackCardDesignVersionId` captured before activation.

`VisualThemeAssignment` links a theme to one or more programs:

- `businessId`, `visualThemeId`, `programId`;
- priority and effective interval;
- unique assignment/overlap rules;
- provider sync status per target.

Scheduler invariants:

1. Activate only a validated, published theme inside its interval.
2. Resolve overlaps deterministically; V1.5 should reject ambiguous equal
   priority rather than guess.
3. On expiry/deactivation, restore the captured valid base design.
4. Publish refresh through an outbox; retry safely and expose partial provider
   state.
5. Never write `LoyaltyLedgerEntry`, balance snapshot,
   `RewardEntitlement`, or `Redemption`.
6. Theme preview uses a snapshot and has no live side effect.

## Provider-neutral card presentation

One canonical `CardPresentationSnapshot` feeds:

- Customer Web card/join page;
- Apple Wallet pass builder;
- Google Wallet class/object builder;
- QR poster renderer;
- Flutter previews.

Provider adapters declare unsupported or transformed fields. A preview response
contains the design version, provider, limitations, render timestamp, and
whether it is deterministic preview or provider-confirmed output.

## Audit trail and outbox

Every security/value/configuration action writes an `AuditEvent` with:

- business/branch, actor, role, action, target type/id;
- request/idempotency/correlation reference;
- safe before/after version references;
- result and reason code;
- timestamp and source;
- no raw token, secret, certificate, full PII, or provider credential.

Events requiring wallet refresh, schedule transition, reports, or notifications
use a transactional outbox. A successful core transaction is not rolled back by
a provider outage; the UI exposes queued/failed sync truth.

## Tenant constraints

- Duplicate `businessId` on business-owned child rows intentionally makes
  scoping and indexing explicit.
- Use composite unique keys such as `[businessId, id]` and composite relations
  where practical to prevent cross-tenant foreign-key composition.
- All access paths begin from authoritative membership + business + branch.
- Customer search, membership, ledger, rewards, themes, campaigns, wallet, and
  audit always filter by `businessId`.
- A program ID, branch ID, customer ID, product ID, theme ID, or entitlement ID
  from another business produces a closed failure, not a fallback lookup.

## Proposed Prisma entities and relationships

This is a naming proposal, not migration SQL:

| Entity | Key relationships |
| --- | --- |
| `Branch` | belongs to `Business`; has events/redemptions/staff context |
| `CustomerAccount` | belongs to `Business`; has memberships |
| `LoyaltyProgramV2` | belongs to `Business`; has rules, rewards, memberships, tiers, designs |
| `EarningRule` | belongs to program version; has optional targets |
| `ProductServiceTarget` | belongs to earning/reward rule; safe catalog reference |
| `RewardDefinition` | belongs to program; has eligibility rules/entitlements |
| `RewardEligibilityRule` | belongs to reward and program version |
| `LoyaltyMembershipV2` | joins business-scoped customer and program |
| `LoyaltyEvent` | belongs to membership/program/branch; owns evaluation results |
| `LoyaltyLedgerEntry` | immutable value line for event/membership/program |
| `RewardEntitlement` | granted reward instance for membership |
| `Redemption` | consumes/reverses an entitlement at a branch |
| `TierDefinition` | program-scoped tier policy |
| `MembershipTierHistory` | effective-dated membership tier |
| `IdempotencyRecord` | business-scoped request fence |
| `Campaign` | business-scoped promotion/event lifecycle |
| `CardDesign` / `CardDesignVersion` | business/program presentation and published snapshots |
| `DesignTemplate` | reusable merchant-owned draft source |
| `VisualTheme` | time-bounded presentation overlay |
| `VisualThemeAssignment` | targets one theme to one/many programs |
| `AuditEventV2` | immutable safe action trail |
| `OutboxMessage` | reliable provider/report/scheduler side effect |

Use a `V2` suffix only during coexistence if needed. Final names are chosen in
the approved migration ADR; Phase 0 intentionally avoids schema churn.

## V1 rule examples

### Visit stamps

`VISIT` evidence → one `STAMP` every configured cooldown → free coffee
entitlement at 8 stamps. Grant and optional stamp consumption are explicit
ledger operations.

### Fixed points

Verified operation → 10 `POINT` → fixed-discount entitlement at 100 points.

### Spend-based points

For each 1,000 IQD block, grant 1 point; floor rounding; 5,000 IQD minimum;
server stores integer IQD amount and rule version.

### Product/service

Two units of an eligible SKU/service → configured points or visit credit. The
event records target ID and display snapshot so later catalog edits do not
rewrite history.

## Deferred design questions

- Simultaneous active-program limits and membership enrollment policy.
- Spend rounding, returns, refunds, and POS evidence policy.
- Point expiry and liability accounting.
- Tier qualification windows.
- Campaign audience engine and notification consent.
- Advanced seasonal theme overlap policy and template marketplace.
- Store Credit/Cashback financial ledger and regulatory treatment.

These questions do not justify reverting to stamp-only tables.
