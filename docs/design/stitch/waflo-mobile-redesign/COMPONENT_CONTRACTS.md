# Waflo Mobile UI V3 Component Contracts

These contracts describe behavior and visual responsibilities without prescribing Dart structure. A production component may be split internally, but it must preserve the contract, semantic tokens, RTL behavior, security, accessibility, and backend truth defined here and in [VISUAL_SYSTEM_LOCK.md](VISUAL_SYSTEM_LOCK.md).

## Shared component rules

- Allowed state names describe observable UI states, not implementation classes.
- Security/unavailable and disabled states take precedence over loading, error, selected, focused, pressed, and default states.
- A mutation is successful only after backend confirmation.
- Components never retain or render data from a previous principal or workspace.
- Every interactive component has a 48px minimum target, visible focus where supported, and an Arabic semantic label.
- Screen-specific documents remain authoritative for exact scenarios.

## 1. `WafloWorkspaceHeader`

| Contract field | Requirement |
| --- | --- |
| Purpose | Identify the authoritative active restaurant workspace and expose only real shell-level utility actions. |
| Allowed states | `LOADING`, `READY`, `IDENTITY_WITHOUT_MEDIA`, `OFFLINE_OR_ERROR`, `UTILITY_DISABLED`. |
| Visual hierarchy | Restaurant identity is primary; real status is supporting; logo/placeholder and utility actions are subordinate. |
| Interaction behavior | Identity is non-interactive unless a real workspace/profile destination is deliberately provided. Utility icons invoke only implemented actions. |
| Loading behavior | Use restrained identity skeletons; never show a sample name, status, or logo. |
| Error behavior | Remove stale identity and show a compact safe error or unavailable label; do not substitute a fake workspace. |
| Disabled behavior | Unsupported utility actions are omitted or fully muted with a reason when visible. |
| Accessibility requirement | Announce restaurant name and status as text; label icon-only actions; preserve RTL reading/focus order. |
| Responsive behavior | Text wraps or truncates safely without hiding status/actions; respects top/cutout safe area from 360–430px. |
| Backend truth requirement | Name, media, status, permissions, and active workspace come from authoritative app context; no list-position selection. |
| Screens where used | Owner Dashboard; Menu Management empty and populated; future top-level owner destinations. |

## 2. `WafloFocusedAppBar`

| Contract field | Requirement |
| --- | --- |
| Purpose | Frame a focused create/edit task with a clear title and back navigation, outside the workspace shell. |
| Allowed states | `DEFAULT`, `UNSAVED_CHANGES`, `SUBMITTING`, `BACK_DISABLED_TEMPORARILY`. |
| Visual hierarchy | Task title leads; back is clear but secondary; no restaurant identity or shell tabs. |
| Interaction behavior | Back returns to the real source route; changed forms request discard confirmation and unchanged forms leave directly. |
| Loading behavior | Preserve title/context while submission is pending; do not imply that back saved a draft. |
| Error behavior | Navigation errors do not erase form state; retry or safe fallback remains explicit. |
| Disabled behavior | Back may be protected only while required to avoid ambiguous in-flight mutation; it is never silently inert. |
| Accessibility requirement | Back target is at least 48px, has a localized semantic label, mirrors correctly in RTL, and appears first in task focus order. |
| Responsive behavior | Title and back never overlap at text scale; top safe area is respected. |
| Backend truth requirement | App-bar mode reflects an actual create/edit route and dirty state; it never claims persistence. |
| Screens where used | Product Editor Create; future Product Editor Edit and other approved focused owner tasks. |

## 3. `WafloBottomNavigation`

