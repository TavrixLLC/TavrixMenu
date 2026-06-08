# API Contract

The detailed working API contract now lives in [05-api-contract.md](05-api-contract.md).

This legacy filename remains so older references still work. Keep both files aligned if this file is still used in a workflow.

The current foundation only implements `GET /health`. All other endpoints are planned.

## Endpoint Inventory

| Area | Method | Path | Auth |
| --- | --- | --- | --- |
| Health | GET | `/health` | Public |
| Auth | GET | `/me` | Clerk |
| Businesses | POST | `/businesses` | Clerk |
| Businesses | GET | `/businesses/me` | Clerk |
| Businesses | PATCH | `/businesses/:id` | Clerk, business role |
| Menu | POST | `/businesses/:id/categories` | Clerk, owner/manager |
| Menu | GET | `/businesses/:id/categories` | Clerk, business role |
| Menu | PATCH | `/categories/:id` | Clerk, owner/manager |
| Menu | DELETE | `/categories/:id` | Clerk, owner/manager |
| Menu | POST | `/businesses/:id/items` | Clerk, owner/manager |
| Menu | GET | `/businesses/:id/items` | Clerk, business role |
| Menu | PATCH | `/items/:id` | Clerk, owner/manager |
| Menu | DELETE | `/items/:id` | Clerk, owner/manager |
| Public | GET | `/public/m/:slug` | Public |
| Public | GET | `/public/m/:slug/items/:itemId` | Public |
| Public | GET | `/public/m/:slug/items/:itemId/pairings` | Public |
| Billing | GET | `/billing/plans` | Clerk |
| Billing | POST | `/billing/checkout` | Clerk, owner |
| Billing | POST | `/billing/portal` | Clerk, owner |
| Billing | POST | `/billing/stripe/webhook` | Stripe signature |
| Admin | GET | `/admin/businesses` | Clerk, admin |
| Admin | GET | `/admin/subscriptions` | Clerk, admin |
| Admin | GET | `/admin/logs` | Clerk, admin |
| Admin | PATCH | `/admin/businesses/:id/status` | Clerk, admin |

Rules:

- Customer web uses public endpoints only.
- Customers do not use Clerk.
- Business roles live in PostgreSQL.
- API changes must remain backward compatible once apps depend on them.
