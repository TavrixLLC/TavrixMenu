# First Restaurant Pilot API Checklist

This runbook is for the API/backend/staging operator during Sprint 13. It is
designed for one real restaurant pilot and intentionally avoids adding new
product scope.

Do not paste or record secrets, bearer sessions, QR payloads, scan tokens, card
references, transfer tokens, customer phone/email, customer names, or private
device identifiers in public reports.

## 1. Preflight

- Confirm Sprint 12 is closed and the pilot is approved to start.
- Confirm the target environment is staging or the explicitly approved pilot environment.
- Record the deployed API commit privately.
- Record the deployed customer-web/card commit privately.
- Record the tested mobile build commit privately.
- Confirm `GET /health` returns 200.
- Confirm `GET /menu-templates` returns 200.
- Confirm the public card domain loads for a known safe slug.
- Confirm no OpenAPI/schema migration is planned for pilot setup.
- Confirm wallet signing and APNs settings are not being changed for this runbook.

## 2. Backup Before Pilot Data Entry

- Take a database backup using the approved staging-only process.
- Store the backup outside the repository.
- Do not paste database connection values into notes or chat.
- Record only:
  - Environment name.
  - Backup timestamp.
  - Operator name or initials.
  - Deployed commit.
  - Whether backup completed.
- Verify restore access exists before entering real pilot configuration.

## 3. Pilot Personas

Required personas:

- `OWNER`: can create/manage the business, menu, loyalty program, appearance, and members.
- `STAFF`: can scan customer loyalty QR codes and add/redeem stamps for the assigned business.
- Synthetic test customer: used only for safe enrollment and Wallet add testing.

Optional persona:

- `MANAGER`: use only if the restaurant needs a manager to configure menu/loyalty without full owner handoff.

Safety rules:

- Do not document passwords, OTPs, session values, card references, QR payloads, or real customer PII.
- Use least privilege for staff.
- Keep test customer data synthetic until the owner approves real customer testing.

## 4. Business Setup

1. Create or verify the pilot business.
2. Confirm the slug is owner-approved and readable.
3. Confirm the business profile:
   - Name.
   - Type.
   - City.
   - Currency.
   - Default language.
   - Logo URL or asset path if already supported.
   - Cover URL or asset path if already supported.
4. Confirm active `OWNER` membership.
5. Add active `STAFF` membership for the cashier/operator.
6. Add optional `MANAGER` only if required.
7. Confirm `GET /me` and `GET /businesses/me` for owner.
8. Confirm `GET /me` and `GET /businesses/me` for staff.
9. Confirm `GET /businesses/{businessId}/app-context` for both roles.

## 5. Menu Setup

1. Create categories.
2. Create items.
3. Confirm prices use the selected currency.
4. Confirm availability/sold-out state for at least one test item if needed.
5. Confirm categories/items order.
6. Confirm public menu:
   - `GET /public/m/{slug}` returns 200.
   - Response includes categories and items.
   - Response includes `appearance.effectiveTemplateId`.
7. Confirm customer-web route loads:
   - `/m/{slug}`
   - `/m/{slug}?previewTemplateId=waflo-warm`
8. Confirm preview does not persist appearance.

## 6. Menu Appearance

1. Confirm `GET /menu-templates` returns enabled templates.
2. Confirm no `/dev/menu-templates` preview URLs appear in the API catalog.
3. Confirm `GET /businesses/{businessId}/appearance`.
4. Save the selected template with `PATCH /businesses/{businessId}/appearance`.
5. Confirm owner or manager can save if policy allows.
6. Confirm staff cannot save and receives 403/permission state.
7. Confirm the public menu reflects the selected template after save.

## 7. Loyalty Setup

1. Create or verify the active loyalty program.
2. Confirm:
   - Program name.
   - Stamp goal.
   - Reward name.
   - Reward description.
   - Terms.
   - Card colors/logo fields if already available.
3. Confirm `GET /businesses/{businessId}/loyalty/program`.
4. Confirm `GET /loyalty/stamp-presets`.
5. Confirm `GET /businesses/{businessId}/loyalty/stamp-style`.
6. Save existing stamp style/appearance only if the owner wants a supported preset.
7. Do not add Card Designer v2 or template marketplace scope.

## 8. Public Loyalty Enrollment

