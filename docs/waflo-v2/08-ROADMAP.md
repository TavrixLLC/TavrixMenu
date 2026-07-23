# Waflo V2 Roadmap

Status: `Planned`. Phase boundaries are release controls, not calendar promises. A phase is complete only when its deliverables and acceptance criteria are evidenced.

## Cross-phase rules

- Preserve Legacy code and data until an approved migration/cutover plan says otherwise.
- Keep the Flutter mobile application as the primary merchant surface; Customer Web stays lightweight and customer-facing.
- Resolve active Business from authoritative membership and fail closed on ambiguity.
- Treat customer tenant isolation, scanner replay/idempotency, and Wallet security as release blockers.
- Keep `LoyaltyProgram`, `Campaign/Event`, and `VisualTheme` as separate bounded concepts.
- Never change loyalty balances or rules through visual design/theme operations.
- No phase may claim `HUMAN_VISUAL_PASS`; visual acceptance remains a human gate.

## Phase 0 — Audit and planning

### Deliverables

- Verify Git branches, remotes, Worktrees, dirty state, unpushed commits, and the latest integrated baseline.
- Create immutable Legacy archive references and an isolated Waflo V2 branch/Worktree.
- Audit monorepo, Flutter, API, Prisma, Customer Web, Admin Web, auth, tenancy, loyalty, Wallet, QR/scanner, audit, billing, tests, and localization.
- Run available typechecks, tests, builds, and Flutter validation without changing Legacy behavior.
- Establish product vision, V1 scope, loyalty domain, mobile IA, design system, migration, security gates, roadmap, decisions, and Phase 1 implementation plan.
- Include Card Customization Studio and Seasonal Theme Engine architecture and release split.

### Acceptance criteria

- Archive branch/tag and V2 branch point to the verified baseline.
- Old Worktrees and dirty work remain untouched.
- All audit claims are labeled verified, unverified, planned, or deferred.
- Only `docs/waflo-v2/` planning files change in the V2 commit.
- Automated results and untested provider/device/security areas are reported honestly.

## Phase 1 — Foundations and design system

### Deliverables

- Create an isolated Waflo V2 Flutter feature shell and semantic design tokens.
- Implement role-aware navigation contracts and explicit workspace/branch context models without connecting unsupported mutations.
- Establish Arabic/Sorani/English typography, RTL/LTR utilities, accessibility primitives, state components, and golden/widget test foundations.
- Define provider-neutral CardDesign preview contracts, Studio UI primitives, and VisualTheme lifecycle types without persistence or scheduling.
- Define versioned API/domain DTO proposals for Business context, customer account, program, ledger, design, campaign, and theme boundaries.
- Produce human-reviewable reference screens for core states; do not publish or deploy.

### Acceptance criteria

- New code is isolated from Legacy UI generations and introduces no Prisma migration.
- Workspace ambiguity fails closed and logout/switch regression tests remain green.
- Components cover loading, empty, error, offline, permission, and confirmed success.
- Touch, contrast, text scaling, screen reader, RTL, and localization checks pass automated coverage where possible.
- CardDesign actions cannot mutate loyalty state by type/API design.
- A human visual review is requested and recorded separately before product acceptance.

## Phase 2 — Business onboarding

### Deliverables

- Account/session handoff, explicit Business selector, create Business, and real branch creation/selection.
- Owner onboarding checklist with backend-confirmed progress.
- Team invitation and membership role assignment for Owner/Manager/Staff.
- Safe resume/retry for partial onboarding and clear unsupported billing state.

### Acceptance criteria

- Multi-business users explicitly select an authorized Business; list order is irrelevant.
- Branch data is persisted and authorization-tested; no fake branch selector.
- Invitation, acceptance, role change, logout, and Business switch clear stale tenant data.
- All success states follow confirmed API responses and audit-sensitive actions are recorded.

## Phase 3 — Loyalty program builder

### Deliverables

- Business-scoped customer/account and multi-program schema implemented through an approved additive migration.
- Program builder for Stamp/Visit, fixed Points, Spend-based Points, and Product/Service-based earning.
- Rewards for free product/service, percentage discount, fixed discount, and custom reward.
- Draft, validate, publish, version, pause/retire policy, and program summary.
- Basic Card Customization Studio: logo/cover, colors, stamp shape/icon, reward media, base design draft/save/publish, and reusable starting design.

### Acceptance criteria

- Earning rules and reward definitions are independent and versioned.
- Every program type passes examples, boundary, precision, authorization, and historical-version tests.
- Program publication is idempotent, audited, and rejects incomplete/unsafe configuration.
- Basic visual customization is Business-scoped, contrast/media validated, and cannot modify balances/rules.
- Existing stamp records remain readable and unchanged.

## Phase 4 — Wallet and customer joining

### Deliverables

- Lightweight localized join page and Business-scoped customer registration/recovery.
- Customer card page, Apple Wallet issuance/update, and Google Wallet issuance/update through provider adapters.
- Live provider-aware previews in Card Studio, join-page customization, and QR Poster generation/export.
- Consent, contact verification, duplicate-account, transfer/recovery, and failure-state flows.

