# Sprint 12: Launch Readiness

**Goal:** Prepare Waflo for the first real restaurant pilot.

**Status:** Scope locked. Implementation not started.

**Based on Sprint 11 result:**
- Apple Wallet visual: PASS
- Apple Wallet APNs installed pass update: PASS
- Google Wallet regression: PASS
- Mobile/web blocker fixes: MERGED
- APNs: disabled (post-controlled-smoke)
- OpenAPI: unchanged
- Known caveat: Real Flutter staff scanner E2E not executed on physical device/emulator

---

## Scope

### 1. Real Flutter Staff Scanner E2E Smoke

**Owner:** Person 2 (Flutter)

**Goal:** Prove the Add Stamp flow works end-to-end on a real device or emulator with a real staff session.

Acceptance:

- [ ] Authenticated staff session (Clerk-verified token)
- [ ] Staff scans valid wallet QR from customer card
- [ ] Staff taps "Add stamp" in the scanner result UI
- [ ] App shows clear success state (stamp added)
- [ ] Backend stamp count increases by 1
- [ ] No raw QR payload or scan tokens logged to console/crash tools
- [ ] Friendly error shown for invalid QR
- [ ] Friendly error shown for expired QR
- [ ] Friendly error shown for unauthorized staff role

**Notes:**
- Sprint 11 merged the Add stamp UI on `staff_scanner_screen.dart` and updated `wallet_scan_cubit.dart` / `wallet_scan_state.dart`
- Local bloc/widget tests pass
- Runtime smoke has not been executed on a physical device or emulator

---

### 2. Owner/Admin Setup Polish

**Owner:** Person 1 + Person 3

**Goal:** Owner can understand how to set up menu and loyalty without external guidance.

Acceptance:

- [ ] Owner setup flow is clear from first login
- [ ] Business setup (name, slug, settings) is not confusing
- [ ] Loyalty program setup is discoverable
- [ ] Loyalty appearance and stamp goal settings are labeled clearly
- [ ] Staff account creation and role assignment steps are documented in-app or in onboarding guide
- [ ] No dead-end states (e.g. empty screens with no action)

---

### 3. Customer-Web Final QA

**Owner:** Person 3

**Goal:** Customer-facing enrollment page is fully correct across platforms before the pilot restaurant directs real customers to it.

Acceptance:

- [ ] Android phone shows Google Wallet action
- [ ] iPhone (Safari) shows Apple Wallet action
- [ ] Desktop shows phone-number fallback prompt
- [ ] Returning customer does not see re-enrollment (Sprint 11 fix verified)
- [ ] Phone field rejects non-phone input (Sprint 11 fix verified)
- [ ] Placeholder images (`Cover`, `Logo`) replaced with real or polished defaults
- [ ] No broken public pages (404s, empty states, layout issues)
- [ ] Stamp layout renders correctly on the live card (5x2 for 10 stamps)

---

### 4. Pilot Restaurant Setup Checklist

**Owner:** Person 1 (to document), Owner of pilot restaurant (to execute)

**Goal:** A checklist that any team member can follow to onboard the first real restaurant end-to-end.

Acceptance:

- [ ] Create business account in Clerk and in Waflo API
- [ ] Add menu categories and items
- [ ] Enable loyalty program with correct stamp goal
- [ ] Create staff user and assign staff role
- [ ] Generate and print/display loyalty QR code
- [ ] Customer enrolls via phone/web
- [ ] Customer adds Apple Wallet or Google Wallet pass
- [ ] Staff scans QR and adds stamp via Flutter scanner
- [ ] Owner or manager can verify stamp count in admin view
- [ ] Checklist published as a runbook in `docs/runbooks/`

---

### 5. Minimum Ops Readiness

**Owner:** Person 1

**Goal:** Team can support the first restaurant without major operational blind spots.

Acceptance:

- [ ] Staging/prod deploy process is documented and runnable by any team member
- [ ] Rollback path documented (docker compose down + redeploy previous image)
- [ ] Database backup status confirmed (automated or manual schedule known)
- [ ] Restore path documented for staging and production
- [ ] APNs toggle process documented: how to enable/disable safely for staging and production
- [ ] Transient 502 monitoring noted: known Cloudflare tunnel edge behavior documented with mitigation
- [ ] Support contact path for pilot restaurant documented (who they contact, how fast)
- [ ] Error log access documented (where to look when something breaks)

---

### 6. Go/No-Go Checklist for First Real Restaurant Pilot

**Owner:** All

**Goal:** A concrete, named checklist so the team knows exactly when it is safe to onboard the first restaurant.

Acceptance:

- [ ] Each checklist item has a pass/fail status and an owner name
- [ ] No item can remain as "probably fine" — all must be verified
- [ ] Checklist published as `docs/runbooks/pilot-go-no-go.md`
- [ ] At least the following areas are covered:
  - Staff scanner runtime (Flutter E2E smoke)
  - Customer enrollment (web QA)
  - Wallet passes (Apple + Google staging verified)
  - Business setup (owner can do it unaided)
  - Ops readiness (deploy, rollback, backup, monitoring)
  - Support path (restaurant knows how to get help)

---

## Out of Scope for Sprint 12

The following must NOT be started during Sprint 12:

- Loyalty v2 (multi-tier rewards, advanced analytics)
- Multi-branch support
- Global pricing / pricing tiers
- Custom domains
- AI recommendations
- Admin dashboard rebuild
- APNs in production (only staging-controlled tests allowed)
- New OpenAPI contract changes (unless a blocker is found)
- Stripe billing changes

---

## Files To Create During Sprint 12

| File | Owner | Purpose |
|------|-------|---------|
| `docs/runbooks/pilot-go-no-go.md` | Person 1 | Go/No-Go checklist with pass/fail per item |
| `docs/runbooks/pilot-restaurant-setup.md` | Person 1 | Step-by-step restaurant onboarding runbook |
| `docs/runbooks/apns-toggle.md` | Person 1 | APNs enable/disable procedure |
| `docs/runbooks/ops-deploy-rollback.md` | Person 1 | Deploy + rollback procedure |

---

## Sprint 12 Carryover from Sprint 11

- **Real Flutter staff scanner E2E smoke** (not executed on physical device/emulator in Sprint 11)

---

## Do Not Block Sprint 12 On

- Diagnostics serial suffix mismatch (`efbe885d` vs `b56fc93b`) — cosmetic only, pass matching is dynamic and correct at runtime
- APNs in production — out of scope until pilot restaurant explicitly needs live push updates
