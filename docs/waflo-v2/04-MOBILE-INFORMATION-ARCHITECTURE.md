# Waflo V2 Mobile Information Architecture

Status: `PLANNED`. This is the target Flutter IA; current Flutter routes and V3
tabs are `EXISTING_VERIFIED` legacy foundations, not the final V2 navigation.

## Navigation model

Top-level order for Owner and Manager:

1. **Home** — status, next action, setup/operations summary.
2. **Loyalty Programs** — programs, builder, rewards, card design, performance.
3. **Scan** — primary operational entry.
4. **Customers** — tenant-scoped search, membership, history, rewards.
5. **More** — business/branch/team/settings/account and deferred packages.

Rules:

- Five equal, safe-area-aware destinations; no oversized/floating scanner tab.
- Arabic/Sorani mirror direction and reading order without reordering the
  semantic destination list.
- A focused editor (program builder, reward editor, Card Studio, customer
  detail, redemption confirmation) has its own app bar and no bottom nav.
- Back returns to the exact originating context without replaying mutations.
- Deep links resolve authentication, authoritative business, role, and target
  ownership before rendering target data.
- Ambiguous multi-business state opens the workspace selector and does not load
  a guessed business.

## Role-specific shells

### Owner

Owner sees all five destinations and can configure authorized business,
branches, programs, rewards, base designs, team, and settings. Billing remains
hidden/informational until real entitlement behavior is available.

### Manager

Manager sees the same operational information architecture but actions are
permission-derived. Default policy can manage programs/customers/operations but
cannot transfer ownership, delete the business, manage billing, or promote an
Owner. The backend response, not a hardcoded mobile role map, is authoritative.

### Staff

Staff opens a simplified operations shell:

- primary: Scan;
- secondary: manual customer search;
- recent operations;
- minimal account, workspace/branch identity, and logout.

Staff does not see program/card design, business settings, billing, staff
management, or owner onboarding. If product testing requires a five-tab shell,
unauthorized destinations are omitted and the role-specific model is tested;
they are not shown as decorative disabled owner tabs.

## Workspace and branch entry

1. Restore Clerk session.
2. Load all active memberships.
3. Zero businesses: enter owner onboarding or show a role-appropriate no-access
   state.
4. One business: select it authoritatively.
5. Multiple businesses: require explicit selection; no `.first` fallback.
6. Load business app context and permissions.
7. Select/confirm branch if the role/session is not bound to one branch.
8. Clear old workspace data before new context renders; discard late results.

Workspace and branch identity stay visible on operational screens. Switching
either clears customer, scanner, program, and recent-operation state before new
data loads.

## Screen inventory

### Authentication and onboarding

| Screen | Roles | Primary action | Important states |
| --- | --- | --- | --- |
| Language choice | All | Confirm Arabic/Sorani/English | restoring, persistence error |
| Welcome/sign-in | Merchant roles | Real Clerk sign-in/create account | config unavailable, auth error, loading |
| Workspace selector | Multi-business roles | Select authoritative business | loading, no access, error |
| Business setup | New Owner | Create business | validation, submitting, backend error |
| Branch setup | Owner | Create primary branch | no branch, validation, retry |
| Loyalty goal | Owner/authorized Manager | Choose intended outcome | informational choices only |
| Setup completion | Owner | Continue to program builder | derived progress, never fake percentage |

### Home

- Exact next action derived from real state.
- Current business and branch identity.
- Active program health and wallet sync warnings.
- Today's verified operations if a backend contract exists.
- Setup checklist until the secure loyalty loop is live.
- No fabricated zero metrics or unavailable recent activity.

### Loyalty Programs

| Screen | Purpose |
| --- | --- |
| Program list | Active/draft/paused/archived programs with truthful status |
| Program goal/type | Select V1 type and explain evidence requirements |
| Earning rules | Configure typed rule and conditions |
| Rewards | Define supported reward and eligibility threshold |
| Program review | Review immutable/effective policy before activation |
| Program detail | Status, members, earned units, rewards, wallet/design state |
| Card Customization Studio | Base design, media, colors, stamp/reward visuals, join/poster, previews, templates |
| Visual Theme detail | Base/seasonal overlay preview and assignment; scheduling marked V1.5 when deferred |
| Provider sync | Apple/Google/web states, retry/diagnostic handoff without secrets |

### Scan

- Camera permission rationale and request.
- Camera scan with a stable target area.
- Manual card/code/customer fallback.
- Scan result with business/program/customer-safe summary.
- Evidence form chosen by program type:
  - visit/stamp confirmation;
  - fixed points confirmation;
  - integer-safe IQD amount;
  - product/service and quantity.
- Earn review and backend confirmation.
- Available rewards and redemption entry.
- Recent operations scoped to business/branch.

The scan token only resolves context. Earning and redemption require a fresh,
authorized, idempotent mutation.

