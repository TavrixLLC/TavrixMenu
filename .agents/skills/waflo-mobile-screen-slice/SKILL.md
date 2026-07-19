---
name: waflo-mobile-screen-slice
description: Use when implementing, reviewing, or planning one bounded Waflo Flutter Mobile UI V3 screen or state slice; do not use for backend-only work, broad application rewrites, visual generation, documentation-only design approval, deployment, or production operations.
---

# Waflo Mobile Screen Slice

Apply this workflow to one explicitly bounded Mobile UI V3 slice. Keep the
result grounded in repository authority, real capabilities, and verifiable
Flutter behavior.

## Collect the task inputs

Record these inputs when they apply. Stop and request the missing value when
its absence would make the slice or authorization ambiguous.

- Slice identifier
- Exact screen and state
- Approved visual path
- Allowed source paths
- Excluded scope
- Backend dependency
- Required tests
- Branch and expected base commit
- Commit authorization status

## Follow the authority chain

Read the narrowest applicable sources in this order:

1. Repository `AGENTS.md` and `apps/mobile/AGENTS.md`
2. Exact approved screen visual under
   `docs/design/stitch/waflo-mobile-redesign/`
3. The screen's `states.md`
4. The screen's `validation-contract.md`, when present
5. The screen's `interaction-contract.md`
6. The screen's `backend-data-contract.md`
7. The screen's `responsive.md`
8. `docs/design/stitch/waflo-mobile-redesign/DESIGN.md`
9. Older references, only as non-authoritative context

Let security, accessibility, responsive behavior, and backend truth override
raster details. Never use a non-authoritative variant as implementation truth.

## Run the workflow

### 1. Check safety

- Confirm the current branch.
- Confirm the expected `HEAD`.
- Inspect the worktree and run `git diff --check`.
- Stop with `SCOPE_DRIFT_DETECTED` when unrelated dirty files exist.

### 2. Read authority

- Read the root and mobile instructions completely.
- Read the exact screen visual and its applicable contracts.
- Record which authority documents were read.

### 3. Map the existing code

- Identify the current route, page, Cubit and states, repositories, APIs,
  relevant tests, and shared widgets.
- Inspect each affected path before modifying it.
- Do not perform a broad refactor without explicit scope.

### 4. Classify capabilities

Classify every visible action as exactly one of:

- `AVAILABLE`
- `PARTIAL`
- `MISSING`
- `DEFERRED`
- `BLOCKED`

Disable, omit, or make informational every unsupported action. Never fake a
preview, QR result, upload, draft, notification, billing action, Loyalty
mutation, or success state.

### 5. Implement only the slice

- Use one writing agent for one bounded slice.
- Preserve Arabic-first RTL behavior.
- Represent real loading, error, empty, and success states.
- Never turn loading or request failure into a fake empty state.
- Show success only after backend confirmation.
- Keep interactive targets at least 48 logical pixels.
- Respect safe areas and provide responsive scrolling where content can grow.
- Do not copy screenshot coordinates or create screenshot-derived assets.
- Do not hardcode sample product, category, metric, business, or customer data.
- Do not expand backend, schema, authentication, or OpenAPI scope implicitly.

### 6. Protect workspace state

- Resolve the active workspace from authoritative state.
- Never use `businesses.first` or any unordered list position.
- Reject asynchronous results from an obsolete principal or workspace.
- Clear workspace-scoped state when the principal or workspace changes.
- Invoke `$waflo-tenant-isolation` when the slice touches scoped data; do not
  copy its full audit workflow here.

### 7. Validate proportionately

- Format only relevant files unless broader formatting is explicitly allowed.
- Run `dart format` on the allowed Dart paths.
- Run `flutter analyze`.
- Run the relevant unit and widget tests.
- Run workspace-isolation regression tests when the slice affects scoped data.
- Run `git diff --check`.
- Review the final diff against the explicit allowed and excluded scope.

### 8. Preserve the human gate

- Report visual mismatches without approving the implementation visually.
- End implementation visual status as `HUMAN_VISUAL_REVIEW_REQUIRED`.
- Never declare `HUMAN_VISUAL_PASS`.
- Do not commit when the task requires human review before commit.

## Report the result

Return this compact report:

A) Decision
B) Slice
C) Authority documents read
D) Capability classifications
E) Files modified
F) Backend/API/schema changed
G) Tenant isolation impact
H) Automated checks
I) Known gaps
J) Human visual review required
K) Commit allowed
L) Suggested next action

Choose the decision that best describes the outcome:

- `MOBILE_SCREEN_SLICE_IMPLEMENTED`
- `MOBILE_SCREEN_SLICE_DOCUMENTED_ONLY`
- `BACKEND_CAPABILITY_BLOCKED`
- `TENANT_ISOLATION_REVIEW_REQUIRED`
- `SCOPE_DRIFT_DETECTED`
- `TEST_FAILED`
- `HUMAN_VISUAL_REVIEW_REQUIRED`

Never automatically commit, push, merge, or deploy. Treat commit authorization
as an explicit task input, not a consequence of passing automated checks.
