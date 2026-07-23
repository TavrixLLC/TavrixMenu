# Waflo V2 Current-State Audit

Audit date: 2026-07-23 (Asia/Baghdad)

Audited baseline: `1c95c8c293b3fd2175ece3bbfd20bd81a39030f8`
Phase: `Phase 0 — audit and planning`

## Status vocabulary

- `EXISTING_VERIFIED`: inspected in source and covered by a successful check in this audit.
- `EXISTING_UNVERIFIED`: present in source, but not proven end to end in the target environment.
- `PLANNED`: approved direction with no implementation claim.
- `DEFERRED`: intentionally outside V1 or moved to a later release.
- `BLOCKED`: must not be released until the named gate is closed.

## Executive verdict

The repository is a real monorepo with reusable NestJS, PostgreSQL/Prisma,
Clerk authentication, business roles, stamp loyalty, Apple/Google Wallet,
scanner, media, Customer Web, and a tested Flutter application. It is not yet a
multi-program loyalty platform. The current data model is stamp-centric,
`Customer` identity is global, `Branch` does not exist, Billing/Admin backend
modules are empty, audit coverage is sparse, and multi-business selection is
fail-closed but has no selector.

The selected legacy baseline is the latest remote Waflo head on the integrated
Waflo sequence, not a claim that every repository branch was merged. It was
verified after selection with 578 passing automated tests, three successful
typechecks, and three successful production builds.

No Legacy source file was changed during Phase 0. Dependency installation,
generation, analysis, tests, and builds left the worktree with no tracked diff
before this documentation was added.

## Git source audit

### Original checkout

| Item | Observed value |
| --- | --- |
| Path | `D:\install\business\TavrixMenu` |
| Branch | `codex/waflo-codex-tooling-v1` |
| HEAD | `f562a143ca504b61e99155adca9519edfb143f60` |
| Status | Clean; `0 ahead / 0 behind` its same-name `origin` ref |
| Remote | `origin = https://github.com/TavrixLLC/TavrixMenu` |
| Remote refresh | `git fetch origin --tags` succeeded; no prune was used |

`main` and `dev` are not the newest Waflo state:

- local `main` is `545ada63...`; `origin/main` is `03b2d194...` and the two are
  not equal;
- `dev` and `origin/dev` are both `e85f1670...`;
- the selected Waflo baseline is 22 commits ahead of `dev` and contains it;
- `origin/main` has a divergent merge commit that is not an ancestor of the
  selected Waflo line. It must not be used as a freshness proxy.

### Baseline decision

Selected commit:

```text
1c95c8c293b3fd2175ece3bbfd20bd81a39030f8
feat(mobile): add three-language localization foundation
2026-07-22T18:12:13+03:00
```

Evidence:

1. It is the newest remote Waflo head by commit date after refreshing `origin`.
2. `codex/waflo-localization-foundation-v1` is clean in its existing worktree.
3. Local and remote refs are identical; it has no unpushed commit.
4. It contains `origin/dev`, the verified W2A isolation commit
   `f9abd774...`, product doctrine, V2/V3 UI foundations, V3 menu/product flow,
   product-surface documentation, and localization.
5. The complete checks in this document pass at this exact tree.

Important exception: `codex/sprint-14d-a-mobile-menu-item-iqd-upload-audit`
at `b5e7fecb...` diverges by one commit from `e85f1670...`; the selected baseline
contains 22 commits that branch does not contain, while that branch contains one
commit absent from the baseline. It was not silently merged.

### Relevant ahead/behind topology

Counts are relative to the selected baseline. `Baseline only` means commits in
`1c95c8c...` but not in the compared ref.

| Ref | Commit | Baseline only | Ref only | Result |
| --- | --- | ---: | ---: | --- |
| `origin/codex/waflo-localization-foundation-v1` | `1c95c8c...` | 0 | 0 | Exact match |
| `origin/dev` | `e85f1670...` | 22 | 0 | Ancestor of baseline |
| `origin/codex/waflo-v2-w2a-scanner-context-isolation-fix` | `f9abd774...` | 16 | 0 | Ancestor; invariant preserved |
| `origin/codex/waflo-v3-m1p1-menu-product-flow` | `25d5944f...` | 2 | 0 | Ancestor |
| `origin/codex/waflo-product-surface-split-v1` | `aeeacf45...` | 1 | 0 | Direct parent |
| `origin/codex/sprint-14d-a-mobile-menu-item-iqd-upload-audit` | `b5e7fecb...` | 22 | 1 | Diverged; not merged |
| `origin/main` | `03b2d194...` | 164 | 1 | Diverged historical line |

