# Backend Reuse and Migration

Status: planning only. This document proposes a safe transition; it does not modify Prisma, run a migration, backfill production data, or authorize deployment.

## 1. Migration objectives

1. Preserve the verified NestJS/PostgreSQL foundations and project history.
2. Introduce a multi-program loyalty domain without corrupting existing stamp balances.
3. Close tenant-isolation and replay/idempotency blockers before exposing new mutations.
4. Run old and new read paths side by side until reconciliation is proven.
5. Keep visual customization independent from financial/loyalty state.

## 2. Reuse, redesign, isolate, defer

| Area | Decision | Evidence and boundary |
|---|---|---|
| NestJS application structure | Reuse | Modules, validation, guards, testing, and Prisma access are established. Add bounded Waflo V2 modules rather than a rewrite. |
| PostgreSQL and Prisma | Reuse with additive schema | Current schema is operational and heavily tested. New entities require reviewed migrations later. |
| Clerk authentication | Reuse | API identity verification exists. Active Business resolution must continue to come from authoritative membership. |
| `Business` / `BusinessUser` roles | Reuse and harden | OWNER/MANAGER/STAFF checks exist. Multi-business selection and branch scope need explicit contracts. |
| Branches | Redesign/add | No runtime `Branch` model was found. Branch support must be real before branch-dependent V1 flows claim success. |
| Current loyalty tables | Preserve as legacy input | `stampGoal`, `stampCount`, and `stampsDelta` are stamp-specific. Do not overload them with points or spend. |
| Customer identity | Isolate/redesign | Global unique phone/email and a platform-global Customer row threaten Business isolation. Introduce business-scoped accounts and explicit identity linkage. |
| Wallet foundations | Reuse behind adapters | Apple/Google generation, device registration, refresh jobs, and tests exist. Provider/device validation remains required. |
| QR and scanner token foundation | Reuse after audit | Tokens are signed/hashed and business-bound, but mutation replay and expiration/idempotency need resolution. |
| Media | Reuse after completing clients | API foundations exist; mobile picker/upload/publish states must be honest and business-scoped. |
| Audit | Reuse schema, expand coverage | `AuditLog` exists but verified writes are limited. New commands need actor, target, Business, branch, correlation, and before/after metadata. |
| Billing | Defer from loyalty launch path | Prisma models and contracts exist, while runtime modules are incomplete. Do not gate V1 pilot on fictional billing behavior. |
| Menu / AI | Isolate as Growth Menu | Preserve legacy code and routes. Do not make them dependencies of Loyalty V1. |
| Customer Web | Reuse and evolve | Join, card, Wallet, and menu surfaces exist. Move new loyalty reads behind versioned APIs without making a customer app mandatory. |
| Admin Web | Preserve, not merchant primary | It contains platform/admin surfaces and mock data. It is not the Waflo V2 merchant dashboard. |

## 3. Target backend boundaries

Proposed NestJS bounded modules:

- `workspace`: authoritative Business membership, active context, and branch access.
- `customer-accounts`: business-scoped customer identity and verified contact methods.
- `loyalty-programs`: programs, earning rules, rewards, tiers, versions, and publishing.
- `loyalty-ledger`: idempotent accrual/reversal/adjustment entries and balance projection.
- `redemptions`: entitlement checks, reserve/confirm/cancel lifecycle.
- `scanner`: signed presentation, nonce/expiry validation, transaction command orchestration.
- `card-designs`: base designs, media references, previews, revisions, and publishing.
- `campaigns` and `visual-themes`: independent event/theme metadata and assignments; advanced scheduler in V1.5.
- `wallet`: provider-neutral pass projection and provider adapters.
- `audit`: cross-module command/event recording.

The mobile app consumes versioned DTOs. It must not infer reward readiness, point conversions, role permissions, or theme lifecycle locally.

## 4. Stamp-only to multi-program transition

### 4.1 Legacy facts to preserve

For every existing membership, retain:

- Original Business, Customer, and LoyaltyProgram identifiers.
- `stampGoal`, `stampCount`, `rewardReady`, and transaction history.
- Card access hashes/transfers, Wallet pass links, and audit timestamps.
- Existing public/customer URL behavior until its replacement is verified.

### 4.2 Proposed mapping

| Legacy field/entity | Proposed V2 representation |
|---|---|
| `LoyaltyProgram.stampGoal` | Published `EarningRule` plus reward threshold for a stamp/visit program |
| `LoyaltyMembership.stampCount` | Opening `LoyaltyLedgerEntry` or immutable legacy opening-balance record |
| `rewardReady` | Derived entitlement/projection; never the only source of truth |
| `LoyaltyTransaction.stampsDelta` | Historical ledger entry with unit `STAMP` and legacy source metadata |
| `LoyaltyStampStyle` | Input to a versioned base `CardDesign`; no loyalty value mutation |
| `Customer` shared identity | `CustomerAccount` per Business, optionally linked to a separate platform identity after policy approval |

