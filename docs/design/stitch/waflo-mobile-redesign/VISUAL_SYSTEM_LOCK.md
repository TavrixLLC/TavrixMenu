# Waflo Mobile UI V3 Visual System Lock

Status: **`VISUAL_SYSTEM_LOCKED_WITH_DOCUMENTED_GAPS`**

This document locks the implementation-neutral visual system shared by the four approved Waflo Mobile UI V3 references. It does not approve Flutter implementation, create backend behavior, or replace human implementation visual QA.

## Lock basis and authority

The archive authority order remains:

1. the approved visual for the exact screen and state;
2. that screen's state contract;
3. for forms, its validation contract;
4. its interaction contract;
5. its backend data contract;
6. its responsive rules;
7. [DESIGN.md](DESIGN.md);
8. older design material.

Security, tenant isolation, accessibility, responsive behavior, and truthful backend state override literal raster details at every level.

The locked evidence set is:

| Screen and state | Approved reference | Lock role |
| --- | --- | --- |
| Owner Dashboard — returning owner, one category, zero products | [01-owner-dashboard/returning-zero-products-approved.png](01-owner-dashboard/returning-zero-products-approved.png) | Guided workspace dashboard, restaurant identity header, metrics, honest unavailable actions, shell navigation |
| Menu Management — one category, zero products | [02-menu-management/empty-approved.png](02-menu-management/empty-approved.png) | Menu readiness, category selection, first-product empty state, disabled preview |
| Menu Management — populated | [02-menu-management/populated-approved.png](02-menu-management/populated-approved.png) | Category controls, search, product cards, availability, edit intent, responsive product layout |
| Product Editor — Create Product | [03-product-editor/create-product-approved.png](03-product-editor/create-product-approved.png) | Focused app bar, form hierarchy, optional media, availability, submission actions |

Dashboard files under `variants/` are excluded from the lock.

## Canonical visual decisions

### Brand and language

| Role | Locked value or rule |
| --- | --- |
| Primary | `#AE3115`; normal primary actions, selected navigation, focus emphasis, and brand presence |
| Accent | `#FF6B4A`; supporting emphasis, never a substitute for semantic state |
| Background | `#F7F9FF` |
| Surface | `#FFFFFF` |
| Text / on-surface | `#181C20` |
| Error | `#BA1A1A`; error and destructive states only, always with a non-color cue |
| Direction | Arabic-first RTL; layout, directional icons, reading order, focus order, and control order mirror correctly |
| Character | Premium restaurant SaaS: modern, warm, operationally clear, and uncluttered |

Normal Primary styling must not make routine actions look destructive. Destructive controls use the semantic Error role and explicit wording or iconography.

### Typography hierarchy

- Use semantic roles for page title, supporting introduction, section title, card title, body, field label, helper/error text, navigation label, and numeric metric.
- Page titles lead the screen; section titles lead groups; button and field labels remain unmistakable at text scale.
- Arabic shaping and line height must be tested with production copy. Do not reproduce rasterized letter spacing or fixed line breaks.
- The exact production Arabic typeface and final scaled metrics remain an F1 implementation choice subject to licensing, platform rendering, and human visual QA.

### Layout, spacing, and surfaces

- Use a 4px base grid.
- Use a 16px standard page margin.
- Use 24px common card padding where width permits. Padding may reduce on narrow devices only when hierarchy and touch targets remain intact.
- Use 16–24px card radii consistently by component role; do not choose a different radius per screen.
- Use restrained, soft shadows only to separate Surface from Background. Focus, selection, and disabled state must not depend on elevation.
- Support reference widths of approximately 360–430px.
- Do not implement fixed screenshot heights or absolute screenshot coordinates.
- Use natural vertical scrolling, respect top/bottom/cutout safe areas, prevent horizontal page overflow, and keep content clear of fixed navigation or sticky actions.
- Product cards fall back to one column whenever two columns cannot preserve readable content, actions, and large-text behavior.

### Touch and accessibility

- Every interactive target is at least 48px by 48px, including back, icon-only, edit, overflow, chip, switch, and navigation targets.
- Status never relies on color alone. Add a label, icon, shape, or semantic state.
- Icon-only controls have Arabic semantic labels and appropriate button/toggle roles.
- Support text scaling without overlap, clipped critical copy, or hidden actions.
- Preserve keyboard traversal and visible focus behavior wherever Flutter/platform input supports them.
- Screen-reader order follows RTL task order, not raster coordinates.
- Accessibility and responsive overrides are mandatory even when they differ from the approved raster.

