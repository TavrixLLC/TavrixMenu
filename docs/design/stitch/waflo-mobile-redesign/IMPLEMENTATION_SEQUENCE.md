# Waflo Mobile UI V3 Implementation Sequence

Product-surface ownership is governed by
[`docs/product/WAFLO_PRODUCT_SURFACE_SPLIT_V1.md`](../../../product/WAFLO_PRODUCT_SURFACE_SPLIT_V1.md).
Advanced configuration and billing are Web Studio-first, Mobile remains
operations-first, customer menu and loyalty experiences belong to Customer Web,
and Platform Backend authorization and entitlement enforcement are
authoritative. This does not invalidate the Mobile V3 Dashboard, daily Menu
Management, simple Product Editor, or scanner sequence.

This sequence began as a bounded future engineering plan and is not standing
authorization to start Flutter work. Finalized V3 foundation, shell/dashboard,
and M1P1 Menu/simple Product slices are current implementation evidence; later
rows remain subject to explicitly scoped branches, current contract review, and
the required human gates.

## Sequence principles

- Implement foundations before screens and real read paths before mutations that depend on them.
- Keep each slice reviewable, testable, and independently reversible.
- Do not copy raster coordinates, Stitch code/assets, or screenshot content.
- Preserve existing business logic where it is correct, but do not treat the current UI as the V3 visual foundation.
- A later implementation task must re-check current backend/frontend contracts; this sequence records the reviewed state, not a permanent claim.

## V3-F1 — Design tokens and reusable primitives

| Delivery field | Contract |
| --- | --- |
| Exact scope | Add V3 semantic colors, typography roles, 4px spacing scale, radii, elevation, motion/reduced-motion policy, focus/disabled/error rules, and primitive Primary/Secondary Button, Card/Surface, Status Badge, Inline Error, Skeleton, and Section Header behavior. |
| Excluded scope | App shell, navigation, screen composition, forms with business behavior, API calls, backend changes, production illustration assets. |
| Source areas likely affected | Mobile semantic theme/token area and a new/isolated V3 shared-component area; avoid broad rewrites of existing screens. |
| Tests required | Token-value/semantic-role tests; disabled precedence; 48px targets; RTL/text-scale widget tests; contrast review evidence; reduced-motion behavior for skeletons. |
| Backend dependency | None. |
| Security checks | Components expose no sample business/user/customer data and no raw error content; primitives remain data-agnostic. |
| Visual reference | All four approved PNGs plus [VISUAL_SYSTEM_LOCK.md](VISUAL_SYSTEM_LOCK.md). |
| Human QA checkpoint | Review component hierarchy, Arabic shaping, contrast, shadows, radii, disabled/error distinction, 360/430px widths, and representative text scales. Codex reports mismatches but does not declare final visual acceptance. |
| Commit boundary | One focused F1 commit containing tokens, primitives, their tests, and no screen migration. Commit only after automated guards and required human review. |

## V3-F2 — App shell and canonical bottom navigation

| Delivery field | Contract |
| --- | --- |
| Exact scope | Implement the safe-area-aware workspace shell and `WafloBottomNavigation` with five equal tabs in the locked order, one selected treatment, real destination mapping, and disabled handling. |
| Excluded scope | Redesigning tab content, focused editor routes, scanner/loyalty feature expansion, workspace selector, auth changes. |
| Source areas likely affected | Mobile shell/router/navigation components and narrow shell navigation tests. |
| Tests required | Exact tab order/labels; equal treatment and scanner parity; selected semantics/indicator; safe-area/content inset; destination mapping; unavailable-tab behavior; RTL and text-scale tests. |
| Backend dependency | Existing authenticated app context only; no new endpoint. |
| Security checks | Preserve role/permission boundaries and authoritative active workspace; no dead active-looking destination; no list-position business selection. |
| Visual reference | Dashboard and both Menu references; Product Editor is the negative reference proving focused flows omit bottom navigation. |
| Human QA checkpoint | Review tab balance, selected treatment consistency, reachable targets, safe-area behavior, and no content overlap on representative devices. |
| Commit boundary | One F2 commit limited to shell/navigation and tests; no screen visual migration or feature mutation. |

