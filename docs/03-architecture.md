# Architecture

Tavrix Menu is a monorepo with one backend API, two web apps, one Flutter app, shared packages, and local infrastructure.

## Diagram

```text
Business Owner / Manager / Staff
        |
        v
Flutter Business App -- Clerk token --> Backend API ----> PostgreSQL
                                           |   |
                                           |   +--------> Redis
                                           |
Customer Browser --> Customer Web --> Public API
                                           |
Tavrix Service Owner --> Admin Web --> Admin API
                                           |
Stripe Checkout / Portal / Webhook ------> Backend API
                                           |
Clerk JWT Issuer ------------------------> Backend JWT verification
```

## Components

- `apps/api`: NestJS backend and source of truth.
- `apps/mobile`: Flutter business app for owners, managers, and staff.
- `apps/customer-web`: public Next.js customer menu website.
- `apps/admin-web`: internal Next.js admin dashboard for Tavrix service owners.
- PostgreSQL: primary relational database.
- Redis: cache, queues, rate limiting, and short-lived state later.
- Clerk: authentication for business users, staff, and admins only.
- Stripe: subscriptions, checkout, billing portal, and webhooks.

## Source of Truth

The backend API is the source of truth. Frontends never access the database directly.

Rules:

- All writes go through the API.
- All business permissions are enforced in the API.
- Public customer pages use public read-only API endpoints.
- Authenticated routes require Clerk Bearer tokens.
- Stripe subscription state is updated from verified webhooks, not from frontend claims.

## Public Website

The customer website is public. Customers do not use Clerk and do not need an app. Public menu data must be filtered before it is returned:

- Only active businesses.
- Only active categories.
- Only available items.
- No private staff, subscription, audit, or internal metadata.

## Multi-Tenancy

Multi-tenant isolation is based on `business_id`.

Every business-owned query must filter by `business_id`. A user can only access a business if there is an active `business_users` row connecting that user to the business with the required role.
