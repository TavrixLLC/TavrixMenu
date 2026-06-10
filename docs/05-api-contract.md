# API Contract

This file is the working API contract. Sprint 1 implements health, Clerk-backed business auth, business profile endpoints, menu management, and public menu reads.

Once Flutter or customer web depends on an endpoint, keep it backward compatible. Add fields without removing or renaming existing fields. Breaking changes require coordination across the team.

## Conventions

- Production and staging authenticated requests use
  `Authorization: Bearer <clerk-jwt>`.
- Local development can use dev auth only when `NODE_ENV=development`:
  `Authorization: Bearer dev:user_tavrix_owner;email=owner@tavrix.local;name=Tavrix%20Owner`.
- Non-development environments reject `dev:` tokens.
- Customers do not authenticate.
- Business routes require a valid Clerk token and internal business membership.
- Owner-only routes require `BusinessUser.role = OWNER` unless documented otherwise.
- All errors use a consistent JSON shape.

Backend base URLs:

- Desktop: `http://localhost:3000`
- Android emulator: `http://10.0.2.2:3000`
- Physical phone: `http://<LAN-IP>:3000`

Swagger:

- UI: `http://localhost:3000/docs`
- JSON: `http://localhost:3000/docs-json`

API CORS currently allows local Flutter and web development clients with
credentials. Tighten allowed origins before production deployment.

Clerk environment:

- `CLERK_JWT_ISSUER` is required when `NODE_ENV` is `test` or `production`.
- `CLERK_JWKS_URL` is optional; if omitted the API uses
  `<CLERK_JWT_ISSUER>/.well-known/jwks.json`.
- `CLERK_SECRET_KEY` is not required by Sprint 3 because the backend does not
  call the Clerk Admin API.

Example error:

```json
{
  "message": "Business not found",
  "code": "BUSINESS_NOT_FOUND"
}
```

## Health

### GET /health

Auth: public.

Request: none.

Response:

```json
{
  "status": "ok",
  "service": "tavrix-menu-api"
}
```

Errors:

- `500` if the API process is unhealthy.

## Auth

### GET /me

Auth: Clerk required.

Purpose: return or create/sync the internal user linked to the Clerk user ID.
This is the first authenticated startup endpoint for Flutter and dashboards.

Request: none.

Response:

```json
{
  "user": {
    "id": "usr_123",
    "clerkUserId": "user_abc",
    "name": "Owner Name",
    "email": "owner@example.com",
    "phone": null,
    "status": "ACTIVE",
    "createdAt": "2026-06-10T00:00:00.000Z",
    "updatedAt": "2026-06-10T00:00:00.000Z"
  },
  "memberships": [
    {
      "id": "mem_123",
      "role": "OWNER",
      "isActive": true,
      "business": {
        "id": "bus_123",
        "name": "Tavrix Cafe",
        "slug": "tavrix-cafe",
        "type": "cafe",
        "city": "Baghdad",
        "currency": "IQD",
        "language": "ar",
        "logoUrl": null,
        "coverUrl": null
      }
    }
  ],
  "onboarding": {
    "hasBusiness": true,
    "activeBusinessCount": 1,
    "recommendedNextStep": "OPEN_DASHBOARD"
  },
  "businesses": [
    {
      "id": "bus_123",
      "name": "Tavrix Cafe",
      "slug": "tavrix-cafe",
      "type": "cafe",
      "role": "OWNER"
    }
  ]
}
```

`onboarding.recommendedNextStep` values:

- `CREATE_BUSINESS`: zero active memberships.
- `OPEN_DASHBOARD`: one active membership.
- `SELECT_BUSINESS`: more than one active membership.

The `businesses` array remains for backward compatibility. New clients should
prefer `memberships` and `onboarding`.

Errors:

- `401` missing or invalid Clerk token.

## Businesses

### POST /businesses

Auth: Clerk required.

Role: authenticated user becomes owner.

Request:

```json
{
  "name": "Tavrix Cafe",
  "type": "cafe",
  "city": "Baghdad",
  "currency": "IQD",
  "language": "ar"
}
```

Response:

```json
{
  "business": {
    "id": "bus_123",
    "name": "Tavrix Cafe",
    "slug": "tavrix-cafe",
    "type": "cafe",
    "logoUrl": null,
    "coverUrl": null,
    "currency": "IQD",
    "language": "ar",
    "city": "Baghdad",
    "status": "ACTIVE"
  },
  "currentMembership": {
    "id": "mem_123",
    "role": "OWNER",
    "isActive": true
  },
  "appContext": {
    "business": {
      "id": "bus_123",
      "name": "Tavrix Cafe",
      "slug": "tavrix-cafe",
      "type": "cafe",
      "city": "Baghdad",
      "currency": "IQD",
      "language": "ar",
      "logoUrl": null,
      "coverUrl": null
    },
    "currentMembership": {
      "id": "mem_123",
      "role": "OWNER",
      "isActive": true
    },
    "permissions": {
      "canManageBusiness": true,
      "canManageMenu": true,
      "canManageMembers": true,
      "canViewMembers": true,
      "canViewPublicLink": true
    },
    "publicMenu": {
      "slug": "tavrix-cafe",
      "path": "/m/tavrix-cafe",
      "url": "http://localhost:3001/m/tavrix-cafe",
      "qrPayload": "http://localhost:3001/m/tavrix-cafe"
    }
  }
}
```

Behavior: creates the business, creates an active `OWNER` membership for the
current user, and returns enough app context for Flutter to continue without a
separate bootstrap call.

Errors:

- `400` invalid body.
- `401` unauthenticated.
- `409` slug already exists.

### GET /businesses/me

Auth: Clerk required.

Response:

```json
[
  {
    "id": "bus_123",
    "name": "Tavrix Cafe",
    "slug": "tavrix-cafe",
    "type": "cafe",
    "logoUrl": null,
    "coverUrl": null,
    "currency": "IQD",
    "language": "ar",
    "city": "Baghdad",
    "role": "OWNER",
    "status": "ACTIVE"
  }
]
```

Errors:

- `401` unauthenticated.

### PATCH /businesses/:id

Auth: Clerk required.

Role: `OWNER`.

Request:

```json
{
  "name": "Tavrix Cafe",
  "logoUrl": "https://example.com/logo.png",
  "coverUrl": "https://example.com/cover.png",
  "city": "Baghdad"
}
```

Response:

```json
{
  "id": "bus_123",
  "name": "Tavrix Cafe",
  "slug": "tavrix-cafe",
  "type": "cafe",
  "logoUrl": "https://example.com/logo.png",
  "coverUrl": "https://example.com/cover.png",
  "currency": "IQD",
  "language": "ar",
  "city": "Baghdad",
  "status": "ACTIVE"
}
```

Errors:

- `401` unauthenticated.
- `403` missing business role.
- `404` business not found.

### GET /businesses/:id/app-context

Auth: Clerk required.

Role: `OWNER`, `MANAGER`, or `STAFF`.

Purpose: one Flutter business-app bootstrap payload with current business,
membership, permissions, and public menu link.

Response:

```json
{
  "business": {
    "id": "bus_123",
    "name": "Tavrix Cafe",
    "slug": "tavrix-cafe",
    "type": "cafe",
    "city": "Baghdad",
    "currency": "IQD",
    "language": "ar",
    "logoUrl": null,
    "coverUrl": null
  },
  "currentMembership": {
    "id": "mem_123",
    "role": "OWNER",
    "isActive": true
  },
  "permissions": {
    "canManageBusiness": true,
    "canManageMenu": true,
    "canManageMembers": true,
    "canViewMembers": true,
    "canViewPublicLink": true
  },
  "publicMenu": {
    "slug": "tavrix-cafe",
    "path": "/m/tavrix-cafe",
    "url": "http://localhost:3001/m/tavrix-cafe",
    "qrPayload": "http://localhost:3001/m/tavrix-cafe"
  }
}
```