## V3-F3 — Focused editor app bar and common form controls

| Delivery field | Contract |
| --- | --- |
| Exact scope | Implement `WafloFocusedAppBar`, text/multiline/select/price fields, labeled availability control, image-field unavailable shell, confirmation dialog, field validation layout, keyboard/focus behavior, and form action layout. |
| Excluded scope | Product API submission, media picker/upload, Edit Product data loading, category creation, bottom navigation. |
| Source areas likely affected | New V3 focused-flow/form shared components, form utilities for numeral normalization, and component tests. |
| Tests required | RTL labels/focus order; 48px targets; text scaling; Arabic/Iraqi/Western digit normalization; deterministic price validation; error adjacency; unsaved-change confirmation; keyboard inset/action reachability; disabled draft/media states. |
| Backend dependency | Read-only validation alignment with current item DTO and business currency; no request is sent in this slice. |
| Security checks | No screenshot/sample values; select field cannot retain options across workspace reset; raw identifiers/errors are not user-visible. |
| Visual reference | Product Editor Create approved PNG and its validation/responsive contracts. |
| Human QA checkpoint | Review app-bar language, field hierarchy/focus/error states, currency association, switch semantics, keyboard behavior, 360/430px layouts, and large text. |
| Commit boundary | One F3 commit for common focused/form components and tests only; no product feature wiring. |

## V3-D1 — Owner Dashboard zero-product state

| Delivery field | Contract |
| --- | --- |
| Exact scope | Render the exact returning-owner/one-category/zero-product hierarchy from real dashboard summary and real permission/readiness data, including workspace header, guided hero, supported metrics, unavailable actions, and honest activity/loyalty information. |
| Excluded scope | Populated-dashboard visual, activity-feed backend, notification sending, entitlement inference, loyalty builder/scanner redesign, new analytics. |
| Source areas likely affected | Dashboard presentation/state mapping, V3 dashboard components, shell integration, and dashboard tests; retain existing repository/use-case boundaries where correct. |
| Tests required | Loading/error are not zero; supported counts map correctly; unsupported metrics show unavailable; permission/readiness gates; Add Product navigation prerequisite; disabled notifications/preview; workspace reset and late-result regression; RTL/responsive widget tests. |
| Backend dependency | Existing app context and dashboard summary. Loyalty status may use the existing program read; recent activity/customer total/entitlements remain unavailable without contracts. |
| Security checks | Active membership required; no stale identity/metrics; permission-gated actions; no fake customer/activity/subscription values. |
| Visual reference | [01-owner-dashboard/returning-zero-products-approved.png](01-owner-dashboard/returning-zero-products-approved.png). |
| Human QA checkpoint | Compare hierarchy, warmth, header, hero, metrics, disabled treatment, scroll, navigation inset, 360/430px and text scale. |
| Commit boundary | One D1 commit for the zero-product dashboard and its tests; do not include downstream destination implementation. |

## V3-M1 — Menu Management empty states

| Delivery field | Contract |
| --- | --- |
| Exact scope | Implement Menu loading/error, one-category/zero-product approved state, documented no-category state, selection, first-product CTA gating, readiness summary, and disabled preview. |
| Excluded scope | Populated product cards/search, full category-create/edit redesign, Product Editor implementation, public preview screen, media assets extracted from raster. |
| Source areas likely affected | Menu presentation/state selectors, V3 empty/readiness/category components, shell integration, and menu/widget tests. |
| Tests required | Failure versus confirmed empty; no-category versus one-category; real selection; Add Product disabled without category/permission; preview readiness gating; workspace clearing; safe-area/RTL/text-scale tests. |
| Backend dependency | Existing app context, dashboard summary, category list, and public link/readiness data. |
| Security checks | Categories must belong to active business; no arbitrary first-record authority; no cross-workspace selection/search/error; no fake URL/QR. |
| Visual reference | [02-menu-management/empty-approved.png](02-menu-management/empty-approved.png); no-category behavior remains documented-only. |
| Human QA checkpoint | Review readiness hierarchy, category chip selection, original/native empty art, muted preview, CTA priority, scroll/navigation inset, 360/430px. |
| Commit boundary | One M1 commit for empty states and tests; category mutation workflow and Product Editor remain separate. |