### Customers

- Business-scoped customer search/list.
- Customer detail and contact/verification status permitted to the role.
- Memberships by program.
- Balance/ledger summary by unit.
- Available/redeemed/expired reward entitlements.
- Recent operations and adjustments.
- Manual enrollment only if the identity/recovery policy is satisfied.
- Adjustment action only for an authorized role with reason and audit.

### More

- Business profile.
- Branches and active branch.
- Team and permissions.
- Wallet/provider readiness.
- Language and accessibility preferences.
- Security/session devices when implemented.
- Account/logout.
- Billing status only when authoritative.
- `Waflo Growth Menu` as a separate package entry when real; not a V1 core tab.

## Program-builder flow

```text
Goal → Program type → Earning evidence/rule → Reward → Eligibility
→ Card base design → Provider previews → Review → Save draft → Activate
```

Builder rules:

- Persist drafts only through a real backend draft state.
- Each step can be revisited before activation.
- Activation shows policy/version impact.
- Editing an active material rule creates an effective version; it does not
  rewrite historical transactions.
- Visual changes publish through Card Studio and never create a program version
  or value event.

## Card Customization Studio flow

```text
Choose base/template → Upload logo/cover → Colors/contrast
→ Stamp/reward visuals → Join page → QR poster
→ Apple preview → Google preview → Web preview
→ Save draft → Publish design
```

The preview header identifies provider, design version, limitations, and
whether output is deterministic or provider-confirmed. Failed provider sync is
not shown as design-save failure if the base design committed and a retryable
outbox job exists; the two states are displayed separately.

For V1.5 seasonal work:

```text
Create visual overlay → Select occasion/custom → Choose target programs
→ Preview → Set timezone/start/end → Resolve conflicts → Schedule
→ Auto-activate → Auto-expire → Restore base design
```

## Customer join flow

Customer Web, linked from a real QR/poster:

```text
Program explanation → identity input/consent → verified join or safe recovery
→ membership/card issued → web card → Apple/Google Wallet handoff
```

An existing identity never receives a new card-access token from unauthenticated
phone/email knowledge. Provider failure leaves the live web card and a truthful
retry state.

## Earning flow

1. Resolve active business and branch.
2. Scan or search customer.
3. Show matching active programs and evidence form.
4. Enter amount/product/visit evidence.
5. Review action and reward impact estimate.
6. Submit with idempotency key.
7. Backend persists event, ledger, entitlement, audit, and outbox atomically.
8. Render confirmed result; retry same key after uncertainty.

## Redemption flow

1. Show explicit available entitlement and terms.
2. Confirm customer, reward, branch, and fulfillment.
3. Require staff confirmation and optional policy authorization.
4. Submit idempotently.
5. Backend locks and consumes entitlement once.
6. Show confirmed receipt/result and update wallet/report asynchronously.

No generic `Redeem reward` action may infer which entitlement to consume.

## State model

Every data screen uses distinct states:

| State | Required behavior |
| --- | --- |
| Initial | No stale prior-principal or prior-business data |
| Loading | Preserve safe layout; do not render zeros as data |
| Empty | Backend succeeded and returned no records; teach one real next action |
| Success | Render only confirmed state and capability-derived actions |
| Error | Explain safe cause, retry, and whether previous data is stale |
| Offline | Label cached read state; disable V1 value writes |
| Permission denied | No hidden retry loop; explain role/workspace requirement |
| Partial provider sync | Show core save vs Apple/Google/web state separately |

Late result rule: every async result validates current principal, business,
branch, and request generation before state emission.

## Empty-state examples

- No program: explain the four V1 choices; CTA `Create loyalty program` only if
  authorized.
- No customer: show real join QR/poster readiness; do not invent demo customer.
- No reward: guide reward definition before activation.
- No branch: Owner creates one; Staff receives a blocked operational state.
- No recent operation: only after a successful empty response.
- Seasonal scheduling unavailable: show base design only; no inactive switch
  that appears publishable.

## Offline behavior

V1 supports cached read-only context only when provenance and timestamp are
visible. Scan, earning, adjustment, redemption, program activation, design
publish, theme schedule, invite, and wallet issuance require backend
confirmation. An offline mutation queue is `DEFERRED` pending device trust,
conflict, replay, and idempotency design.

## Accessibility and responsive behavior

- Minimum 48×48dp target and at least 8dp between adjacent critical actions.
- Semantic labels, roles, selected/disabled/busy states, and announced inline
  errors.
- Logical focus order follows mirrored visual order.
- Dynamic text and Arabic/Sorani shaping must not clip at largest supported
  text scale.
- Reduced motion removes non-essential transitions.
- Test compact phone, large phone, tablet, portrait, and landscape; long forms
  use readable maximum width on tablets.
- Bottom/fixed actions reserve safe-area and scroll inset space.