Errors:

- `401` unauthenticated.
- `403` missing active business membership.
- `404` business not found.

### GET /businesses/:id/public-link

Auth: Clerk required.

Role: `OWNER`, `MANAGER`, or `STAFF`.

Response:

```json
{
  "businessId": "bus_123",
  "slug": "tavrix-cafe",
  "publicMenuPath": "/m/tavrix-cafe",
  "publicMenuUrl": "http://localhost:3001/m/tavrix-cafe",
  "qrPayload": "http://localhost:3001/m/tavrix-cafe"
}
```

`CUSTOMER_WEB_BASE_URL` controls the URL base and defaults locally to
`http://localhost:3001`. The QR payload is the URL string; the backend does not
generate QR images.

Errors:

- `401` unauthenticated.
- `403` missing active business membership.
- `404` business not found.

### GET /businesses/:id/members

Auth: Clerk required.

Role: `OWNER` or `MANAGER`.

Response includes active and inactive memberships:

```json
[
  {
    "id": "mem_123",
    "userId": "usr_123",
    "clerkUserId": "user_tavrix_owner",
    "email": "owner@tavrix.local",
    "name": "Tavrix Owner",
    "phone": null,
    "role": "OWNER",
    "isActive": true,
    "createdAt": "2026-06-10T00:00:00.000Z",
    "updatedAt": "2026-06-10T00:00:00.000Z"
  }
]
```

Errors:

- `401` unauthenticated.
- `403` missing owner or manager role.

### POST /businesses/:id/members

Auth: Clerk required.

Role: `OWNER`.

Request:

```json
{
  "clerkUserId": "user_tavrix_staff",
  "email": "staff@tavrix.local",
  "name": "Tavrix Staff",
  "role": "STAFF"
}
```

Behavior:

- Finds or creates the user by `clerkUserId`.
- Creates a membership if none exists.
- Reactivates an inactive membership and updates its role.
- Returns `409` if the membership already exists and is active.
- Does not send email, create invite tokens, or call the Clerk Admin API.

Errors:

- `400` invalid body.
- `401` unauthenticated.
- `403` missing owner role.
- `409` business member already active.

### PATCH /businesses/:id/members/:memberId

Auth: Clerk required.

Role: `OWNER`.

Request:

```json
{
  "role": "MANAGER",
  "isActive": true
}
```

Rules:

- Cannot demote the last active `OWNER`.
- Cannot deactivate the last active `OWNER`.
- A business must always have at least one active `OWNER`.

Errors:

- `400` last active owner protection failed or invalid body.
- `401` unauthenticated.
- `403` missing owner role.
- `404` member not found for this business.

### DELETE /businesses/:id/members/:memberId

Auth: Clerk required.

Role: `OWNER`.

Behavior: soft deactivates the membership by setting it inactive. It never hard
deletes the row.

Errors:

- `400` last active owner protection failed.
- `401` unauthenticated.
- `403` missing owner role.
- `404` member not found for this business.

## Menu

### POST /businesses/:id/categories

Auth: Clerk required.

Role: `OWNER` or `MANAGER`.

Request:

```json
{
  "nameAr": "المشروبات الساخنة",
  "nameEn": "Hot Drinks",
  "sortOrder": 0
}
```

Response:

```json
{
  "id": "cat_123",
  "businessId": "bus_123",
  "nameAr": "المشروبات الساخنة",
  "nameEn": "Hot Drinks",
  "sortOrder": 0,
  "isActive": true
}
```

Errors:

- `400` invalid body.
- `403` missing role.

### GET /businesses/:id/categories

Auth: Clerk required.

Role: `OWNER`, `MANAGER`, or `STAFF`.

Query:

- `includeInactive=true` optionally includes archived categories.
- Default behavior hides archived categories and returns only `isActive = true`.

