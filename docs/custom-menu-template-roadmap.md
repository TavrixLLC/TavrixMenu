# Custom Menu Template Roadmap

Sprint 12B prepares the public menu architecture for future custom merchant templates, but it does not allow normal business owners to upload arbitrary CSS.

## Current State

- Businesses can select an enabled public menu template by `menuTemplateId`.
- Existing businesses default to `waflo-warm`.
- Invalid, missing, disabled, or unknown template IDs fall back to `waflo-warm`.
- The public menu renderer emits one stable HTML contract.
- Templates are Waflo-managed CSS-first entries in `packages/menu-templates/manifest.cjs` plus customer-web CSS files.
- API exposes enabled template metadata through `GET /menu-templates`.
- Admin/mobile picker flows should consume the API catalog instead of maintaining separate template lists.
- `menuThemeOverrides` exists as optional future storage, but arbitrary owner-managed CSS is not enabled.

## Future Capabilities

The architecture should later support:

- Waflo-created private template IDs for one business or a group of businesses.
- Template versioning and controlled rollout.
- Merchant-specific CSS variables for reviewed brand customizations.
- Safe fallback if a private CSS file is disabled, missing, or fails review.
- Template status controls such as `enabled`, `disabled`, `private`, and `deprecated`.
- Preview and QA tooling before a custom template is made available.

## Security Model

Normal business owners must not upload arbitrary CSS in this sprint.

Future custom CSS should be:

- Waflo-managed.
- Reviewed before activation.
- Versioned.
- Sanitized.
- Scoped to the public menu HTML contract.
- Denied access to tokens, QR payloads, card references, transfer tokens, JWTs, phone numbers, emails, or customer PII.

Custom CSS must not:

- Fetch external scripts.
- Hide required wallet/legal/availability information.
- Spoof official Apple Wallet or Google Wallet badges.
- Exfiltrate data through URLs.
- Depend on private DOM details outside `docs/public-menu-html-contract.md`.
- Require a React component branch for visual-only changes.

## Proposed Future Flow

1. Waflo creates a private template manifest entry.
2. Waflo writes CSS against the public menu HTML contract.
3. Waflo adds preview metadata and thumbnails when available.
4. The template is previewed with representative menu data in mobile and desktop widths.
5. Accessibility and RTL checks are run.
6. The template is marked `enabled` for one or more approved businesses.
7. API catalog, admin/mobile picker, and customer-web rendering are verified.
8. If the template is disabled or missing, the public menu falls back to `waflo-warm`.

## Schema Direction

The current fields are enough for the first custom-template path:

- `menuTemplateId`: selected public or private template ID.
- `menuThemeOverrides`: optional reviewed JSON token overrides.

If more storage is required later, use additive migration-based changes. Do not rewrite menu data models for visual customization.

## Operational Notes

- Keep public menu URLs stable.
- Keep existing menu data compatible.
- Keep template CSS in source control or another reviewed Waflo-managed asset path.
- Keep release notes for template changes that affect merchant public menus.
- Keep a rollback path to `waflo-warm`.