| Contract field | Requirement |
| --- | --- |
| Purpose | Navigate among the five top-level authenticated workspace destinations. |
| Allowed states | `DEFAULT`, `SELECTED`, `DESTINATION_DISABLED`, `SHELL_LOADING`. |
| Visual hierarchy | Five equal tabs; selected icon/label use Primary plus one subtle shared indicator; scanner has no special elevation or size. |
| Interaction behavior | One tap changes to a real destination while preserving authoritative workspace context; selected-tab taps do not create duplicate navigation. |
| Loading behavior | Existing selection remains clear; navigation that lacks required context is disabled until context resolves. |
| Error behavior | A failed destination load shows that destination's error state without changing the tab order or leaking previous data. |
| Disabled behavior | An unavailable destination is visibly muted, non-interactive, and optionally explained; no dead active-looking tab. |
| Accessibility requirement | Equal 48px-or-larger targets; selected semantics; localized icon labels; predictable RTL visual and focus order. |
| Responsive behavior | Fixed, safe-area aware, no horizontal scroll, equal widths at 360–430px, and content inset prevents overlap. |
| Backend truth requirement | Destinations and permission/readiness state must be real; shell changes clear workspace-scoped state. |
| Screens where used | Dashboard, Menu Management, and future top-level Scanner, Loyalty, and Settings destinations; never Product Editor. |

## 4. `WafloPrimaryButton`

| Contract field | Requirement |
| --- | --- |
| Purpose | Express the strongest currently valid action in a task or section. |
| Allowed states | `ENABLED`, `PRESSED`, `FOCUSED`, `LOADING`, `DISABLED`, `SUCCESS_FEEDBACK_EXTERNAL`. |
| Visual hierarchy | Primary fill, high-contrast label, optional supporting icon; one dominant primary action per local task context. |
| Interaction behavior | Sends one deliberate action; repeated taps are ignored while pending. |
| Loading behavior | Remains dimensionally stable, shows restrained progress, and prevents duplicate submission. |
| Error behavior | Returns to an actionable state only when safe; error appears adjacent or at form level and preserves input. |
| Disabled behavior | Fully muted, no active elevation/fill, no tap callback; reason supplied when not self-evident. |
| Accessibility requirement | Minimum 48px height/target, meaningful label, busy/disabled semantics, text-scale-safe content. |
| Responsive behavior | May become full width or stack with secondary actions; label never clips at supported widths. |
| Backend truth requirement | Enabled only with real prerequisites and permission; success is external and follows a confirmed result. |
| Screens where used | Dashboard hero/actions, Menu empty/populated actions, Product Editor submission, retry/confirmation where primary. |

## 5. `WafloSecondaryButton`

| Contract field | Requirement |
| --- | --- |
| Purpose | Provide a real lower-priority alternative without competing with the main action. |
| Allowed states | `ENABLED`, `PRESSED`, `FOCUSED`, `LOADING`, `DISABLED`, `DESTRUCTIVE_VARIANT`. |
| Visual hierarchy | Outline or low-emphasis surface; destructive variant uses Error rather than Primary. |
| Interaction behavior | Executes one real secondary action such as category editing, cancel, remove, or retry. |
| Loading behavior | Prevents repeat activation and preserves action context. |
| Error behavior | Keeps the control available for safe retry and presents an honest adjacent error. |
| Disabled behavior | Fully muted and inert; unsupported draft/preview behavior cannot retain an active outline. |
| Accessibility requirement | Minimum 48px target, explicit label, non-color destructive cue, visible focus. |
| Responsive behavior | Stacks below/after primary when side-by-side labels or targets become unsafe. |
| Backend truth requirement | Never offers an unwired route/mutation; destructive success follows confirmation. |
| Screens where used | Dashboard and Menu alternate actions; Product Editor draft treatment only when disabled/omitted; dialogs. |

## 6. `WafloTextField`

| Contract field | Requirement |
| --- | --- |
| Purpose | Capture or filter a single line of user text with an unmistakable label. |
| Allowed states | `EMPTY`, `FILLED`, `FOCUSED`, `VALID`, `VALIDATION_ERROR`, `DISABLED`, `READ_ONLY`, `LOADING_DEPENDENCY`. |
| Visual hierarchy | Label and entered value lead; hint is temporary support; helper/error appears adjacent. |
| Interaction behavior | RTL input, appropriate keyboard action, deterministic trim/validation, and no clearing of valid text after other errors. |
| Loading behavior | Remains disabled only when a dependency is unresolved; never fills with sample content. |
| Error behavior | Uses semantic Error, clear Arabic copy, and focus/scroll guidance without trapping input. |
| Disabled behavior | Muted field, value remains readable when needed, and reason is exposed. |
| Accessibility requirement | Programmatic label, value, required/invalid/read-only state, visible focus, large-text-safe error. |
| Responsive behavior | Full available width, no horizontal page overflow, and safe long-value behavior. |
| Backend truth requirement | Limits mirror documented/server validation; values come from the user or authoritative record. |
| Screens where used | Product Editor product name; Menu Management search; future category forms. |

