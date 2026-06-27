# Sprint 13: First Restaurant Pilot API Plan

## Decision

Sprint 13 starts from a closed Sprint 12 launch-readiness baseline. This plan is
API/backend/staging focused and does not add product scope by default.

Recommended API decision: `SPRINT_13_API_PILOT_RUNBOOK_READY`

## Scope Boundary

Sprint 13 API work should support onboarding one real restaurant pilot with the
already-built Waflo flows:

- Owner business setup.
- Staff assignment.
- QR menu categories and items.
- Public menu rendering.
- Public loyalty enrollment.
- Wallet add flow.
- Staff wallet scan.
- Add stamp.
- Redeem reward.
- Menu appearance/template selection.
- Existing loyalty/wallet appearance controls.

Out of scope unless a verified pilot blocker is found:

- New product features.
- OpenAPI contract changes.
- Database schema changes.
- Wallet signing changes.
- APNs changes.
- Recovery/transfer security changes.
- Scanner token validation changes.
- Billing.
- Multi-branch support.
- Loyalty v2.
- Template marketplace.

## Current API Readiness Result

The current API already supports the required pilot operations:

| Capability | Current API support | Pilot note |
| --- | --- | --- |
| Create business | `POST /businesses` | Creates the business and assigns the current authenticated user as `OWNER`. |
| Owner context | `GET /me`, `GET /businesses/me`, `GET /businesses/{businessId}/app-context` | Verify role is `OWNER` before pilot setup begins. |
| Staff membership | `POST /businesses/{businessId}/members`, `PATCH /businesses/{businessId}/members/{memberId}` | Add least-privilege `STAFF` access for scanner operators. |
| Optional manager | `POST /businesses/{businessId}/members` with `MANAGER` if needed | Use only if the pilot restaurant has a real manager workflow. |
| Menu categories/items | `POST/GET/PATCH/DELETE` category and item routes | Supports setup, archive/restore, and reorder. |
| Public menu | `GET /public/m/{slug}`, `GET /public/m/{slug}/items/{itemId}` | Public source for QR menu smoke checks. |
| Menu templates | `GET /menu-templates`, `GET/PATCH /businesses/{businessId}/appearance` | Mobile/admin preview URL remains web-owned: `/m/:slug?previewTemplateId=<template-id>`. |
| Loyalty program | `GET/POST/PATCH /businesses/{businessId}/loyalty/program` | One active stamp-card program per business. |
| Loyalty appearance | `GET/PATCH /businesses/{businessId}/loyalty/stamp-style`, `GET /loyalty/stamp-presets` | Use existing preset/style controls only. |
| Public loyalty enrollment | `GET /public/m/{slug}/loyalty`, `POST /public/m/{slug}/loyalty/enroll` | Phone-only recovery remains blocked. Same-business duplicates must not issue card access. |
| Customer card view | `GET /public/loyalty/cards/{cardReference}` | Use only through customer-web/mobile stored reference flows; do not print references. |
| Wallet add | `POST /public/loyalty/cards/{cardReference}/apple-wallet`, `POST /public/loyalty/cards/{cardReference}/google-wallet` | Do not change signing. Apple Wallet installed-pass refresh is platform-controlled. |
| Staff wallet scan | `POST /businesses/{businessId}/loyalty/wallet-scan` | OWNER/MANAGER/STAFF allowed; cross-business cards must be rejected. |
| Add stamp | `POST /businesses/{businessId}/loyalty/memberships/{membershipId}/stamps` | Returns updated `cardState`; staff UI must not wait for Wallet provider refresh. |
| Redeem reward | `POST /businesses/{businessId}/loyalty/memberships/{membershipId}/redeem` | Use only when reward is ready and staff confirms redemption. |

No API blocker is known at Sprint 13 start.

## Pilot Personas

Use safe, dedicated pilot accounts. Do not document passwords, OTPs, session
values, card references, QR payloads, customer phone numbers, email addresses,
or personal identifiers.

Required:

- `OWNER`: restaurant owner or Waflo onboarding operator acting as the owner.
- `STAFF`: cashier/operator who scans customer Wallet QR codes and adds stamps.
- Test customer loyalty card: synthetic pilot test customer created through the
  public loyalty flow or approved internal setup.

Optional:

- `MANAGER`: only if the restaurant has a manager who should configure menu or
  loyalty settings without full owner control.

## Pilot Business Setup Checklist

Before customer-facing testing:

- Confirm staging and target environment are the intended pilot environment.
- Record deployed API/customer-web/mobile build commits in the private pilot log.
- Take a database backup before entering real pilot configuration.
- Create or verify the pilot business.
- Confirm the public slug is correct, readable, and approved by the owner.
- Confirm `OWNER` membership is active.
- Add active `STAFF` membership for the cashier/operator account.
- Add `MANAGER` only if explicitly needed.
- Enter business profile data:
  - Display name.
  - Business type.
  - City.
  - Currency.
  - Default language.
  - Logo and cover assets if available.
- Enter menu data:
  - Categories.
  - Items.
  - Prices.
  - Descriptions.
  - Availability/sold-out states.
  - Images if available.
- Select the public menu template from the existing catalog.
- Preview the public menu before saving/publishing expectations to the owner.
- Configure loyalty program:
  - Program name.
  - Stamp goal.
  - Reward name.
  - Reward description.
  - Terms.
  - Existing card/stamp appearance controls if available.
