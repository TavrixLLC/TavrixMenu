# Mobile Menu Template Picker Contract

Flutter implementation is not included in this branch. Mobile should integrate the public menu template picker against the same API contract used by admin-web.

## Endpoints

- `GET /menu-templates`
  - Returns enabled Waflo-managed templates.
  - Use `displayName`, `description`, `bestFor`, `version`, `status`, `enabled`, `isDefault`, `preview.previewColors`, `preview.previewLayout`, and `supportedFeatures`.
  - `preview.thumbnailUrl`, `preview.mobilePreviewUrl`, and `preview.desktopPreviewUrl` are currently `null` unless Waflo publishes production-safe preview assets later.
  - Do not use `/dev/menu-templates/*` from the catalog. That route is dev/QA-only and is not a mobile/admin preview contract.
  - Do not hardcode template IDs in Flutter except as a defensive fallback for `waflo-warm`.

- `GET /businesses/:businessId/appearance`
  - Requires an active business membership.
  - Returns `businessId`, `menuTemplateId`, `menuThemeOverrides`, `effectiveTemplateId`, `fallbackApplied`, and `defaultTemplateId`.
  - STAFF can view this endpoint.

- `PATCH /businesses/:businessId/appearance`
  - OWNER only in the current role model.
  - Request body: `{ "menuTemplateId": "<template-id>" }`.
  - Unknown template IDs are rejected.
  - The update is scoped to the selected business.

## Preview Without Saving

Use the existing public menu URL with a query parameter:

`/m/:slug?previewTemplateId=<template-id>`

Rules:

- The `previewTemplateId` query is consumed by customer-web, not the API public menu endpoint.
- Opening this URL must not save changes.
- The page uses the same public menu data and CSS template contract as the saved public menu.
- Invalid preview IDs safely render the business effective template.
- Disabled or unknown template IDs must not render as previews.
- Do not send or display QR payloads, tokens, card references, transfer tokens, JWTs, phone numbers, email addresses, or other sensitive data.

## Suggested Screen Behavior

- Load catalog and current appearance in parallel.
- Show template cards or rows from API catalog metadata.
- Mark `effectiveTemplateId` as current.
- Use `preview.previewColors` and `preview.previewLayout` for a compact native preview.
- Provide an "Open full preview" action that opens `/m/:slug?previewTemplateId=<template-id>`.
- Keep the chosen template as a draft until the owner taps Save.
- Disable Save for STAFF and show a permission message.
- Show loading, success, validation error, unauthorized, forbidden, and network error states.

## Waflo-Managed Template Addition Flow

1. Add CSS under `apps/customer-web/app/styles/menu-templates/`.
2. Add metadata to `packages/menu-templates/manifest.cjs`.
3. Add preview metadata and thumbnail URLs when available.
4. Run API, customer-web, and admin-web tests/builds.
5. Confirm the template appears in `GET /menu-templates`.
6. Confirm admin/mobile can preview it without saving.
7. Confirm customer-web renders it through the same public menu HTML contract.

Normal business owners must not upload arbitrary CSS in this sprint.
