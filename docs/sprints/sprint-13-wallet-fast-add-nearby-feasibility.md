# Sprint 13 Wallet Fast Add + Nearby Reminder Feasibility

## A) Decision

`DO_NOW_FAST_ADD_COPY_ONLY`

For the first restaurant pilot, the smallest safe improvement is to make the existing loyalty/wallet handoff feel faster and clearer through customer-web copy, layout, and CTA ordering. The API already supports the required secure primitives for enrollment, card view, wallet add, returning same-device access, and add-device transfer.

Nearby wallet relevance should be deferred until the pilot business has an approved physical location data source and the team accepts the platform limitations. Do not promise guaranteed nearby marketing notifications.

## B) Current Wallet Add Flow

Current customer path:

1. Customer scans the restaurant QR and opens `/m/:slug`.
2. Customer chooses the loyalty entry point and lands on `/m/:slug/loyalty`.
3. First-time customer enters required phone and optional email/name.
4. `POST /public/m/:slug/loyalty/enroll` creates a card only when it is safe to do so.
5. The customer sees progress and device-aware wallet actions.
6. iOS shows Apple Wallet as the primary wallet action when the Apple flag is enabled.
7. Android shows Google Wallet as the primary wallet action.
8. Desktop shows phone-oriented fallback guidance instead of pretending to be a phone wallet flow.
9. Apple Wallet add is click-only through the public card route and returns a signed pass package.
10. Google Wallet add is click-only through the public card route and returns a Save-to-Wallet response.
11. Returning same-browser customers use the locally stored opaque card reference.
12. Cross-device access uses the dedicated short-lived transfer flow from a trusted old device.

Current API surfaces involved:

- `GET /public/m/:slug/loyalty`
- `POST /public/m/:slug/loyalty/enroll`
- `GET /public/loyalty/cards/:token`
- `POST /public/loyalty/cards/:token/apple-wallet`
- `POST /public/loyalty/cards/:token/google-wallet`
- `POST /public/loyalty/card-transfers`
- `POST /public/loyalty/card-transfers/redeem`

Current safety baseline:

- Phone-only recovery remains blocked.
- Same-business duplicate join remains blocked without returning card access.
- Same phone can join a different business.
- Wallet add remains user initiated.
- Card references are opaque and should not be displayed as product copy.
- Staff scanner tokens are separate from customer card references and transfer codes.

## C) Friction Identified

### Too many perceived steps

The technical sequence is correct, but the customer may perceive it as:

1. Open menu.
2. Find loyalty.
3. Fill a form.
4. See a card.
5. Choose a wallet.
6. Confirm in Apple or Google Wallet.

For a first visit, that is acceptable only if the page explains the reward quickly and makes the primary next action obvious.

### Wallet add button visibility

The wallet button is already device-aware, but the pilot experience should make the first wallet action feel like the natural next step after joining. The web card should still be visible, but it should not compete with the main wallet CTA on phone devices.

### Identity friction

Phone is required for duplicate prevention and pilot staff recovery. Email should stay optional unless the product decision changes. The UX should frame phone as "so the restaurant can find your card later with staff help", not as a login credential.

### Duplicate card risk

The backend already blocks same-business duplicate joins from a clean device without returning card access. The copy should avoid making this feel like an app error. It should explain that the card already exists and recovery needs transfer from a trusted device or staff help.

### Platform detection

Device-aware behavior is implemented in customer-web. The risk is not the API contract; the risk is pilot copy and layout making the fallback path feel slower than the primary platform wallet path.

### Apple Wallet update expectations

The customer web card is the source of truth. Apple Wallet installed-pass refresh timing is platform-controlled and must not be presented as instant.

## D) Safe Fast-Add Target

Target Sprint 13 customer path:

1. Customer scans restaurant QR.
2. Public menu opens and shows a clear loyalty entry point.
3. Loyalty landing gives a short benefit statement first.
4. Customer enters required phone and optional name/email.
5. On success, show the live card state and one primary wallet CTA:
   - iPhone: Add to Apple Wallet.
   - Android: Add to Google Wallet.
   - Desktop: Open this link on your phone / copy link.
6. Keep "Open live card" as the safe fallback.
7. Do not auto-add a wallet pass without user approval.
8. Do not expose the public card reference in visible copy.

Recommended implementation scope if approved:

- Customer-web only.
- No API contract change.
- No OpenAPI change.
- No schema change.
- No wallet signing change.
- Make the post-enrollment wallet CTA visually dominant on phones.
- Tighten copy above the form and in duplicate/recovery states.
- Add an "Already joined?" path that clearly separates trusted-device transfer from staff help.
- Keep existing tests for device-aware wallet buttons and click-only wallet requests.

