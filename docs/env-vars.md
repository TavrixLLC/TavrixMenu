# Environment Variables

For local setup instructions, see [02-local-development.md](02-local-development.md).

Do not commit real secrets. Use local `.env` files copied from each app's `.env.example`.

## apps/api

- `DATABASE_URL`
- `REDIS_URL`
- `CLERK_JWT_ISSUER` required when `NODE_ENV` is `test` or `production`
- `CLERK_JWKS_URL` optional; defaults to `<CLERK_JWT_ISSUER>/.well-known/jwks.json`
- `CLERK_SECRET_KEY` reserved for future Clerk Admin API work; not required in Sprint 3
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `API_PORT`
- `NODE_ENV`
- `CUSTOMER_WEB_BASE_URL`

## apps/customer-web

- `NEXT_PUBLIC_API_BASE_URL`

## apps/admin-web

- `NEXT_PUBLIC_API_BASE_URL`
- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`
- `CLERK_SECRET_KEY`

## apps/mobile

- `API_BASE_URL`
- `CLERK_PUBLISHABLE_KEY`
