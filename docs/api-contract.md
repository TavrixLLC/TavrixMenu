# API Contract

This is the initial endpoint plan for Tavrix Menu. The current foundation only implements `GET /health`.

## Health

- `GET /health`

## Auth

- `GET /me`

## Businesses

- `POST /businesses`
- `GET /businesses/me`
- `PATCH /businesses/:id`

## Menu

- `POST /businesses/:id/categories`
- `GET /businesses/:id/categories`
- `POST /businesses/:id/items`
- `GET /businesses/:id/items`
- `PATCH /items/:id`
- `DELETE /items/:id`

## Public

- `GET /public/m/:slug`
- `GET /public/m/:slug/items/:itemId`
- `GET /public/m/:slug/items/:itemId/pairings`

## Billing

- `GET /billing/plans`
- `POST /billing/checkout`
- `POST /billing/portal`
- `POST /billing/stripe/webhook`

## Admin

- `GET /admin/businesses`
- `GET /admin/subscriptions`
- `GET /admin/logs`
- `PATCH /admin/businesses/:id/status`
