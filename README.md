# Tavrix Menu

Tavrix Menu is a SaaS platform for restaurants and cafes that provides QR menus, AI-powered product recommendations, loyalty cards, staff scanning, and subscription billing.

This repository contains the active Waflo product foundations and ongoing implementation work across the monorepo. Capability and release readiness must be read from the current product, API, security, and design authority documents.

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

Customers do not need to download an app. The Flutter app is only for business owners, managers, and staff. Clerk is used only for business users, staff, and admins. Public customer menu browsing does not require authentication.

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
- Do not present any unsupported capability as implemented or release-ready.

## Branching Rules

- main is stable.
- dev is integration.
- feature branches should be used for work.
- Example branches:
  - feature/api-foundation
  - feature/mobile-auth-shell
  - feature/customer-web-menu
  - feature/admin-dashboard

## Current Implementation Status

The repository has advanced beyond its original app-shell foundation. It now contains real auth, business, menu, Loyalty, wallet/scanner, and mobile workflow foundations, but the presence of code does not establish full security or release readiness.

Use `docs/05-api-contract.md` for API truth and
`docs/design/stitch/waflo-mobile-redesign/CAPABILITY_MATRIX.md` for the current
Mobile V3 capability and release-blocker status. In particular, Customer tenant
isolation remains a release blocker before Loyalty release.
