# Waflo V2 Design System

Status: `Planned` unless an item is explicitly marked `Existing and verified`.

This specification is the visual and interaction foundation for the new Flutter mobile application. It does not declare the existing Flutter UI production-ready and does not authorize Phase 1 implementation.

## 1. Design principles

1. Arabic-first and RTL by construction, not by mirroring at the end.
2. Mobile-first workflows with one clear primary action per screen.
3. Role-appropriate density: Owner and Manager receive context; Staff receives the shortest safe transaction path.
4. Backend honesty: loading, failure, empty, saved, and published are distinct states.
5. Loyalty state and visual presentation are separate. A design change must never mutate balances, earning rules, rewards, or ledger entries.
6. Accessible defaults before merchant customization. Unsafe color combinations must be blocked or corrected before publishing.

The `ui-ux-pro-max` design review informed the use of strong hierarchy, generous spacing, reduced motion, inline validation, and minimum touch targets. Its suggested palette and Latin-first type choices were not adopted because the approved Waflo brand and Arabic/Sorani requirements are authoritative.

## 2. Color tokens

### 2.1 Brand primitives

| Token | Value | Intended use |
|---|---:|---|
| `brand.primary` | `#AE3115` | Primary actions, active navigation, key emphasis |
| `brand.accent` | `#FF6B4A` | Accent surfaces and decorative emphasis |
| `surface.canvas` | `#F7F9FF` | Application background |
| `surface.base` | `#FFFFFF` | Cards, sheets, inputs |
| `text.primary` | `#181C20` | Main text |
| `feedback.error` | `#BA1A1A` | Error text and destructive actions |
| `feedback.success` | `#176B3A` | Confirmed success |
| `feedback.warning` | `#8A4B00` | Warnings requiring attention |

### 2.2 Verified contrast guidance

- `#AE3115` with white text is approximately `6.46:1` and may be used for normal text.
- `#FF6B4A` with white text is approximately `2.82:1` and must not be used for normal white-on-accent labels.
- `#FF6B4A` with `#181C20` text is approximately `6.08:1`.
- `#181C20` on `#F7F9FF` is approximately `16.27:1`.
- Success and warning colors above exceed `6.5:1` with white.

Flutter implementation must expose semantic tokens such as `actionPrimaryBackground`, `onActionPrimary`, `statusSuccess`, and `dividerSubtle`; feature code must not use raw hex values. Merchant-selected colors belong to a separate validated `CardDesign` token set and must not override application chrome.

## 3. Typography

`Existing but unverified`: the repository contains more than one Flutter theme generation. V3 relies mainly on platform defaults, while older V2 styling references Latin-oriented choices. No bundled Arabic/Sorani production font was verified.

`Planned`:

- Evaluate and license/bundle `Noto Sans Arabic` or an equivalent Arabic/Sorani-capable family for `ar` and `ckb`.
- Use a compatible, highly legible Latin family for `en`; `Inter` is a candidate, not an approved dependency.
- Prefer tabular numerals for points, money, and reporting values.
- Define semantic styles: Display, Title, Body, Label, Caption, and Numeric Emphasis.
- Support system text scaling without clipping at least through `200%` on critical flows.
- Use locale-aware line height and avoid fixed-height text containers.

Typography and Kurdish glyph quality require human linguistic and visual approval. Codex cannot issue `HUMAN_VISUAL_PASS`.

## 4. Spacing, shape, and elevation

- Base grid: `4 dp`.
- Standard screen margin: `16 dp`; use `20–24 dp` only on sufficiently wide layouts.
- Common gaps: `4, 8, 12, 16, 24, 32 dp`.
- Card content padding: normally `16 dp`; `24 dp` for high-emphasis setup cards.
- Minimum interactive target: `48 × 48 dp`.
- Common radii: `12, 16, 20, 24 dp`; use pills only for statuses, chips, or intentionally rounded actions.
- Prefer borders and tonal separation to heavy shadows. Modal sheets may use restrained elevation.

Use logical direction values (`start`, `end`) instead of physical `left`, `right`. Insets must respect device safe areas and keyboard appearance.

## 5. Core components

### 5.1 Navigation and structure

- `RoleAwareAppShell`: renders only destinations authorized for the active membership.
- `WafloBottomNavigation`: Home, Programs, Scan, Customers, More; Staff receives the reduced mapping defined in the information architecture.
- `WorkspaceSwitcher`: explicit, membership-backed selection; it never defaults by list position.
- `BranchContextControl`: visible whenever an action is branch-scoped.
- `WafloAppBar`, `WafloSectionHeader`, `WafloBottomSheet`, and `WafloDialog`.

### 5.2 Buttons

- `PrimaryButton`: one preferred outcome per surface.
- `SecondaryButton`: safe alternative.
- `TertiaryButton`: low-emphasis navigation or disclosure.
- `DestructiveButton`: irreversible or high-impact operations, always explicit.
- `IconButton`: accessible name required; icon alone must not carry ambiguous meaning.

Disabled buttons explain the missing prerequisite when it is not obvious. A button may show success only after backend confirmation.

### 5.3 Inputs and forms

- Text, phone, email, money, integer, percentage, select, searchable select, date/time, color, media, product/service, and rule-builder inputs.
- Validation appears next to the affected field and is announced to assistive technologies.
- Amounts and phone numbers use locale-appropriate direction isolation so they remain readable inside RTL content.
- Unsaved changes, draft state, validation failure, and publish failure are separate states.

### 5.4 Cards and feedback

- Program, customer, reward, transaction, metric, setup task, and warning cards.
- Skeleton/loading, empty, recoverable error, permission denied, offline read-only, and stale-data states.
- Status chips include both text and icon/shape; color alone is insufficient.
- Toasts are supplemental. Important outcomes stay visible in the page or transaction receipt.

