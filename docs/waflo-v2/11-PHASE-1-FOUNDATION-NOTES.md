# Phase 1 Foundation Notes

Status: `HUMAN_VISUAL_PASS - PHASE 1 R5 recorded; Sorani human linguistic
review still required`. No PR, merge, Phase 2 work, production bootstrap
integration, migration, or release enablement is authorized by this checkpoint.

## 1. Verified implementation boundary

Phase 1 remains additive under:

- `apps/mobile/lib/waflo_v2/`
- `apps/mobile/test/waflo_v2/`
- `apps/mobile/assets/waflo_v2/`
- the minimal asset/font declaration in `apps/mobile/pubspec.yaml`
- `docs/waflo-v2/02-V1-SCOPE.md`
- `docs/waflo-v2/03-LOYALTY-DOMAIN.md`
- `docs/waflo-v2/08-ROADMAP.md`
- `docs/waflo-v2/09-DECISIONS.md`
- this note

The production application bootstrap, Legacy Flutter generations, API,
Prisma schema/migrations, Customer Web, Admin Web, W2A workspace/scanner code,
and existing routes are not modified. `WafloV2FoundationApp` remains a
fixture/test host and is not imported by production bootstrap.

## 2. Official Brand System alignment

### Token layers

- `WafloPrimitives`: the eleven official raw colors only.
- `WafloColors`: intent-based application roles, including action, text,
  surface, status foreground, status container, and on-container roles.
- `WafloComponentTokens`: shared component aliases for primary actions, focus,
  card/control radii, and the official elevation token.
- Features consume semantic roles, not primitive brand names.

Official primitives:

`#AE3115`, `#FF6B4A`, `#7D2311`, `#FFF0EC`, `#241916`, `#76645F`,
`#F7F9FF`, `#FFFFFF`, `#1F8F6A`, `#E6A23C`, `#C93C2B`.

Automated contrast evidence includes:

| Pair | Ratio |
|---|---:|
| Brick / White | 6.46:1 |
| Coral / Warm Ink | 6.08:1 |
| Success / derived deep warm foreground | 4.82:1 |
| Warning / Warm Ink | 7.83:1 |
| Danger / White | 5.04:1 |
| Success container / on-container | 7.09:1 |
| Warning container / Warm Ink | 15.73:1 |
| Information Soft Coral / Ember | 8.93:1 |

White is not used on Coral, Warning, or Success where it fails normal-text AA.
Information uses a warm brand-neutral treatment rather than unrelated blue.

### Geometry and elevation

- Radii: `8`, `14`, `22`, `32`, `999`; `22` is the standard card radius.
- Central elevation: `0 12 32 rgba(36,25,22,0.10)`.
- Most surfaces remain border-based; the elevation token is reserved for
  materially elevated preview content.

### Typography and licenses

- Latin: Manrope.
- Arabic and Sorani: Noto Sans Arabic.
- Display `48/56 800`, H1 `36/44 800`, H2 `28/36 700`, Body `16/26 400`,
  Label `14/20 600`, Caption `12/18 500`.
- Arabic/Sorani fall back to bundled Manrope for Latin glyphs; English falls
  back to bundled Noto Sans Arabic. No runtime font download exists.

Files came from the official Google Fonts repository:

- `ofl/manrope/Manrope[wght].ttf`, SHA-256
  `D0639BE45D0AF36E798172419D7BD173C4BD4F29E2B76CBB69DB1D11BF8B0A40`.
- `ofl/notosansarabic/NotoSansArabic[wdth,wght].ttf`, SHA-256
  `63111B5B2E074DD48CC67692E0A2726D86EE94C1C37FE8598257B7B4E87E869E`.
- Family-specific OFL files are bundled under
  `assets/waflo_v2/fonts/` and tested through Flutter's asset bundle.

### Official mark