## E) Security Requirements

Fast-add must preserve:

- User consent before Apple or Google Wallet provisioning.
- Wallet add endpoints remain click-only.
- No automatic pass creation during render.
- No raw card references in UI copy or logs.
- No scan token exposure.
- No staff/cashier QR reuse for customer recovery.
- Phone-only and email-only recovery remain blocked.
- Same-business duplicate join returns safe recovery-required state without card access.
- Cross-business enrollment remains scoped to the current business/program.
- Transfer codes remain short-lived, single-use, hashed at rest, and scoped to issuing another card reference for the same membership.
- Public enrollment and transfer endpoints remain rate-limited or covered by existing abuse controls.
- Repeated enrollment attempts must not create duplicate memberships for the same business/program.

If a short-lived enrollment/session token is proposed later, it must be:

- Opaque and random.
- Hashed at rest if stored.
- Scoped only to completing the wallet add handoff.
- Not usable for staff actions.
- Not usable as a recovery credential by phone/email alone.
- Expired quickly.

## F) Nearby Reminder Feasibility

### Apple Wallet

Apple Wallet supports pass relevance by location through top-level `locations` in the pass. Apple documentation describes this as passive relevance that can make a pass easier to access when it is useful. It does not behave like guaranteed push marketing. Apple also documents a limit of up to ten relevant locations per pass.

Pilot implication:

- Feasible for a single restaurant location once Waflo has approved coordinates.
- Do not promise an alert or notification.
- Phrase as "Wallet may surface the pass when nearby", not "customers receive a notification".
- Requires adding location data into generated Apple pass payloads.
- Should not be attempted without exact pilot restaurant latitude/longitude.

Source:

- Apple PassKit guide: https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PassKit_PG/Creating.html

### Google Wallet

Google Wallet loyalty classes support `merchantLocations`. The Google Wallet API reference states there is a maximum of ten merchant locations on a class and that these locations can trigger notification behavior within a Google-set radius.

Pilot implication:

- Feasible for one pilot location if coordinates are available.
- Google controls radius and notification behavior.
- Only installed wallet pass users can receive this behavior.
- Do not promise guaranteed notifications.
- Current Waflo Google Wallet payload builder does not include `merchantLocations`.

Source:

- Google Wallet loyalty class reference: https://developers.google.com/wallet/reference/rest/v1/loyaltyclass

### Current Waflo Data Gap

The current `Business` model stores city and assets but does not store approved latitude/longitude coordinates. Nearby relevance therefore needs either:

- a tiny approved pilot-only config source, or
- a schema/config addition for business location coordinates.

Because Sprint 13 is the first restaurant pilot and the current product already has QR menu plus wallet loyalty value, nearby relevance should not block pilot launch.

## G) Recommended Sprint 13 Scope

### Do now

`DO_NOW_FAST_ADD_COPY_ONLY`

Recommended as Sprint 13 pilot-safe:

- Improve customer-web loyalty landing and success copy.
- Make the platform-specific wallet button the obvious primary action after enrollment.
- Keep live card fallback clear.
- Keep returning same-device and trusted-device transfer language concise.
- Clarify Apple Wallet refresh timing without making it scary.
- Keep all API behavior unchanged.

### Do not do now

- Do not add automatic Wallet add.
- Do not add phone-only recovery.
- Do not use staff scanner QR as a recovery credential.
- Do not add background marketing notifications.
- Do not add multi-branch.
- Do not add a template marketplace.
- Do not add billing.

## H) Deferred Items

### Nearby single-location relevance

`DEFER_NEARBY_TO_LATER`

Bring back when:

- pilot restaurant coordinates are approved,
- owner accepts non-guaranteed platform behavior,
- team decides where business location coordinates live,
- APNs/Wallet operational expectations are documented for the pilot,
- tests can prove payload fields are present without leaking tokens.

### Multi-location support

Defer to multi-branch scope. Both Apple and Google impose practical location limits, and Waflo does not need branch logic for the first pilot.

### Retention reminders

Defer to engagement/ops scope. Real customer reminders require opt-in, throttling, consent language, unsubscribe/help paths, and support handling.

## I) API Impact

No API change is recommended for the first pilot fast-add improvement.

No OpenAPI change is recommended.

No schema change is recommended unless Sprint 13 explicitly decides to store pilot coordinates for wallet relevance.

## J) Pilot Recommendation

Proceed with fast-add copy/CTA polish only for the first restaurant pilot. Keep nearby wallet relevance as a documented follow-up, not a launch blocker.