### Important recent commit sequence

The selected linear Waflo sequence after `dev` includes:

- `312e5752` — Waflo UI/UX V2 blueprint.
- `06c6be52` — V2 design system foundations.
- `7841295b` — V2 shell/navigation.
- `58b6e5b1` — guided walkthrough doctrine.
- `d238926a` — first-run owner wizard.
- `f9abd774` — W2A workspace/scanner-context isolation.
- `37a52909` — Mobile UI V3 visual foundation.
- `f562a143` — repository safety guards.
- `7a3f7896` through `8597baeb` — V3 tokens, primitives, navigation, and shell.
- `25d5944f` — V3 menu/product flow.
- `aeeacf45` — product surface split.
- `1c95c8c2` — Arabic/Sorani/English localization foundation.

## Archive preservation

Both refs were created without checking out or moving the source branch:

| Ref | Type | Target | Remote state |
| --- | --- | --- | --- |
| `archive/waflo-legacy-2026-07-23` | Branch | `1c95c8c293b3fd2175ece3bbfd20bd81a39030f8` | Pushed to `origin` |
| `waflo-legacy-2026-07-23` | Annotated tag | `1c95c8c293b3fd2175ece3bbfd20bd81a39030f8` | Pushed to `origin` |

The tag object is `1fb85549...`; `git rev-list -n 1` and `git cat-file`
confirm that it peels to the selected commit.

## Worktree audit

All pre-existing worktrees were preserved. No branch was moved and no existing
worktree was removed.

| Path | Branch / HEAD | Working state | Same-name remote state |
| --- | --- | --- | --- |
| `TavrixMenu` | `codex/waflo-codex-tooling-v1` / `f562a143` | Clean | 0 ahead, 0 behind |
| `TavrixMenu-closeout` | `codex/sprint-13-media-upload-e2e-closeout` / `5378798c` | Clean | 0/0 |
| `TavrixMenu-google-auth` | `codex/sprint-14e-auth-a-real-google-signin` / `b5e7fecb` | **5 modified tracked files** | No same-name remote; HEAD exists on remote under Sprint 14d ref |
| `TavrixMenu-login-ux` | `codex/sprint-14e-a1-login-ux-blueprint` / `b5e7fecb` | **1 modified tracked file** | No same-name remote; HEAD exists on remote under Sprint 14d ref |
| `TavrixMenu-ops` | `codex/sprint-14d-ops-smoke-config-fixture` / `e85f1670` | **3 untracked files** | No same-name remote; HEAD is reachable from `origin/dev` |
| `TavrixMenu-wt-l10n-v1` | `codex/waflo-localization-foundation-v1` / `1c95c8c` | Clean | Exact same-name remote; 0/0 |
| `TavrixMenu-wt-mobile-ux-core-v1` | `codex/waflo-mobile-ux-core-v1` / `1c95c8c` | **22 modified + 6 untracked files** | No same-name remote; HEAD exists on remote under localization ref |
| `TavrixMenu-wt-v3-f1a` | `codex/waflo-v3-f1a-design-tokens-pilot` / `7a3f7896` | Clean | 0/0 |
| `TavrixMenu-wt-v3-f1b` | `codex/waflo-v3-f1b-theme-buttons` / `c9720220` | Clean | 0/0 |
| `TavrixMenu-wt-v3-f1c` | `codex/waflo-v3-f1c-content-primitives` / `ad81b9ec` | Clean | 0/0 |
| `TavrixMenu-wt-v3-f2a` | `codex/waflo-v3-f2a-workspace-navigation` / `92f75cbe` | Clean | 0/0 |
| `TavrixMenu-wt-v3-f2b` | `codex/waflo-v3-f2b-app-shell-integration` / `8597baeb` | Clean | 0/0 |
| `TavrixMenu-wt-v3-m1p1` | `codex/waflo-product-surface-split-v1` / `aeeacf45` | Clean | 0/0 |
| `TavrixMenu-wt-waflo-v2` | `waflo-v2-mobile-first` / `1c95c8c` at creation | Clean before docs | Push pending final Phase 0 commit |

The dirty worktrees contain uncommitted work and were treated as protected.
They were read only for status. There is no evidence of a unique unpushed
commit at their current HEADs, but their uncommitted files are not on `origin`
and remain the owners' responsibility.

Five pre-existing stashes were also preserved: failed V2 owner visual review,
preserved 14e UI WIP, Apple Wallet visual WIP, and two customer-wallet/returning
loyalty WIP stashes. No stash was applied, dropped, or rewritten.