Do not silently reinterpret a stamp as a point. Each migrated ledger entry records unit, source, original ID, migration batch, and deterministic idempotency key.

## 5. Safe migration sequence

### Stage A — prove and freeze invariants

1. Inventory production cardinality and null/duplicate patterns using read-only queries.
2. Decide Business-scoped customer identity and contact-verification policy.
3. Define program/version/ledger invariants and authorization matrix.
4. Add characterization tests for all current join, add-stamp, redeem, transfer, and Wallet flows.
5. Take and verify backups through the deployment owner. Human approval is mandatory.

### Stage B — expand

1. Add new tables, enums, indexes, and nullable linkage columns only.
2. Keep existing tables and constraints untouched unless a separately reviewed migration requires change.
3. Add versioned read/write services behind disabled feature flags.
4. Deploy schema and code independently where platform tooling permits.

### Stage C — deterministic backfill

1. Create a migration batch with immutable version and checksum.
2. Map each Business/program/customer/membership deterministically.
3. Generate opening balances and historical entries with unique legacy-source keys.
4. Backfill base `CardDesign` from legacy stamp style without changing balances.
5. Re-run safely; duplicate input must produce zero duplicate rows.
6. Record rejects for manual review rather than guessing.

### Stage D — dual read and reconciliation

1. Continue legacy writes while comparing legacy and V2 projections in shadow mode, or use one authoritative write with a transactional compatibility projection after design review.
2. Compare membership counts, balances, earned rewards, redemptions, and Wallet-visible values per Business.
3. Alert on mismatch; never auto-correct financial/loyalty state without an audited command.
4. Pilot with selected Businesses only after tenant-isolation and security gates pass.

### Stage E — controlled cutover

1. Enable V2 writes per Business with an explicit feature flag and cutover checkpoint.
2. Preserve legacy reads for support and rollback.
3. Monitor error rate, duplicate commands, ledger imbalance, redemption failures, Wallet refresh, and audit completeness.
4. Require human approval for each production rollout expansion.

### Stage F — contract later

Legacy columns/tables may be made read-only or removed only after the agreed retention period, zero reconciliation mismatches, verified backup restore, customer/support readiness, and a separate migration approval. Removal is not part of V1.

## 6. Customer identity transition

The current global unique phone/email model must not be relaxed by an ad hoc constraint drop. Proposed approach:

1. Create `CustomerAccount(businessId, ...)` with Business-scoped normalized contact uniqueness.
2. Preserve the legacy `Customer` ID as a source link.
3. Link two Business accounts to a platform identity only through a deliberate consent/privacy policy; do not expose cross-Business history.
4. Make every customer, membership, ledger, redemption, card, media, and theme query require `businessId` from the authorized request context.
5. Add negative tests proving that raw IDs from Business A fail under Business B.

The exact phone/email verification and recovery policy requires product/security approval before schema implementation.

## 7. Card designs and seasonal themes

Visual migration is additive and isolated:

- A base `CardDesign` revision is associated with a Business and program assignment.
- Legacy `LoyaltyStampStyle` may seed the first draft/base design.
- Apple/Google projections are regenerated from a published design version, not written into loyalty rules.
- `VisualTheme` stores overrides and assignments; its activation changes only the resolved design projection.
- `Campaign/Event` may reference a theme but does not own balances or earning rules.
- Expiry resolves back to the base design automatically; it does not create ledger entries.
- Scheduler operations are idempotent and audited. Advanced scheduling remains V1.5 if it threatens V1 release.

## 8. Backfill verification

Every migration batch must produce machine-checkable evidence:

- Source and target counts per Business.
- Sum of positive, negative, and net units per program and membership.
- Reward-ready/entitlement comparison with documented exceptions.
- Orphan and duplicate reports.
- Cross-Business reference scan with zero tolerated violations.
- Repeat-run result demonstrating idempotency.
- Sample Wallet and customer-page projections.
- Hash/checksum of the migration implementation and report.

## 9. Rollback strategy

Rollback is forward-safe, not destructive:

1. Disable the per-Business V2 feature flag.
2. Stop new V2 commands while preserving all V2 rows and audit records.
3. Route supported reads/writes back to the verified legacy path only if compatibility invariants still hold.
4. Reverse post-cutover V2 mutations through compensating ledger entries, never by deleting ledger history.
5. Restore a database backup only under the deployment owner’s incident procedure and human approval.
6. Keep Wallet pass identifiers and customer access tokens stable where possible; rotate only through an audited incident action.

No `DROP`, destructive constraint change, production backfill, or rollback command belongs in Phase 0 or Phase 1.

## 10. Migration acceptance gates

- Customer tenant isolation has passing positive and negative integration tests.
- Active Business and branch context fail closed under ambiguity.
- Ledger totals reconcile with legacy data at the agreed precision.
- Every mutation uses an idempotency key and emits an audit record.
- Scanner replay/expiry rules are enforced server-side.
- Wallet updates are validated with provider sandboxes and physical devices where required.
- Backup and restore evidence exists.
- Product, security, data, and deployment owners approve the cutover.
