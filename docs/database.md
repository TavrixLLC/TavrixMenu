# Database

For the detailed current schema guide, see [04-database-schema.md](04-database-schema.md).

The initial Tavrix Menu schema includes users, businesses, business memberships, menu categories, menu items, plans, subscriptions, and audit logs.

## Why business_id

The platform starts with restaurants and cafes, but the database uses `business_id` instead of `restaurant_id` everywhere. This keeps the product ready for future business types such as bakeries, food trucks, hotel cafes, market counters, or other menu-driven businesses.

## Initial Relations

- `users` stores internal user records. A user can later be linked to Clerk through `clerk_user_id`.
- `businesses` stores each business profile and is owned by a user through `owner_id`.
- `business_users` connects users to businesses with roles such as owner, manager, and staff.
- `menu_categories` belong to a business.
- `menu_items` belong to a business and a menu category.
- `plans` define subscription tiers and future Stripe price mappings.
- `subscriptions` connect businesses to plans and future Stripe subscriptions.
- `audit_logs` optionally connect actions to a business and user.

The first schema pass is intentionally small. Loyalty, AI usage, wallet integrations, branches, customer profiles, and custom domains will be added later when those features are designed.