## Branch inventory

At the audit snapshot there were 95 local branches and 94 named remote branches
plus the symbolic `origin` ref. `waflo-v2-mobile-first` was local and unpushed;
the Archive branch was already remote. The complete names were inspected with:

```powershell
git for-each-ref --sort=refname --format='%(refname:short)' refs/heads
git for-each-ref --sort=refname --format='%(refname:short)' refs/remotes/origin
```

The large inventory confirms that branch date alone is not a completeness
signal. Relevant Waflo, `main`, `dev`, active worktree, Archive, and divergent
Sprint refs are recorded above with hashes and topology. No branch was deleted,
renamed, reset, or merged.

## Monorepo structure

| Area | Technology | Audit result |
| --- | --- | --- |
| Root workspace | pnpm 10.12.1 + Turbo | 7 pnpm projects; Flutter is outside pnpm workspace |
| `apps/api` | NestJS 11, TypeScript, Prisma 6, PostgreSQL | `EXISTING_VERIFIED` build/typecheck/unit coverage |
| `apps/mobile` | Flutter 3.41.9, Dart 3.11.5, Bloc/Cubit, Dio, Clerk beta | `EXISTING_VERIFIED` analyze/tests; current UI has multiple generations |
| `apps/customer-web` | Next.js 15, React 19 | `EXISTING_VERIFIED` tests/build; menu, join, card, wallet routes exist |
| `apps/admin-web` | Next.js 15, React 19, Clerk | `EXISTING_UNVERIFIED` as product; build/typecheck pass, no test script, contains mock data |
| `packages/config` | Shared config | `EXISTING_UNVERIFIED` in isolation |
| `packages/menu-templates` | Public menu template package | Exercised by API/Customer Web tests |
| `packages/shared-types` | Shared TypeScript types | Reusable, but not the new loyalty domain authority |

## Technical capability audit

### Authentication, business context, and roles

- Clerk bearer verification and current-user synchronization exist.
- `GET /me` returns all active `BusinessUser` memberships and the real role per
  membership.
- Server-side `BusinessAccessService` verifies active membership and role.
- Roles are `OWNER`, `MANAGER`, and `STAFF`; permission booleans are real but
  currently coarse.
- Flutter's business data source rejects more than one business instead of
  choosing by list position. This is safe fail-closed behavior.
- Flutter still routes any user with a business toward the shell and derives a
  top-level role from the first active membership. There is no authoritative
  workspace selector, so multi-business support is `BLOCKED`.
- W2A principal/workspace clearing and late scanner-result rejection are
  implemented and covered by Flutter tests. This is a regression invariant.

### Businesses and branches

- `Business`, owner relation, `BusinessUser`, profile, dashboard summary,
  membership administration, public link, menu appearance, and tenant checks
  exist.
- **No `Branch` Prisma model, relation, controller, API route, or Flutter domain
  exists.** Branch support is `PLANNED`, not reusable existing behavior.

### Loyalty

Current loyalty is strictly stamp-oriented:

- `LoyaltyProgram.stampGoal` and reward name/description;
- `LoyaltyMembership.stampCount`, `rewardReady`, lifetime stamp/reward totals;
- `LoyaltyTransaction.stampsDelta` with stamp-specific event types;
- only one active program is normally allowed per business;
- row-level `FOR UPDATE` protects stamp earning/redemption concurrency;
- no request idempotency key, generic ledger, points/spend/product rules,
  reward definition entity, entitlement instance, campaign, or tier model.

The public join flow hashes card tokens, requires Iraqi phone format, blocks
unverified recovery, and has secure one-time transfer foundations. However,
`Customer.phone` and `Customer.email` are globally unique and the same global
customer row may be reused across businesses. Customer tenant isolation remains
a `BLOCKED` release gate before Loyalty.

### Wallet, QR, scanner, and media

- Google Wallet class/object/save URL, refresh job, and scanner foundations are
  present and heavily unit tested with mocked provider boundaries.
- Apple pass generation, signed update web service, device registration,
  update markers, and APNs job foundations exist. Real installed-card refresh
  on physical devices was not run in Phase 0 and remains
  `EXISTING_UNVERIFIED`.
- Wallet scan tokens are HMAC-signed, hashed at rest, business-bound, and
  versioned. The current token has no explicit expiry and can be scanned
  repeatedly until rotated.
- Scan lookup is read-only, but the subsequent stamp mutation has no backend
  idempotency key. Duplicate retries/replays are therefore a V2 security risk.
