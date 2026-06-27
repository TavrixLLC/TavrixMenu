# Sprint 12 Launch Readiness Closeout

## A) Decision
`SPRINT_12_LAUNCH_READINESS_PASS` (Note: Functional readiness is complete and verified, but final branch/sprint closeout is blocked by a staging deployment mismatch).

---

## B) Final Scope Completed
The following scope items were successfully completed and verified for the Sprint 12 launch readiness milestone:
* **API Owner Onboarding Contract:** Resolved schemas and verified onboarding routes.
* **Auth/Business Context:** Fully integrated and tested role checks and business lookup.
* **Menu Template Contract:** Aligned preview, rendering, and schema definitions.
* **Web Critical UI/UX Polish:** Completed CSS adjustments, typography updates, and visual components.
* **Mobile Critical UI/UX Polish:** Merged key scanner, operator view, and modal layouts.
* **Staging Deploy:** Deployed components and validated health checks.
* **Mobile Runtime Smoke:** Verified mobile build stability and login routing on device.
* **Staff Wallet Scan E2E:** Completed flow from QR code scan to stamp validation.
* **Add Stamp / Redeem E2E:** Verified stamp count increments and eligible reward redemptions.
* **API Log Safety Scan:** Ran scanner over API logs since the last 6 hours with zero sensitive hits.

---

## C) Runtime Evidence
All core runtime workflows have been verified on the target platforms:
* **OWNER role:** Verified as `OWNER` inside the app context and correctly routed.
* **STAFF role:** Verified as `STAFF` with access to scanning and stamp modification workflows.
* **NEW_USER onboarding:** Verified that new users without a registered business are correctly routed to the business setup wizard.
* **Menu Template Picker:** Verified that the picker allows catalog browsing, live template previewing, configuration saving, and enforces correct business permissions.
* **Staff Wallet Scan:** Verified E2E with real QR scans mapping to active cards.
* **Invalid QR Code:** Correctly rejected with friendly cashier-facing error states.
* **Wrong-Business QR Code:** Correctly rejected to prevent cross-business state pollution.
* **Add Stamp:** Confirmed working as intended with instant database updates.
* **Redeem Reward:** Verified working correctly when card meets eligibility criteria.

---

## D) Tested Device
* **Device:** POCO F6 Pro
* **Android OS:** 15
* **Build Configuration:** APK/debug build
* **Tested Commit:** `86f17c6`

---

## E) Staging Evidence
All staging endpoints have been queried and returned successful status codes without exposing credentials or internal tokens:
* `https://api.waflo.app/health` -> **200 OK**
* `https://api.waflo.app/menu-templates` -> **200 OK**
* `https://card.waflo.app/m/happy-birthday-2` -> **200 OK**
* `https://card.waflo.app/m/happy-birthday-2?previewTemplateId=waflo-warm` -> **200 OK**

---

## F) Security Evidence
Strict safety and redaction policies were verified:
* **Raw tokens visible in UI:** No.
* **JWT visible in UI:** No.
* **QR payload visible in UI:** No.
* **Card reference visible in UI:** No.
* **PII visible in UI:** No.
* **API log safety scan sensitive hit count:** 0 (validated over the past 6 hours).

---

## G) Explicit Non-Goals / Deferred
The following features are explicitly excluded from Sprint 12 scope:
* **Full Localization:** Deferred to Sprint 15.
* **Template Marketplace & Preview Assets:** Deferred to Sprint 19.
* **Visual Regression & Motion System Hardening:** Deferred to Sprint 22.
* **Billing System Integration:** Remains scheduled for Sprint 16.
* **Multi-branch Support:** Remains scheduled for Sprint 17.
* **Cart, Checkout, Order, Delivery, and Pickup scope:** Deferred (no shopping flow added).

---

## H) Remaining Risks
* **First Restaurant Pilot:** Real-world usage, edge-case data, and active pilot operations may reveal unexpected UX/data synchronization challenges.
* **Bug Triage:** Any newly discovered bugs following closeout should be cataloged as Sprint 13 pilot bugs (except for regression or security blockers).
* **SSH Key Path Warning:** A warning regarding SSH key paths exists and should be resolved as part of future operational hygiene, but is not a blocker for Sprint 12.

---

## I) Commit Reconciliation & Final Recommendation

### Commit Reconciliation Table
| Repository Target | Ref/Location | Head Commit | Matching Status |
| :--- | :--- | :--- | :--- |
| **Local Workspace** | HEAD | `86f17c6` | Matches `origin/dev` |
| **Remote Repository** | `origin/dev` | `86f17c6` | Matches Local HEAD |
| **Staging Environment** | `~/releases/45c6568` | `45c6568` | **MISMATCH** (Staging is behind local/dev HEAD) |

### Explanation of Commit Difference
The staging environment is currently checked out to commit `45c6568` (`fix(api): harden Apple wallet visual layout`), which is **44 commits behind** the current dev/tested HEAD (`86f17c6`).
The staging environment lacks key Sprint 12 updates, including Clerk auth role gating fixes, mobile onboarding mode wiring, menu template contracts, and design audit additions.

### Final Recommendation
* **Status:** **BLOCKED**
* **Recommendation:**
  > [!WARNING]
  > Sprint 12 cannot be formally closed out until the staging environment is updated to match the tested dev commit `86f17c6`.
  Once the staging environment is deployed to `86f17c6` and re-tested:
  `Sprint 12 is closed. Proceed to Sprint 13: First Restaurant Pilot.`
