# Customer Loyalty Recovery Security Contract

## Audience

This is the contract handoff for Person 2 (customer-web/mobile consumers) and Person 3 (security/audit). The generated source of truth remains [`docs/openapi/waflo-openapi-current.json`](../../openapi/waflo-openapi-current.json).

## Security Boundary

Phone numbers and email addresses are identifiers, not authentication. They must never be sufficient to return, rotate, or reconstruct an existing public card access token.

The only supported returning-customer proof in this pilot is the opaque card reference already held by the same browser/device. Customer-web may use that reference with:

`GET /public/loyalty/cards/{token}`

The reference must not be logged or replaced with stored customer PII.

## Enrollment Endpoint

`POST /public/m/{slug}/loyalty/enroll`

### `JOIN`

- A normalized Iraqi phone is required.
- Email and name remain optional.
- When the phone and optional email are unused, the API creates a new customer and membership and returns `201`.
- When either identifier already belongs to a customer, the API returns the generic verification-required response below.
- Existing customer or membership records are not updated, duplicated, or issued fresh card access.

### `RECOVER`

- Contact details are never treated as proof of ownership.
- Email-only recovery is rejected because phone remains required by the request schema.
- Every valid `RECOVER` request returns the same generic verification-required response.
- The API does not look up the submitted phone to decide the recovery response.
- No customer data, membership state, or card access is returned.

### Verification-Required Response

```json
{
  "statusCode": 403,
  "code": "RECOVERY_REQUIRES_VERIFICATION",
  "message": "Recovery requires phone verification or staff help."
}
```

Consumers must not interpret this response as confirmation that a card exists.

## Customer-Web Behavior

- A valid same-device opaque reference opens the returning card and existing platform-aware Wallet actions.
- Without a local reference, "I already joined" explains that verification is required.
- The recovery UI does not collect a phone or email and does not call `RECOVER`.
- A `JOIN` response with `RECOVERY_REQUIRES_VERIFICATION` transitions to the same safe help state.

## Future Recovery Work

- Add OTP proof through an approved SMS, WhatsApp, or email provider.
- Bind OTP challenges to the business, normalized identifier, short expiry, attempt limits, and one-time use.
- Add a staff-assisted pilot recovery flow with authenticated staff authorization and an auditable customer handoff.
- Do not enable token issuance until the backend verifies one of these proofs.
