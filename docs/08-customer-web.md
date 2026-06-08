# Customer Web

`apps/customer-web` is the public customer menu website. It is the customer's main experience.

Customers do not download an app and do not use Clerk.

## Responsibilities

- Render public menu pages.
- Render product detail pages.
- Load public menu data from `GET /public/m/:slug`.
- Load product data from `GET /public/m/:slug/items/:itemId`.
- Show AI suggestion cards later from approved pairings.
- Support loyalty join flow later.
- Stay mobile-first because most traffic comes from QR scans.

## Routes

- `/`: basic public landing or placeholder.
- `/m/[slug]`: public business menu.
- `/m/[slug]/item/[itemId]`: public product detail.
- `/card/[cardToken]`: future customer loyalty card page.

## UI Rules

- Use placeholders if logo, cover, or item image is missing.
- Show Arabic text fields first when available.
- Handle loading, error, and not-found states.
- Product cards show image, name, price, description, and availability.
- Product detail shows image, name, price, description, and pairing CTA.
- Do not expose admin-only, business-only, subscription, audit, or staff data.

## AI Suggestion Cards

Current AI suggestion cards are mock UI. Later they should display only backend-approved suggestions.

Card fields:

- Image placeholder or item image.
- Item name.
- Price.
- Short reason.
- Button to view product.

Unavailable products must not be shown.

## API Integration Rule

Customer web should consume public endpoints only. It should not call authenticated business or admin endpoints.