1. Confirm `GET /public/m/{slug}/loyalty` returns enrollment context.
2. Enroll a synthetic new customer using safe test data.
3. Confirm response includes safe card state.
4. Do not print or store the returned card reference in reports.
5. Reload the customer card through customer-web and confirm progress displays.
6. Confirm same-business duplicate join is blocked safely and returns no card access.
7. Confirm phone-only `RECOVER` remains blocked and returns no card access.
8. Confirm cross-business enrollment behavior separately only with synthetic data if needed.

## 9. Wallet Add Smoke

Apple Wallet:

- Use a supported iPhone/Safari flow.
- Do not screenshot QR codes.
- Do not print Apple pass authentication values.
- Confirm pass add screen opens if Apple Wallet is enabled/configured.
- Confirm installed pass appears if the owner/device completes add.

Google Wallet:

- Use an Android/Chrome flow.
- Do not print Save URLs.
- Confirm the Google Wallet save flow opens if Google Wallet is enabled/configured.

Both:

- Confirm the live web card remains the source of truth.
- Do not promise instant Apple Wallet installed-pass refresh.

## 10. Staff Wallet Scan Smoke

1. Sign in as assigned `STAFF`.
2. Confirm staff app-context returns the pilot business with role `STAFF`.
3. Open Wallet Scan.
4. Scan the synthetic customer card on a physical Android device.
5. Confirm card found state shows safe customer/program/progress context.
6. Confirm malformed scan is rejected.
7. Confirm cross-business scan is rejected.
8. Add one stamp.
9. Confirm updated progress is returned by API.
10. Confirm live web card reflects the new progress.
11. If reward is ready, redeem only with owner-approved synthetic flow.
12. Confirm no raw scan tokens, QR payloads, card references, phone/email, or PII appear in logs.

## 11. Log Safety Scan

Search staging/API logs since the pilot setup window for these categories:

- Bearer sessions or JWT-like values.
- Clerk sessions.
- QR payloads.
- Scan tokens.
- Card references.
- Transfer tokens.
- Apple pass authentication values.
- Push tokens or full device identifiers.
- Customer phone/email/name.
- Database connection values.
- Private keys or certificate material.
- Service account material.

Report only the category and hit count. Do not paste matching values.

Expected result: zero sensitive hits.

## 12. Rollback Responses

If the menu breaks:

- Revert to known-good menu template.
- Confirm public menu endpoint.
- Confirm customer-web route.
- Keep menu data intact unless directed otherwise.
- Tell the owner: "We are restoring the last verified menu display while preserving your menu content."

If staff scanning breaks:

- Stop counter scanning until the safe path is identified.
- Confirm staff role/app-context.
- Confirm wallet-scan endpoint with safe synthetic input.
- Use manual fallback only if it does not expose QR payloads and the owner approves.
- Tell the owner: "Customer card data is safe; we are pausing staff scanning until the scan path is verified."

If add stamp/redeem breaks:

- Stop loyalty changes at the counter.
- Confirm membership belongs to the pilot business.
- Confirm add/redeem endpoint response.
- Do not edit database manually unless an approved operator runbook exists.
- Tell the owner: "We are pausing loyalty updates to avoid incorrect progress."

If Wallet refresh is delayed:

- Confirm backend card state changed.
- Confirm live web card changed.
- Do not tell users to toggle phone settings as the normal solution.
- Tell the owner: "The online card is current; Apple Wallet refresh timing can vary by device."

## 13. Bug Triage

| Severity | When to use | Action |
| --- | --- | --- |
| P0 | Security leak, cross-business card access, phone-only recovery returning access, signing/key exposure, payment-impacting issue. | Stop affected flow, contain, preserve logs safely, report immediately. |
| P1 | Public menu down, staff scan broken, add stamp/redeem broken, owner/staff cannot access assigned business. | Fix or rollback same day before continuing pilot operations. |
| P2 | Owner/admin confusion, permission copy unclear, setup friction, non-critical role UX issue. | Track for Sprint 13 polish unless it blocks the owner. |
| P3 | Minor UI/copy polish or visual issue. | Batch after first live usage feedback. |

## 14. Pilot Go/No-Go

Go only when:

- Backup completed.
- Owner and staff contexts verified.
- Public menu loads.
- Loyalty enrollment works for synthetic customer.
- Wallet add path is understood for the target devices.
- Staff scan and add stamp pass on physical device.
- Redeem passes if the pilot will demo redemption.
- Log safety scan has zero sensitive hits.
- Owner has been told that live web card is source of truth and Apple Wallet installed-pass refresh timing can vary.

No-go when:

- Any P0 exists.
- Staff scan/add stamp is broken.
- Public menu is unavailable.
- Phone-only recovery returns card access.
- Logs expose sensitive values.
