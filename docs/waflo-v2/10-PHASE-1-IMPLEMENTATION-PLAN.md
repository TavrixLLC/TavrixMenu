# Phase 1 Implementation Plan

Status: `Implemented in the working tree — human visual/linguistic gate open; not committed or pushed`. The owner approved the plan and resolved its six open decisions on 2026-07-23. The implementation introduces no Prisma migration, production API, scheduler, deployment, customer notification, or live Wallet action.

## 1. Phase objective

Create a clean, testable Waflo V2 Flutter foundation that can host the later Business onboarding and loyalty journeys without modifying or deleting Legacy UI behavior. Establish semantic design tokens, localization/RTL/accessibility foundations, role/workspace navigation contracts, honest application states, and pure CardDesign/VisualTheme preview contracts.

Phase 1 does not implement the loyalty ledger, customer migration, program persistence, earning, redemption, branch persistence, live media upload, live Wallet issuance, or seasonal scheduler.

## 2. Preconditions and human gates

Before implementation:

1. Confirm the decisions and open questions in `09-DECISIONS.md`, especially customer identity, program cardinality, branch permission model, points precision, Card Studio V1/Seasonal V1.5 split, and isolated Flutter namespace.
2. Confirm work occurs only on `waflo-v2-mobile-first` in its dedicated Worktree and starts from a clean status.
3. Re-run the existing API/Web/Flutter baseline if the branch has advanced.
4. Obtain approval before adding any third-party font/package or generated asset.
5. Schedule human Arabic/Sorani visual review. Codex can prepare evidence but cannot issue `HUMAN_VISUAL_PASS`.

## 3. Proposed code boundary

Use a new isolated namespace rather than extending existing V2/V3 generations in place:

```text
apps/mobile/lib/waflo_v2/
  app/
  core/
    accessibility/
    localization/
    navigation/
    state/
    theme/
    workspace/
  features/
    home/
    programs/
    scan/
    customers/
    more/
    card_studio/
  shared/
    components/
    models/
```

The exact entry-point integration must be the smallest reversible seam discovered during implementation. Legacy `lib/features/v2`, `lib/features/v3`, existing routes, and current product flows remain unchanged unless the approved Phase 1 slice explicitly needs an additive entry behind a development-only flag.

Expected test boundary:

```text
apps/mobile/test/waflo_v2/
  core/
  features/
  golden/
```

No file path is authorized merely by appearing here. Inspect nested `AGENTS.md`, current imports, generated localization rules, and dirty status again before editing.

## 4. Work packages and order

### WP1 — Baseline characterization and dependency map

Tasks:

- Record Flutter/Dart versions, current routing, app bootstrap, state management, HTTP/auth integration, theme generations, localization generation, assets, and test utilities.
- Add characterization tests only where the new seam could regress W2A workspace/logout/scanner isolation.
- Map generated files and commands so no generated localization file is hand-edited.
- Propose any new dependency separately with purpose, maintenance/security review, and no-dependency alternative.

Expected files:

- Existing tests only if an uncovered regression invariant requires an additive test.
- `apps/mobile/test/waflo_v2/...` for new isolated tests.
- No production feature behavior yet.

Exit criteria:

- Clean baseline passes and new namespace/import direction is documented in the implementation commit or review notes.
- No Legacy snapshot/golden is silently rewritten.

### WP2 — Semantic tokens and theme extension

Tasks:

- Implement primitive, semantic, and component tokens from `05-DESIGN-SYSTEM.md`.
- Encode approved brand colors, text/status colors, 4 dp spacing grid, radii, elevation, and 48 dp touch minimum.
- Select typography only after Arabic/Sorani glyph and license review; otherwise retain an explicit system-font fallback.
- Add light theme only; structure tokens so a future dark palette is additive.

Expected files:

