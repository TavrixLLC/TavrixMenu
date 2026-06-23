# Customer Loyalty Card Transfer Contract

## Purpose

This contract describes secure cross-device transfer for an existing public loyalty card. The generated source of truth remains [`docs/openapi/waflo-openapi-current.json`](../../openapi/waflo-openapi-current.json).

Phone and email remain identifiers only. They never authorize recovery or card access.

## Endpoints

### Create From Trusted Device

`POST /public/loyalty/card-transfers`

Request:

```json
{
  "cardToken": "<trusted-public-card-reference>"
}
```

The API validates the card reference already held by the trusted browser, applies a per-membership creation limit, and returns:

```json
{
  "transferToken": "<short-lived-transfer-code>",
  "expiresAt": "2026-06-23T13:05:00.000Z"
}
```

The transfer token is random and opaque. Only its SHA-256 hash is stored.

### Redeem On New Device

`POST /public/loyalty/card-transfers/redeem`

Request:

```json
{
  "transferToken": "<short-lived-transfer-code>"
}
```

A valid token is atomically marked used and returns the existing membership card state with an additional public card reference. Existing device references remain valid, and stamp and reward state is unchanged.

Invalid, expired, already-used, inactive-card, and staff-wallet-QR inputs return the same safe response:

```json
{
  "statusCode": 410,
  "code": "LOYALTY_TRANSFER_UNAVAILABLE",
  "message": "This transfer code is invalid, expired, or already used."
}
```

## Security Rules

- Transfer tokens expire after five minutes.
- Each transfer token is single-use.
- Creation is limited to three transfer tokens per membership per ten minutes.
- Raw transfer tokens are never stored or logged.
- Transfer tokens contain no customer PII or membership identifiers.
- Transfer tokens do not use the `waflo_scan_v1` staff scanner format.
- Transfer tokens cannot call staff stamp or redeem endpoints.
- Phone-only and email-only recovery remain blocked.
- Successful redemption creates a new `TRANSFER` access record. Existing device references remain valid.
- All active access records resolve to the same membership, progress, and reward state.
- Legacy membership-level hashes remain supported and are backfilled as `JOIN` access records during migration.

## Card Access Model

Each trusted browser reference is represented by a `LoyaltyCardAccess` row:

- `membershipId`: shared loyalty membership and progress.
- `tokenHash`: SHA-256 hash only; raw references are never persisted.
- `source`: `JOIN`, `TRANSFER`, or reserved `STAFF_RECOVERY`.
- `createdAt` and optional `lastUsedAt`.
- optional `revokedAt` for future explicit session revocation.

No customer PII or device fingerprint is stored. The legacy token columns remain on `LoyaltyMembership` for backward compatibility.

## Smoke Expectation

Run `pnpm --filter tavrix-menu-api loyalty:card-add-device-smoke` with a sanitized environment containing `API_BASE_URL` and `LOYALTY_CARD_SMOKE_TOKEN`.

The successful result is:

`OLD_DEVICE_STILL_VALID_AFTER_TRANSFER`

The smoke verifies that the original and newly issued references both return the same unchanged card state.

## Customer-Web Flow

- The trusted card page exposes "Add card to another device".
- QR creation is click-only.
- The QR points to `/m/{slug}/loyalty#transfer=...`; the fragment is not sent in the initial HTTP request.
- The new phone Camera can open that fragment link and customer-web redeems it automatically.
- Manual code or link entry is also supported.
- Without the old device, customer-web shows an "Ask staff for help" placeholder. No staff-assisted backend recovery is included yet.
