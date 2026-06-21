# Person 2 Runbook: Mobile Wallet Scanner Development

This guide outlines how the Mobile App Owner (Person 2) can safely implement, test, and verify the staff wallet QR scanning feature without requiring access to backend private keys, Apple Developer certificates, or local-dev secrets.

## Development Boundary
* **No Secret Sharing:** You do not need access to the `.p12`/`.pem` certificates or private signing passwords to develop the mobile scanner.
* **Mock-First Integration:** Rely entirely on the OpenAPI contract specifications and sample payloads to mock responses during scanner implementation.

## Scanning Workflow & Verification
1. **Contract Reference:** Use the finalized contract schemas located in `docs/contracts/mobile-staff-wallet-scan/mobile-staff-wallet-scan.contract.json`.
2. **Mock Payload Integration:** For testing scanner camera outputs:
   * Refer to success and failure payload examples in `docs/contracts/mobile-staff-wallet-scan/examples/`.
   * Simulate camera scans using raw scan tokens formatted according to the contract, without requesting real tokens from the backend.
3. **Camera Testing:**
   * Test barcode recognition with simulated QR outputs.
   * **Strict Security Rule:** Never take screenshots, photos, or recordings of active pass QR codes during testing or share them in public channels.
4. **API Integration:** Ensure the scanner targets the public endpoints:
   * Target endpoint: `POST /businesses/:id/loyalty/wallet-scan`
   * Standard response mapping includes verification of success/unauthorized/cross-business states.
