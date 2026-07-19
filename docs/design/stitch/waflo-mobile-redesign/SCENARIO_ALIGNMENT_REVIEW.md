# Waflo Mobile UI V3 Scenario Alignment Review

Status: **Complete — all reviewed scenarios are aligned or aligned with an explicitly documented gap.**

This review compares the four approved visual states, their contracts, product doctrine, the canonical API contract, and read-only inspection of current Flutter/API source and tests. It evaluates whether the locked visual system can represent real product behavior; it does not claim that Waflo Mobile UI V3 is implemented.

## Result summary

| Scenario | Result | Primary reason |
| --- | --- | --- |
| A — New owner | `ALIGNED_WITH_DOCUMENTED_GAP` | Product doctrine and real contracts cover the journey, but this archive has no approved Login, guided setup, workspace, or first-category visuals. |
| B — Returning owner, one category, zero products | `ALIGNED` | The exact dashboard, create editor, and resulting populated menu states form a truthful real-create path. |
| C — Returning owner with populated menu | `ALIGNED_WITH_DOCUMENTED_GAP` | Menu behavior is covered; Edit Product has no approved visual or dedicated authenticated item read. |
| D — Workspace isolation | `ALIGNED` | Contracts require clearing, current session coordination resets scoped state, and existing tests cover principal changes and late results. |
| E — No category | `ALIGNED_WITH_DOCUMENTED_GAP` | Behavior and real category mutation exist, but the no-category/create-category state has no approved visual. |
| F — Product creation failure | `ALIGNED` | Validation, submission, preservation, retry, and duplicate prevention are explicitly contracted. |
| G — Missing capability | `ALIGNED_WITH_DOCUMENTED_GAP` | Every named missing/partial capability has an honest disabled, omitted, or informational path. |

No scenario requires fake behavior to reproduce the approved visual hierarchy. No `SCENARIO_DRIFT` was found.

## Scenario A — New owner

`Login → guided setup → real business → real category → first product → workspace shell`

| Review field | Finding |
| --- | --- |
| Visual coverage | Partial. Product Editor Create provides the approved first-product direction, and the shell destination patterns are approved. Login, the first-run wizard, workspace setup, and first-category creation have no approved V3 visuals in this archive. |
| Interaction coverage | Product doctrine defines the resumable guided journey, optional versus required steps, and real completion conditions. Current Flutter source contains a first-run wizard and real business/menu flows, but those are not accepted as V3 visual implementations. |
| Backend coverage | Real authenticated user bootstrap, business creation/app context, category creation, product creation, dashboard summary, and public link contracts exist. Optional image upload is partial; draft persistence is missing and unnecessary for the minimum real path. |
| Loading/error coverage | Doctrine requires resume from the exact incomplete step. Screen contracts cover category/product loading, validation, failure preservation, retry, and no fake progress. Exact wizard loading/error visuals remain unapproved. |
| Security/tenant coverage | The journey must establish an authoritative active workspace before scoped requests. W2A clearing remains mandatory. Multi-business users fail closed until explicit selection exists. |
| Remaining blocker | Missing approved visuals for Login, guided setup, workspace setup, and no-category/category-create states. Multi-business selection remains unavailable. |
| Implementation recommendation | Do not infer those missing screens from the four PNGs. Implement only after separate visual approval; reuse the locked primitives and real completion conditions. Keep image optional and draft absent. |
| Status | **`ALIGNED_WITH_DOCUMENTED_GAP`** |

## Scenario B — Returning owner with one category and zero products

`Dashboard → Add Product → Product Editor → successful backend creation → Menu populated state`

