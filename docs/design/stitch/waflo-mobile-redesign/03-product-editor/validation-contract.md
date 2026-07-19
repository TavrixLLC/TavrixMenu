# Product Editor Validation Contract

Validation is grounded in the current Create Item DTO, menu service, Prisma schema, and media upload source. Client validation improves usability but never replaces server validation or invents limits.

## Product name

- Required for the Arabic-first create flow.
- Trim surrounding whitespace before validation and submission.
- Reject empty or whitespace-only input.
- Current backend maximum length: 160 characters.
- Do not silently truncate; show a field-level error.

## Description

- Optional under the current backend contract.
- Trim safely while preserving intentional internal line breaks.
- Current backend maximum length: 1000 characters.
- Do not clear valid description input after another field fails.

## Category

- Required.
- Must be selected from real categories belonging to the authoritative active business.
- Reject an arbitrary, stale, or unauthorized category record identifier.
- The backend create service rechecks that the category belongs to the target business.

## Price

- Required.
- Iraqi dinar is the approved scenario currency; the runtime currency still comes from the authoritative business.
- Parse deterministically and submit the backend's decimal-string representation.
- Reject negative values.
- The current DTO accepts non-negative digit strings with an optional decimal part of at most two digits.
- Storage is Prisma `Decimal(10,2)`; do not perform binary floating-point arithmetic.
- Do not infer cents or multiply Iraqi dinar input by 100.
- Do not invent a user-facing minimum or maximum that the published contract does not define.
- The existing mobile onboarding input path normalizes Iraqi/Arabic digits. Product Editor should reuse or equivalently test that architecture when implemented, rather than silently misparsing Arabic numeral entry.

## Availability

- Explicit boolean submitted with the create request.
- Current backend behavior defaults an omitted value to `true`; the form must document and visibly reflect its chosen default.
- The displayed state and submitted value must match.
- Do not show the enabled value while submitting a different value.

## Image

- Optional for product creation under the current item contract.
- Current media source supports menu-item JPEG, PNG, and WebP input up to 5MB and normalizes it to WebP within 1600×1200 bounds.
- The upload route is not documented in `docs/05-api-contract.md`; treat these limits as current source-backed behavior, not permission to invent other formats or client-only server claims.
- Validate hints client-side for usability, then handle authoritative server rejection.
- Normalization should avoid exposing unsafe image metadata where supported.
- A returned media URL is not proof that product creation succeeded.

## Duplicate submission

- Guard on the client before sending.
- Send one create request per deliberate submission.
- The current create contract does not document idempotency or duplicate-product protection; backend behavior must be reviewed before relying on either.
- Rapid taps must not create repeated requests.

## Error presentation

- Field-specific errors remain adjacent to their fields and use semantic error styling, not the normal Primary color.
- Form-level backend errors preserve valid user input.
- Scroll or focus the first invalid field without trapping keyboard or assistive-technology users.
