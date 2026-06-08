# API Contract

This file is the working API plan. The only implemented endpoint in the foundation is `GET /health`; the rest are planned for Sprint 1 and later.

Once Flutter or customer web depends on an endpoint, keep it backward compatible. Add fields without removing or renaming existing fields. Breaking changes require coordination across the team.

## Conventions

- Authenticated requests use `Authorization: Bearer <clerk-token>`.
- Customers do not authenticate.
- Business routes require a valid Clerk token and internal business membership.
- Owner-only routes require `BusinessUser.role = OWNER` unless documented otherwise.
- All errors use a consistent JSON shape.

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

Request: none.

Response:

```json
{
  "id": "usr_123",
  "clerkUserId": "user_abc",
  "name": "Owner Name",
  "email": "owner@example.com",
  "businesses": [
    {
      "businessId": "bus_123",
      "role": "OWNER",
      "status": "ACTIVE"
    }
  ]
}
```

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
  "slug": "tavrix-cafe",
  "type": "cafe",
  "city": "Baghdad",
  "currency": "IQD",
  "language": "ar"
}
```

Response:

```json
{
  "id": "bus_123",
  "name": "Tavrix Cafe",
  "slug": "tavrix-cafe",
  "type": "cafe",
  "status": "ACTIVE"
}
```

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
    "role": "OWNER",
    "status": "ACTIVE"
  }
]
```

Errors:

- `401` unauthenticated.

### PATCH /businesses/:id

Auth: Clerk required.

Role: `OWNER` or `MANAGER`.

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
  "status": "ACTIVE"
}
```

Errors:

- `401` unauthenticated.
- `403` missing business role.
- `404` business not found.

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
- `409` category has items and cannot be deleted until moved or archived.

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

## Public

### GET /public/m/:slug

Auth: public.

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
      "items": [
        {
          "id": "item_123",
          "nameAr": "قهوة تركية",
          "nameEn": "Turkish Coffee",
          "price": "4500.00",
          "imageUrl": null,
          "isAvailable": true
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
  "isAvailable": true
}
```

Errors:

- `404` business or item not found.

### GET /public/m/:slug/items/:itemId/pairings

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