| Review field | Finding |
| --- | --- |
| Visual coverage | Complete for the required transition: approved zero-product Dashboard, approved Create Product, and approved populated Menu references exist. The approved Menu empty state also covers the same starting menu condition. |
| Interaction coverage | Dashboard/Menu contracts require a real selected category and permission before Add Product. Product Editor validates, submits once, returns after confirmation, and refreshes the selected category. |
| Backend coverage | Dashboard summary, real category list, business-scoped product create, category/business assertion, decimal price, explicit availability, and product list refresh are available. Image is optional. |
| Loading/error coverage | Dashboard/Menu distinguish loading/error from zero. Product Editor defines valid, submitting, success, create-error, and validation-error states with preserved input and no duplicate request. |
| Security/tenant coverage | Active business and selected category are authoritative; category ownership is rechecked by the service; logout/workspace change clears screen and mutation state. |
| Remaining blocker | No product capability blocker for an image-free create slice. The V3 Flutter screens/components themselves have not started. |
| Implementation recommendation | Implement V3-D1, V3-M1, then V3-P1 using real category/product contracts. Navigate and refresh only after confirmed success. Do not make P1 depend on media upload or drafts. |
| Status | **`ALIGNED`** |

## Scenario C — Returning owner with populated menu

`Dashboard/Menu → select category → search → toggle availability → edit product → customer preview when a real route exists`

| Review field | Finding |
| --- | --- |
| Visual coverage | Populated Menu approves category selection, search, owner product cards, availability, edit intent, and product creation. A dedicated Edit Product visual and customer preview screen are missing. |
| Interaction coverage | Contracts define explicit category selection, client filtering of a successfully loaded real list, a distinct no-search-match state, confirmed availability mutation, edit routing by real record, and conditional preview. |
| Backend coverage | Business category/item lists, item update, availability update, public readiness/link, and public menu route exist. Owner item-list fields are not all guaranteed, and there is no dedicated authenticated item-by-record read. |
| Loading/error coverage | Menu has loading, request error, search empty, and per-item mutation states. Failed availability restores/refreshes confirmed state. Edit loading/error visuals remain documented only. |
| Security/tenant coverage | Lists and mutations are business-scoped and role-gated. Edit must not use a public route or cached record from another workspace. Preview uses only a real confirmed URL. |
| Remaining blocker | Product Editor Edit requires a real record-load/update audit and a separately approved edit visual. Current frontend search and V3 availability presentation are not implemented. |
| Implementation recommendation | Implement V3-M2 with local search over supported loaded fields. Use a one-column fallback. Defer V3-P3 until the authenticated load/update audit; enable preview only from real readiness/link data. |
| Status | **`ALIGNED_WITH_DOCUMENTED_GAP`** |

## Scenario D — Workspace isolation

`Owner A → logout → Owner B → no A data or flash`

| Review field | Finding |
| --- | --- |
| Visual coverage | Isolation is intentionally not encoded as sample identities in the rasters. The locked header, skeleton, error, metric, menu, form, and feedback contracts define the required cleared/loading presentation. |
| Interaction coverage | Logout/principal change resets dashboard, menu, loyalty, scanner, appearance, and business-setup state before the next workspace loads. Pending results are generation-guarded in current state management. |
| Backend coverage | Authenticated business routes enforce active membership and business ownership/role checks. Category/product mutations validate same-business ownership. |
| Loading/error coverage | Prior identity, records, selected category, search, errors, media, form values, results, and pending mutations are cleared. A new load uses skeleton/error rather than flashing old content or fake zero. |
| Security/tenant coverage | Existing workspace-isolation tests cover account changes in one process, clearing scanner/menu/loyalty state, discarding late prior-owner loads, and removing old results/errors. This is evidence of current coverage, not a waiver for future V3 regression tests. |
| Remaining blocker | Explicit multi-business selection is not implemented; users with more than one business intentionally fail closed. Customer tenant isolation is a separate backend blocker before Loyalty release. |
| Implementation recommendation | Preserve the coordinator/reset and stale-result protections in every V3 slice. Add component/screen regression tests whenever new local state is introduced. Never select a workspace by list position. |
| Status | **`ALIGNED`** |

## Scenario E — No category

`Menu Management → create first category → then enable Add Product`

