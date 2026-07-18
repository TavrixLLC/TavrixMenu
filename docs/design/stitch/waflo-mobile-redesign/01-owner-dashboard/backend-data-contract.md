# Owner Dashboard Backend Data Contract

Source authority: [`docs/05-api-contract.md`](../../../../05-api-contract.md). This document maps the approved dashboard concept only to contracts that already exist. It does not create endpoints or broaden backend behavior.

All authenticated requests must use the authoritative active-business context established by W2A. A list position such as `businesses.first` is not an acceptable workspace selector.

| Visible data | Existing contract | Classification | Mapping and limitation |
| --- | --- | --- | --- |
| Active business | `GET /businesses/:id/app-context` and `GET /businesses/:id/dashboard-summary` | Available now | Both expose business identity for a requested business with active-membership enforcement. The `:id` must come from authoritative workspace selection. |
| Category count | `GET /businesses/:id/dashboard-summary` → `counts.activeCategories` / `counts.inactiveCategories` | Available now | Use the count that matches the UI label; do not combine active and inactive records silently. |
| Product count | `GET /businesses/:id/dashboard-summary` → item counts | Available now | Choose active, available, unavailable, or total semantics explicitly. The approved zero state must not be inferred from a failed request. |
| Loyalty program count/status | `GET /businesses/:id/loyalty/program` | Derivable now | The contract returns the active program or `null`; the current backend allows one active program per business. Dashboard summary does not include this state. |
| Customer count | No authoritative business customer-count contract in `docs/05-api-contract.md` | Missing backend contract | Loyalty memberships are not declared to be the authoritative total CRM customer count. Do not display a real-looking zero or total without a dedicated contract. |
| Recent activity | No business-scoped owner activity-feed contract in `docs/05-api-contract.md` | Missing backend contract | Admin logs are not a substitute for an owner dashboard feed. Empty activity may appear only when a future authoritative response proves it is empty. |
| Menu readiness | `GET /businesses/:id/dashboard-summary` → `onboardingHints` and `publicMenu`; `GET /businesses/:id/public-link` | Available now | `hasCategories`, `hasItems`, `hasPublicMenuReady`, recommended next step, and the public link support honest menu readiness. The backend provides a URL payload, not a QR image. |
| Entitlement state | Billing plan, checkout, and portal routes do not expose authoritative active entitlements | Missing backend contract | The billing/entitlement dashboard state is deferred until a real business entitlement contract exists. Never infer active subscription from plan availability or a portal URL. |

## Data-integrity rules

- A load failure is an error, not a zero value.
- Counts from different business scopes must never be combined.
- Data from a previous session or active business must be cleared before the next workspace renders.
- “Available now” describes backend documentation only; it does not claim the mobile UI is wired.
- Missing contracts remain unavailable or informational until backend authority exists.