- Customer Web and mobile QR foundations exist. A decorative/fallback QR is not
  acceptable product truth.
- Media upload validates purpose/type/size and normalizes images. Mobile image
  selection/upload integration is incomplete.

### Audit, billing, and admin

- `AuditLog` exists, but the only non-generated `auditLog.create` site found is
  menu appearance update. Loyalty earning, redemption, staff changes, program
  changes, wallet actions, and security events lack a complete audit trail.
- `Plan` and `Subscription` schema models exist.
- `BillingModule`, `AdminModule`, and `UsersModule` are empty runtime modules.
- The API contract documents Billing/Admin endpoints that the runtime modules
  do not implement. Contract/runtime drift must be corrected before those
  endpoints are presented as available.
- Admin Web contains real API clients for some owner workflows but also
  `mock-data.ts`; it is not an authoritative merchant dashboard or billing
  product.

### Localization and UI generations

- Flutter contains Arabic (`ar`), Kurdish Sorani (`ckb`), and English (`en`)
  ARB files, generated localizations, explicit RTL for Arabic/Sorani, locale
  persistence, and framework localizations for Sorani.
- Localization consistency tests pass. Linguistic/visual acceptance on real
  devices remains a human gate.
- Legacy `AppTheme`, UI V2 tokens/widgets, and UI V3 tokens/widgets coexist.
  Waflo V2 must establish one new canonical namespace and must not incrementally
  polish all old generations.

## Verification results

Toolchain: Node `v24.12.0`, pnpm `10.12.1`, Flutter `3.41.9`, Dart `3.11.5`.

| Check | Result | Numeric evidence |
| --- | --- | --- |
| API typecheck | PASS | `tsc --noEmit`, 0 errors |
| API tests | PASS | 204 tests, 38 suites, 204 passed, 0 failed/skipped |
| API build | PASS | Nest production build completed |
| Customer Web tests | PASS | 65 tests, 17 suites, 65 passed, 0 failed/skipped |
| Customer Web typecheck | PASS | 0 errors |
| Customer Web build | PASS | 10 routes built; 5 static pages generated |
| Admin Web tests | NOT AVAILABLE | No `test` script in `apps/admin-web/package.json` |
| Admin Web typecheck | PASS | 0 errors |
| Admin Web build | PASS | 7 routes reported; 9 static pages generated |
| Flutter analyze | PASS | `No issues found` |
| Flutter tests | PASS | 309 passed, 0 failed |
| Tracked diff after checks | PASS | Empty `git status`, empty `git diff --check` |

Automated test total: **578 passed, 0 failed**. This does not include live
database migrations, real Clerk sign-in, real wallet provider calls, physical
Apple/Google Wallet device behavior, payment flows, offline device QA, security
penetration testing, or human visual/linguistic acceptance.

## Priority findings

### Release blockers

1. Replace global customer ownership with verifiable business-scoped customer
   accounts before Loyalty release.
2. Add authoritative multi-business workspace selection; preserve fail-closed
   behavior until complete.
3. Complete scanner/Loyalty security audit: idempotency, replay/rotation,
   mutation authorization, rate limiting, abuse resistance, and negative E2E.
4. Implement Branch as a first-class tenant-owned entity before claiming the
   onboarding journey supports branches.
5. Verify installed Apple Wallet updates and Google Wallet behavior on real
   devices.

### High-priority architecture gaps

1. Replace stamp counters as domain authority with immutable loyalty events and
   a generic ledger.
2. Separate earning rules, reward definitions/eligibility, redemption, tiers,
   campaigns/events, and visual themes.
3. Add backend idempotency and an audit event for every value mutation.
4. Define provider-neutral card presentation and preview contracts.
5. Keep visual theme changes isolated from balances, earning rules, reward
   entitlements, and redemption state.

### Reusable foundations

- NestJS module structure, validation, OpenAPI patterns, Prisma/PostgreSQL, and
  transactional row locking.
- Clerk authentication and authoritative `BusinessUser` roles.
- `Business` ownership, tenant-aware service patterns, menu/media foundations.
- Apple/Google Wallet provider adapters, token hashing, refresh job pattern.
- Customer Web join/card/wallet route structure, after tenant remediation.
- Flutter network/error/state architecture, localization foundation, W2A
  isolation, and tested UI primitives where they meet the new system.
- Existing automated test suite and safety guards.

## Phase 0 mutation boundary

Allowed changes in this branch are limited to `docs/waflo-v2/`. No Prisma
migration, schema change, application-code change, branch merge, reset,
worktree move, destructive command, deployment, or Pull Request belongs to
Phase 0.
