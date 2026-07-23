# Waflo V2 Decision Log

Status: decisions below are `Accepted for Phase 0 planning` unless marked `Proposed` or `Open`. Implementation, migration, deployment, and visual acceptance still require their applicable approvals.

## Decision format

Each record states the decision, repository/product evidence, consequences, and what would trigger reconsideration. Older product documents remain historical evidence; a superseding decision is recorded instead of rewriting their history.

## D-001 — The merchant product is Mobile-first

**Decision:** Build the primary Owner/Manager/Staff experience as Flutter applications for iOS and Android. Do not build a primary merchant Web Dashboard for Waflo V2.

**Why:** Scanning, counter operations, team work, camera access, and daily loyalty activity are inherently mobile. The repository already contains a Flutter application and scanner foundations. A previous Web Studio-first surface split is superseded for Waflo V2 by this explicit product decision.

**Consequences:** Configuration, reporting, team, scanning, program setup, and Card Studio must be usable on a phone. Admin Web remains a platform/admin surface; Customer Web remains customer-facing.

## D-002 — One Flutter app adapts by role

**Decision:** Owner, Manager, and Staff share one application binary with server-authorized role-aware navigation and actions.

**Why:** Authentication, workspace context, scanner, customer lookup, and transaction components are shared. Separate apps would multiply releases and create permission drift.

**Consequences:** UI hides irrelevant complexity, but the API remains the authorization authority. Staff defaults to scan/search/earn/redeem/recent operations; Manager permissions are explicit; Owner controls business/program/team settings.

## D-003 — Customers do not need a Waflo app

**Decision:** Customer onboarding uses lightweight Web pages and Apple Wallet/Google Wallet.

**Why:** Mandatory installation increases friction for a short join-and-use journey. Customer Web and Wallet foundations already exist.

**Consequences:** The customer journey must work in supported mobile browsers, maintain secure recovery/transfer, and show live Wallet/customer state. A customer app may be reconsidered only for a proven use case that Wallet/Web cannot serve.

## D-004 — Reuse the backend; do not rewrite it wholesale

**Decision:** Evolve NestJS, PostgreSQL, Prisma, Clerk auth, Businesses/memberships, Wallet, scanner/token, media, and tests with bounded additive modules.

**Why:** These areas contain working code and broad automated coverage. A rewrite would discard evidence and increase migration risk, while the main structural defects can be isolated behind new domain boundaries.

**Consequences:** Legacy stamp tables are preserved during expansion. New ledger/customer/program/design entities are added through later reviewed migrations. Characterization and reconciliation precede cutover.

## D-005 — Loyalty V1 and Growth Menu are separate products

**Decision:** Menu and AI recommendations do not drive Waflo Loyalty V1 architecture. Preserve current menu code and position future work as `Waflo Growth Menu`.

**Why:** Loyalty already has a long critical path across tenant isolation, Wallet, scanner, ledger, rewards, and customer identity. Menu/AI would expand scope and permission/data concerns.

**Consequences:** No Legacy menu deletion. Loyalty entities may reference a neutral product/service identifier but cannot depend on the Legacy menu module. Growth Menu needs separate approval, pricing, and roadmap.

## D-006 — Earning and reward definitions are separate

**Decision:** Model how value is earned independently from what the customer receives, its eligibility conditions, and its redemption method.

**Why:** The current `stampGoal/stampCount` model couples progress to one reward pattern. V1 requires four earning types and four reward types, and future tiers, cashback, referrals, subscriptions, and hybrids must remain possible.

**Consequences:** Programs own versioned EarningRules and RewardDefinitions. Ledger entries record units and applied versions. Entitlements/redemptions are separate from balance projection.

## D-007 — Customer accounts are Business-scoped

**Decision:** `Proposed, requires security/product approval.` A merchant’s customer account and contact uniqueness belong to a Business. Optional platform identity linking must not expose cross-Business data.

**Why:** The verified schema makes phone/email globally unique and can share one Customer row across Businesses. This is a documented Loyalty release blocker.

