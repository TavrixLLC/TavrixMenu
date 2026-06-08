# Auth and Clerk

Clerk is used for business owners, managers, staff, and Tavrix service admins only.

Customers do not use Clerk. Customer menu browsing is public, and future customer loyalty cards will use internal customer records and random card tokens.

## Backend Auth Flow

1. Frontend signs in with Clerk.
2. Frontend sends `Authorization: Bearer <clerk-token>` to the API.
3. Backend verifies the token against Clerk.
4. Backend reads the Clerk user ID.
5. Backend finds or creates an internal `User` where `users.clerk_user_id` matches the Clerk user ID.
6. Backend uses internal database roles for authorization.

The internal `User` should be created or synced on the first valid authenticated request.

## Roles

Business roles live in PostgreSQL in `business_users`.

Do not use Clerk metadata as the source of truth for business permissions.

Business route checks should verify:

- The user exists.
- The target business exists.
- The user has an active `business_users` row for that business.
- The user's role allows the action.

## Admin Access

Admin access must be checked in the backend, not only in admin web route protection.

Admin web can hide pages from non-admins, but the API must still reject non-admin requests.

## Future Guards and Decorators

- `ClerkAuthGuard`: verifies Bearer token and attaches current internal user.
- `CurrentUser` decorator: reads the current internal user from the request.
- `BusinessRoleGuard`: checks active business membership and required role.
- `AdminGuard`: checks internal Tavrix admin access.

## Development Fallback

A development auth fallback may be added only for `NODE_ENV=development`.

Rules:

- It must never be enabled in production.
- It must be obvious in code and logs when fallback auth is active.
- It must not grant admin access by default.
- It must not be used for staging or production testing.

## Customer Auth Rule

Do not add Clerk to customer web. Customers browse public menu routes without login.
