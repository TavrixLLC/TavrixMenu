# AI Recommendations

AI recommendations are a future module. Do not build the AI system before Sprint 1 and Sprint 2 acceptance criteria are done.

## Goal

Suggest products that pair well with a selected product. Customer web displays suggestions as product cards with:

- Image
- Name
- Price
- Short reason

Example:

- Turkish Coffee -> Tamriya
- Turkish Coffee -> Baklava

## Product Rules

- AI must only recommend existing menu items.
- AI must return product IDs, not invented products.
- Suggestions should be generated and stored ahead of time.
- Suggestions should not be generated per customer click.
- Owner or manager can approve or reject suggestions.
- Customer web displays approved suggestions only.
- Unavailable products must not be shown.

## Future Flow

1. Backend reads a business menu.
2. AI suggests pairings between existing menu item IDs.
3. Backend stores suggested pairings as pending.
4. Owner or manager reviews suggestions.
5. Approved pairings are returned by public API.
6. Customer web displays approved pairings on product pages.

## Future Models

- `MenuItemPairing`
- `aiTagsJson` on menu items or a related table
- `AIUsageLog`

## API Shape Later

Public endpoint:

```text
GET /public/m/:slug/items/:itemId/pairings
```

Admin/business endpoint later:

```text
GET /businesses/:id/ai/pairings
PATCH /ai/pairings/:id
```

Do not expose AI prompts, internal scores, or rejected suggestions to customers.
