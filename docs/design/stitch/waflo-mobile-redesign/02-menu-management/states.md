# Menu Management States

`EMPTY_ONE_CATEGORY` and `POPULATED` have approved visuals. Other states define product behavior without authorizing a fabricated screenshot.

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

- Approved visual: [populated-approved.png](populated-approved.png).
- The category list comes from the authoritative active business.
- The selected category is an authoritative selection from that real list, remains visually obvious, and is never chosen from unordered records by arbitrary position.
- The product list contains real business-scoped records filtered by the selected category.
- Search filters supported fields on real loaded records and clearing search restores the selected category product list.
- Availability status is backend-backed.
- Do not invent thumbnails; use an honest no-image treatment when a record has no image.
- Unavailable products remain visible to the owner when the owner list requests the documented inactive/unavailable records.
- Product edits require confirmed backend success.
- Do not show an optimistic success message before mutation success is confirmed.
- Customer preview is enabled only when a real public-menu route exists and the menu is actually ready.

## `POPULATED_SEARCH_RESULT`

- Show matching real products from the selected category only.
- Preserve the selected category and keep its selected treatment visually obvious.
- Allow clearing search to restore the selected category product list.
- Never replace populated search results with onboarding empty-state copy.

## `POPULATED_MUTATION_IN_PROGRESS`

- Prevent repeated availability or edit mutations while a mutation is pending.
- Show restrained progress on the affected control or product without blocking unrelated reading.
- Preserve the last confirmed backend state while the mutation is pending.
- On failure, restore the last confirmed state or refresh it from the backend and show an honest error.
- Do not display success until the backend confirms the mutation.

## `SEARCH_EMPTY_RESULT`

- Distinguish a search with no matches from a category that has zero products.
- Preserve the selected real category and search context.
- Offer a clear way to clear the search.
- Do not display onboarding empty-state copy or imply the business has no products.
