# Person 3 Runbook: Customer Web & Wallet QA Guide

This guide outlines how the Web Owner (Person 3) can safely test and verify the customer-web loyalty flow and wallet enrollment buttons.

## Development Boundary
* **No Secret Sharing:** You do not need access to backend certificates (`.p12`) or API environment credentials to run or verify frontend styling and logic.
* **Local Gating Configuration:** Confirm the state of the Apple Wallet button toggles inside `apps/customer-web/.env` using:
  `NEXT_PUBLIC_ENABLE_APPLE_WALLET_BUTTON=true`

## Wallet QA Steps
1. **Enrollment Testing:**
   * Open the customer enrollment flow at the local URL: `http://localhost:3001/m/tavrix-cafe/loyalty`.
   * Create a new test membership to generate a mock token.
2. **Button State QA:**
   * Verify that the "Add to Apple Wallet" and "Save to Google Wallet" buttons render correctly under various screen sizes.
   * Verify that hover states, micro-animations, and loaded templates meet design guidelines.
3. **Download Verification:**
   * Ensure that clicking "Add to Apple Wallet" correctly proxies the request through the customer-web API router (`POST /api/loyalty/cards/[token]/apple-wallet`) and downloads a `.pkpass` file.
   * If a signing failure occurs, verify that the frontend displays a user-friendly error state instead of exposing raw stack traces.
4. **Token Security:**
   * **Strict Security Rule:** Do not log or display the raw unhashed card tokens or ApplePass authentication tokens in your browser console, screenshots, or bug reports.
