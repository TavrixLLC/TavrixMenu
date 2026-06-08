# Tavrix Menu

Tavrix Menu is a SaaS platform for restaurants and cafes that provides QR menus, AI-powered product recommendations, loyalty cards, staff scanning, and subscription billing.

This repository is the initial production foundation only. It sets up the monorepo, app shells, database schema, infrastructure, and docs needed for the team to start building safely.

## Monorepo Structure

```text
apps/
  api/            NestJS backend API
  mobile/         Flutter app for business owners, managers, and staff
  customer-web/   Public Next.js menu website for customers
  admin-web/      Internal Next.js admin dashboard for Tavrix Menu service owners
packages/
  shared-types/   Placeholder shared API/domain types
  config/         Placeholder shared config references
infra/            Docker Compose services
docs/             API, database, auth, billing, env, and team docs
```

Customers do not need to download an app. The Flutter app is only for business owners, managers, and staff. Clerk is planned only for business users, staff, and admins. Public customer menu browsing does not require authentication.

## Documentation

Start with [docs/README.md](docs/README.md). The numbered docs are the project handoff source for team workflow, architecture, API contracts, database rules, auth, billing, security, roadmap, and reusable Codex prompts.

## Install Dependencies

Enable pnpm through Corepack if pnpm is not already installed:

```bash
corepack enable
corepack pnpm install
```

Or, if pnpm is already available:

```bash
pnpm install
```

## Run PostgreSQL and Redis

```bash
docker compose -f infra/docker-compose.yml up -d
```

Stop services:

```bash
docker compose -f infra/docker-compose.yml down
```

## Run API

```bash
cp apps/api/.env.example apps/api/.env
pnpm dev:api
```

Health check:

```bash
curl http://localhost:3000/health
```

Prisma commands:

```bash
pnpm --filter tavrix-menu-api prisma:generate
pnpm --filter tavrix-menu-api prisma:migrate
```

## Run Customer Web

```bash
cp apps/customer-web/.env.example apps/customer-web/.env
pnpm dev:customer
```

Open `http://localhost:3001/m/tavrix-cafe` for the mock public menu.

## Run Admin Web

```bash
cp apps/admin-web/.env.example apps/admin-web/.env
pnpm dev:admin
```

Open `http://localhost:3002` for the mock internal admin dashboard.

## Run Flutter App

```bash
cd apps/mobile
cp .env.example .env
flutter pub get
flutter run
```

The Flutter app is for business owners, managers, and staff only.

## Team Ownership Rules

- Backend developer owns apps/api and docs related to API/database.
- Flutter developer owns apps/mobile.
- Web developer owns apps/customer-web and apps/admin-web.
- Avoid modifying another person's app without coordination.
- Keep API contract updated before frontend integration.

## Codex Rules

- Backend developer only edits apps/api and docs.
- Flutter developer only edits apps/mobile.
- Web developer only edits apps/customer-web and apps/admin-web.
- Do not implement unrelated features.
- Keep changes small and focused.
- Keep API contract updated before frontend integration.
- Do not add real secrets.
- Do not implement AI, loyalty, wallet, or custom domains in this foundation pass.

## Branching Rules

- main is stable.
- dev is integration.
- feature branches should be used for work.
- Example branches:
  - feature/api-foundation
  - feature/mobile-auth-shell
  - feature/customer-web-menu
  - feature/admin-dashboard

## Current Foundation Status

- NestJS API shell with `/health`.
- Prisma schema with users, businesses, menus, billing, and audit logs.
- Public customer web shell with mock menu and product detail pages.
- Internal admin web shell with mock dashboards and Clerk placeholders.
- Flutter app shell with placeholder business user screens.
- Docker Compose for PostgreSQL and Redis.
- Initial docs for API contract, database, Clerk, Stripe plans, env vars, and task ownership.

## Intentionally Not Implemented Yet

- Full business logic.
- Loyalty.
- AI recommendations beyond mock UI cards.
- Wallet integration.
- Custom domains.
- Real Clerk authentication.
- Real Stripe billing flows.
- Customer accounts or customer authentication.