Only `Waflo-Brand-System/Logo/PNG/waflo-mark-primary-256.png` was extracted
from the Brand System ZIP. It is isolated at
`assets/waflo_v2/brand/waflo-mark-primary-256.png`, SHA-256
`E42C1706DB7F2A17A788339B640280F433E10800079B7B5508F73131638B5450`.
The shell renders it at the recommended 32dp inside explicit clear space and
rejects sizes below the documented 24dp minimum.

## 3. Role, localization, and truthful-state foundation

- Arabic (`ar`) and Sorani (`ckb`) use RTL and Noto Sans Arabic; English (`en`)
  uses LTR and Manrope.
- Owner/Manager retain Home, Programs, Scan, Customers, More when capabilities
  allow.
- Staff uses the approved Scan, Rewards, My Activity, Account navigation.
  Manual customer search is represented as a fallback inside Scan, never a
  separate tab.
- Workspace resolution still fails closed and never selects a Business by list
  position. UI capability filtering is presentation only; future backend
  Business/Branch authorization remains mandatory.
- Loading, empty, error, offline, forbidden, stale, confirmed, draft, and
  disabled states remain distinct. Compact gallery states use the official
  Caption role to avoid clipping and excessive density.

## 4. Blueprint contracts — no operational implementation

- Program lifecycle is `DRAFT → VALIDATED → PUBLISHED → PAUSED → ARCHIVED`.
  Active is derived from Published plus temporal/operational conditions.
- V1 presentation contracts include Visit/Stamp, Spend-based, Item-based,
  Category-based, Completed Service, Hybrid, and non-scheduled Welcome.
- Manual Adjustment is an administrative Secure Operations command, not an
  EarningRule; the contract requires permission, Reason, AuditLog, and
  policy-based approval.
- Reward contracts include all Blueprint Planned V1 kinds. They do not imply a
  Reward Engine, entitlement, inventory, discount, redemption, or backend path.
- CustomerAccount remains Business-scoped in the future design; Phase 1 adds no
  Prisma or authentication change.

## 5. Card Studio and provider preview foundation

- `CardDesignDraft` has five independent colors: primary, secondary, accent,
  background, and text.
- Contrast resolution evaluates the merchant text color, Warm Ink, and white,
  then uses the best accessible foreground. Coral resolves to Warm Ink.
- Empty media remains visibly “not uploaded”; local-only media cannot be treated
  as server-confirmed.
- Waflo Card is an exact/deterministic preview.
- Apple Wallet and Google Wallet have different constrained structures and an
  explicit `Platform approximation` badge. `isAvailable`,
  `isDeterministicPreview`, and `isRealDeviceVerified` drive presentation.
- No preview claims real-device verification. Save, upload, publish, QR,
  Wallet issuance, notifications, Scheduler, Earning, and Redemption remain
  disabled/unimplemented.
- `LoyaltyProgram`, `Campaign/Event`, and `VisualTheme` remain separate; visual
  changes have no loyalty-value mutation dependency.

## 6. Verification record

Verified with Flutter `3.41.9` / Dart `3.11.5` in the dedicated V2 Worktree:

- Format verification: `58` Dart files checked, `0` changed.
- Full `flutter analyze`: `0` issues.
- Focused Waflo V2 suite: `83/83` passed.
- Focused isolation/Workspace/Scanner/Shell matrix: `81/81` passed.
- Full Flutter suite including Legacy: `392/392` passed.
- Visual review scenarios: `9/9` widget renders passed.
- Isolated Flutter Web review build: release build passed.

API, Customer Web, and Admin Web suites were not rerun because no Backend, Web,
shared package, or production bootstrap file changed. This note does not claim
a new pass for those surfaces.

## 7. Visual evidence and remaining gates

Final local browser-engine evidence is under ignored build output:

`apps/mobile/build/waflo_v2_review_evidence/phase1-brand-alignment-r4/`

