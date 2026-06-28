# Sprint 13 Real Restaurant Pilot Data Pass

This document records the audited execution evidence for the Sprint 13 Real Restaurant Pilot Data Pass. All private identifiers, credentials, URLs, and database references have been redacted according to security rules.

## Verdict

### Final Decision
**`SPRINT_13_REALISTIC_INTERNAL_PILOT_PASS`**

**`REAL_RESTAURANT_PILOT_PENDING`**

---

## Detailed Check Evidence

### A) Decision
* **Verdict:** `SPRINT_13_REALISTIC_INTERNAL_PILOT_PASS`
* **Pilot Target Status:** `REAL_RESTAURANT_PILOT_PENDING`
* **Status:** The technical infrastructure and realistic data presentation successfully passed all E2E validation gates on staging.

### B) Pilot Type
* **Classification:** Realistic Internal Pilot (representing a realistic restaurant menu structure, layout, and loyalty flow).

### C) Business Setup Result
* **Redacted Label:** `PILOT_BUSINESS`
* **Business ID:** `PILOT_BUSINESS_ID_REDACTED`
* **Configuration:** Profile updated with logo and cover images under `REDACTED_UPLOAD_URL` paths.
* **Role Verification:** Owner permissions validated (`OWNER_TEST_USER`). Staff operator successfully assigned (`STAFF_TEST_USER`).

### D) Menu Completeness Result
* **Categories:** 3 categories configured ('المشروبات الساخنة' / 'Hot Drinks', 'المشروبات الباردة' / 'Cold Drinks', and 'الحلويات' / 'Desserts').
* **Items:** 12 menu items populated with pricing visible in IQD.
* **Images:** 8 menu items configured with high-quality uploaded image references.
* **Sold-Out Items:** 1 item ('كنافة' / 'Kunafeh') set to unavailable. Verified that it renders as unavailable on the menu list and its detail page remains accessible with clear sold-out status indicators.

### E) Template Selected
* **Template ID:** `coffeehouse-premium` (a selected template from the 7 templates).

### F) Media Upload Result
* **Endpoint:** `POST /businesses/{businessId}/media/uploads`
* **Status:** Passed. Enforces Clerk authorization. `OWNER_TEST_USER` can upload images. `STAFF_TEST_USER` is rejected. Unsupported formats and oversized files are correctly rejected. Normalization to WebP is active.
* **Backup Verification:**
  * Volume path: `REDACTED_UPLOAD_VOLUME`
  * Backup file: `REDACTED_BACKUP_ARTIFACT`

### G) Public QR/Mobile Result
* **Public Route:** `REDACTED_PUBLIC_MENU_URL`
* **Mobile Viewport Check (390px):** Loaded successfully without any horizontal overflow. Logo, cover image, and menu item cards render correctly. Category navigation bar is sticky, scrollable, and interactive.

### H) Loyalty Result
* **Enrollment Route:** `REDACTED_PUBLIC_MENU_URL/loyalty`
* **Enrollment:** Verified using synthetic test data (`CUSTOMER_TEST_USER`).
* **Test Phone:** `REDACTED_TEST_PHONE`
* **Live Card:** Opens successfully and displays reward progress (0/5 stamps).
* **Negative/Safety Checks:** Same-business duplicate enrollments and phone-only card recovery are blocked. Customer-visible copy does not expose any database IDs, access tokens, or raw device signatures.

### I) Wallet Result
* **Apple Wallet Pass:** Generated signed pass package (`.pkpass` file size ~144KB) with Generic Loyalty wording and barcode scanner integration.
* **Google Wallet Pass:** Generated signed Save-to-Wallet URL with correct class/object payload.
* **Wording:** Wording remains generic and non-technical. Live web card serves as the primary source of truth, mitigating device-specific push delays.

### J) Staff Scan/Stamp/Redeem Result
* **Staff Scan:** Passed. Cashier `STAFF_TEST_USER` can scan customer QR codes via the `/loyalty/wallet-scan` endpoint. Malformed and cross-business scans are successfully rejected.
* **Transaction Flow:** Adding stamps and redeeming rewards successfully updates the backend loyalty membership state and refreshes the live customer web card.

### K) Bugs/Blockers Found
* **None.** No security, functional, or visual regression blockers were found.

### L) API Log Safety Count
* **Hits:** 0 (Validated over the past 6 hours of API logs).
* **Scan Details:**
  * JWT / Authorization sessions: 0
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

### M) Remaining Risks
* **List of Remaining Risks:**
  * real merchant owner not yet onboarded
  * real merchant staff device flow pending
  * real customer environment pending
  * hosted admin dashboard deferred
  * Arabic/RTL real merchant content QA pending
  * local VPS upload storage remains temporary
  * paid readiness belongs to Sprint 14

### N) Recommendation
* **Verdict:** Proceed to first real merchant pilot scheduling / Sprint 14 planning only after merchant selection.