## V3-M2 — Menu Management populated state

| Delivery field | Contract |
| --- | --- |
| Exact scope | Implement populated category chips, local search over supported real loaded fields, distinct search-empty state, owner-visible available/unavailable product cards, confirmed availability changes, implemented edit intent, and reachable Add Product. |
| Excluded scope | Dedicated Edit Product screen, media upload, fabricated descriptions/images, server-side search, orders/sales features, unimplemented overflow actions. |
| Source areas likely affected | Menu populated presentation/state filtering, product/category shared components, availability mutation wiring, and menu tests. |
| Tests required | Category-scoped filtering; clear search; search-empty distinction; include unavailable owner records; toggle pending/deduplication/rollback; permission/read-only state; hidden unsupported overflow actions; one-column fallback and text-scale tests. |
| Backend dependency | Existing business category/item lists with owner-visible inactive opt-in, item availability update, and business currency. |
| Security checks | Every record/action remains in active business; current category selection is explicit; stale cached records/results clear on workspace change. |
| Visual reference | [02-menu-management/populated-approved.png](02-menu-management/populated-approved.png). |
| Human QA checkpoint | Review card density, image placeholder, Arabic wrap, canonical `د.ع`, availability semantics, selected category, search, 360/430px, and forced one-column/large-text layouts. |
| Commit boundary | One M2 commit for populated browsing/search/availability and tests; no Edit Product or media integration. |

## V3-P1 — Create Product without image upload dependency

| Delivery field | Contract |
| --- | --- |
| Exact scope | Implement focused Create Product using real business/category context, required name/category/price, optional description, explicit availability, deterministic digit/decimal handling, submission guard, confirmed success navigation/refresh, failure preservation/retry, and disabled/omitted draft/media upload. |
| Excluded scope | Image picker/upload, Save as Draft, Edit Product, category creation inside the form, backend/API/schema changes. |
| Source areas likely affected | Product-create feature presentation/state/repository integration, focused route, menu refresh handoff, and product-create tests; reuse existing menu create contract through a clean feature boundary. |
| Tests required | Field limits and whitespace; Arabic/Iraqi/Western digits; no cent multiplication/binary float; category ownership/stale category rejection; availability payload; single in-flight request; failure preserves fields; success refresh/navigation only after confirmation; unsaved back; workspace reset. |
| Backend dependency | Existing business-scoped product create, category list/assertion, item DTO validation, decimal storage, and business currency. |
| Security checks | OWNER/MANAGER permission; authoritative business and category; no prior-business form/selection/error/result; safe error copy; no raw identifier exposure. |
| Visual reference | [03-product-editor/create-product-approved.png](03-product-editor/create-product-approved.png), with media and draft honesty overrides. |
| Human QA checkpoint | Review focused hierarchy, labels, numeric entry, availability, disabled/omitted unsupported actions, keyboard reachability, errors, 360/430px, and return-to-menu flow. |
| Commit boundary | One P1 commit for image-free create and tests. No media, draft, edit, or backend work may ride along. |

## V3-P2 — Product image selection/upload integration after contract completion