## 7. `WafloMultilineField`

| Contract field | Requirement |
| --- | --- |
| Purpose | Capture optional or required longer Arabic text without constraining it to raster height. |
| Allowed states | `EMPTY`, `FILLED`, `FOCUSED`, `VALID`, `VALIDATION_ERROR`, `DISABLED`, `READ_ONLY`. |
| Visual hierarchy | Persistent label, content area, character/requirement helper when useful, then error. |
| Interaction behavior | Preserves intentional internal line breaks, trims safely, and grows within controlled bounds. |
| Loading behavior | No sample description; loaded edit content appears only from an authoritative record. |
| Error behavior | Adjacent wrapping message; valid content remains intact. |
| Disabled behavior | Muted but readable when content must be reviewed; not focusable as an editor. |
| Accessibility requirement | Multiline semantics, label association, text scaling, keyboard traversal, and no nested-scroll trap. |
| Responsive behavior | Natural growth or controlled internal scroll; no fixed screenshot height. |
| Backend truth requirement | Current Product Editor description is optional with the documented maximum; do not invent new limits. |
| Screens where used | Product Editor description; future focused content forms. |

## 8. `WafloSelectField`

| Contract field | Requirement |
| --- | --- |
| Purpose | Choose one real option, such as a business-scoped category. |
| Allowed states | `UNSELECTED`, `SELECTED`, `OPEN`, `LOADING_OPTIONS`, `EMPTY_OPTIONS`, `ERROR`, `DISABLED`. |
| Visual hierarchy | Label and current selection lead; selector affordance and helper/error are clear. |
| Interaction behavior | Opens an accessible option surface, keeps selection explicit, and rejects stale/unauthorized values. |
| Loading behavior | Options are unavailable with progress; previous-business options are cleared before loading. |
| Error behavior | Shows load/retry state without inventing choices or silently keeping stale selection. |
| Disabled behavior | Inert with a reason, especially when no category or permission exists. |
| Accessibility requirement | Announces label, selected value, expanded state, option count, and focus movement. |
| Responsive behavior | Option labels wrap safely; popup/sheet stays inside safe areas and keyboard bounds. |
| Backend truth requirement | Options come only from the authoritative active business and required record state. |
| Screens where used | Product Editor category; future settings/category-linked forms. |

## 9. `WafloPriceField`

| Contract field | Requirement |
| --- | --- |
| Purpose | Capture an exact business-currency product price without cent or numeral ambiguity. |
| Allowed states | `EMPTY`, `FILLED`, `FOCUSED`, `VALID`, `VALIDATION_ERROR`, `DISABLED`, `READ_ONLY`. |
| Visual hierarchy | Price label and numeric value lead; canonical currency marker `د.ع` is clearly associated but not editable. |
| Interaction behavior | Normalize supported Arabic/Iraqi/Western digits, keep normal IQD entry integer-safe, and submit exact major-unit decimal text. |
| Loading behavior | Currency may wait on authoritative business context; no fallback amount is inserted. |
| Error behavior | Reject empty, negative, malformed, or over-precision values using adjacent Arabic guidance. |
| Disabled behavior | Inert while currency/workspace/permission is unresolved; reason remains available. |
| Accessibility requirement | Announce currency and numeric value unambiguously; numeric keyboard does not replace validation. |
| Responsive behavior | Value and suffix never overlap; large numbers/text scale reflow without horizontal overflow. |
| Backend truth requirement | Runtime currency comes from the business; item contract accepts non-negative decimal text with up to two fractional digits; no binary float/cents assumption. |
| Screens where used | Product Editor create and future edit. |

## 10. `WafloAvailabilityControl`

