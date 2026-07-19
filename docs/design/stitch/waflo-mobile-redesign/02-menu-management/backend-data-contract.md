# Menu Management Backend Data Contract

Source authority: [`docs/05-api-contract.md`](../../../../05-api-contract.md). This mapping uses existing documented routes only and does not define new endpoints.

| Populated-screen field or action | Existing contract | Classification | Mapping and limitation |
| --- | --- | --- | --- |
| Authoritative active business | `GET /businesses/:id/app-context`; `GET /businesses/:id/dashboard-summary` | Available | Both expose the requested business under active-membership enforcement. The request business must come from W2A authoritative workspace context. |
| Business-scoped category list | `GET /businesses/:id/categories` | Available | Returns categories for the requested business. `includeInactive=true` is the documented opt-in for archived categories. |
| Selected category identifier | Client selection from a record returned by `GET /businesses/:id/categories` | Partial | The API exposes real category identifiers but does not expose a server-owned “selected category.” Client state must preserve an explicit real selection and must not use unordered-list position as authority. |
| Business/category-scoped product list | `GET /businesses/:id/items` | Partial | The documented route is business-scoped and returns each item's category association; no category query is documented. Filter the real loaded business list by the selected real category. Request `includeInactive=true` when unavailable owner-visible records are required. |
| Product name | `GET /businesses/:id/items` → localized name fields | Available | Render the supported localized field from the real item record; never copy a name from the raster. |
| Product description | Item create contract and public menu response include localized descriptions | Partial | The documented owner `GET /businesses/:id/items` response does not guarantee description fields. Do not populate owner cards from raster samples or an invented route. |
| Product price and currency | `GET /businesses/:id/items` → `price`; app context/dashboard summary → business `currency` | Available | Combine the real item price with the authoritative active business currency. Do not hard-code IQD when the business uses another currency. |
| Optional product media | Item create contract and public menu response include `imageUrl` | Partial | The documented owner item-list response does not guarantee media, and no merchant upload contract is documented here. Use an approved native missing-photo treatment when media is absent. |
| Availability state | Item `isAvailable`; `GET /businesses/:id/items?includeInactive=true` | Available | Public menus hide unavailable items. Owner management deliberately includes unavailable/archived records and renders confirmed state. |
| Category creation/edit | `POST /businesses/:id/categories`; `PATCH /categories/:id` | Available | Role-gated real mutations exist. Archive/restore and reorder behavior are separately documented; success must use the real response. |
| Product edit mutation | `PATCH /items/:id` | Available | Send only documented editable fields for a real product belonging to the authoritative business; success follows the confirmed response. |
| Availability mutation | `PATCH /items/:id` with documented availability field | Available | Disable repeat mutation while pending. On failure restore or refresh the last confirmed backend state. |
| Menu readiness | `GET /businesses/:id/dashboard-summary` → `onboardingHints` | Available | `hasCategories`, `hasItems`, `hasPublicMenuReady`, and the recommended next step support the empty and ready states. A request failure is not “not ready.” |
| Public preview URL | `GET /businesses/:id/app-context`; `GET /businesses/:id/public-link`; `GET /public/m/:slug` | Available | Authenticated contracts provide a real path/URL, and the public route returns only active public records. The backend provides a URL payload, not a QR image. |
| Search | No server-side product-search query is documented | Partial | Search may filter supported fields on a successfully loaded real product list for the selected category. It must not pretend an undocumented route exists. |

## Workspace and tenant rules

- Never select `businesses.first` or any other list position as the active business.
- Active business context must be authoritative before any category, item, readiness, or preview request starts.
- W2A tenant-isolation rules remain mandatory: logout/workspace change clears lists, selected category, search, errors, pending mutations, and prior results.
- Never retain cross-business cached records or show stale Owner A products, categories, availability, search results, or errors under Owner B.
- Category and item IDs used by mutations must belong to the same authoritative active business; cross-business access must fail closed.
- “Available” describes the documented backend contract, not mobile implementation status.

## Contract gaps relevant to this screen

- Image upload or generated-media behavior is not defined by these menu contracts. A plain `imageUrl` field does not authorize upload or asset-generation features.