**Consequences:** Add Business-scoped CustomerAccount, negative tenant tests, and explicit verification/recovery policy before V1 Loyalty data migration. Never merely remove current unique constraints without an additive transition.

## D-008 — Active Business selection fails closed

**Decision:** Use authoritative memberships and require explicit selection when multiple Businesses are available; never select by list order.

**Why:** API membership truth and Flutter fail-closed datasource behavior exist, but a complete selector/onboarding experience is missing. First-membership role derivation remains unsafe UX state.

**Consequences:** Phase 1 defines the contract and Phase 2 delivers the flow. Business/session switches clear all customer/scanner/draft/cache state, preserving W2A regression invariants.

## D-009 — Branch is a first-class scope

**Decision:** `Proposed.` Add a real Branch entity and membership/operation scope before branch workflows are declared functional.

**Why:** Product journeys require branches, but no verified Branch model or API was found.

**Consequences:** Programs may apply Business-wide or to selected branches. Staff earning/redemption requires permitted branch context. Phase 2 must not simulate branch persistence.

## D-010 — The ledger is append-only and mutations are idempotent

**Decision:** Accrual, redemption consumption, reversal, adjustment, and migration openings are immutable ledger facts or compensating entries. Every command uses a server-enforced idempotency key.

**Why:** Scanner retries, concurrent devices, and unreliable mobile networks make counter mutation unsafe without replay and duplicate protection. Existing row locks help stamp concurrency but no end-to-end idempotency mechanism was verified.

**Consequences:** No direct balance editing. Exact retries return the first result; conflicting key reuse fails. Audit/outbox writes share the database transaction.

## D-011 — Online confirmation is required for V1 mutations

**Decision:** V1 may cache read-only context, but earning and redemption require server confirmation. Offline writes are deferred.

**Why:** Offline authority introduces device revocation, sequencing, fraud limits, conflicts, and double-spend risk.

**Consequences:** Network failure is an error/offline state, never success or zero. An offline mutation queue needs a separately approved threat model.

## D-012 — Program, Campaign/Event, and VisualTheme are separate

**Decision:** `LoyaltyProgram` controls earning/rewards; `Campaign/Event` describes an occasion/audience; `VisualTheme` controls presentation overrides.

**Why:** Seasonal presentation must not change balances or business rules. Campaign scheduling and visual scheduling have different permissions, failure modes, and audit needs.

**Consequences:** A theme can apply to one or many programs and a campaign can optionally reference it. Theme lifecycle cannot produce ledger/redemption mutations. Expiry resolves to the base design.

## D-013 — Basic Card Customization Studio is V1

**Decision:** Include logo/cover, core colors, stamp shape/icon, reward media, join page, QR Poster, provider-aware Wallet previews, base design draft/save/publish, and reuse from an existing business design in V1.

**Why:** Card identity and preview are central to merchant setup and Wallet confidence, not an unrelated decoration feature.

**Consequences:** Accessibility/provider validation blocks publish. Preview is labeled and does not claim provider issuance. Designs and media are Business-scoped and versioned independently from loyalty state.

## D-014 — Advanced Seasonal Theme Engine is V1.5 by default

**Decision:** Define its contracts early, but schedule named reusable templates, presets, multi-program scheduling, automatic activation/expiry, conflicts, and revision rollback for V1.5 if they threaten V1 delivery.

**Why:** Reliable schedulers, timezones, overlap policy, Wallet propagation, and fallback behavior add operational complexity. The base design is sufficient to validate the core loyalty journey.

**Consequences:** Phase 1 may create pure domain/UI contracts only. No scheduler, persistence migration, customer notification, or fake activation. Moving it into V1 requires explicit scope and security approval.

## D-015 — Visual customization never mutates loyalty value

**Decision:** Design/theme commands cannot write memberships, balances, rules, ledger entries, entitlements, or redemptions.

**Why:** Merchants must safely change seasonal appearance without financial or loyalty side effects.

**Consequences:** Separate services, DTOs, permissions, audit events, and tests enforce the boundary. Wallet/customer projections consume a resolved design revision plus separately computed loyalty state.

## D-016 — Preserve Legacy and use additive migration

