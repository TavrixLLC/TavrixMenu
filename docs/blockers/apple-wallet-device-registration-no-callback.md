# Apple Wallet Device Registration Blocker Analysis

This document details the blocker encountered during local smoke testing of the Apple Wallet integration on custom subdomains (`waflo.app`).

## Status Classification
Based on local-dev preflight and E2E physical iPhone verification, the integration status is classified as:
* **`PASS_REAL_SIGNING_ONLY`** - The backend successfully signs and packages `.pkpass` files using the real Apple Developer certificates (`pass.p12` and `AppleWWDRCAG4.cer`).
* **`PASS_IPHONE_ADD_VISUAL`** - The compiled pass successfully loads in iOS Safari, displays visually correct stamps/loyalty data, and can be added directly to the native Apple Wallet app.
* **`BLOCKED_BY_DEVICE_REGISTRATION_NO_DEVICE_CALLBACK`** - The iOS Wallet daemon (`passd`) fails to send the required registration callback request back to the public-facing API endpoint (`https://api.waflo.app/apple-wallet/v1/devices/...`).

## APNs Boundary & Testability
> [!IMPORTANT]
> Apple Push Notification service (APNs) updates **cannot be tested** until a device successfully registers. The Apple Wallet server must receive and store a device's push token during the registration handshake before it can construct and dispatch APNs update payloads.

## Blocker Root Cause & Next Steps
* The physical device successfully downloads and verifies the signed pass (containing the correct `webServiceURL` and `authenticationToken` fields), but fails to initiate the direct background registration handshake.
* Since the API server log receives no callback, this indicates a client-side issue inside the iOS daemon (`passd`) when attempting to resolve or connect to local-dev tunnels.
* **Containment Action:** No more repeated add/remove or pull-to-refresh loops should be conducted on the physical device unless one of the following changes:
  1. `pass.json` generation parameters (e.g., `webServiceURL` or token scheme) change.
  2. Apple Wallet update controller routes are modified.
  3. API tunnel or domain configuration changes.
  4. Server-side log endpoints capture a different client-side failure.
  5. The pass generation/serial strategy is updated.

## Verification Constraints
* **No QR Screenshots:** Never capture or share visual representations of generated barcodes or QR codes to avoid token leakage.
* **No Token Printing:** Never log, print, or store the unhashed public card tokens, raw scan tokens, push tokens, or ApplePass authentication tokens in console outputs, tests, or documentation.