- `apps/mobile/lib/waflo_v2/core/theme/waflo_colors.dart`
- `apps/mobile/lib/waflo_v2/core/theme/waflo_spacing.dart`
- `apps/mobile/lib/waflo_v2/core/theme/waflo_radii.dart`
- `apps/mobile/lib/waflo_v2/core/theme/waflo_typography.dart`
- `apps/mobile/lib/waflo_v2/core/theme/waflo_theme.dart`
- Focused token/theme tests under `apps/mobile/test/waflo_v2/core/theme/`.

Exit criteria:

- Feature code consumes semantic tokens, not raw brand hex values.
- Contrast tests cover approved foreground/background pairs.
- Theme does not alter existing app theme when the development flag is off.

### WP3 — Localization, bidi, and accessibility primitives

Tasks:

- Reuse the generated `ar`, `ckb`, and `en` localization foundation.
- Provide locale direction helpers, bidi isolation for phone/money/code, text-scale-safe layout helpers, semantic labels, focus order, and reduced-motion access.
- Define localized status/error/action keys for the new shell through the repository’s generation process.
- Add pseudo-long-content fixtures or equivalent overflow coverage without inventing customer-visible translations.

Expected files:

- `apps/mobile/lib/waflo_v2/core/localization/...`
- `apps/mobile/lib/waflo_v2/core/accessibility/...`
- Authorized source localization files and generated outputs only if the existing generator requires them.
- Tests under `apps/mobile/test/waflo_v2/core/localization/` and `accessibility/`.

Exit criteria:

- Arabic/Sorani render RTL and English LTR.
- Directional icons, phone, currency, codes, and dynamic type have automated widget coverage.
- Human linguistic quality remains explicitly pending until reviewed.

### WP4 — Honest state and shared components

Tasks:

- Implement page/surface states for initial loading, refreshing, empty, recoverable error, forbidden, offline read-only, stale data, submitting, confirmed success, and unsaved draft.
- Implement the minimum shared components needed to render them: buttons, inputs, cards, status chips, banners, skeletons, retry, and bottom sheet/dialog shell.
- Prevent local-only fake success: component APIs require confirmed outcomes for success presentation.

Expected files:

- `apps/mobile/lib/waflo_v2/core/state/...`
- `apps/mobile/lib/waflo_v2/shared/components/...`
- Widget and semantics tests under `apps/mobile/test/waflo_v2/shared/components/`.

Exit criteria:

- Failure is not encoded as empty/zero.
- Disabled/submitting semantics and backend-confirmed success are distinguishable.
- Minimum targets, focus, screen reader names, text scaling, and RTL pass tests.

### WP5 — Role-aware shell and workspace contracts

Tasks:

- Define immutable `ActiveWorkspace`, `ActiveBranchContext`, `MembershipRole`, and navigation-policy models based on authoritative backend membership data.
- Build the planned bottom navigation destinations: Home, Programs, Scan, Customers, More, with Staff’s reduced presentation.
- Implement multi-Business ambiguity, no-membership, selector-required, and unauthorized-role states as explicit routes/models.
- Preserve W2A late-result and logout/Business-switch clearing invariants.
- Use fixtures/adapters only in tests and development previews; label non-live screens and disable mutations.

Expected files:

- `apps/mobile/lib/waflo_v2/core/workspace/...`
- `apps/mobile/lib/waflo_v2/core/navigation/...`
- `apps/mobile/lib/waflo_v2/app/waflo_v2_app_shell.dart`
- Placeholder feature entry screens under `features/*/presentation/` with informational/disabled unsupported actions only.
- Tests under `apps/mobile/test/waflo_v2/core/workspace/`, `navigation/`, and `app/`.

Exit criteria:

- No selection by membership list order.
- Owner/Manager/Staff destination policy is deterministic and tested, while server checks remain authoritative.
- Workspace/session switch cannot display stale prior-Business data or scanner context.

### WP6 — Card Customization Studio primitives

Tasks:

