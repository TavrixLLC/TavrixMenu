# Waflo V2 Roadmap

Status: `PLANNED`. The approved Loyalty, Customization & Security Blueprint is
the production-phase authority. A phase is complete only after its acceptance
criteria and human gates pass; UI previews do not imply backend capability.

## Cross-phase rules

- Preserve Legacy until validated cutover and rollback evidence exist.
- Customer and Branch tenant isolation are release blockers.
- No value-changing success before backend confirmation.
- No production migration, merge, deployment, Wallet issuance, notification,
  or financial action without its explicit human gate.
- `LoyaltyProgram`, `Campaign/Event`, and `VisualTheme` remain separate.
- W2A workspace/scanner isolation and late-result protection are regression
  invariants.

## Phase 0 — Audit and planning

### Deliverables

- Git/Worktree/branch evidence and immutable Legacy archive references.
- Verified current-state audit, product scope, domain proposal, IA, security
  gates, migration strategy, decisions, and Phase 1 plan.

### Acceptance criteria

- No Legacy code or dirty Worktree was overwritten.
- Baseline claims distinguish verified, unverified, planned, and deferred.

## Phase 1 — V2 Foundation

### Deliverables

- Isolated `apps/mobile/lib/waflo_v2/` namespace.
- Official primitive → semantic → component tokens, local Manrope and Noto Sans
  Arabic fonts with OFL licenses, RTL/LTR localization, spacing, radii, shadow,
  accessibility primitives, and role-aware shell.
- Owner/Manager shell and final Staff navigation: Scan, Rewards, My Activity,
  Account; manual customer search is a fallback inside Scan.
- Truthful loading/empty/error/offline/disabled states.
- Preview-only Card Studio contracts with five independent colors and clearly
  distinct deterministic Waflo vs Apple/Google platform approximations.
- Presentation contracts for Blueprint earning/reward catalogs, official
  program lifecycle, Business-scoped identity, and Branch visibility.

### Acceptance criteria

- Arabic/Sorani RTL and English LTR widget/localization tests pass, including
  360dp large text.
- Contrast, typography, asset, role, workspace, and preview-fidelity tests pass.
- Full Flutter/Legacy regression suite and isolated Web review build pass.
- Production bootstrap, Legacy, Backend, Prisma, QR, upload, Wallet issuance,
  Scheduler, and Loyalty mutations remain untouched.
- Human visual/linguistic approval is recorded separately; Codex cannot issue
  `HUMAN_VISUAL_PASS`.

## Phase 2 — Identity, Workspace, Branches, and Team

### Deliverables

- OTP authentication/recovery flows and authoritative active-Business selection.
- Business/Branch create and explicit branch membership assignments.
- Owner/Manager/Staff invites, roles, capabilities, and session/device controls.
- Business-scoped `CustomerAccount` implementation plan and approved migration.

### Acceptance criteria

- Ambiguous multi-Business state fails closed; switching clears tenant data.
- Owner sees all Branches; Manager/Staff see only assigned Branches; backend
  independently authorizes every Business/Branch operation.
- Recovery cannot merge/transfer CustomerAccount across Businesses and every
  exceptional recovery records Actor, Reason, Timestamp, and AuditLog.

## Phase 3 — Loyalty Program Builder

### Deliverables

- Goal/templates and validated V1 EarningRule catalog: Visit/Stamp, Spend,
  Item, Category, Completed Service, Hybrid, and non-scheduled Welcome.
- Full Blueprint Planned V1 RewardDefinition catalog and economics guardrails.
- Lifecycle `DRAFT → VALIDATED → PUBLISHED → PAUSED → ARCHIVED`; Active is
  derived from Published plus temporal/operational conditions.
- One Published program per Business in V1, with multiple Draft/Archived.

### Acceptance criteria

- Rules and rewards are independent, versioned, tenant-scoped concepts.
- Item/category/service inputs use authoritative identifiers.
- Invalid reward economics are blocked; publish requires validated terms and
  branch scope.
- No direct Ledger counter or Legacy stamp reinterpretation is introduced.