### Acceptance criteria

- Customer needs no Waflo app and can complete the journey on supported mobile browsers.
- Cross-Business identity/data access tests pass and enumeration is controlled.
- QR Poster links resolve only to their intended Business/program and remain scannable in print tests.
- Preview is labeled honestly and differs clearly from provider-confirmed issued state.
- Apple/Google sandbox and real-device evidence validates issuance and updates before release.

## Phase 5 — Scanner and earning

### Deliverables

- Staff-first scan shell, manual lookup fallback, program/branch context, amount/product entry, and confirmed receipt.
- Server-authoritative earning engine and append-only ledger.
- HMAC/key-versioned presentation validation, expiry/revocation policy, replay controls, and idempotency.
- Recent operations and authorized reversal/adjustment path.

### Acceptance criteria

- All four V1 earning methods pass unit, integration, concurrency, replay, and exact-retry tests.
- Duplicate request returns the original result; conflicting key reuse fails.
- Online failure is never shown as zero/empty/success; V1 offline mode remains read-only.
- Staff actions are branch/role-scoped and fully audited.
- Security review resolves all applicable scanner release blockers.

## Phase 6 — Rewards and redemption

### Deliverables

- Reward entitlement calculation/projection separated from earning balances.
- Redemption eligibility, reserve/confirm/cancel lifecycle, receipt, and reversal policy.
- Free product/service, percentage, fixed amount, and custom reward handling.
- Staff confirmation UX and recent redemption history.

### Acceptance criteria

- Concurrent scans cannot double-redeem an entitlement.
- Reward calculation uses the published historical program/reward version.
- Redemption is idempotent, Business/branch/role-scoped, and audited.
- Invalid, expired, unavailable, or offline cases do not decrement balances.
- Custom rewards expose explicit staff instructions and confirmation requirements.

## Phase 7 — Customers and reports

### Deliverables

- Business-scoped customer search, profile, memberships, balances, rewards, visits, transactions, and redemptions.
- Owner/Manager operational metrics and program/branch filters.
- Export policy and audit/activity views where authorized.
- Empty, stale, delayed, partial, and error-state reporting.

### Acceptance criteria

- No customer or aggregate can be accessed across Businesses or unauthorized branches.
- Metrics reconcile with ledger/redemption source data for fixed test fixtures.
- Loading/failed queries never render as zero.
- Exports are authorized, rate-limited, redacted where required, and audited.

## Phase 8 — Security, QA, and pilot

### Deliverables

- Tenant-isolation, authz, QR/scanner, replay, idempotency, media, Wallet, privacy, and operational security review.
- End-to-end Arabic/Sorani/English journeys on target iOS/Android devices and supported customer browsers.
- Accessibility, performance, reliability, backup/restore, monitoring, incident, support, and rollback exercises.
- Controlled pilot flags, selected Business onboarding, issue triage, and go/no-go evidence pack.

### Acceptance criteria

- Every gate in `07-SECURITY-AND-RELEASE-GATES.md` is closed with evidence or the release is blocked.
- All automated suites pass with no unexplained flaky failures.
- Real Wallet, camera, poor-network, timezone, print QR, and device-switch scenarios pass.
- Required human product, visual, security, data, migration, deployment, and pilot approvals are recorded.
- Rollback preserves ledger/audit history and has been rehearsed.

## V1.5 — Seasonal Theme Engine and advanced Studio

This increment may proceed after V1 foundations or earlier only if it cannot delay security and Wallet reliability.

### Deliverables

- Named reusable design templates and controlled duplication across programs.
- Seasonal presets for Ramadan, Eid, New Year, Birthday, Black Friday, business anniversary, and custom occasions.
- `Draft/Scheduled/Active/Expired` theme lifecycle with preview, `startAt`, `endAt`, Business timezone, manual controls, and automatic transitions.
- Multi-program theme assignment, overlap/conflict policy, design revision history, and automatic base-design fallback.
- Independent Campaign/Event management and optional association with a VisualTheme.

### Acceptance criteria

- Scheduler actions are idempotent, leased/locked, auditable, and timezone-tested.
- Overlap resolution is deterministic and visible before publish.
- Theme activation/expiry changes visual projections only; ledger, balances, rules, rewards, and redemptions remain byte-for-byte unchanged in regression fixtures.
- Wallet/customer/join/poster outputs fall back to the correct published base design after expiry.
- Authorized users can preview without sending customer notifications or publishing.

## Future — Waflo Growth Menu and AI recommendations

### Potential deliverables

- Separately packaged menu management/growth tools.
- Performance insights and explainable recommendation assistance.
- Campaign suggestions that require merchant review and explicit publish action.

### Entry criteria

- Loyalty V1 is stable and tenant/security gates remain green.
- Growth Menu has a separately approved product scope, permissions, data policy, pricing, and release plan.
- Existing menu features are preserved during evaluation; they are not silently coupled to loyalty programs.
- AI suggestions never execute pricing, menu, campaign, or customer communication changes without human confirmation.
