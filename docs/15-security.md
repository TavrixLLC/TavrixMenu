# Security

Security rules must be enforced in the backend. Frontend checks improve UX but do not protect data.

## Auth and Permissions

- All business routes require auth.
- Every business-owned query must filter by `business_id`.
- Business membership must be checked in `business_users`.
- Staff permissions must be enforced server-side.
- Never trust role, business ID, or admin status from the frontend.
- Customers do not use Clerk.

## Input Validation

- Validate DTOs with class-validator.
- Reject unknown fields where possible.
- Validate route params.
- Validate decimal prices.
- Validate slugs.

## Public Endpoints

- Public menu endpoints are read-only.
- Return only public fields.
- Rate limit public endpoints later.
- Do not expose subscription, staff, audit, or internal IDs beyond what the public UI needs.

## Stripe

- Protect Stripe webhook signature.
- Use raw request body for webhook verification.
- Make webhook processing idempotent.
- Never activate subscriptions from frontend redirects alone.

## Clerk

- Verify Clerk tokens in backend.
- Map Clerk user ID to internal user.
- Do not use Clerk metadata as the source of truth for business roles.
- Development auth fallback must never run in production.

## Secrets

- No real secrets committed.
- `.env` files stay local.
- Rotate secrets if accidentally exposed.

## Audit

Audit sensitive actions:

- Business status changes.
- Subscription changes.
- Staff role changes.
- Loyalty redemptions later.
- Admin overrides.

## Customer Tokens

Customer QR tokens must be random and unguessable. Tokens must not contain phone numbers, names, or internal customer data.

## Uploads Later

Image uploads need validation later:

- File type.
- File size.
- Image dimensions.
- Malware scanning if available.
- Object storage permissions.
