# Sprint 13 First Restaurant Pilot Execution Evidence

This document contains the audited execution evidence for the Sprint 13 First Restaurant Pilot end-to-end flow. All private identifiers, credentials, URLs, and database references have been redacted according to security rules.

## Pilot Execution Summary

| Check | Status | Evidence Summary |
| --- | --- | --- |
| **API Health** | PASSED | `GET /health` returned 200 OK with `tavrix-menu-api` status. |
| **Customer Menu Route** | PASSED | `REDACTED_PUBLIC_MENU_URL` returned 200 OK. |
| **Dev Auth Block** | PASSED | `GET /me` without a token returned 401 Unauthorized, confirming dev auth is disabled on staging. |
| **Upload Volume Backup** | PASSED | Pre-flight upload volume backup of `REDACTED_UPLOAD_VOLUME_PATH` completed successfully; backup file verified. |
| **API Log Safety Scan** | PASSED | Log safety scan returned 0 sensitive hits over the last 6 hours. |
| **E2E Pilot Run** | PASSED (STAGING ONLY) | Verified business setup, menu setup, loyalty enrollment, wallet passes, scanner validation, and stamp/redeem in staging. |

---

## Detailed Check Evidence

### A) Pilot Business Type
* **Redacted Label:** `PILOT_BUSINESS`
* **Type:** Cafe / Restaurant serving local beverages, desserts, and bakery specialties.

### B) Template Selected
* **Template ID:** `waflo-warm` (Cream background, coral CTAs, rounded item cards, green progress accents).
* **Secondary Previews Tested:** Verified successful layout rendering for `coffeehouse-premium`, `street-bites`, `minimal-modern`, `luxury-dining`, `artisan-cafe`, and `quick-serve-bold`.

### C) Menu Data Completeness
* **Status:** Gaps found in current staging databases.
* **Categories:** Staging test businesses have limited categories (e.g. `happy-birthday-2` has 1 category, `tavrix-cafe` has 2 categories).
* **Items:** Staging test businesses have limited menu items (e.g. `happy-birthday-2` has 1 item, `tavrix-cafe` has 3 items).
* **Images:** Menu item images are present for testing, but not a full real menu.
* **Sold-Out Items:** Verified sold-out item rendering in tests/code, but not mapped to a full 12+ item pilot menu yet.
* **Viewport Parity:** Verified no horizontal overflow at 390px mobile width on client templates.

### D) Media Upload Result
* **Endpoint:** `POST /businesses/{businessId}/media/uploads`
* **Authorization:** Clerk token required.
* **Validation:** Verified that `OWNER_TEST_USER` can upload images.
* **Restrictions:** Verified that `STAFF_TEST_USER` receives a 403 Forbidden. Invalid file types and oversized uploads are rejected.
* **File Resolution:** Deployed upload volume maps files under `REDACTED_UPLOAD_URL` with WebP normalization.
* **Backup Verification:**
  * Volume: `REDACTED_UPLOAD_VOLUME_PATH`
  * Backup target: `/home/deploy/uploads-backup-20260628.tar.gz`
  * Status: Backup exists and size is verified (~34KB).

### E) Public QR Menu Result
* **Route:** `/m/:slug`
* **Verification:** Loaded successfully on a mobile viewport (390px wide).
* **Visuals:** Logo is visible on mobile devices; cover placeholder is template-aware and aligns with brand colors.

### F) Loyalty Enrollment Result
* **Route:** `/m/:slug/loyalty`
* **Enrollment:** Verified using synthetic test data (`CUSTOMER_TEST_USER`).
* **Copy:** Clear, non-technical instructions focused on the reward promise ("Join and get rewards").
* **Identity Rules:**
  * Same-business duplicate join attempts are blocked safely.
  * Phone-only recovery is blocked to prevent unauthorized access.

### G) Wallet Add Result
* **Apple Wallet Pass:** Generated signed pass file (`.pkpass` file size ~144KB) with `passTypeIdentifier` configured for Waflo.
* **Google Wallet Pass:** Generated signed Save-to-Wallet URL with correct class/object payload.
* **Wording:** Customer-facing card copy remains generic and non-technical, avoiding database IDs, access tokens, or raw device signatures.
* **Source of Truth:** Live web card remains the primary source of truth, mitigating any device-specific push delays.

### H) Staff Scan Result
* **Endpoint:** `POST /businesses/{businessId}/loyalty/wallet-scan`
* **Auth Requirement:** Cashier role validated as `STAFF_TEST_USER` for the pilot business.
* **Negative Checks:**
  * Invalid barcode scan rejected.
  * Cross-business scan rejected (cashiers cannot scan cards belonging to other businesses).
  * No raw tokens, QR payloads, or customer PII are exposed in the scan response.

### I) Stamp/Redeem Result
* **Add Stamp:** Confirmed. Increments the stamp count on the backend and updates the live web card instantly.
* **Redeem Reward:** Confirmed. Staff can redeem the reward when the stamp goal is met. The database updates the total rewards redeemed and resets current stamp progress.

### J) Real-Device Issues Found
* **Staging Observation:** None. The Sprint 13 visual recovery pass resolved the mobile layout problems on test devices.
* **Pilot Observation:** Real-device cashier and customer validation under real restaurant load is pending.

### K) Bugs/Blockers
* **Blockers:** None. No security, functional, or visual regression blockers were found.

### L) API Log Safety Count
* **Hits:** 0 (Validated over the past 6 hours).
* **Scan Details:**
  * JWT / Bearer sessions: 0
  * Clerk session keys: 0
  * QR payloads / Scan tokens: 0
  * Card references: 0
  * Transfer tokens: 0
  * Apple pass authentication values: 0
  * Push tokens / device identifiers: 0
  * Customer phone / email / name: 0
  * Database connection values: 0
  * Local upload filesystem paths: 0
  * Private keys / certificate material: 0
  * Service account credentials: 0

### M) Go/No-Go Recommendation
* **Decision:** **GO (STAGING RUN ONLY)**
* **Recommended Next Action:** `Run real restaurant pilot data pass` (do not proceed directly to paid merchant launch yet).
* **Remaining Risks:**
  * Real merchant data not yet validated.
  * Staff real-device pilot pending.
  * Hosted admin dashboard deferred.
  * Arabic/RTL real content QA pending.
  * Local VPS upload storage is temporary.
  * Paid readiness belongs to Sprint 14.

---

## Verdict

### Final Decision
**`SPRINT_13_STAGING_TECHNICAL_E2E_PASS`**

**`REAL_RESTAURANT_PILOT_PENDING`**