Response:

```json
[
  {
    "id": "cat_123",
    "nameAr": "المشروبات الساخنة",
    "nameEn": "Hot Drinks",
    "sortOrder": 0,
    "isActive": true
  }
]
```

Errors:

- `403` missing business membership.

### PATCH /categories/:id

Auth: Clerk required.

Role: `OWNER` or `MANAGER`.

Request:

```json
{
  "nameAr": "الحلويات",
  "sortOrder": 1,
  "isActive": true
}
```

Response:

```json
{
  "id": "cat_123",
  "nameAr": "الحلويات",
  "sortOrder": 1,
  "isActive": true
}
```

Errors:

- `403` missing role.
- `404` category not found.

### DELETE /categories/:id

Auth: Clerk required.

Role: `OWNER` or `MANAGER`.

Response:

```json
{
  "deleted": true
}
```

Errors:

- `403` missing role.
- `404` category not found.

Behavior: this endpoint archives the category by setting `isActive = false`.
Normal business category lists hide archived categories unless
`includeInactive=true` is provided. Public menus always hide archived
categories.

### POST /businesses/:id/items

Auth: Clerk required.

Role: `OWNER` or `MANAGER`.

Request:

```json
{
  "categoryId": "cat_123",
  "nameAr": "قهوة تركية",
  "nameEn": "Turkish Coffee",
  "descriptionAr": "قهوة قوية تقدم بفنجان صغير",
  "descriptionEn": "Rich coffee served in a small cup.",
  "price": "4500.00",
  "imageUrl": null,
  "isAvailable": true,
  "sortOrder": 0
}
```

Response:

```json
{
  "id": "item_123",
  "businessId": "bus_123",
  "categoryId": "cat_123",
  "nameAr": "قهوة تركية",
  "price": "4500.00",
  "isAvailable": true
}
```

Errors:

- `400` invalid body.
- `403` missing role.

### GET /businesses/:id/items

Auth: Clerk required.

Role: `OWNER`, `MANAGER`, or `STAFF`.

Query:

- `includeInactive=true` optionally includes unavailable or archived items.
- Default behavior hides unavailable or archived items and returns only
  `isAvailable = true`.

Response:

```json
[
  {
    "id": "item_123",
    "categoryId": "cat_123",
    "nameAr": "قهوة تركية",
    "nameEn": "Turkish Coffee",
    "price": "4500.00",
    "isAvailable": true
  }
]
```

Errors:

- `403` missing membership.

### PATCH /items/:id

Auth: Clerk required.

Role: `OWNER` or `MANAGER`.

Request:

```json
{
  "price": "5000.00",
  "isAvailable": false
}
```

Response:

```json
{
  "id": "item_123",
  "price": "5000.00",
  "isAvailable": false
}
```

Errors:

- `403` missing role.
- `404` item not found.

### DELETE /items/:id

Auth: Clerk required.

Role: `OWNER` or `MANAGER`.

Response:

```json
{
  "deleted": true
}
```

Errors:

- `403` missing role.
- `404` item not found.

Behavior: this endpoint archives the item by setting `isAvailable = false`.
Normal business item lists hide archived/unavailable items unless
`includeInactive=true` is provided. Public menus always hide unavailable items.

## Public

### GET /public/m/:slug

Auth: public.

Behavior: always returns only active businesses, active categories, and
available menu items. Query parameters cannot expose inactive or archived
records.

Response:

```json
{
  "business": {
    "id": "bus_123",
    "name": "Tavrix Cafe",
    "slug": "tavrix-cafe",
    "type": "cafe",
    "logoUrl": null,
    "coverUrl": null,
    "currency": "IQD",
    "language": "ar",
    "city": "Baghdad"
  },
  "categories": [
    {
      "id": "cat_123",
      "nameAr": "المشروبات الساخنة",
      "nameEn": "Hot Drinks",
      "sortOrder": 0,
      "items": [
        {
          "id": "item_123",
          "nameAr": "قهوة تركية",
          "nameEn": "Turkish Coffee",
          "descriptionAr": "Traditional strong coffee.",
          "descriptionEn": null,
          "price": "4500.00",
          "imageUrl": null,
          "isAvailable": true,
          "sortOrder": 0
        }
      ]
    }
  ]
}
```