- Test public loyalty enrollment with synthetic data only.
- Add Apple Wallet and Google Wallet where device/platform allows.
- Print/test QR menu material only after the public slug and menu render are confirmed.
- Run staff scanner smoke with a covered QR and no screenshots of QR payloads.

## API Verification Checklist

For the selected pilot business, verify the following without printing secrets,
tokens, card references, QR payloads, customer phone/email, or other PII:

- `GET /health` returns 200.
- `GET /menu-templates` returns enabled templates and no dev preview URLs.
- `GET /public/m/{slug}` returns 200 and includes `appearance.effectiveTemplateId`.
- `GET /me` as owner returns one active owner business context.
- `GET /businesses/me` as owner returns the pilot business with `OWNER`.
- `GET /businesses/{businessId}/app-context` as owner returns owner permissions.
- `GET /me` as staff returns the pilot business with `STAFF`.
- `GET /businesses/{businessId}/app-context` as staff returns staff permissions.
- `GET /businesses/{businessId}/categories` returns expected menu categories.
- `GET /businesses/{businessId}/items` returns expected pilot items.
- `GET /businesses/{businessId}/appearance` returns selected template state.
- `GET /businesses/{businessId}/loyalty/program` returns the active loyalty program.
- `GET /businesses/{businessId}/loyalty/stamp-style` returns the current style or a safe default.
- `GET /public/m/{slug}/loyalty` returns public enrollment context.
- `POST /public/m/{slug}/loyalty/enroll` works for a synthetic new customer.
- Same-business duplicate enrollment remains blocked safely and returns no card access.
- Phone-only `RECOVER` remains blocked and returns no card access.
- Wallet add endpoints work where configured:
  - Apple Wallet pass package can be requested on supported Apple flow.
  - Google Wallet Save URL can be requested on supported Google flow.
- `POST /businesses/{businessId}/loyalty/wallet-scan` succeeds for the pilot card.
- Malformed scan is rejected.
- Cross-business scan is rejected.
- `POST /businesses/{businessId}/loyalty/memberships/{membershipId}/stamps` updates progress.
- `POST /businesses/{businessId}/loyalty/memberships/{membershipId}/redeem` works only when reward is ready.
- API logs do not contain secrets, QR payloads, scan tokens, card references, transfer tokens, phone/email, or customer PII.

## Backup And Rollback

Before pilot setup:

- Capture a staging database backup using the approved staging-only backup
  process.
- Store backup artifacts outside the repository in the approved secure location.
- Record the deployed code commit and backup timestamp in the private pilot log.
- Confirm restore access before entering real pilot data.

Rollback target:

- Primary rollback target is the last known-good Sprint 12 runtime baseline.
- If a newer staging deployment is used for the pilot, record that exact commit
  and keep it as the rollback target until the next verified deployment.

If the public menu breaks:

- Stop handing out new QR material.
- Confirm `GET /health` and `GET /public/m/{slug}`.
- If API is healthy but public menu fails, check customer-web deployment and template selection.
- If template is suspected, switch back to the known-good template from the existing catalog.
- Tell the owner: "We are reverting the menu display to the last verified layout while preserving your menu data."

If staff scanner fails:

- Do not ask staff to expose or send QR payloads.
- Confirm staff account has active `STAFF` membership.
- Confirm API health and app-context for the staff business.
- Run safe malformed-token and cross-business checks privately.
- If camera scanning fails but manual safe code entry works, continue pilot only if the owner accepts the temporary operational workaround.
- Tell the owner: "The live card data is safe; we are checking the staff app scan path before using it at the counter."

If Wallet update appears delayed:

- Confirm add stamp/redeem updated backend card state.
- Confirm the live web card shows current progress.
- Do not promise instant Apple Wallet refresh.
- Tell the owner: "The live card is the source of truth. Apple Wallet refresh timing is controlled by the device, and the installed pass may update shortly after sync."

## Pilot Bug Triage

| Severity | Definition | Examples | Response |
| --- | --- | --- | --- |
| P0 | Security, data leak, payment, or Wallet-breaking issue. | PII exposed in logs, card access issued by phone-only recovery, cross-business card access, Wallet signing outage during promised test. | Stop pilot flow, contain, preserve logs safely, notify owner with non-sensitive summary. |
| P1 | Core pilot workflow broken. | Staff scan fails, add stamp fails, redeem fails, public menu unavailable, owner cannot access pilot business. | Same-day fix or rollback. Use manual fallback only if safe and owner-approved. |
| P2 | Owner/admin confusion that risks support load but does not break core flow. | Unclear setup copy, permission message confusion, wrong next action. | Queue for Sprint 13 polish; do not change API unless contract gap is proven. |
| P3 | UI/copy polish or non-blocking visual issue. | Spacing, minor wording, non-critical template styling. | Track and batch after first live usage feedback. |

## API Change Policy During Sprint 13

Default answer to new API ideas during the first pilot is "not yet." Change API
only when a real pilot blocker is reproduced and documented.

Allowed API work if proven:

- A security or data isolation bug.
- A role/context bug that blocks owner or staff operation.
- A public menu or loyalty endpoint failure that cannot be fixed by data/config.
- A log-safety issue.

Not allowed by default:

- Billing.
- Multi-branch.
- Loyalty v2.
- Template marketplace.
- New recovery method without verified identity design.
- Wallet signing or APNs changes.
