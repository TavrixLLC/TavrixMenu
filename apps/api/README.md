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

## Google Wallet Local Smoke Procedure

### Prerequisites

1. Set `GOOGLE_WALLET_ENABLED=true` in `apps/api/.env`.
2. Start a localhost.run tunnel: `ssh -R 80:localhost:3000 nokey@localhost.run`
3. Update `WALLET_IMAGE_PUBLIC_BASE_URL` in `.env` to the **new** tunnel URL (e.g. `https://<hash>.lhr.life/generated`).
4. **Restart the API** — `ConfigService` reads env at startup; updating `.env` without restarting has no effect.
5. Start customer-web: `pnpm --filter @tavrix-menu/customer-web dev`

### Running the Smoke

Always test through the **customer-web Add to Google Wallet button**, not by calling the API directly:

1. Open `http://localhost:3001` in the browser or on device.
2. Navigate to a loyalty card with an active membership.
3. Tap **Add to Google Wallet**.
4. Verify the Google Wallet save page loads with card details (no "Something went wrong").

### Safe Reporting Rules

The following **must never appear** in smoke reports, tickets, PRs, chat, or AI assistant conversations:

| Sensitive item | Safe alternative to report |
|---|---|
| Full `saveUrl` (contains JWT) | `saveUrl prefix: https://pay.google.com/gp/v/save/eyJ…` (first ~50 chars) |
| Full JWT | Never — confirm `status: ACTIVE` and `lastSyncedAt` only |
| `barcode.value` raw scan token | `scanTokenLast4` only (e.g. `MvPE`) |
| Full public card token | Never — use the customer-web flow which handles it automatically |
| Service account JSON contents | Never |
| Tunnel URL (`*.lhr.life`) | Acceptable in `.env` only; never commit, never paste in reports |

### Tunnel URL Lifecycle

`WALLET_IMAGE_PUBLIC_BASE_URL` must be treated as **ephemeral** during local smoke tests:

- The URL changes on every `localhost.run` restart.
- Update `.env` **and** restart the API after each new tunnel.
- In production this variable points to a stable CDN URL and tunnel handling is irrelevant.

### Pass/Token Rotation After a Leak

If a raw scan token or full saveUrl is accidentally exposed:

```bash
# Run from apps/api directory — deletes the WalletPass row and rotates the public card token
pnpm exec ts-node --project tsconfig.json scripts/rotate-test-pass.ts
# Delete the script immediately after use
```

> **Note (Sprint 9D):** Existing Wallet passes created before Sprint 9D may need
> to be re-synced or re-added before the QR barcode appears.

## Future Integrations

- Clerk backend session verification will be added in `src/modules/auth` and backend guards.
- Stripe billing, checkout, portal, and webhooks will be added in `src/modules/billing`.
- Business permissions must be enforced by the API using internal PostgreSQL roles.
