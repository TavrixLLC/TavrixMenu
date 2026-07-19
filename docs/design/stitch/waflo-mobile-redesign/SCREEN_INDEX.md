# Waflo Mobile UI V3 Screen Index

Status in this index is intentionally conservative. An approved visual means that exact state has a human-approved visual reference; it does not mean implementation or post-implementation visual QA has started.

## Archive review status

| Review | Status | Authority |
| --- | --- | --- |
| Visual System Lock | `VISUAL_SYSTEM_LOCKED_WITH_DOCUMENTED_GAPS` | [VISUAL_SYSTEM_LOCK.md](VISUAL_SYSTEM_LOCK.md) |
| Component contracts | Complete — 20 named contracts | [COMPONENT_CONTRACTS.md](COMPONENT_CONTRACTS.md) |
| Scenario alignment | Complete — no `SCENARIO_DRIFT` | [SCENARIO_ALIGNMENT_REVIEW.md](SCENARIO_ALIGNMENT_REVIEW.md) |
| Capability alignment | Complete — current evidence and blockers recorded | [CAPABILITY_MATRIX.md](CAPABILITY_MATRIX.md) |
| Future implementation sequence | Bounded — F1 through P3 | [IMPLEMENTATION_SEQUENCE.md](IMPLEMENTATION_SEQUENCE.md) |
| Flutter V3 implementation | Not started by this documentation task | Future explicitly scoped branches only |

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

Codex tooling foundation. This is not authorization to begin Flutter implementation.

Next branch: `codex/waflo-codex-tooling-v1`

## Known documented gaps

- Dashboard recent activity has no authoritative owner activity-feed contract.
- Customer total and active entitlement state cannot be inferred from current contracts.
- Edit Product has no approved visual and only a partial authenticated record-read path.
- Product image upload is source-backed but not canonical in `docs/05-api-contract.md` and is not integrated in Product Editor.
- Save as Draft, notification sending, and authoritative entitlement behavior are missing.
- Multi-business selection is not implemented; affected users continue to fail closed.
- Customer tenant isolation remains a backend release blocker before Loyalty release.
- Loading/error and several future-screen visuals remain documented behavior only and require later human visual review.

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