## 6. Card Customization Studio

### 6.1 V1 baseline

The Studio is a Flutter merchant workflow for Owner and authorized Manager roles. It configures presentation only.

Supported controls:

- Business/program logo and cover image.
- Primary, secondary, background, and text colors.
- Stamp shape and icon for stamp/visit programs.
- Reward image or icon.
- Customer join-page appearance.
- QR Poster appearance and print/export preview.
- Side-by-side, provider-aware Apple Wallet and Google Wallet previews.
- Save a base design and reuse an existing business-owned design as the starting point for another program.

Core components:

- `StudioStepRail` or compact stepper: Brand, Colors, Earning Visual, Rewards, Join Page, Poster, Wallet, Review.
- `MediaAssetPicker`: real upload state only; no fake local success.
- `AccessibleColorPicker`: hex input, swatches, contrast result, and safe suggested correction.
- `StampShapePicker` and `IconPicker` with semantic labels.
- `JoinPagePreview`, `QrPosterPreview`, `AppleWalletPreview`, and `GoogleWalletPreview`.
- `PreviewViewportSwitcher` for phone and print aspect ratios.
- `DraftStatusBar` with last confirmed save and publish state.

Provider previews are visual approximations backed by provider capability rules. They must be labeled `Preview`; only an issued test pass on the actual provider proves the result. Unsupported provider fields are hidden or explained instead of simulated.

### 6.2 Design validation

Before publish, validate:

- Contrast for text and critical icons.
- Image format, dimensions, safe crop, size, and upload completion.
- Required provider fields and provider-specific limits.
- QR quiet zone, minimum physical size, and print legibility.
- RTL/LTR text overflow across Arabic, Sorani Kurdish, and English.
- Ownership of every referenced media/design asset by the active Business.

Saving a draft and publishing an active design are different commands. Publishing requires backend confirmation and creates an audit event.

## 7. Seasonal Theme Engine

### 7.1 Architectural rule

`LoyaltyProgram`, `Campaign/Event`, and `VisualTheme` are independent concepts:

- `LoyaltyProgram` owns earning and reward behavior.
- `Campaign/Event` owns an occasion, audience, and optional communication context.
- `VisualTheme` owns visual overrides only.

Changing or expiring a theme cannot alter a membership, balance, tier, reward entitlement, transaction, or redemption.

### 7.2 Theme experience

Supported occasion presets may include Ramadan, Eid, New Year, Birthday, Black Friday, business anniversary, and a custom occasion. Presets are editable starting points, not globally imposed campaigns.

Each theme exposes:

- `startAt`, `endAt`, and the Business timezone.
- `Draft`, `Scheduled`, `Active`, or `Expired` status.
- Preview without publishing.
- Manual activation/deactivation where policy permits.
- Automatic activation and expiry.
- Automatic fallback to the immutable base design after expiry.
- Assignment to one or multiple programs.
- A conflict preview when scheduled themes overlap.

### 7.3 Release scope

- `V1`: one validated base design per program, preview surfaces, draft/save/publish, and reuse from an existing design.
- `V1.5`: named reusable templates, advanced seasonal presets, multi-program assignments, scheduling, conflict resolution, automatic activation/expiry, and history/rollback of published visual revisions.

If scheduling threatens V1 security or wallet reliability, it remains in V1.5. The proposed domain contracts may be defined in Phase 1, but no scheduler or persistence migration is implemented there.

## 8. RTL and localization

`Existing and verified`: generated Flutter localization support and automated tests exist for Arabic (`ar`), Sorani Kurdish (`ckb`), and English (`en`).

`Existing but unverified`: human translation quality and full visual behavior on physical devices.

Rules:

- Arabic and Sorani use RTL application direction; English uses LTR.
- Icons conveying forward/back direction mirror; universal icons such as QR, play, and check do not.
- Charts, timelines, phone numbers, currency, dates, and codes receive deliberate bidirectional handling.
- Do not concatenate translated fragments. Use parameterized messages and plural rules.
- Merchant-authored custom reward/theme text retains the author-selected locale and safe fallback.
- Preview each customizable surface in all enabled locales before publish.

## 9. Accessibility and motion

- Target WCAG 2.2 AA contrast for application UI and publish-time validation for merchant designs.
- Every control has an accessible name, role, state, and logical focus order.
- Scanner workflows provide visual, audible, and haptic outcomes where the platform and user settings allow.
- Respect reduced-motion settings. Use motion to explain state change, normally `150–250 ms`, never as the only feedback.
- Do not auto-dismiss errors before assistive technology can announce them.
- Provide non-camera alternatives for manual customer lookup and code entry.

## 10. Responsive and platform behavior

The primary targets are iOS and Android phones. Layouts must remain usable on small screens, large text, keyboard-open states, and common tablet widths. Platform conventions may differ for pickers, back navigation, and Wallet actions while retaining the same product contract.

Dark mode is `Deferred` from V1. The initial system uses a complete light semantic palette; no partial dark theme may ship.

## 11. Design release gates

No new mobile surface is accepted until:

1. Loading, empty, error, offline, permission, and success states are specified.
2. Arabic RTL, Sorani RTL, and English LTR are exercised.
3. Touch targets, screen-reader labels, contrast, text scaling, and keyboard behavior pass.
4. Owner, Manager, and Staff permissions match backend authorization.
5. Card/Wallet previews are labeled honestly and compared with real provider artifacts before release.
6. A human grants visual acceptance. Automated checks and Codex review do not replace `HUMAN_VISUAL_PASS`.
