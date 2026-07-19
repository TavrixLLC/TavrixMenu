# Waflo Mobile UI V3 Screen Index

Status in this index is intentionally conservative. An approved visual means that exact state has a human-approved visual reference; it does not mean implementation or post-implementation visual QA has started.

| Screen | Canonical state | Approved visual | States | Interaction contract | Backend mapping | Additional visual status | Implementation status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 01 Owner Dashboard | Returning owner / one category / zero products | Yes | Yes | Yes | Yes | Product-populated state is documented only | Not started |
| 02 Menu Management | Empty and populated category states | Yes — empty and populated | Yes | Yes | Yes | Loading, error, and search-empty visuals are documented only | Not started |
| 03 Product Editor | Create Product | Yes — Create Product | Yes | Yes | Yes | Edit visual missing; validation and responsive behavior specified | Not started |

## Canonical approved references

- Owner Dashboard: [01-owner-dashboard/returning-zero-products-approved.png](01-owner-dashboard/returning-zero-products-approved.png)
- Menu Management empty state: [02-menu-management/empty-approved.png](02-menu-management/empty-approved.png)
- Menu Management populated state: [02-menu-management/populated-approved.png](02-menu-management/populated-approved.png)
- Product Editor Create Product: [03-product-editor/create-product-approved.png](03-product-editor/create-product-approved.png)

## Product Editor specification status

| State | Approved visual | States | Validation contract | Interaction contract | Backend mapping | Responsive rules | Implementation status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Create Product | Yes | Yes | Yes | Yes | Yes | Yes | Not started |
| Edit Product | Missing | Documented only | Reuses applicable documented validation | Documented only | Partial read / available update | Reuses applicable rules | Not started |

Edit Product has no approved visual; its behavior is documented only, and implementation is not started.

## Menu Management visual status

| State | Visual status |
| --- | --- |
| Empty / one category / zero products | Approved |
| Populated | Approved |
| Loading | Documented only |
| Error | Documented only |
| Search empty | Documented only |

## Next project task

Waflo Mobile UI V3 Visual System Lock and Scenario Alignment Review

## Upcoming screens

The following screens are future work. Their presence here does not define features, states, data, or visual direction:

- authentication
- guided onboarding
- category management
- customer menu preview
- QR publish/share
- menu appearance
- loyalty program builder
- loyalty card designer
- customer CRM
- notifications
- work locations
- staff management
- staff scanner
- business settings
- billing
- account/logout