| Delivery field | Contract |
| --- | --- |
| Exact scope | After explicit contract approval, add native image selection/permission, local preview/replace/remove, validated upload, progress/failure/retry, confirmed URL handoff, workspace cleanup, and optional image-free continuation. |
| Excluded scope | Generated images, screenshot assets, remote hard-coded URLs, required-image policy, draft persistence, unrelated media types, backend work hidden in this UI slice. |
| Source areas likely affected | Product media presentation/state, platform picker integration, media repository/data source, create-product coordination, platform configuration explicitly required by the approved picker, and focused tests. |
| Tests required | Permission denied; cancel; supported type/size hints; replace/remove; one upload; failure preservation; retry; only confirmed URL submitted; image-free create; workspace/logout cleanup; metadata/privacy handling review. |
| Backend dependency | The media upload route is canonical in `docs/05-api-contract.md`. Native selection, authorized handoff, response/error behavior, and lifecycle security still require an explicitly scoped current-contract audit before Mobile integration. |
| Security checks | Business-scoped role authorization, safe MIME/content handling, no local-path submission/logging, no cross-workspace retained preview/URL, no sensitive metadata exposure. |
| Visual reference | Product Editor Create media area and populated Menu media hierarchy; raster art/photos remain reference-only. |
| Human QA checkpoint | Review every image lifecycle state, progress/error clarity, native placeholder, crop/aspect behavior, permission copy, and create-without-image path. |
| Commit boundary | One P2 integration commit only after the contract gate and automated guards; any required backend/API contract change is a separately scoped prior commit/branch. |

## V3-P3 — Edit Product after real product-load/update audit

| Delivery field | Contract |
| --- | --- |
| Exact scope | After audit and visual approval, load an authoritative business-owned product, initialize the focused form, validate changes, update supported fields once, preserve confirmed state/errors, handle unsaved changes, and refresh Menu after confirmed success. |
| Excluded scope | Public-route data as owner authority, cross-business caches, new item fields, delete/archive redesign, draft support, media integration unless P2 is complete and explicitly included. |
| Source areas likely affected | Product-edit route/state/repository boundary, authenticated load strategy, focused form reuse, menu refresh handoff, and edit tests. |
| Tests required | Record/business ownership; missing/stale record; full initialization; unchanged/dirty navigation; changed-category validation; update payload; pending dedupe; failure preservation; success refresh; workspace/principal switch invalidation. |
| Backend dependency | **Hard gate:** audit the business-scoped owner read source and item update contract. A dedicated authenticated item read may require a separate backend/API scope before P3. |
| Security checks | Never use public item read or another business's cached record; role and category ownership revalidated; no stale image/form/error after workspace change. |
| Visual reference | Create Product system for shared form language only. Edit Product itself has no approved visual and requires separate human approval before implementation acceptance. |
| Human QA checkpoint | Review edit-versus-create clarity, loaded values, dirty-state confirmation, error/pending states, return/refresh behavior, responsive layouts, and any approved edit-specific differences. |
| Commit boundary | One P3 commit after read/update audit and visual approval; backend/API changes, if needed, land separately first. |

## Concurrency, guard, and commit rules

- One writing agent at a time.
- Read-only reviewers may run in parallel.
- No commit before automated guards pass.
- Codex may report visual differences but never gives final visual acceptance or claims `HUMAN_VISUAL_PASS`.
- No giant redesign commit; each named slice is its own bounded commit boundary.
- No backend expansion hidden inside UI work. Backend, API-contract, schema, auth, or security changes require their own explicit scope and sequencing.
- No `git add .`; stage only the paths reviewed for the slice.
- Human visual review is required at each checkpoint before a UI commit is accepted under the product doctrine.
- A slice that discovers authority conflict, tenant risk, or unsupported behavior stops and records the blocker instead of fabricating a fallback.

## Planned order and gates

`Codex tooling foundation → F1 → F2 → F3 → D1 → M1 → M2 → P1 → P2 (contract gate) → P3 (read/update and visual gates)`

F1–F3 may establish reusable foundations, but screen slices remain sequential where they share the same write surface. P2 and P3 do not begin merely because P1 is complete; each retains its explicit hard gate.
