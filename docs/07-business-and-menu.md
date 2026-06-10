# Business and Menu

The business and menu module is Sprint 1 core product work.

## Business Flow

1. Owner signs in with Clerk.
2. Owner creates a business.
3. API creates the `Business` and an active `BusinessUser` with role `OWNER`.
4. Owner or manager creates categories and menu items.
5. Staff can view limited business information but cannot edit the menu.
6. Customer scans QR code and sees the public menu website.

## Business Roles

- Owner: full business access, billing, staff, menu, QR, and settings.
- Manager: menu and operational access, but not subscription ownership unless later allowed.
- Staff: limited access, scanner and own activity later.

Staff cannot edit menu items or categories.

## Business Fields

- `name`: public display name.
- `slug`: public URL identifier.
- `type`: initial values are restaurant or cafe, but the platform is more general.
- `logoUrl`: optional business logo.
- `coverUrl`: optional cover image.
- `currency`: default `IQD`.
- `language`: default `ar`.
- `city`: optional city.
- `status`: `ACTIVE`, `SUSPENDED`, or `PENDING`.

## Menu Categories

- Categories belong to one business.
- Categories are sorted by `sortOrder`.
- Public menu shows only categories where `isActive = true`.
- Arabic name is required.
- English name is optional.
- Sprint 1 delete archives categories by setting `isActive = false`.

## Menu Items

- Items belong to one business and one category.
- Items are sorted by `sortOrder`.
- Public menu shows only items where `isAvailable = true`.
- Price is stored as a Decimal in the database.
- `imageUrl` is optional.
- Arabic name is required.
- English name and descriptions are optional.
- Sprint 1 delete archives items by setting `isAvailable = false`.

## Demo Seed

Sprint 1 should add a seed business:

- Business: Tavrix Cafe
- Categories: Hot Drinks, Desserts
- Items: Turkish Coffee, Tamriya, Baklava

The public mock route can then be replaced with real API data from `GET /public/m/tavrix-cafe`.
