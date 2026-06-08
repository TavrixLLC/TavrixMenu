# Clerk Setup

For the detailed auth guide, see [06-auth-clerk.md](06-auth-clerk.md).

Clerk is planned for business owners, managers, staff, and Tavrix Menu admins only.

Customers do not use Clerk. Customers browse public menu pages without authentication and will later be managed internally through name, phone, and loyalty card token records.

## Backend Mapping

The backend will verify Clerk sessions and map the Clerk user ID to the internal `users.clerk_user_id` value.

## Roles and Permissions

Business roles live in PostgreSQL in the `business_users` table. Do not rely on Clerk metadata as the source of truth for business permissions.

Backend guards must enforce:

- The authenticated user exists internally.
- The authenticated user belongs to the target business.
- The user's business role allows the requested action.

Admin access must also be checked in the backend. Frontend route protection alone is not enough.
