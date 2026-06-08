# Tavrix Menu Overview

Tavrix Menu is a SaaS platform for restaurants and cafes. It gives each business a public QR menu website, business management tools, subscriptions, and future modules for AI product recommendations, loyalty cards, and staff scanning.

The repository is currently in the foundation stage. The monorepo exists, the app shells exist, the first Prisma schema exists, local Docker infrastructure exists, and placeholder pages/screens are available. The next product stage is Sprint 1: Clerk/Auth, business creation, menu CRUD, and a real public menu API.

## Users

- Tavrix service owners use the internal admin dashboard to manage businesses, subscriptions, logs, and service operations.
- Business owners use the Flutter app to create and manage their business, menu, QR menu, staff, and subscription.
- Managers use the Flutter app to manage menu and business operations within their assigned permissions.
- Staff use the Flutter app for limited tools such as scanning customer loyalty cards later.
- Customers use the public website from a QR code or link. Customers do not download an app and do not use Clerk.

## Product Modules

- QR Menu: public mobile-first menu pages for customers.
- AI Recommendations: future approved product pairing cards shown on product pages.
- Loyalty: future web-based customer cards with staff scanning from the Flutter app.
- Staff Scanner: future Flutter flow for staff to scan loyalty cards and redeem rewards.
- Admin Dashboard: internal Tavrix service-owner dashboard.
- Billing: Stripe subscriptions for Basic and Pro plans.

## Current Stage

Foundation completed:

- Monorepo with `apps/api`, `apps/mobile`, `apps/customer-web`, and `apps/admin-web`.
- NestJS API shell with `GET /health`.
- Prisma schema for users, businesses, menu, plans, subscriptions, and audit logs.
- Next.js customer web mock menu pages.
- Next.js admin web mock dashboard pages.
- Flutter placeholder app for owners, managers, and staff.
- Docker Compose for PostgreSQL and Redis.

Sprint 1 is next:

- Clerk authentication for business users and admins.
- Internal user sync from Clerk user ID.
- Business creation and membership.
- Menu category and item CRUD.
- Public menu API consumed by customer web.
- Seed data for a demo business.

## Not Implemented Yet

- Real Clerk authentication.
- Business permission guards.
- Real public menu API.
- Real menu management UI.
- Stripe checkout, portal, and webhooks.
- AI recommendation generation.
- Loyalty programs and customer cards.
- Wallet passes.
- QR generation and scan tracking.
- Image upload.
- Custom domains.
- Production deployment.