### Top-level navigation

The workspace shell has five equal tabs in this canonical order:

1. `الرئيسية`
2. `المنيو`
3. `المسح`
4. `الولاء`
5. `الإعدادات`

- The scanner tab is neither floating nor larger than another tab.
- The selected tab uses a Primary-colored icon and label plus one subtle, consistent indicator.
- The same indicator geometry is used across all top-level screens.
- The bar is fixed and safe-area aware; scroll content receives sufficient bottom inset.
- Bottom navigation appears only on top-level workspace destinations.
- Focused creation, editing, confirmation, and other task flows do not show bottom navigation.
- A tab without a real destination is disabled or informational; it never looks tappable while doing nothing.

### Headers and app bars

- Dashboard and Menu Management use one consistent `WafloWorkspaceHeader`: real restaurant identity, optional real status, and only implemented utility actions.
- Product Editor uses `WafloFocusedAppBar`: a clear 48px back action and task title, without the restaurant identity header or bottom navigation.
- Do not copy header coordinates from the rasters.
- Do not add a hamburger menu unless a real navigation behavior requires it.
- Missing logo/media uses a native placeholder; raster restaurant imagery is not reusable.

### Buttons and action hierarchy

- A primary button uses Primary fill and carries the single strongest action in its local task context.
- A secondary button is outlined or low-emphasis and never competes with the primary action.
- Destructive actions use semantic destructive styling, explicit wording, and confirmation where consequences warrant it.
- Disabled buttons are fully muted, non-interactive, and include explanatory helper text when the reason is not self-evident. They do not retain active shadows or Primary fill.
- Loading buttons prevent repeated submission, preserve their label context, and show restrained progress.
- Disabled state takes precedence over loading, pressed, focused, hovered, and default styling.

### Inputs and form feedback

- Fields have persistent or unmistakable labels, RTL alignment, and clear focus, error, loading, and disabled treatment.
- Required fields are marked consistently; validation is adjacent to the relevant field and uses semantic Error styling.
- Field values and options come from user input or authoritative data, never raster samples.
- Multiline fields grow within sensible bounds and remain usable with keyboard and large text.
- Selection fields show a clear selection affordance and only authoritative options.
- Submission errors preserve valid input and local media selection where safe.

### Availability

- Availability uses accessible switch semantics plus an explicit available/unavailable label.
- Owner management may display unavailable products; the public menu does not.
- A pending mutation prevents repeated toggles and preserves the last confirmed value.
- The UI changes its confirmed state only after backend confirmation; on failure it restores or refreshes the confirmed value and shows an honest error.
- Availability is not a draft state.

### IQD and numeric entry

- Iraqi dinar is the default approved product scenario currency; runtime currency still comes from the authoritative business.
- The canonical Arabic presentation for IQD is `د.ع`. English `IQD` visible in a raster does not force English runtime UI.
- Use a deterministic integer-safe representation for normal IQD entry and exact major-unit decimal-string transport where the current item contract permits fractional digits. Do not infer cents or multiply by 100.
- Accept and normalize Arabic, Iraqi, and Western digit entry through the existing validated input architecture.
- Avoid binary floating-point conversion and preserve exact server-supported decimal representation.

### Product images and illustrations

- Approved PNG content is reference-only. Do not crop, trace, extract, ship, or recreate embedded interface fragments, illustrations, photographs, or icons.
- Product media comes only from real merchant selection and a backend-confirmed upload URL.
- Missing media uses an approved native placeholder.
- Selection, selected-local, replacing, removing, uploading, upload-failed, and uploaded states remain distinct.
- Upload progress and failure are honest and preserve other form data.
- Image upload remains `PARTIAL` until the route is canonical in the API contract and the Product Editor integration is complete.
- Empty-state illustrations require separately approved original assets with recorded provenance or native Flutter composition.

### Drafts and unsupported actions

- Save as Draft is `MISSING` today. It is omitted or fully disabled with optional helper text.
- Availability must not be repurposed to simulate a draft.
- There is no local-only or fake draft persistence and no draft success feedback.
- Public preview, loyalty, scanning, notifications, billing, or any other unsupported action is disabled, omitted, or informational until its real prerequisites are present.

