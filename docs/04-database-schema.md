# Database Schema

The current database schema is defined in `apps/api/prisma/schema.prisma`.

## Current Models

### User

Internal user record for business owners, managers, staff, and admins. A user can later be linked to Clerk with `clerkUserId`.

Key fields:

- `id`
- `clerkUserId`
- `name`
- `email`
- `phone`
- `status`

Relations:

- Owns businesses through `Business.ownerId`.
- Belongs to businesses through `BusinessUser`.
- Can be attached to audit logs.

### Business

A tenant in Tavrix Menu. The first market is restaurants and cafes, but the model is intentionally general.

Key fields:

- `id`
- `ownerId`
- `name`
- `slug`
- `type`
- `logoUrl`
- `coverUrl`
- `currency`
- `language`
- `city`
- `status`

Relations:

- Has one owner user.
- Has many business users.
- Has many menu categories.
- Has many menu items.
- Has many subscriptions.
- Has many audit logs.

### BusinessUser

Membership and role table between users and businesses.

Roles:

- `OWNER`
- `MANAGER`
- `STAFF`

Status:

- `ACTIVE`
- `INVITED`
- `DISABLED`

Permissions must come from this table, not Clerk metadata.

### MenuCategory

Menu grouping inside a business.

Key fields:

- `businessId`
- `nameAr`
- `nameEn`
- `sortOrder`
- `isActive`

Only active categories should appear publicly.

### MenuItem

Sellable menu item inside a business and category.

Key fields:

- `businessId`
- `categoryId`
- `nameAr`
- `nameEn`
- `descriptionAr`
- `descriptionEn`
- `price`
- `imageUrl`
- `isAvailable`
- `sortOrder`

Only available items should appear publicly.

### Plan

Subscription plan definition.

Key fields:

- `name`
- `stripeMonthlyPriceId`
- `stripeYearlyPriceId`
- `limitsJson`

### Subscription

Business subscription state.

Key fields:

- `businessId`
- `planId`
- `stripeCustomerId`
- `stripeSubscriptionId`
- `status`
- `currentPeriodEnd`

Subscription activation must be updated from verified Stripe webhooks.

### AuditLog

Record of sensitive or important actions.

Key fields:

- `businessId`
- `userId`
- `action`
- `metadataJson`
- `createdAt`

## Why business_id

The schema uses `business_id` instead of `restaurant_id` because Tavrix Menu should later support more than restaurants and cafes. Future tenants may include bakeries, tea houses, food trucks, hotel cafes, market counters, or other menu-driven businesses.

## Multi-Tenancy Rule

Every business-owned record must include `business_id` unless there is a strong reason not to. Every API query for business-owned data must filter by `business_id`.

## Future Models

Add these later when the feature is designed:

- `Branch`
- `QRCode`
- `QRScan`
- `MenuItemPairing`
- `LoyaltyProgram`
- `Customer`
- `CustomerLoyaltyCard`
- `LoyaltyTransaction`
- `Reward`
- `RewardRedemption`
- `WalletPass`
- `StaffInvite`
- `FileAsset`

Do not add these models before the sprint that owns the feature.