- Define pure client models for `CardDesignDraft`, design revision, color/media/stamp/reward visual values, provider preview capabilities, and validation results.
- Implement non-publishing Studio layout primitives: step navigation, accessible color input, media placeholder states, stamp/icon selectors, preview viewport, and draft/publish status presentation.
- Implement fixture-driven `JoinPagePreview`, `QrPosterPreview`, `AppleWalletPreview`, and `GoogleWalletPreview` clearly labeled as previews.
- Ensure models contain presentation data only and cannot encode balance/rule mutations.

Expected files:

- `apps/mobile/lib/waflo_v2/features/card_studio/domain/...`
- `apps/mobile/lib/waflo_v2/features/card_studio/presentation/components/...`
- `apps/mobile/lib/waflo_v2/features/card_studio/presentation/card_studio_preview_screen.dart`
- Tests under `apps/mobile/test/waflo_v2/features/card_studio/` and selected golden tests.

V1 baseline represented in the contracts:

- Logo, cover, primary/secondary/background/text colors.
- Stamp shape/icon and reward image/icon.
- Join page, QR Poster, Apple Wallet, and Google Wallet projections.
- Base design revision and reusable-source reference.

Exit criteria:

- Unsafe contrast and invalid asset/QR/provider constraints produce explicit validation errors.
- No upload, save, publish, Wallet issuance, QR export, or notification is faked.
- Fixture previews are isolated from production repositories/services.

### WP7 — Seasonal Theme Engine contracts only

Tasks:

- Define pure types for `CampaignEvent`, `VisualTheme`, `ThemeAssignment`, `ThemeStatus`, scheduled window, Business timezone, and resolved visual projection.
- Encode `Draft`, `Scheduled`, `Active`, and `Expired` states and invariant `endAt > startAt`.
- Define deterministic base-design fallback and overlap-result types without implementing scheduler priority policy before approval.
- Add boundary tests demonstrating that theme resolution cannot change loyalty program rules or balance fixtures.

Expected files:

- `apps/mobile/lib/waflo_v2/features/card_studio/domain/visual_theme.dart`
- `apps/mobile/lib/waflo_v2/features/card_studio/domain/campaign_event.dart`
- `apps/mobile/lib/waflo_v2/features/card_studio/domain/theme_assignment.dart`
- Pure tests under `apps/mobile/test/waflo_v2/features/card_studio/domain/`.

Exit criteria:

- Domain types separate Program, Campaign/Event, and VisualTheme identifiers.
- No persistence, timer, background job, automatic publish, or customer notification exists.
- Advanced seasonal implementation remains scheduled for V1.5 unless the owner changes the decision.

### WP8 — Review application and evidence pack

Tasks:

- Add the smallest reversible development-only route/flag needed to render approved Phase 1 surfaces, if review cannot use isolated widget tests alone.
- Capture automated test results and human-review instructions for Arabic/Sorani/English, common screen sizes, large text, reduced motion, and role states.
- Run formatter, analyze, tests, and any approved golden comparison.
- Inspect diff to prove only the approved slice changed.

Expected files:

- A narrowly scoped additive bootstrap/flag file only if approved.
- Test/golden evidence files only under the new Waflo V2 test boundary.
- No screenshots or binaries committed unless repository policy and reviewer approve them.

Exit criteria:

- Human reviewer can reach every target state without production writes.
- Automated evidence is green; human visual result is recorded by a human.
- Legacy flows remain unchanged when the flag/entry seam is off.

## 5. API and domain contract preparation

Phase 1 may define reviewed documentation or shared DTO shapes, but no live endpoint or Prisma entity. Expected future contracts include:

- Authoritative `/me` membership and explicit active-workspace/branch context.
- Business-scoped CustomerAccount identity.
- Program/EarningRule/RewardDefinition draft and version summaries.
- Ledger command with idempotency key and confirmed result.
- CardDesign draft/validate/publish and provider preview capabilities.
- Campaign/Event and VisualTheme lifecycle/assignment.

