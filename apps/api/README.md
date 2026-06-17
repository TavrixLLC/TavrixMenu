# Tavrix Menu API

NestJS backend API foundation for Tavrix Menu.

## Install

From the repository root:

```bash
pnpm install
```

## Environment

```bash
cp apps/api/.env.example apps/api/.env
```

Set `DATABASE_URL` before running Prisma migrations.

## Run Dev

```bash
pnpm dev:api
```

## Prisma

Generate the Prisma client:

```bash
pnpm --filter tavrix-menu-api prisma:generate
```

Create and apply a development migration:

```bash
pnpm --filter tavrix-menu-api prisma:migrate
```

## Health Endpoint

```bash
curl http://localhost:3000/health
```

Expected response:

```json
{
  "status": "ok",
  "service": "tavrix-menu-api"
}
```

## Google Wallet Scan Smoke Note

Real Google Wallet loyalty membership passes should show a square QR code after
Sprint 9D, not only the `WAFLO-...` member display text. Existing Wallet passes
created before Sprint 9D may need to be re-synced or re-added before the QR code
appears.

## Future Integrations

- Clerk backend session verification will be added in `src/modules/auth` and backend guards.
- Stripe billing, checkout, portal, and webhooks will be added in `src/modules/billing`.
- Business permissions must be enforced by the API using internal PostgreSQL roles.
