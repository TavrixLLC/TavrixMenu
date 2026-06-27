# Media Upload MVP Runbook

Sprint 13 media upload is a pilot-safe replacement for asking owners to paste
image URLs manually.

## Scope

Supported upload purposes:

- `BUSINESS_LOGO`
- `BUSINESS_COVER`
- `MENU_ITEM_IMAGE`

Out of scope:

- Media library.
- Cropping editor.
- Gallery management.
- Drag-and-drop bulk upload.
- Customer uploads.
- Staff image management.

## Endpoint

`POST /businesses/{businessId}/media/uploads`

Authentication:

- Bearer token required.
- Active `OWNER` or `MANAGER` membership required.
- `STAFF` is forbidden.

Request:

- `multipart/form-data`
- `purpose`: one of the supported purposes.
- `file`: one image file.

Response:

```json
{
  "url": "https://api.waflo.app/uploads/business-media/menu-item-image/2026/06/example.webp",
  "contentType": "image/webp",
  "sizeBytes": 123456,
  "purpose": "MENU_ITEM_IMAGE"
}
```

The response never includes local filesystem paths, raw storage keys, bearer
tokens, card references, QR payloads, or customer PII.

## Validation

Allowed source formats:

- JPG/JPEG
- PNG
- WebP

Rejected formats:

- SVG
- GIF
- PDF
- HTML
- JavaScript
- executables
- ZIP/archive files
- unknown or corrupt files

Size limits:

- `BUSINESS_LOGO`: 2 MB
- `BUSINESS_COVER`: 5 MB
- `MENU_ITEM_IMAGE`: 5 MB

The API validates both client hints and decoded image content. Images are
normalized to WebP and metadata is stripped during re-encoding.

## Storage

Pilot storage driver:

- Local VPS filesystem.
- Default production root: `/opt/waflo/uploads`.
- Public URL prefix: `/uploads/`.
- Staging Docker mounts `/opt/waflo/uploads` into `api_staging`.

Operational requirement:

- Include `/opt/waflo/uploads` in staging/pilot backups.
- Do not commit uploaded files.
- Do not serve directory indexes.

## Frontend Assignment Flow

The upload endpoint only uploads and returns a safe public URL.

Business logo or cover:

1. Upload with `BUSINESS_LOGO` or `BUSINESS_COVER`.
2. Save the returned URL with `PATCH /businesses/{businessId}` as `logoUrl` or
   `coverUrl`.

Menu item image:

1. Upload with `MENU_ITEM_IMAGE`.
2. Save the returned URL with `PATCH /items/{itemId}` as `imageUrl`.

Existing role behavior still applies to the save step. For example, current
business profile updates are owner-only, while menu item updates use the
existing menu-manager policy.

## Smoke Checklist

- `GET /health` returns 200.
- Owner upload of a valid image succeeds.
- Manager upload succeeds where the manager has an active business membership.
- Staff upload returns forbidden.
- Invalid image is rejected.
- Oversized image is rejected.
- Returned URL loads publicly.
- Logs do not contain local paths, bearer tokens, QR payloads, card references,
  customer PII, or secrets.