## Phase 4 — Secure Operations

### Deliverables

- Scanner and manual-search fallback, customer lookup, Earn, Reward grant,
  Redeem, approval, append-only Ledger, refund, and reversal services.
- Idempotency, replay prevention, limits, anomaly signals, and AuditLog.
- Protected Manual Adjustment command with permission, Reason, evidence, audit,
  and policy-based Manager/Owner approval.

### Acceptance criteria

- No offline earning/redemption in V1 and no success before confirmation.
- Concurrent/retried Earn and Redeem cannot duplicate value.
- Full/partial refund appends linked reversal under the original rule; negative
  balance blocks new redemption until Available Balance is sufficient.
- Cross-Business/Branch, QR replay, self-award, and adjustment-abuse tests pass.

## Phase 5 — Customer Experience and Wallet

### Deliverables

- Lightweight Customer Web enrollment, verification, activity, recovery, and
  Waflo customer card.
- Apple Wallet and Google Wallet issuance/update/revocation through approved
  adapters, with secure membership/card tokens.

### Acceptance criteria

- Customers need no Waflo app and cannot take over a card with known contact
  data alone.
- iPhone/Android real-device issuance, update, barcode/QR scanning, and failure
  cases pass a human/device gate.
- Preview, provider confirmation, sync, and device verification remain distinct.

## Phase 6 — Card Studio V1 production enablement

### Deliverables

- Quick/Pro modes, five colors, logo/cover/reward media upload from phone,
  card/stamp/reward visual controls, join page, QR Poster, and versioning.
- Deterministic Waflo preview and provider-constrained Apple/Google previews.
- Business-scoped drafts, test mode, safe validation, save/publish, and rollback.

### Acceptance criteria

- Upload validation, tenant storage, malware/type/size checks, and signed URL
  policies pass.
- Publishing a design never mutates program economics, balances, rules,
  entitlements, Ledger, or redemption.
- Provider safe areas and real-device results pass; approximations remain labeled.

## Phase 7 — Customers, Analytics, and Operations

### Deliverables

- Tenant-scoped customer/activity views, role-scoped reports, branch comparison,
  pending approvals, anomaly review, privacy workflows, and audited exports.

### Acceptance criteria

- Staff sees only necessary own/branch activity and no hidden revenue/PII.
- Metrics reconcile to Ledger and label correlation vs causal claims.
- Export/delete/support actions have permission, step-up, rate, and audit gates.

## Phase 8 — V1.5 Growth

### Deliverables

- Seasonal Theme Engine with reusable Ramadan, Eid, New Year, Birthday, Black
  Friday, anniversary, and custom templates.
- Scheduling, preview-before-publish, automatic activation/expiry, multi-program
  assignment, conflict policy, base-design fallback, and Wallet propagation.
- Birthday, Referral, VIP tiers, slow-hour/item spotlight, and lapsed campaigns.

### Acceptance criteria

- Timezone/DST, overlap, retries, rollback, and provider propagation tests pass.
- Theme start/end cannot change Loyalty rules, balances, Ledger, rewards, or
  redemptions; expiry restores the approved base design automatically.
- Consent, frequency, fraud, and campaign-budget controls pass.

## Phase 9 — Hardening and migration

### Deliverables

- Approved additive migrations, dry-run/backfill/reconciliation, staged rollout,
  observability, backup restore drill, security/load tests, and rollback.

### Acceptance criteria

- Customer tenant isolation, MASVS/API authorization matrix, Wallet/device, QR,
  concurrency, idempotency, and incident-response release gates pass.
- Real data reconciles with Legacy and rollback is proven before cutover.

## Phase 10 — Legacy deletion

### Deliverables

- Remove Legacy routes/code only after complete V2 cutover, retention approval,
  and recovery archive confirmation.

### Acceptance criteria

- Stable staged production period, reconciled data, no required Legacy consumer,
  and explicit human deletion approval.

## Future — Waflo Growth Menu and AI recommendations

Growth Menu remains a separately approved product/package. It may provide
neutral item/service references to Loyalty but does not own the Loyalty domain.