It contains Owner Arabic RTL, Staff Sorani RTL, Manager English LTR, Arabic
state gallery, Arabic Studio, Sorani Wallet previews, English Studio, a 360dp
large-text Arabic surface, and the provider comparison. Chrome enforces a 500px
headless canvas minimum, so screenshot 8 visibly centers an exact 360dp app
surface; widget tests also execute the Studio at 360dp directly.

The screenshots were generated with local Chrome because the in-app browser's
trusted bridge was unavailable in this session. They are browser evidence, not
iOS/Android or Wallet device evidence. Remaining gates include Sorani human
linguistic acceptance, real-device safe areas/screen readers, and later genuine
Apple/Google Wallet issuance/update tests.

## 8. Visual Alignment R5 decision and linguistic gate

Card Studio is a mobile wizard, not a long page of simultaneously visible
sections. The horizontal rail is an interactive progress navigator, and the
Previous/Next actions move through the same eight-step state. Only the selected
step's content is mounted. The rail auto-reveals the selected chip and exposes a
visible horizontal-swipe affordance; this behavior is covered in both LTR and
RTL at 360dp with 1.6x text scaling.

Preview-only status is communicated by the top banner and, only where useful,
one section badge. Read-only fields no longer repeat the same helper message.
The small deterministic Waflo rendering is explicitly named `Compact Waflo
Card preview`; the larger Studio review remains the exact Waflo design preview.
Apple Wallet and Google Wallet remain `Platform approximation` and are not
real-device verification.

Sorani (`ckb`) copy remains `HUMAN_LINGUISTIC_REVIEW_REQUIRED`. A fluent Sorani
reviewer must approve terminology, grammar, truncation behavior, and Wallet
fidelity notices before final visual acceptance. Automated localization and RTL
tests cannot satisfy this gate, and Phase 1 must not claim that they do.

## 9. Visual Alignment R5 verification

R5 was verified with Flutter `3.41.9` / Dart `3.11.5` in the dedicated V2
Worktree:

- Changed Dart format verification: `8` files checked, `0` changed.
- Full `flutter analyze`: `0` issues.
- Focused Card Studio suite: `8/8` passed.
- Focused Waflo V2 suite: `83/83` passed.
- Full Flutter suite including Legacy: `392/392` passed.
- Isolated Flutter Web review build: release build and Wasm dry run passed.
- R5 browser evidence: `5/5` requested captures generated and reviewed.

The R5 evidence is under ignored build output at:

`apps/mobile/build/waflo_v2_review_evidence/phase1-visual-alignment-r5/`

The large-text artifact has a true `360x1200` PNG viewport. Browser evidence is
not a substitute for device testing or the required Sorani linguistic review.
The owner `HUMAN_VISUAL_PASS - PHASE 1 R5` is recorded below. No production
bootstrap, upload, publishing, QR, Wallet issuance, Loyalty mutation, Backend,
Prisma, or Migration path was enabled by R5.

## 10. Phase 1 visual approval checkpoint

`HUMAN_VISUAL_PASS - PHASE 1 R5` was granted by the owner for Phase 1 visual
acceptance.

- Approval date: `2026-07-23`.
- Visual evidence directory:
  `apps/mobile/build/waflo_v2_review_evidence/phase1-visual-alignment-r5/`.
- `SORANI_HUMAN_LINGUISTIC_REVIEW_REQUIRED` remains open and must not be
  removed or marked complete until a fluent human reviewer approves Sorani
  terminology, grammar, truncation behavior, and Wallet fidelity notices.
- Apple Wallet and Google Wallet previews remain `Platform approximation`.
- Real iOS/Android device verification and real Apple/Google Wallet device
  issuance/update verification remain deferred release gates.

This checkpoint closes Phase 1 only. It does not authorize Phase 2, production
bootstrap integration, uploads, publishing, QR, Wallet issuance, Loyalty
mutations, Scheduler work, Backend changes, Prisma schema changes, migrations,
merge, PR, or deployment.
