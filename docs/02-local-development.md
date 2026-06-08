# Local Development

This guide explains how to run Tavrix Menu locally.

## Requirements

- Node.js
- Corepack or pnpm
- Flutter SDK
- Docker Desktop
- Git

On Windows, `pnpm` may not be globally available if Node is installed under `C:\Program Files`. In that case use:

```bash
corepack pnpm install
```

Docker Desktop must be running with the Linux engine enabled before starting PostgreSQL and Redis.

## Install Dependencies

From the repository root:

```bash
corepack pnpm install
```

Or, if pnpm is globally available:

```bash
pnpm install
```

The Flutter app is not part of the pnpm workspace.

## Ports

- API: `3000`
- Customer web: `3001`
- Admin web: `3002`
- PostgreSQL: `5432`
- Redis: `6379`

## Environment Files

Create local env files from examples:

```bash
cp apps/api/.env.example apps/api/.env
cp apps/customer-web/.env.example apps/customer-web/.env
cp apps/admin-web/.env.example apps/admin-web/.env
cp apps/mobile/.env.example apps/mobile/.env
```

Do not commit real `.env` files.

## PostgreSQL and Redis

Start local services:

```bash
docker compose -f infra/docker-compose.yml up -d
```

Stop local services:

```bash
docker compose -f infra/docker-compose.yml down
```

The local PostgreSQL defaults are:

- User: `tavrix_menu`
- Password: `tavrix_menu`
- Database: `tavrix_menu`

Use this local `DATABASE_URL` only in your private `.env` file:

```text
postgresql://tavrix_menu:tavrix_menu@localhost:5432/tavrix_menu
```

## API

Run the API:

```bash
corepack pnpm dev:api
```

Health check:

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

Prisma:

```bash
corepack pnpm --filter tavrix-menu-api prisma:generate
corepack pnpm --filter tavrix-menu-api prisma:migrate
```

## Customer Web

Run the public customer website:

```bash
corepack pnpm dev:customer
```

Open:

```text
http://localhost:3001
http://localhost:3001/m/tavrix-cafe
```

## Admin Web

Run the internal admin dashboard:

```bash
corepack pnpm dev:admin
```

Open:

```text
http://localhost:3002
```

## Flutter

Run the mobile app:

```bash
cd apps/mobile
flutter pub get
flutter run
```

The Flutter app is only for business owners, managers, and staff. It is not a customer app.