| Review field | Finding |
| --- | --- |
| Visual coverage | The exact `EMPTY_NO_CATEGORIES` behavior is documented but has no approved visual. The approved one-category empty state establishes the visual destination after real category creation. |
| Interaction coverage | Menu contracts require category creation first, prohibit local fake categories, and keep product search/creation/preview unavailable until a real category exists and is selected. |
| Backend coverage | Business-scoped category create/list/update/archive/reorder contracts exist with role enforcement. Product creation rejects a category outside the active business. |
| Loading/error coverage | Category loading/error is distinct from empty. Mutation requires pending, confirmed success, error, and retry; Add Product remains disabled until refreshed real state exists. |
| Security/tenant coverage | Category mutations require an authoritative business and menu permission. Category records are cleared on workspace change. |
| Remaining blocker | No approved no-category/category-creation visual and no dedicated V3 category workflow contract beyond the menu interaction mapping. |
| Implementation recommendation | Keep V3-M1 scoped to honest empty states. Obtain/lock category-create visual behavior before expanding that flow; after real success, select the returned/refreshed category explicitly. |
| Status | **`ALIGNED_WITH_DOCUMENTED_GAP`** |

## Scenario F — Product creation failure

`Submit → backend failure → preserve fields → honest error → safe retry → no duplicate product`

| Review field | Finding |
| --- | --- |
| Visual coverage | Create Product supplies the default hierarchy. Failure presentation is documented behavior only and should use the locked input, primary button, and inline error contracts. |
| Interaction coverage | Validate once, protect controls from duplicate submit, preserve form/local selection on failure, focus/scroll the first invalid field, and retry deliberately. |
| Backend coverage | Product create returns validation, authorization, and category/business errors. The current contract does not guarantee idempotency, so client duplicate prevention is mandatory. |
| Loading/error coverage | `CREATE_SUBMITTING`, `CREATE_ERROR`, `VALIDATION_ERROR`, and image error states are explicit. Success/navigation occurs only after confirmation. |
| Security/tenant coverage | Retry reuses the still-authoritative workspace/category only. A principal/workspace change invalidates and clears the form/pending result before any retry. |
| Remaining blocker | Exact Arabic server-error mapping and production V3 error visuals still need implementation QA; this does not create a contract gap. |
| Implementation recommendation | Keep the form mounted on failure, map safe errors, maintain a single in-flight guard, and refresh Menu only after a confirmed create response. Do not rely on undocumented idempotency. |
| Status | **`ALIGNED`** |

## Scenario G — Missing capability

`Draft/image upload/public preview/loyalty/notifications → disabled, omitted, or informational → no fake success`

| Review field | Finding |
| --- | --- |
| Visual coverage | Draft and image intent appear in Product Editor; preview appears in Menu/Dashboard; loyalty, scan, and notification entry points appear on Dashboard/navigation. Dedicated destination visuals are outside this archive. |
| Interaction coverage | Draft is omitted/disabled. Media separates local selection from upload. Preview requires real readiness/link. Loyalty/scanner/notification actions require real routes, permission, state, and release readiness. |
| Backend coverage | Draft, recent activity, notifications, and authoritative entitlement state are missing. Media upload is source-backed but absent from the canonical API contract. Public link/menu, loyalty baseline, and scanner source routes exist with stated limitations. |
| Loading/error coverage | Shared contracts require honest disabled explanations, real upload progress/failure, real preview errors, and no success before confirmation. Missing capabilities never enter fake loading/success states. |
| Security/tenant coverage | W2A remains mandatory for every action. Multi-business selection fails closed. Customer tenant isolation remains a backend release blocker before Loyalty release; scanner context requires its dedicated safety audit before polish/release. |
| Remaining blocker | Media contract completion/integration; customer isolation for Loyalty; multi-business selection; missing notification/activity/entitlement/draft contracts; unapproved destination visuals. |
| Implementation recommendation | Ship only capabilities whose full prerequisite chain is real. Use disabled/omitted/informational treatments for all others. P1 product creation remains image-free; P2, Loyalty, scanner, and later destinations retain their explicit gates. |
| Status | **`ALIGNED_WITH_DOCUMENTED_GAP`** |

## Alignment conclusion

The lock is scenario-safe. Missing future capability alone does not block the visual system because each gap has an honest presentation and bounded implementation sequence. The alignment review must be revisited if a later implementation:

- selects a workspace by list position;
- displays stale prior-workspace content;
- activates draft, upload, preview, loyalty, scanner, notifications, or billing without real prerequisites;
- substitutes load failure with zero/empty data; or
- requires a new visual pattern that conflicts with this lock.
