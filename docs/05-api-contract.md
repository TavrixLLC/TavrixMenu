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

Allowed settings fields:

- `name`
- `type`
- `city`
- `currency`
- `language`
- `logoUrl`
- `coverUrl`

No subscription, payment, custom domain, upload, or generated media fields are
accepted here.

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

### GET /businesses/:id/dashboard-summary

Auth: Clerk required.

Role: `OWNER`, `MANAGER`, or `STAFF`.

Purpose: compact owner workflow summary for Flutter/Admin-Web dashboards. Access
is limited to active members of the requested business; cross-business access is
forbidden.

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
  "currentUser": {
    "role": "OWNER",
    "permissions": {
      "canManageBusiness": true,
      "canManageMenu": true,
      "canManageMembers": true,
      "canViewMembers": true,
      "canViewPublicLink": true
    }
  },
  "counts": {
    "activeCategories": 2,
    "inactiveCategories": 0,
    "activeItems": 3,
    "inactiveItems": 0,
    "availableItems": 3,
    "unavailableItems": 0,
    "activeMembers": 1
  },
  "publicMenu": {
    "path": "/m/tavrix-cafe",
    "url": "http://localhost:3001/m/tavrix-cafe",
    "qrPayload": "http://localhost:3001/m/tavrix-cafe"
  },
  "onboardingHints": {
    "hasCategories": true,
    "hasItems": true,
    "hasPublicMenuReady": true,
    "recommendedNextStep": "SHARE_PUBLIC_MENU"
  }
}
```

`counts.availableItems` counts available items under active categories and is
the public-menu-ready item count. `activeItems` counts available item records for
the business, including records under inactive categories.

`onboardingHints.recommendedNextStep` values:

- `ADD_CATEGORY`: no active categories.
- `ADD_ITEM`: active categories exist but no available item under an active
  category exists.
- `SHARE_PUBLIC_MENU`: active categories, public items, and a public URL exist.
- `READY`: fallback when no setup action is recommended.

The `publicMenu.qrPayload` is the URL string. The backend does not generate QR
images.

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

Use `{ "isActive": true }` to restore an archived category through the existing
update endpoint.

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

### PATCH /businesses/:id/categories/reorder

Auth: Clerk required.

Role: `OWNER` or `MANAGER`. `STAFF` is forbidden.

Request:

```json
{
  "orders": [
    { "id": "cat_123", "sortOrder": 0 },
    { "id": "cat_456", "sortOrder": 1 }
  ]
}
```

Rules:

- All category IDs must belong to the requested business.
- IDs from another business are rejected.
- Duplicate IDs are rejected.
- `sortOrder` must be an integer greater than or equal to zero.
- Active and inactive categories are supported.

Response returns the updated categories ordered by `sortOrder`, then
`createdAt`, then `id`:

```json
[
  {
    "id": "cat_123",
    "businessId": "bus_123",
    "nameAr": "Hot Drinks",
    "nameEn": null,
    "sortOrder": 0,
    "isActive": true
  }
]
```

Errors:

- `400` invalid body, duplicate IDs, or IDs outside the business.
- `401` unauthenticated.
- `403` missing owner or manager role.
- `404` business not found.

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

Use `{ "isAvailable": true }` to restore an archived/unavailable item through
the existing update endpoint.

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

### PATCH /businesses/:id/items/reorder

Auth: Clerk required.

Role: `OWNER` or `MANAGER`. `STAFF` is forbidden.

Implemented because the current Prisma `MenuItem` model supports `sortOrder`.

Request:

```json
{
  "orders": [
    { "id": "item_123", "sortOrder": 0 },
    { "id": "item_456", "sortOrder": 1 }
  ]
}
```

Rules:

- All item IDs must belong to the requested business.
- IDs from another business are rejected.
- Duplicate IDs are rejected.
- `sortOrder` must be an integer greater than or equal to zero.
- Available and unavailable items are supported.

Response returns the updated items ordered by `sortOrder`, then `createdAt`,
then `id`:

```json
[
  {
    "id": "item_123",
    "businessId": "bus_123",
    "categoryId": "cat_123",
    "nameAr": "Turkish Coffee",
    "nameEn": null,
    "descriptionAr": "Traditional strong coffee.",
    "descriptionEn": null,
    "price": "3000",
    "imageUrl": null,
    "isAvailable": true,
    "sortOrder": 0
  }
]
```

Errors:

- `400` invalid body, duplicate IDs, or IDs outside the business.
- `401` unauthenticated.
- `403` missing owner or manager role.
- `404` business not found.

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

### GET /public/m/:slug/loyalty

Auth: public.

Purpose: return the public customer enrollment context for an active business
with an active stamp-card loyalty program. This is Sprint 7A customer-web
support only; it does not create wallet passes, QR scanner flows, payments, OTP,
points, cashback, tiers, campaigns, or notifications.

Response:

```json
{
  "business": {
    "id": "bus_123",
    "name": "Tavrix Cafe",
    "slug": "tavrix-cafe",
    "type": "cafe",
    "city": "Baghdad",
    "logoUrl": null,
    "coverUrl": null,
    "currency": "IQD",
    "language": "ar"
  },
  "loyaltyProgram": {
    "id": "loyalty_program_id",
    "name": "Tavrix Cafe Stamp Card",
    "description": "Collect stamps on coffee visits.",
    "stampGoal": 5,
    "rewardName": "Free coffee",
    "rewardDescription": "One free Turkish Coffee after 5 stamps.",
    "cardColor": "#111827",
    "accentColor": "#f59e0b",
    "logoUrl": null,
    "terms": "Reward is valid for dine-in orders only."
  },
  "enrollment": {
    "acceptsPhone": true,
    "acceptsEmail": true,
    "requiresOtp": false
  }
}
```

Rules:

- Business must be `ACTIVE`.
- Loyalty program must be active.
- Returns `404` when the slug is invalid, the business is inactive, or no active
  loyalty program exists.

### POST /public/m/:slug/loyalty/enroll

Auth: public.

Purpose: allow customer-web to enroll a customer into the active loyalty program
for the public business slug. This is a no-OTP pilot flow and is not
production-secure until OTP and abuse/rate limits are added.

Request:

```json
{
  "phone": "+9647700000000",
  "email": "customer@example.com",
  "name": "Demo Customer"
}
```

Rules:

- At least one of `phone` or `email` is required.
- Phone is trimmed. Email is trimmed and lowercased.
- Existing customers are reused by phone or email.
- If phone and email match different customers, the API returns `409`.
- Existing loyalty memberships are reactivated for the active program.
- A new public card access token is issued or rotated on every successful
  enrollment.
- The plaintext token is returned only in this response. Only a SHA-256 hash is
  stored in the database.
- No stamps are added. No reward is redeemed. No payment, wallet pass, QR
  scanner, or OTP flow is created.

Response:

```json
{
  "customer": {
    "name": "Demo Customer"
  },
  "business": {
    "name": "Tavrix Cafe",
    "slug": "tavrix-cafe",
    "logoUrl": null,
    "coverUrl": null
  },
  "program": {
    "name": "Tavrix Cafe Stamp Card",
    "stampGoal": 5,
    "rewardName": "Free coffee",
    "rewardDescription": "One free Turkish Coffee after 5 stamps."
  },
  "cardState": {
    "stampCount": 0,
    "stampGoal": 5,
    "rewardReady": false,
    "progressPercent": 0,
    "rewardName": "Free coffee",
    "programName": "Tavrix Cafe Stamp Card",
    "totalStampsEarned": 0,
    "totalRewardsRedeemed": 0
  },
  "cardAccess": {
    "token": "public_card_token",
    "cardUrlPath": "/public/loyalty/cards/public_card_token"
  }
}
```

Privacy:

- Public enrollment responses do not return raw phone or email.
- Public enrollment responses do not return internal `customerId` or
  `membershipId`.

Errors:

- `400` invalid body or missing phone/email.
- `404` active business or active loyalty program not found.
- `409` phone and email belong to different customers.

### GET /public/loyalty/cards/:token

Auth: public.

Purpose: return a limited web fallback loyalty card by public access token.

Rules:

- The token is required and length checked.
- The API hashes the token and looks up an active membership by stored hash.
- Business must be active and the loyalty program must be active.
- `publicAccessTokenLastViewedAt` is updated on successful view.
- Staff-only transaction data is not returned.
- Public card routes cannot add stamps or redeem rewards.

Response:

```json
{
  "business": {
    "name": "Tavrix Cafe",
    "slug": "tavrix-cafe",
    "logoUrl": null,
    "coverUrl": null
  },
  "program": {
    "name": "Tavrix Cafe Stamp Card",
    "stampGoal": 5,
    "rewardName": "Free coffee",
    "rewardDescription": "One free Turkish Coffee after 5 stamps.",
    "terms": "Reward is valid for dine-in orders only."
  },
  "customer": {
    "name": "Demo Customer"
  },
  "cardState": {
    "stampCount": 3,
    "stampGoal": 5,
    "rewardReady": false,
    "progressPercent": 60,
    "rewardName": "Free coffee",
    "programName": "Tavrix Cafe Stamp Card",
    "totalStampsEarned": 3,
    "totalRewardsRedeemed": 0
  }
}
```

Privacy:

- Public card responses do not return raw phone or email.
- Public card responses do not return internal business, program, customer, or
  membership IDs.

Errors:

- `400` token parameter validation failed.
- `404` invalid token, inactive membership, inactive business, or inactive
  loyalty program.

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

## Loyalty

Sprint 5 implements backend loyalty core only. Loyalty is a simple stamp-card
system for cashier-led/offline purchases. It does not create Google Wallet
passes, Apple Wallet passes, QR images, payment flows, cashback, tiers,
campaigns, notifications, or amount-based points.

All loyalty routes require Clerk auth and active business membership. `OWNER`
and `MANAGER` can configure the program. `OWNER`, `MANAGER`, and `STAFF` can
view memberships, enroll customers, add stamps, redeem rewards, and view
transactions.

Card state is returned as:

```json
{
  "stampCount": 3,
  "stampGoal": 7,
  "rewardReady": false,
  "progressPercent": 42,
  "rewardName": "Free meal",
  "programName": "Abdullah Grill Rewards"
}
```

`progressPercent` is `Math.floor((stampCount / stampGoal) * 100)` capped at
100.

### GET /businesses/:id/loyalty/program

Auth: Clerk required.

Role: `OWNER`, `MANAGER`, or `STAFF`.

Response: active loyalty program or `null`.

```json
{
  "id": "program_123",
  "businessId": "bus_123",
  "name": "Tavrix Cafe Stamp Card",
  "description": "Collect 5 coffee stamps and earn a free coffee.",
  "stampGoal": 5,
  "rewardName": "Free coffee",
  "rewardDescription": "One free Turkish Coffee after 5 stamps.",
  "isActive": true,
  "cardColor": "#111827",
  "accentColor": "#f59e0b",
  "logoUrl": null,
  "terms": "Reward is valid for one free Turkish Coffee.",
  "createdAt": "2026-06-13T00:00:00.000Z",
  "updatedAt": "2026-06-13T00:00:00.000Z"
}
```

Errors:

- `401` unauthenticated.
- `403` missing active business membership.
- `404` business not found.

### POST /businesses/:id/loyalty/program

Auth: Clerk required.

Role: `OWNER` or `MANAGER`.

Request:

```json
{
  "name": "Tavrix Cafe Stamp Card",
  "description": "Collect stamps on coffee visits.",
  "stampGoal": 5,
  "rewardName": "Free coffee",
  "rewardDescription": "One free Turkish Coffee after 5 stamps.",
  "isActive": true,
  "cardColor": "#111827",
  "accentColor": "#f59e0b",
  "logoUrl": null,
  "terms": "Reward is valid for dine-in orders only."
}
```

Rules:

- `name`, `stampGoal`, and `rewardName` are required.
- `stampGoal` must be an integer from 1 to 50.
- Sprint 5 allows one active loyalty program per business. Creating another
  active program returns `409`.
- This endpoint does not create wallet passes.

Errors:

- `400` invalid body.
- `401` unauthenticated.
- `403` missing owner or manager role.
- `409` duplicate active loyalty program.

### PATCH /businesses/:id/loyalty/program/:programId

Auth: Clerk required.

Role: `OWNER` or `MANAGER`.

Behavior: updates editable program fields. The program must belong to the
business. Reactivating a program is rejected if another active program already
exists for the business.

Errors:

- `400` invalid body.
- `401` unauthenticated.
- `403` missing owner or manager role.
- `404` loyalty program not found for this business.
- `409` duplicate active loyalty program.

### POST /businesses/:id/loyalty/enroll

Auth: Clerk required.

Role: `OWNER`, `MANAGER`, or `STAFF`.

Request:

```json
{
  "phone": "+9647700000000",
  "email": "customer@example.com",
  "name": "Demo Customer",
  "programId": "program_123"
}
```

Rules:

- At least one of `phone` or `email` is required.
- `programId` is optional when the business has exactly one active program.
- Existing customers are reused by phone or email.
- Existing customer/program memberships are returned and reactivated.
- No online payment or wallet pass is created.

Response:

```json
{
  "customer": {
    "id": "customer_123",
    "phone": "+9647700000000",
    "email": "customer@example.com",
    "name": "Demo Customer"
  },
  "membership": {
    "id": "membership_123",
    "businessId": "bus_123",
    "loyaltyProgramId": "program_123",
    "customerId": "customer_123",
    "stampCount": 0,
    "rewardReady": false,
    "totalStampsEarned": 0,
    "totalRewardsRedeemed": 0,
    "status": "ACTIVE"
  },
  "program": {
    "id": "program_123",
    "name": "Tavrix Cafe Stamp Card",
    "stampGoal": 5,
    "rewardName": "Free coffee"
  },
  "cardState": {
    "stampCount": 0,
    "stampGoal": 5,
    "rewardReady": false,
    "progressPercent": 0,
    "rewardName": "Free coffee",
    "programName": "Tavrix Cafe Stamp Card"
  }
}
```

Errors:

- `400` missing phone/email or ambiguous active program.
- `401` unauthenticated.
- `403` missing active business membership.
- `404` no active program or program not found.
- `409` phone and email belong to different customers.

### GET /businesses/:id/loyalty/memberships

Auth: Clerk required.

Role: `OWNER`, `MANAGER`, or `STAFF`.

Query:

- `search`: optional customer name, email, or phone contains search.
- `status`: optional `ACTIVE` or `INACTIVE`.
- `rewardReady`: optional boolean string.

Response: array of memberships with customer, program summary, and `cardState`.

Errors:

- `401` unauthenticated.
- `403` missing active business membership.

### GET /businesses/:id/loyalty/memberships/:membershipId

Auth: Clerk required.

Role: `OWNER`, `MANAGER`, or `STAFF`.

Behavior: returns a single business-owned membership, customer, program summary,
card state, and recent transactions.

Errors:

- `401` unauthenticated.
- `403` missing active business membership.
- `404` membership not found for this business.

### POST /businesses/:id/loyalty/memberships/:membershipId/stamps

Auth: Clerk required.

Role: `OWNER`, `MANAGER`, or `STAFF`.

Request:

```json
{
  "count": 1,
  "reason": "Coffee purchase"
}
```

Rules:

- `count` defaults to 1.
- `count` must be an integer from 1 to 10.
- Membership must belong to the business.
- Membership and program must be active.
- When `stampCount` reaches `stampGoal`, `rewardReady` becomes true.
- A `STAMP_ADDED` transaction is recorded.

Errors:

- `400` invalid count, inactive membership/program, or reward already ready.
- `401` unauthenticated.
- `403` missing active business membership.
- `404` membership not found for this business.

### POST /businesses/:id/loyalty/memberships/:membershipId/redeem

Auth: Clerk required.

Role: `OWNER`, `MANAGER`, or `STAFF`.

Request:

```json
{
  "reason": "Free coffee redeemed"
}
```

Rules:

- Only allowed when `rewardReady` is true.
- Increments `totalRewardsRedeemed`.
- Resets `stampCount` to 0 and `rewardReady` to false.
- Records a `REWARD_REDEEMED` transaction.

Errors:

- `400` reward is not ready.
- `401` unauthenticated.
- `403` missing active business membership.
- `404` membership not found for this business.

### GET /businesses/:id/loyalty/memberships/:membershipId/transactions

Auth: Clerk required.

Role: `OWNER`, `MANAGER`, or `STAFF`.

Behavior: returns loyalty transactions newest first. Membership must belong to
the requested business.

Errors:

- `401` unauthenticated.
- `403` missing active business membership.
- `404` membership not found for this business.

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