If shared code is required, prefer a versioned additive namespace under `packages/shared-types` only after checking every existing consumer. Do not widen the Phase 1 API implicitly.

## 6. Required testing

### Automated

- Flutter `analyze` with zero new issues.
- Full existing Flutter suite plus focused Waflo V2 unit/widget tests.
- Role navigation matrix for Owner/Manager/Staff/no membership/multiple Businesses.
- W2A workspace/session/scanner late-result regressions.
- Arabic/Sorani/English direction, overflow, semantics, and text scaling.
- Token contrast, touch target, reduced motion, and focus behavior.
- Every shared state: loading, empty, error, offline, stale, forbidden, submitting, confirmed, draft.
- CardDesign validation and provider-capability fixtures.
- Theme state/window/fallback and no-loyalty-mutation boundary tests.
- Golden tests only for stable components with an explicit, human-reviewed update process.

Run API/Web baseline checks if Phase 1 touches shared packages or contracts. A Flutter-only slice must still prove it did not modify Legacy/backend behavior through diff review.

### Manual/human

- iOS and Android target sizes, safe areas, keyboard, camera permission shell, and back navigation.
- Arabic/Sorani typography and translation quality.
- Screen reader and external text scaling.
- Preview differentiation for Apple/Google Wallet and printable QR layout.
- Role comprehension and counter-speed assessment for Staff.
- Human visual acceptance; Codex cannot grant it.

## 7. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Existing V2/V3 UI generations become further entangled | New `waflo_v2` namespace, one reversible entry seam, no in-place Legacy refactor |
| False feature completeness from fixture previews | Development/test adapters only, visible Preview/informational labels, all mutations disabled |
| Multi-business regression | Authoritative membership models, explicit ambiguous state, W2A tests |
| Arabic/Sorani font or overflow defects | Font approval gate, bidi/text-scale tests, human linguistic review |
| New package increases build/security risk | Prefer SDK capabilities; require explicit dependency review |
| Studio scope expands into backend implementation | Stop at pure models/components in Phase 1; no upload/save/publish repositories |
| Seasonal scope delays V1 | Contracts only; scheduler/templates remain V1.5 |
| Preview diverges from real Wallet output | Provider capability model and Preview label; physical/provider validation in Phase 4 |
| Visual tokens allow inaccessible merchant output | Publish-time contrast/media/provider validation contract and safe correction UX |
| Shared types accidentally break Web/API | Additive versioned namespace and run all affected package checks |

## 8. Phase 1 definition of done

Phase 1 is complete only when:

1. Approved files are isolated under the new Waflo V2 namespace, except narrowly reviewed localization/shared/bootstrap seams.
2. No Prisma migration, live backend behavior, production scheduler, notification, upload, Wallet issuance, loyalty mutation, or Legacy UI rewrite was introduced.
3. Full relevant baseline and new automated tests pass with exact counts reported.
4. Active Business ambiguity fails closed and W2A regressions stay green.
5. Arabic/Sorani/English, RTL/LTR, accessibility, honest state, and role-shell requirements have test evidence.
6. Card Studio and Seasonal Theme pure contracts enforce presentation-only separation from loyalty value.
7. Git diff contains only explicitly approved paths and is reviewed before staging.
8. A human completes the required visual review; any failure remains open rather than being waived by automation.
9. Documentation records actual results and unresolved risks without claiming Phase 2 functionality.

## 9. Explicitly deferred after Phase 1

- Branch/customer/program/ledger Prisma entities and migrations.
- Authentication changes, Business selector API changes, team invitations, and onboarding persistence.
- Live CardDesign/media save, publish, and Wallet preview/issuance services.
- Seasonal template library, scheduler, activation/expiry workers, conflicts, and notifications.
- Earning, points, spend/product capture, entitlements, redemption, reports, billing, Growth Menu, and AI.
- Dark mode and store release/deployment.