| Contract field | Requirement |
| --- | --- |
| Purpose | Display and change whether a product is available to customers. |
| Allowed states | `AVAILABLE`, `UNAVAILABLE`, `PENDING`, `ERROR_RESTORED`, `DISABLED`, `READ_ONLY`. |
| Visual hierarchy | Explicit Arabic state label plus switch/control; color supports but does not carry meaning. |
| Interaction behavior | One toggle sends the documented value; repeated changes are blocked while pending. |
| Loading behavior | Preserve the last confirmed value and show restrained progress. |
| Error behavior | Restore/refresh confirmed value and present a safe retry/error; no false optimistic success. |
| Disabled behavior | Muted, inert, and explains permission or missing-context reason. |
| Accessibility requirement | Correct switch role, announced label/value/busy state, 48px target, visible focus. |
| Responsive behavior | Label and control do not overlap; card form may compact while keeping the semantic target. |
| Backend truth requirement | Value maps only to the documented availability field; it is never a draft flag. |
| Screens where used | Menu Management populated product cards; Product Editor create/future edit. |

## 11. `WafloImagePickerField`

| Contract field | Requirement |
| --- | --- |
| Purpose | Manage optional local merchant image selection and its separate upload lifecycle. |
| Allowed states | `EMPTY_OPTIONAL`, `SELECTING`, `SELECTED_LOCAL`, `UPLOADING`, `UPLOADED`, `UPLOAD_ERROR`, `PERMISSION_DENIED`, `DISABLED`. |
| Visual hierarchy | Media area, optional status, replace/remove controls, progress/error; never screenshot-derived art. |
| Interaction behavior | Opens the real native picker once; selected media can be replaced/removed; upload occurs only through the supported flow. |
| Loading behavior | Upload progress is distinct from product submission and preserves form fields. |
| Error behavior | Preserve local selection/form, allow retry/replace/remove, and permit image-free create when contract allows. |
| Disabled behavior | Omit or clearly disable when integration is unavailable; do not show a fake picker. |
| Accessibility requirement | Descriptive pick/replace/remove labels, image preview description, progress announcement, 48px controls. |
| Responsive behavior | Media height may reduce on narrow devices; preview preserves aspect without page overflow. |
| Backend truth requirement | Only a backend-confirmed real URL is submitted; current upload support remains `PARTIAL` until canonical documentation/integration is complete. |
| Screens where used | Product Editor create/future edit; product media itself is rendered by `WafloProductCard`. |

## 12. `WafloCategoryChip`

| Contract field | Requirement |
| --- | --- |
| Purpose | Select one authoritative category while preserving visible context. |
| Allowed states | `DEFAULT`, `SELECTED`, `PRESSED`, `FOCUSED`, `DISABLED`, `LOADING_PLACEHOLDER`. |
| Visual hierarchy | Category label leads; selected state combines fill/border with a non-color cue. |
| Interaction behavior | Selects a real loaded category and filters local business-scoped products; no arbitrary list-position authority. |
| Loading behavior | Use restrained placeholders and no fake category names. |
| Error behavior | Category controls are unavailable until recovery; stale prior-business selection is cleared. |
| Disabled behavior | Muted and inert when category data or permission/context is unavailable. |
| Accessibility requirement | Selected semantics, localized label, 48px target, keyboard/focus support, no color-only selection. |
| Responsive behavior | Horizontal scrolling is allowed without page overflow; selection remains visible and reachable. |
| Backend truth requirement | Each chip maps to a real category belonging to the authoritative active business. |
| Screens where used | Menu Management empty and populated. |

## 13. `WafloProductCard`

| Contract field | Requirement |
| --- | --- |
| Purpose | Present an owner-visible real product with supported identity, price, media, availability, and actions. |
| Allowed states | `AVAILABLE`, `UNAVAILABLE`, `NO_IMAGE`, `MUTATION_PENDING`, `ACTION_ERROR`, `READ_ONLY`. |
| Visual hierarchy | Media/placeholder and name lead; price and availability remain prominent; description and actions are supporting. |
| Interaction behavior | Edit targets the real record; overflow shows only implemented actions; availability follows its control contract. |
| Loading behavior | Use skeleton cards without sample copy, prices, availability, or food photos. |
| Error behavior | Per-card mutation error preserves confirmed record state and does not corrupt unrelated cards. |
| Disabled behavior | Permission-restricted cards remain readable while mutation controls are muted/omitted. |
| Accessibility requirement | Logical reading order, image alternative, explicit availability, 48px edit/overflow/toggle targets. |
| Responsive behavior | Two columns only when safe; one-column fallback, no fixed height, safe Arabic wrapping and image aspect ratio. |
| Backend truth requirement | Render only fields guaranteed by the owner record; never fill missing descriptions/media from raster samples. |
| Screens where used | Menu Management populated; future search result states. |