Errors:

- `404` business not found or not public.

### GET /public/m/:slug/items/:itemId

Auth: public.

Behavior: returns only available items under active categories for active
businesses.

Response:

```json
{
  "id": "item_123",
  "nameAr": "قهوة تركية",
  "nameEn": "Turkish Coffee",
  "descriptionAr": "قهوة قوية تقدم بفنجان صغير",
  "descriptionEn": "Rich coffee served in a small cup.",
  "price": "4500.00",
  "imageUrl": null,
  "isAvailable": true,
  "sortOrder": 0
}
```

Errors:

- `404` business or item not found.

### GET /public/m/:slug/items/:itemId/pairings

Status: planned later; not implemented in Sprint 1.

Auth: public.

Response:

```json
[
  {
    "itemId": "item_456",
    "nameAr": "تمرية",
    "nameEn": "Tamriya",
    "price": "3000.00",
    "imageUrl": null,
    "reasonAr": "حلاوتها توازن الطعم القوي للقهوة التركية."
  }
]
```

Errors:

- `404` business or item not found.

## Billing

### GET /billing/plans

Auth: Clerk required.

Response:

```json
[
  {
    "id": "plan_basic",
    "name": "Basic",
    "monthlyPriceUsd": 19,
    "yearlyPriceUsd": 190
  }
]
```

Errors:

- `401` unauthenticated.

### POST /billing/checkout

Auth: Clerk required.

Role: `OWNER`.

Request:

```json
{
  "businessId": "bus_123",
  "planId": "plan_pro",
  "interval": "monthly"
}
```

Response:

```json
{
  "checkoutUrl": "https://checkout.stripe.com/example"
}
```

Errors:

- `403` owner role required.
- `404` plan or business not found.

### POST /billing/portal

Auth: Clerk required.

Role: `OWNER`.

Request:

```json
{
  "businessId": "bus_123"
}
```

Response:

```json
{
  "portalUrl": "https://billing.stripe.com/example"
}
```

Errors:

- `403` owner role required.
- `404` subscription not found.

### POST /billing/stripe/webhook

Auth: Stripe signature required.

Request: raw Stripe webhook body.

Response:

```json
{
  "received": true
}
```

Errors:

- `400` invalid signature or unsupported event.

## Admin

### GET /admin/businesses

Auth: Clerk required plus backend admin verification.

Response:

```json
[
  {
    "id": "bus_123",
    "name": "Tavrix Cafe",
    "slug": "tavrix-cafe",
    "status": "ACTIVE"
  }
]
```

Errors:

- `403` not an internal admin.

### GET /admin/subscriptions

Auth: Clerk required plus backend admin verification.

Response:

```json
[
  {
    "businessId": "bus_123",
    "businessName": "Tavrix Cafe",
    "planName": "Pro",
    "status": "ACTIVE"
  }
]
```

Errors:

- `403` not an internal admin.

### GET /admin/logs

Auth: Clerk required plus backend admin verification.

Response:

```json
[
  {
    "id": "log_123",
    "businessId": "bus_123",
    "userId": "usr_123",
    "action": "business.created",
    "createdAt": "2026-06-08T00:00:00.000Z"
  }
]
```

Errors:

- `403` not an internal admin.

### PATCH /admin/businesses/:id/status

Auth: Clerk required plus backend admin verification.

Request:

```json
{
  "status": "SUSPENDED"
}
```

Response:

```json
{
  "id": "bus_123",
  "status": "SUSPENDED"
}
```

Errors:

- `400` invalid status.
- `403` not an internal admin.
- `404` business not found.