**Decision:** Keep the verified Legacy commit archived; begin V2 from that history; use expand/backfill/reconcile/cutover/contract later.

**Why:** The repository contains divergent branches and dirty Worktrees, and the current stamp data must remain recoverable.

**Consequences:** No Phase 0/1 migration, table removal, force operation, or implicit branch merge. Production migration/rollback requires human approval and evidence.

## D-017 — Dark mode is deferred from V1

**Decision:** Deliver a complete accessible light system first.

**Why:** Current brand palette is defined for light surfaces, while RTL, role shells, scanner, customization, and provider previews already create a large validation matrix.

**Consequences:** Semantic tokens must allow a later dark palette, but no partial/unverified dark UI ships.

## D-018 — Customer identity and recovery are Business-scoped

**Decision:** `Accepted for Phase 1 contracts.` A future `CustomerAccount` belongs to exactly one Business. Verified phone/email uniqueness is enforced within that Business, never globally. OTP is the verification and normal recovery basis. A normal phone change verifies both the old and new numbers. If the old number is unavailable, only an Owner or explicitly authorized Manager may initiate a fully audited manual recovery.

**Why:** Global identity uniqueness can leak tenant existence and incorrectly couple unrelated merchant/customer relationships. Contact similarity is not enough evidence for ownership or identity equivalence.

**Consequences:** No cross-Business transfer or merge and no automatic merge by phone/email similarity. Any future recovery or deliberately approved merge records Actor, Reason, and Timestamp in `AuditLog`. Phase 1 defines assumptions only; it does not change Prisma or authentication.

## D-019 — V1 has one published/active program per Business

**Decision:** `Accepted for Phase 1 contracts.` A Business may have one Published/Active loyalty program and multiple Draft or Archived programs. The active program may own multiple EarningRules and RewardDefinitions, including a hybrid configuration.

**Why:** One live program keeps Wallet, scanner, reporting, and customer communication understandable for V1 while hybrid rules avoid forcing the program back into a stamp-only shape.

**Consequences:** Presentation contracts use collections and stable program identifiers so later multi-active support is additive. Phase 1 flags an invalid fixture portfolio but adds no persistence or backend enforcement.

## D-020 — Branch visibility follows role assignments

**Decision:** `Accepted for Phase 1 presentation contracts.` Owner sees every branch. Manager may be assigned one, several, or all branches. Staff may be assigned one or several specific branches and defaults to one. Only assigned branches and operations appear in Flutter.

**Why:** Counter operations need explicit Branch context, but hiding UI is not authorization.

**Consequences:** The future backend must independently authorize Business and Branch for every operation. Phase 1 performs deterministic presentation filtering only and never treats list position as selection.

## D-021 — IQD, points, rounding, refunds, and expiry policy

**Decision:** `Accepted for future backend implementation; contracts only in Phase 1.` Monetary values use integers in the currency's smallest unit; IQD has scale `1`. Points are integers. Spend-based earning floors each confirmed transaction. Refunds append linked reversing ledger entries rather than updating history. Partial refunds reverse the corresponding amount under the original rule. A refund may produce a negative computed balance and blocks new redemption until available balance is sufficient. Points do not expire in V1.

**Why:** Integer arithmetic and append-only reversals are deterministic and auditable under retries, partial refunds, and concurrent scanner activity.

**Consequences:** A future refund command requires idempotency key, Actor, Reason, original transaction linkage, and audit metadata. Optional expiry is deferred, policy-driven, and non-retroactive by default. Phase 1 contains no Ledger or refund mutation.

## D-022 — Phase 1 uses an isolated Flutter namespace

**Decision:** `Accepted and implemented pending human visual approval.` New foundations live under `apps/mobile/lib/waflo_v2/`. Existing Flutter generations, application bootstrap, W2A workspace/scanner isolation, and late-result protections remain unchanged.

**Why:** The repository contains multiple UI generations. An additive namespace gives Waflo V2 a coherent foundation without destabilizing verified Legacy flows.

**Consequences:** The Phase 1 review host is fixture-only and test-only. No Prisma schema, backend mutation, scheduler, Wallet issuance, upload, QR export, or production route is added.