## 14. `WafloMetricCard`

| Contract field | Requirement |
| --- | --- |
| Purpose | Show one clearly defined authoritative business metric. |
| Allowed states | `VALUE`, `ZERO_CONFIRMED`, `LOADING`, `UNAVAILABLE`, `ERROR`. |
| Visual hierarchy | Label defines the metric; value leads; icon is supporting; availability/error is explicit. |
| Interaction behavior | Non-interactive unless a real destination is separately specified and labeled. |
| Loading behavior | Skeleton value only; no fake zero. |
| Error behavior | Show unavailable/error rather than a number and never preserve another workspace's value. |
| Disabled behavior | Not generally applicable as an action; an unavailable metric uses muted informational treatment. |
| Accessibility requirement | Announce label and value/status together; icon never substitutes for text. |
| Responsive behavior | Reflow grid/stack rather than shrinking critical text; no clipped localized labels. |
| Backend truth requirement | Metric definition and value come from one authoritative business-scoped contract; missing customer/activity/entitlement data stays unavailable. |
| Screens where used | Owner Dashboard; Menu readiness/count summaries where the same semantic contract applies. |

## 15. `WafloEmptyState`

| Contract field | Requirement |
| --- | --- |
| Purpose | Explain a confirmed absence and teach the next real useful action. |
| Allowed states | `NO_CATEGORIES`, `NO_PRODUCTS`, `NO_SEARCH_MATCH`, `NO_ACTIVITY_CONFIRMED`, `CAPABILITY_UNAVAILABLE`, `GENERIC_CONFIRMED_EMPTY`. |
| Visual hierarchy | Clear title and explanation lead; optional original/native illustration supports; real action follows. |
| Interaction behavior | CTA routes to the real prerequisite or mutation; search empty offers clear-search rather than onboarding copy. |
| Loading behavior | Never shown before a successful empty response; use skeleton/loading instead. |
| Error behavior | Never substitutes for request failure; use `WafloInlineError`. |
| Disabled behavior | When the next action is unavailable, show an honest informational reason instead of an active CTA. |
| Accessibility requirement | Reading order is title, explanation, action; illustration is decorative or has useful alternative text. |
| Responsive behavior | Copy and action stack naturally; original/native art scales without overflow or fixed page height. |
| Backend truth requirement | Empty state requires authoritative proof; no fake zero, category, activity, or customer state. |
| Screens where used | Dashboard recent activity/unsupported sections; Menu no-category, no-product, and no-search-match states. |

## 16. `WafloInlineError`

| Contract field | Requirement |
| --- | --- |
| Purpose | Present a safe actionable load, field-group, or mutation failure without replacing valid context. |
| Allowed states | `FIELD_GROUP`, `SECTION_LOAD`, `MUTATION`, `PERMISSION`, `OFFLINE`, `RETRYING`. |
| Visual hierarchy | Short human-readable message leads; retry/supporting action follows; technical detail is excluded. |
| Interaction behavior | Retry is deliberate and deduplicated; focus moves appropriately without trapping the user. |
| Loading behavior | Retry shows restrained progress and prevents duplicate attempts. |
| Error behavior | Uses semantic Error plus icon/text; safe copy does not expose raw server data. |
| Disabled behavior | Retry is disabled when prerequisites/permission remain unavailable, with reason. |
| Accessibility requirement | Announced as an error/live update without excessive repetition; retry target is 48px. |
| Responsive behavior | Arabic copy wraps; no horizontal overflow or overlap with controls. |
| Backend truth requirement | Reflects the actual failed operation; never converts failure to empty/zero or exposes identifiers/PII. |
| Screens where used | All data and mutation screens in this archive. |

## 17. `WafloSkeleton`

