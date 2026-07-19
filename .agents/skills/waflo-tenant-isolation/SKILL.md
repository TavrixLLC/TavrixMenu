---
name: waflo-tenant-isolation
description: Use when a Waflo task touches active business or workspace resolution, authentication or logout, memberships or roles, business-scoped Cubits or caches, categories or products, scanner, Loyalty customers or cards, staff permissions, business-owned API reads or mutations, or asynchronous results that may survive session changes; do not use for purely static visual work with no business-scoped data impact.
---

# Waflo Tenant Isolation

Audit tenant boundaries across Flutter state, repositories, and API behavior.
Use the applicable root, mobile, and API instructions without duplicating them.

## Read authority

Read the sources needed for the affected surface:

- `AGENTS.md`
- `apps/mobile/AGENTS.md` for Flutter state or repository work
- `apps/api/AGENTS.md` for API or authorization work
- `docs/05-api-contract.md` for API truth
- `docs/product/WAFLO_PRODUCT_UX_V2.md` and
  `docs/product/WAFLO_GUIDED_WALKTHROUGH_V1.md` for product doctrine

## Preserve the completed baseline

W2A workspace and scanner-context isolation is complete and verified.

Evidence: `f9abd774386a71b786459ab15bda329d1aadc3a0`.

Do not reopen or relabel completed W2A as unresolved unless new regression
evidence exists.

## Enforce the invariants

### 1. Authoritative workspace

- Never choose a business by list position.
- Route zero-business state honestly to setup or not-found behavior.
- Resolve one business directly when authoritative membership permits it.
- Fail closed for ambiguous multi-business state until an authoritative
  selection exists.

### 2. Cross-session clearing

- Clear workspace-scoped state on logout.
- Clear the previous business state when the principal changes.
- Prevent the prior business name, data, errors, and mutations from appearing
  under the new owner.

### 3. Asynchronous safety

- Discard late results from an obsolete session or workspace.
- Make loading, success, and error emissions generation- or session-aware where
  asynchronous work can outlive its context.
- Prevent old scanner results and errors from surviving workspace changes.

### 4. API and repository scoping

- Tenant-scope every business-owned read and mutation.
- Verify that category and product identifiers belong to the active business.
- Require authoritative role permission for staff actions.
- Never trust a client-provided business identifier without server
  verification.

### 5. Customer and Loyalty safety

- Do not assume globally keyed Customer records are tenant-safe.
- Keep Customer tenant isolation as a Loyalty release blocker.
- Keep the broader scanner and Loyalty audit separate from completed W2A.
- When relevant, inspect customer and card ownership, staff authorization,
  mutation boundaries, replay or token rotation, rate limiting, abuse
  resistance, and negative tests.

### 6. Honest state

- Never present request failure as an empty state.
- Never use stale fallback data from another business.
- Never show fake zero values after authorization or loading failure.

## Run the audit

1. Identify every source of workspace or business context.
2. Trace active-business resolution from authoritative membership state.
3. Trace clearing on logout and principal change.
4. Trace the lifecycle of each affected Cubit, cache, and repository state.
5. Trace protection against asynchronous stale results.
6. Trace API authorization and tenant filters for every affected read and
   mutation.
7. Inspect negative authorization and isolation tests.
8. Classify each remaining risk and keep deferred risk distinct from a W2A
   regression.

## Require relevant regression evidence

Cover these scenarios when the affected surface makes them relevant:

- Owner A loads Business A.
- Logout occurs in the same process without force stop or data clearing.
- Owner B loads Business B in that process.
- No A data flashes under B.
- No A error flashes under B.
- Late A results are discarded.
- Scanner resolution uses the fresh workspace.
- Unauthorized business, category, and product access is rejected.
- Ambiguous multi-business state fails closed.
- Zero-business state routes honestly.

Use synthetic labels in tests and reports. Do not print real identifiers,
emails, tokens, business names, customer data, or other PII.

## Report the result

Return this compact report:

A) Decision
B) Data and mutation surfaces inspected
C) Active-workspace authority
D) Logout/principal-change clearing
E) Late-result protection
F) API tenant filtering
G) Role authorization
H) Negative tests
I) Customer/Loyalty risk
J) W2A regression status
K) Remaining blockers
L) Files modified
M) Commit allowed

Choose the decision that best describes the evidence:

- `TENANT_ISOLATION_PASS`
- `TENANT_ISOLATION_PASS_WITH_DEFERRED_RISK`
- `W2A_REGRESSION_DETECTED`
- `AUTHORIZATION_GAP_FOUND`
- `CUSTOMER_TENANCY_BLOCKER`
- `MULTI_BUSINESS_SELECTION_BLOCKED`
- `NEGATIVE_TESTS_MISSING`
- `SCOPE_DRIFT_DETECTED`

Never automatically alter production data, run destructive database commands,
perform a migration, weaken authorization, bypass multi-business fail-closed
behavior, mark Customer tenant isolation resolved without implementation and
tests, commit, push, merge, or deploy.