## D-023 — Official Brand System governs Phase 1 UI tokens

**Decision:** `Accepted.` Use the eleven official Brand System primitives, five
independent CardDesign colors (`primaryColor`, `secondaryColor`, `accentColor`,
`backgroundColor`, `textColor`), radii `8/14/22/32/999`, the official elevation
token, Manrope for Latin, Noto Sans Arabic for Arabic/Sorani, and the official
primary Waflo mark.

**Why:** The first Phase 1 review used partial palette values, platform font
fallbacks, and a temporary “W” mark, so it was not eligible for visual approval.

**Consequences:** Primitive, semantic, and component layers are separate.
Accessible status foreground/container pairs are tested; Coral and Warning use
Warm Ink where white fails. Font files and OFL licenses are bundled from the
official Google Fonts repository with no runtime font download.

## D-024 — Staff navigation has four operational destinations

**Decision:** `Accepted.` Staff navigation is Scan, Rewards, My Activity, and
Account. Manual customer search is a fallback inside Scan and is never a
top-level destination.

**Why:** Staff needs a focused counter workflow plus its own results/account,
without Owner/Manager configuration or a broad customer browser.

**Consequences:** Presentation capabilities control visibility, but the future
backend must still authorize every Business, Branch, and operation.

## D-025 — Blueprint governs V1 earning scope

**Decision:** `Accepted.` V1 Product Scope includes Visit/Stamp, Spend-based,
Item-based, Category-based, Completed Service, bounded Hybrid, and Welcome when
no Scheduler is required.

**Why:** These rules cover the approved business scenarios without making the
domain stamp-only or pulling scheduled campaigns into V1.

**Consequences:** Manual Adjustment is not an EarningRule. It is a protected
Secure Operations command requiring explicit permission, Reason, AuditLog, and
policy-based approval. Phase 1 exposes contracts only and no earning mutation.

## D-026 — Blueprint Planned V1 reward catalog is Product Scope

**Decision:** `Accepted.` V1 Product Scope includes Free Item, Free
Service/Add-on, Fixed Amount Discount, Percentage Discount, Item/Category
Discount, Buy X Get Y, Bundle/Combo, Multi-milestone, Voucher, and Welcome
Reward.

**Why:** These are the approved merchant outcomes and require distinct
eligibility/fulfillment guardrails rather than one custom text field.

**Consequences:** Phase 1 defines extensible presentation contracts only. It
does not claim Reward Engine, entitlement, inventory, discount calculation, or
redemption functionality.

## D-027 — Active is derived from the official Program lifecycle

**Decision:** `Accepted.` Program lifecycle is `DRAFT → VALIDATED → PUBLISHED →
PAUSED → ARCHIVED`. Active is derived from `PUBLISHED` plus temporal and
operational conditions, not stored as a parallel lifecycle state.

**Why:** A separate Active state can contradict schedule, pause, and operational
readiness and makes transition/audit logic ambiguous.

**Consequences:** V1 allows one Published program per Business and multiple
Draft/Archived programs. Contracts provide `isOperationallyActiveAt` without
adding backend enforcement or schema work in Phase 1.

## D-028 — Blueprint is production authority; Phase 1 Studio is preview-only

**Decision:** `Accepted.` The approved Blueprint supersedes earlier production
phase assumptions. Phase 1 Card Studio is an isolated preview foundation only.

**Why:** A visually convincing fixture must not be mistaken for upload, save,
publish, Wallet issuance, QR, Scheduler, or Loyalty functionality.

**Consequences:** Waflo preview is labeled exact/deterministic. Apple and Google
are structurally distinct and labeled `Platform approximation`; neither claims
real-device verification. Production enablement follows the Blueprint roadmap
and its human/security gates.

## Phase 1 approval status

The former open questions and Brand Alignment decisions were resolved by the
owner on 2026-07-23 through D-018–D-028. `HUMAN_VISUAL_PASS` is still withheld;
the remaining gate is the owner's visual/linguistic acceptance after reviewing
the regenerated evidence. Codex cannot issue that pass.