| Contract field | Requirement |
| --- | --- |
| Purpose | Reserve approximate layout during authoritative data loading without fabricating content. |
| Allowed states | `HEADER`, `CARD`, `METRIC`, `LIST`, `FORM_DEPENDENCY`, `STATIC`. |
| Visual hierarchy | Mirrors broad component mass only, not readable sample text or exact screenshot content. |
| Interaction behavior | Non-interactive and removed when load succeeds/fails. |
| Loading behavior | Animation is restrained and respects reduced-motion preferences. |
| Error behavior | Replaced by a real error component; it does not loop indefinitely after failure. |
| Disabled behavior | Not interactive; loading dependent actions remain separately disabled. |
| Accessibility requirement | Excluded from meaningful reading order or announced once as loading; no flashing motion. |
| Responsive behavior | Uses the same responsive layout rules as its destination component. |
| Backend truth requirement | Exists only while a real request/dependency is pending; no sample business or product data. |
| Screens where used | Workspace header, Dashboard metrics, Menu categories/cards, Product Editor edit dependencies. |

## 18. `WafloConfirmationDialog`

| Contract field | Requirement |
| --- | --- |
| Purpose | Confirm discard or consequential/destructive action with explicit outcomes. |
| Allowed states | `OPEN`, `CONFIRMING`, `CONFIRM_ERROR`, `DISMISSED`. |
| Visual hierarchy | Consequence-specific title/body; safe cancel and explicit confirm; destructive confirm uses Error. |
| Interaction behavior | Focus is contained while open; cancel preserves state; confirm runs once; back/dismiss behavior is explicit. |
| Loading behavior | Confirm action shows progress and blocks repeat; dialog remains stable. |
| Error behavior | Keep dialog/context when safe, explain failure, and allow retry/cancel. |
| Disabled behavior | Confirm remains disabled until required acknowledgement/prerequisite when applicable. |
| Accessibility requirement | Announced title, modal semantics, initial safe focus, keyboard dismissal policy, 48px actions, text-scale support. |
| Responsive behavior | Fits narrow screens/safe areas; actions stack when labels cannot fit. |
| Backend truth requirement | Never claims deletion/save/discard persistence before the actual action completes; discard does not create a draft. |
| Screens where used | Product Editor unsaved changes; future category/product destructive actions. |

## 19. `WafloStatusBadge`

| Contract field | Requirement |
| --- | --- |
| Purpose | Communicate compact non-interactive status with text and supporting visual cue. |
| Allowed states | `POSITIVE`, `NEUTRAL`, `WARNING`, `ERROR`, `UNAVAILABLE`, `LOADING`. |
| Visual hierarchy | Short localized label leads; color/icon/shape supports the meaning. |
| Interaction behavior | Non-interactive; use a button/chip contract if tapping is required. |
| Loading behavior | Neutral placeholder without claiming a status. |
| Error behavior | Error badge uses semantic Error and explicit text/icon. |
| Disabled behavior | Use `UNAVAILABLE` wording rather than a disabled interactive appearance. |
| Accessibility requirement | Status text is announced; no color-only meaning; adequate contrast and text-scale behavior. |
| Responsive behavior | Label wraps only when necessary; never obscures adjacent price/action. |
| Backend truth requirement | Status must be confirmed or explicitly unavailable; no inferred subscription, readiness, or activity state. |
| Screens where used | Workspace status, Menu readiness/product availability, Dashboard capability/metric context. |

## 20. `WafloSectionHeader`

| Contract field | Requirement |
| --- | --- |
| Purpose | Name and explain a coherent content group and optionally expose one real secondary action. |
| Allowed states | `TITLE_ONLY`, `TITLE_AND_SUBTITLE`, `WITH_ACTION`, `LOADING_SUPPORT`, `ACTION_DISABLED`. |
| Visual hierarchy | Section title leads; subtitle explains; action is secondary and visually separate. |
| Interaction behavior | Optional action invokes one real destination/operation and never turns the whole header into an ambiguous target. |
| Loading behavior | Title may remain while dependent subtitle/action is skeletonized or disabled. |
| Error behavior | Section error appears below via `WafloInlineError`; title remains useful context. |
| Disabled behavior | Optional action is muted/omitted with a reason; title is never styled as disabled. |
| Accessibility requirement | Correct heading semantics/order; action has explicit label and 48px target. |
| Responsive behavior | Subtitle and action reflow/stack without clipping; RTL alignment remains consistent. |
| Backend truth requirement | Counts/status in subtitle and action availability come from authoritative data/permissions. |
| Screens where used | Dashboard, Menu Management, Product Editor form groups, and future top-level owner screens. |
