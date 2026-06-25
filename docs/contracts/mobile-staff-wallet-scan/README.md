# Mobile Staff Wallet Scan Contract Pack

## Purpose

This package gives mobile developers a sanitized, implementation-ready contract for the staff Wallet Scan flow. It contains compact schemas, fake response fixtures, and an optional Postman collection without production credentials or customer data.

The source of truth is [`docs/openapi/waflo-openapi-current.json`](../../openapi/waflo-openapi-current.json). The compact contract in this folder is a mobile-focused view of that generated OpenAPI document, checked against the current controllers, DTO validation, services, and tests.

## Access Requirements

- Send an `Authorization: Bearer <staff-bearer-token>` header.
- Obtain the selected business ID from `GET /businesses/me`.
- Substitute that ID into every business-scoped loyalty endpoint.
- Wallet scan, add stamp, and redeem allow active `OWNER`, `MANAGER`, and `STAFF` business roles.
- A wallet pass from another business is rejected with `403`.

## Token Safety

The wallet QR value is sensitive and short-lived application input:

- Do not log it, include it in analytics, or attach it to crash reports.
- Do not persist it in local storage, state restoration, caches, or test snapshots.
- Keep it only long enough to submit the scan request.
- Clear the input after a successful scan.
- Error UI must show the server error message, never the submitted value.

All identifiers, customer details, timestamps, and values in this package are fake and sanitized.

## Mobile Flow

1. Call `GET /businesses/me` and select the intended active business.
2. Submit the pasted QR value to `POST /businesses/{businessId}/loyalty/wallet-scan`.
3. Render `customer`, `program`, `progress`, and `walletPass` from the successful response. The membership is represented by `membershipId`; the scan response does not contain a nested membership object.
4. Use `membershipId` with the add-stamp or redeem endpoint when those actions are enabled in the mobile UI.
5. Treat the add-stamp or redeem response as the completed mobile action. The backend enqueues Google Wallet refresh work asynchronously and does not return queue status. Mobile must not wait for the wallet provider.

## Files

- `mobile-staff-wallet-scan.contract.json`: compact endpoint, schema, error, and implementation contract.
- `examples/`: sanitized success and error fixtures.
- `examples/wallet-refresh-queued-note.json`: explicit asynchronous refresh behavior because queue status is not exposed.
- `postman/wallet-scan.postman_collection.json`: optional placeholder-only request collection.

Audit this package before merge. Do not replace placeholders with real credentials or wallet values in committed files.