### Loading, success, error, and workspace change

- Loading uses restrained skeletons or progress without sample business, category, product, metric, or media data.
- A load error is not a real zero or empty state.
- Success appears only after a real backend confirmation.
- Mutation controls prevent duplicate requests.
- Errors preserve user input where appropriate and expose safe retry.
- Logout, principal change, or workspace change clears prior-business data, selection, search, form state, media state, errors, results, and pending mutation presentation before the next workspace renders.

## State precedence

When more than one state applies, use this precedence:

1. unavailable because of security, permission, or missing authoritative workspace;
2. disabled because a capability or prerequisite is missing;
3. loading or mutation pending;
4. error requiring correction or retry;
5. selected, focused, pressed, or default presentation.

This prevents an unavailable or unsafe control from appearing active because a lower-priority visual state also applies.

## Cross-screen consistency audit

The classification describes how each observed difference is governed. `VISUAL_CONFLICT` was not required for any audited item.

| Audit item | Cross-screen finding | Classification | Locked resolution |
| --- | --- | --- | --- |
| Arabic RTL direction | All four references are RTL; directional spacing and back/navigation affordances vary by context. | `RESOLVED_BY_DESIGN_SYSTEM` | RTL governs layout, focus, icon direction, and reading order on every screen. |
| Typography hierarchy | The references agree on strong titles and quieter support copy, but do not lock a production typeface or one exact scaled metric set. | `IMPLEMENTATION_CHOICE_REQUIRED` | Use semantic type roles; choose a licensed Arabic typeface and validate shaping/text scale in F1 and human QA. |
| Page margins | Apparent raster margins vary with composition and source width. | `RESOLVED_BY_DESIGN_SYSTEM` | 16px page margin; responsive internal reduction only. |
| Spacing grid | Visual gaps vary, especially between the dense populated grid and spacious editor. | `RESOLVED_BY_DESIGN_SYSTEM` | All spacing derives from the 4px grid and component role. |
| Surface treatment | White cards on a cool background are consistent; hero surfaces add warm tint. | `RESOLVED_BY_DESIGN_SYSTEM` | Background, Surface, and restrained tinted semantic surfaces are canonical. |
| Card radius | References use several rounded geometries. | `RESOLVED_BY_DESIGN_SYSTEM` | 16–24px by shared component role, not screen-specific imitation. |
| Shadows | Shadow strength varies between cards and controls. | `RESOLVED_BY_DESIGN_SYSTEM` | Use a restrained shared elevation set; disabled controls have no active elevation cue. |
| Primary and secondary buttons | Filled and outlined actions are consistent in intent, while exact sizing varies. | `RESOLVED_BY_DESIGN_SYSTEM` | Primary fill for the strongest real action; outlined/low-emphasis secondary; 48px minimum. |
| Disabled controls | Notification and preview are visibly muted, but Save as Draft appears actionable in the Product Editor raster. | `BACKEND_CAPABILITY_CONSTRAINT` | Draft is omitted or fully disabled; all unsupported actions use the canonical disabled treatment and explanation. |
| Form fields | Only Product Editor defines a full form; labels mostly appear as placeholders in the reference. | `ACCESSIBILITY_OVERRIDE_REQUIRED` | Production fields use persistent or unmistakable labels, adjacent validation, RTL alignment, and visible focus. |
| Icons | Icon families and stroke/fill treatments vary, and raster icons have no production provenance. | `IMPLEMENTATION_CHOICE_REQUIRED` | Select one licensed/native icon family by semantic role, mirror directional icons, and label icon-only actions. |
| Restaurant identity header | Dashboard and both Menu references show the same identity pattern with minor compositional variation. | `RESOLVED_BY_DESIGN_SYSTEM` | One workspace header contract supplies real identity/status and implemented utilities. |
| Focused editor app bar | Product Editor intentionally omits the workspace identity header and shell navigation. | `RESOLVED_BY_DESIGN_SYSTEM` | Focused app bar with back navigation is canonical for create/edit tasks. |
| Bottom navigation | Shell references show five equal destinations; Product Editor has none. | `RESOLVED_BY_DESIGN_SYSTEM` | Five equal tabs on top-level destinations only, in the locked order. |
| Selected tab treatment | Home and Menu references both use Primary icon/label and a small underline, with small geometry differences. | `RESOLVED_BY_DESIGN_SYSTEM` | One subtle indicator geometry is shared by every selected tab. |
| Category controls | Empty state uses an explicit check on the selected chip; populated state mixes icons and fill. | `RESOLVED_BY_DESIGN_SYSTEM` | Selected category is identified by label plus fill/border and a non-color cue; chips remain real-data driven. |
| Product cards | Populated Menu uses a dense two-column photographic grid; other screens do not establish this component. | `ACCESSIBILITY_OVERRIDE_REQUIRED` | Two columns are conditional; switch to one column when copy, text scale, availability, or actions become unsafe. |
| Availability controls | Product cards combine badge, label, and switch; Product Editor uses a larger labeled switch. | `RESOLVED_BY_DESIGN_SYSTEM` | Shared semantic value and labels; presentation adapts to card versus form without color-only communication. |
| Empty-state illustration style | Dashboard and Menu references use related warm dimensional illustration styles, but the embedded art cannot be reused. | `IMPLEMENTATION_CHOICE_REQUIRED` | Commission/approve original assets with provenance or use native composition; preserve hierarchy, not pixels. |
| IQD presentation | Populated product cards use `IQD`; Product Editor uses `د.ع`. | `RESOLVED_BY_DESIGN_SYSTEM` | Use one canonical Arabic `د.ع` presentation for the approved Arabic runtime. |
| Loading and error expectations | Approved PNGs show successful exact states, not loading/error visuals. | `IMPLEMENTATION_CHOICE_REQUIRED` | Implement the documented skeleton, inline error, preservation, and retry contracts with shared components. |
| Safe areas | All references visually respect device chrome; exact insets differ by raster. | `RESOLVED_BY_DESIGN_SYSTEM` | Use runtime safe-area insets at top and bottom. |
| Scroll behavior | Long references imply different content heights and the editor ends without shell navigation. | `RESOLVED_BY_DESIGN_SYSTEM` | Natural vertical scroll; no fixed screenshot height; keyboard and navigation insets remain reachable. |
| Minimum touch targets | Some edit, overflow, and inline toggle visuals appear smaller than 48px. | `ACCESSIBILITY_OVERRIDE_REQUIRED` | Preserve visible scale if useful, but expand the semantic/tappable target to at least 48px. |
| Public preview | Empty Menu shows a disabled preview; other references imply readiness without defining a new preview screen. | `BACKEND_CAPABILITY_CONSTRAINT` | Enable only with a real public route and confirmed readiness; remove any fabricated fallback URL or QR. |
| Product media | Populated cards show food photos and Product Editor shows upload intent, while the canonical upload contract is incomplete. | `BACKEND_CAPABILITY_CONSTRAINT` | Use real URLs only; ship P1 without upload dependency and defer P2 integration until contract completion. |
| Loyalty and scanner entry points | Dashboard and navigation expose intent, but no dedicated approved screens are part of this archive. | `BACKEND_CAPABILITY_CONSTRAINT` | Keep entry points permission- and readiness-aware; this lock does not visually approve those destination screens. |
| Notifications | Dashboard shows an unavailable notification action without a current backend contract. | `BACKEND_CAPABILITY_CONSTRAINT` | Keep disabled/omitted/informational; never simulate sending. |

## Lock readiness decision

The decision is **`VISUAL_SYSTEM_LOCKED_WITH_DOCUMENTED_GAPS`** because:

- all four approved references are readable and governed by a clear authority order;
- shared navigation, header, control, spacing, accessibility, responsive, state, and truthfulness decisions are consistent;
- no unresolved `VISUAL_CONFLICT` requires changing an approved image;
- draft, media upload, preview readiness, recent activity, notifications, entitlement state, multi-business selection, and customer isolation gaps are explicitly bounded;
- no missing capability must be faked to reproduce the visual hierarchy; and
- the implementation can proceed in small, guarded slices while unsupported behavior remains disabled, omitted, or informational.

This is not `WAFLO_UI_V3_VISUAL_SYSTEM_LOCKED` without qualification because production typography/assets, non-default loading/error visuals, Product Editor edit mode, media integration, and identified product/security gaps still require later implementation or human review.
