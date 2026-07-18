# Menu Management Backend Data Contract

Source authority: [`docs/05-api-contract.md`](../../../../05-api-contract.md). This mapping uses existing documented routes only and does not define new endpoints.

| Menu concept | Existing contract | Classification | Mapping and limitation |
| --- | --- | --- | --- |
| Business-scoped category list | `GET /businesses/:id/categories` | Available | Returns categories for the requested business with active-membership enforcement. `includeInactive=true` is the documented opt-in for archived categories. |
| Business-scoped product list | `GET /businesses/:id/items` | Available | Returns items for the requested business. Owner management must deliberately request documented inactive/unavailable records when they must remain visible. |
| Category creation/edit | `POST /businesses/:id/categories`; `PATCH /categories/:id` | Available | Role-gated real mutations exist. Archive/restore and reorder behavior are separately documented; success must use the real response. |
| Product creation/edit | `POST /businesses/:id/items`; `PATCH /items/:id` | Available | The contract supports category association, localized fields, price, image URL, availability, and ordering fields documented by the API. |
| Product availability | Item `isAvailable`; `PATCH /items/:id`; `GET /businesses/:id/items?includeInactive=true` | Available | Public menus hide unavailable items. Owner management can request unavailable/archived items; the UI must not infer availability. |
| Menu readiness | `GET /businesses/:id/dashboard-summary` → `onboardingHints` | Available | `hasCategories`, `hasItems`, `hasPublicMenuReady`, and the recommended next step support the empty and ready states. A request failure is not “not ready.” |
| Public preview URL | `GET /businesses/:id/app-context`; `GET /businesses/:id/public-link`; `GET /public/m/:slug` | Available | Authenticated contracts provide a real path/URL, and the public route returns only active public records. The backend provides a URL payload, not a QR image. |

## Workspace and tenant rules

- Never select `businesses.first` or any other list position as the active business.
- Active business context must be authoritative before any category, item, readiness, or preview request starts.
- W2A tenant-isolation rules remain mandatory: logout/workspace change clears lists, selected category, search, errors, pending mutations, and prior results.
- Category and item IDs used by mutations must belong to the same authoritative active business; cross-business access must fail closed.
- “Available” describes the documented backend contract, not mobile implementation status.

## Contract gaps relevant to this screen

- No server-side product-search query is documented. Search may filter a successfully loaded real list, but must not pretend an undocumented endpoint exists.
- Image upload or generated-media behavior is not defined by these menu contracts. A plain `imageUrl` field does not authorize upload or asset-generation features.
