# Owner Dashboard States

Only `RETURNING_OWNER_ZERO_PRODUCTS` currently has an approved visual. Other states below define honest behavior and do not authorize fabricated screenshots.

## `LOADING`

- The shell and header may use restrained skeletons while the authoritative active business and dashboard data load.
- Never show fake metric values or a sample business name.
- Actions requiring business data, permissions, public-menu readiness, loyalty state, customers, or entitlements remain disabled.
- A prior workspace's data, error, action result, or business identity must be cleared before loading the next workspace.

## `ERROR`

- Show an honest inline error with a retry action.
- Do not retain or flash stale prior-business data.
- Do not replace a failed request with fake zero counts or an empty-activity state that suggests loading succeeded.
- Keep dependent actions disabled until the required data is recovered.

## `RETURNING_OWNER_ZERO_PRODUCTS`

- The authoritative active business has exactly one real category and zero products.
- There is no active loyalty program.
- The approved scenario has zero customers and genuinely empty recent activity.
- Display zero customers or empty activity only when an authoritative contract proves those facts; until then, show the metric or section as unavailable rather than faking success.
- The primary next action is `إضافة منتج` for the existing category.
- `فتح المنيو` is unavailable until a real public menu is ready.
- Notification and customer-dependent actions are disabled with helper text.

Approved visual: [returning-zero-products-approved.png](returning-zero-products-approved.png).

## `RETURNING_OWNER_WITH_PRODUCTS`

- Behavior is documented only; there is no approved visual for this state.
- All metrics come from the backend for the authoritative active business.
- Product, category, menu-readiness, loyalty, customer, and activity sections must distinguish unavailable data from real zero values.
- The recommended next action depends on the real menu state, permissions, public route, and product availability; it is not always “add product.”

## `BILLING_OR_ENTITLEMENT_ISSUE`

- Show an honest informational state without implying that a subscription or entitlement is active.
- Explain which capability is unavailable only when a real entitlement response supports that explanation.
- Do not implement entitlement-gated success behavior until an authoritative entitlement contract exists.
- Preserve navigation to safe, available areas; do not fabricate checkout, portal, or upgrade results.
