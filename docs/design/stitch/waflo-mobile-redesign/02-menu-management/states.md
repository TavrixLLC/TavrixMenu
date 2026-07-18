# Menu Management States

Only `EMPTY_ONE_CATEGORY` currently has an approved visual. Other states define product behavior without authorizing a fabricated screenshot.

## `LOADING`

- Category and product areas use restrained skeletons.
- Do not show fake category names, product names, prices, thumbnails, availability, or menu-readiness values.
- Product and preview actions remain disabled until authoritative business-scoped data loads.
- Clear prior-workspace menu data, selection, errors, and mutation results before the next workspace renders.

## `ERROR`

- Show an honest inline error and retry action.
- Preserve no cross-business stale data.
- Do not substitute the onboarding empty-state for a failed category or product request.
- Keep dependent mutations and preview disabled until recovery.

## `EMPTY_ONE_CATEGORY`

- The authoritative active business has exactly one category named `المقبلات`.
- The category has zero products.
- The primary action is `إضافة أول منتج`.
- Category modification remains secondary.
- Customer preview is unavailable until the real public menu is ready.
- Do not render product cards, fake prices, or fake thumbnails.

Approved visual: [empty-approved.png](empty-approved.png).

## `EMPTY_NO_CATEGORIES`

- Route the owner toward creating the first category.
- Do not present add-product as actionable before a real category exists and is selected.
- Product search and preview remain unavailable.
- Do not create a local-only category to advance the flow.

## `POPULATED`

- Behavior is documented only; an approved populated visual is missing.
- Products are real backend records for the authoritative business and selected category.
- Availability status must come from the backend.
- Do not invent thumbnails; use an honest no-image treatment when a record has no image.
- Unavailable products remain visible to the owner when the owner list requests the documented inactive/unavailable records.
- Customer preview is available only when a real public-menu route exists and the menu is actually ready.

## `SEARCH_EMPTY_RESULT`

- Distinguish a search with no matches from a category that has zero products.
- Preserve the selected real category and search context.
- Offer a clear way to clear the search.
- Do not display onboarding empty-state copy or imply the business has no products.
