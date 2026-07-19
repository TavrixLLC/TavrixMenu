# Product Editor Backend Data Contract

Primary contract authority: [`docs/05-api-contract.md`](../../../../05-api-contract.md). Source mappings are used read-only to clarify validation, defaults, storage, and media support that the canonical document does not fully describe. No route is invented here.

## Classification meanings

- `AVAILABLE`: current documented contract and source support the required behavior.
- `PARTIAL`: supporting source or a broader route exists, but the canonical contract or end-to-end Product Editor flow is incomplete.
- `MISSING`: no current field, state, or route supports the behavior.
- `DEFERRED`: intentionally reserved for later product/backend work and not currently actionable.

| Field or action | Existing contract/source mapping | Classification | Product Editor rule |
| --- | --- | --- | --- |
| Authoritative active business identifier | `GET /businesses/:id/app-context` | `AVAILABLE` | Use only the W2A authoritative active workspace; never choose a business by list position. |
| Selected category identifier | `GET /businesses/:id/categories`; create service category/business assertion | `AVAILABLE` | A passed or newly selected category must be a real category belonging to the same active business. |
| Product name | `CreateItemDto.nameAr`; `POST /businesses/:id/items` | `AVAILABLE` | Required, non-empty string; current maximum is 160 characters. |
| Product description | Optional localized description fields in `CreateItemDto` | `AVAILABLE` | Optional; current maximum is 1000 characters. |
| Price | `CreateItemDto.price`; `POST /businesses/:id/items` | `AVAILABLE` | Required non-negative decimal string with up to two fractional digits. Do not use binary floating-point arithmetic. |
| Currency and storage representation | Active business currency; Prisma `MenuItem.price` as `Decimal(10,2)` | `AVAILABLE` | The approved scenario is IQD. Submit major-unit decimal text exactly; do not infer cents or multiply by 100. |
| Availability | Optional create boolean; service fallback and schema default are `true` | `AVAILABLE` | The form explicitly reflects and submits the user's chosen value; no separate mutation is needed during create. |
| Optional product media reference | Optional `imageUrl` in create/update DTOs, maximum 500 characters | `AVAILABLE` | Omit or send the real confirmed upload URL; never send a local path, raster asset, or generated placeholder URL. |
| Product create mutation | `POST /businesses/:id/items` | `AVAILABLE` | Role-gated, business-scoped create. The service validates that the category belongs to the same business. |
| Product read for future edit mode | `GET /businesses/:id/items` plus full source `mapItem` mapping | `PARTIAL` | A business-scoped list can provide a real record, but no dedicated authenticated item-by-record read route is documented. Edit must not use the public route or cross-business cache. |
| Product update for future edit mode | `PATCH /items/:id` | `AVAILABLE` | Source resolves the existing item business, checks role, and revalidates a changed category against that business. Edit visual approval is still deferred. |
| Draft support | No draft field in `CreateItemDto` or `MenuItem`, and no draft route in menu/media modules | `MISSING` | Save as Draft is disabled or omitted. Do not persist an unavailable product as a fake “draft” because availability is a different domain state. |
| Image upload support | Source route `POST /businesses/:id/media/uploads` with `MENU_ITEM_IMAGE`; not listed in `docs/05-api-contract.md` | `PARTIAL` | Backend source supports authorized JPEG/PNG/WebP upload, normalization, and a returned URL, but canonical API documentation and Product Editor integration are incomplete. |

## Source-backed limits and behavior

- Create/update DTOs: `apps/api/src/modules/menu/dto/create-item.dto.ts` and `update-item.dto.ts`.
- Business/category enforcement and availability default: `apps/api/src/modules/menu/menu.service.ts`.
- Price storage: `apps/api/prisma/schema.prisma` (`Decimal(10,2)`).
- Media types, size, normalization bounds, and route: `apps/api/src/modules/media/`.
- Current menu-item media source accepts JPEG, PNG, or WebP up to 5MB, normalizes to WebP, and limits within 1600×1200.

## Mandatory isolation and scope rules

- No `businesses.first` or other list-position workspace selection.
- Category belongs to the authoritative active business.
- Product creation is business-scoped.
- No cross-business category or product record identifiers.
- No stale Owner A category, product, form, image, error, or mutation result may appear under Owner B.
- W2A workspace isolation remains mandatory through initial state, image selection, submission, error, and navigation.
- No global Customer behavior is introduced by Product Editor.
- The Customer tenant-isolation release blocker remains separate and unresolved by this design task.
