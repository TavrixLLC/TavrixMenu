# Waflo Mobile UI V3 Capability Matrix

Product-surface ownership is governed by
[`docs/product/WAFLO_PRODUCT_SURFACE_SPLIT_V1.md`](../../../product/WAFLO_PRODUCT_SURFACE_SPLIT_V1.md),
with the cross-surface current-state view in
[`WAFLO_CAPABILITY_OWNERSHIP_MATRIX_V1.md`](../../../product/WAFLO_CAPABILITY_OWNERSHIP_MATRIX_V1.md).
Advanced configuration and billing are Web Studio-first, Mobile remains
operations-first, customer menu and loyalty experiences belong to Customer Web,
and Platform Backend authorization and entitlement enforcement are
authoritative.

This matrix records present evidence, not intended future behavior. “UI approved visual” means a capability or entry intent appears in one of the four approved references; it does not mean the destination screen or Flutter implementation is approved.

## Status vocabulary

| Status | Meaning |
| --- | --- |
| `AVAILABLE` | The reviewed layer supports the named capability for the stated scope. |
| `PARTIAL` | Some supporting behavior exists, but a required contract, state, field, integration, or approved visual is incomplete. |
| `MISSING` | No reviewed support exists for the required behavior. |
| `DEFERRED` | Product/implementation intentionally postpones the behavior. |
| `BLOCKED` | The capability must not proceed because a safety or prerequisite gate is unresolved. |

## Matrix

| Capability | UI approved visual | UI documented | Frontend current support | Backend current support | Security readiness | Implementation decision | Release blocker yes/no |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Dashboard metrics | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | Rebuild the V3 presentation from real dashboard-summary counts. Unsupported customer, activity, or entitlement values stay unavailable. | No |
| Dashboard recent activity | `AVAILABLE` | `AVAILABLE` | `MISSING` | `MISSING` | `MISSING` | Keep unavailable or omit until a dedicated business-scoped owner activity contract exists; never infer empty from failure. | No — it can be omitted honestly |
| Add Product | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | Finalized M1P1 uses a focused V3 route gated by real business, category, permission, and submission state. Advanced editing remains separate. | No |
| Manage Categories | `AVAILABLE` | `AVAILABLE` | `PARTIAL` | `AVAILABLE` | `AVAILABLE` | Preserve real create/archive/restore/reorder foundations; separately define/approve the V3 create/edit workflow and never fabricate a category. | No |
| Public Menu Preview | `AVAILABLE` | `AVAILABLE` | `PARTIAL` | `AVAILABLE` | `AVAILABLE` | Enable only from a real public URL plus confirmed readiness. Remove/avoid fabricated fallback URLs and keep unavailable states muted. | No — it can remain disabled |
| Product image selection | `AVAILABLE` | `AVAILABLE` | `MISSING` | `PARTIAL` | `PARTIAL` | Defer the active picker field until native selection, permission handling, workspace clearing, and the upload handoff are integrated; otherwise omit/disable. | No — image is optional |
| Product image upload | `AVAILABLE` | `AVAILABLE` | `MISSING` | `AVAILABLE` | `PARTIAL` | The canonical media route exists, but Mobile integration remains a separately scoped V3-P2 task requiring native selection, lifecycle, handoff, and security review. | No — V3-P1 is image-free |
| Create Product | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | Finalized M1P1 provides deterministic whole-dinar IQD parsing, real category ownership, explicit availability, no draft, and no fake image upload. | No |
| Edit Product | `AVAILABLE` | `PARTIAL` | `MISSING` | `PARTIAL` | `PARTIAL` | Defer to V3-P3 after the authenticated record-load/update audit and separate edit visual approval; never load from the public route or stale cache. | Yes — required for the sellable menu-management MVP |
| Product availability | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | Finalized M1P1 provides a labeled control with backend-confirmed persistence, permission checks, and owner visibility of unavailable items. | No |
| Save as Draft | `AVAILABLE` | `AVAILABLE` | `MISSING` | `MISSING` | `MISSING` | Omit or fully disable. Availability is not a draft; provide no persistence or success feedback. | No — drafts are outside current capability |
| Create Loyalty Card | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | `BLOCKED` | Existing loyalty-program behavior is not visually approved by this archive. Keep the V3 entry gated and do not release Loyalty until the customer tenant-isolation blocker is resolved. | Yes — before Loyalty release |
| Scan Loyalty Card | `AVAILABLE` | `AVAILABLE` | `AVAILABLE` | `PARTIAL` | `BLOCKED` | Preserve camera/manual, business-role, and completed W2A workspace/scanner-context isolation foundations. Before release, resolve customer tenant isolation and complete the separate broader scanner/Loyalty security audit. | Yes — before Loyalty/scanner release |
| Send Notification | `AVAILABLE` | `AVAILABLE` | `MISSING` | `MISSING` | `MISSING` | Keep disabled, omitted, or informational with an honest explanation; do not simulate send or success. | No — it can remain unavailable |
| Billing/Entitlement states | `MISSING` | `AVAILABLE` | `DEFERRED` | `PARTIAL` | `PARTIAL` | Billing plans/actions do not establish active entitlements. Hide or show clearly staged information until authoritative entitlement state and real mobile actions exist. | No — defer without fake gating |
| Multi-business workspace selection | `MISSING` | `PARTIAL` | `BLOCKED` | `PARTIAL` | `AVAILABLE` | Continue the current fail-closed behavior. Add no list-position fallback; implement a separate authoritative selector before supporting multi-business users. | Yes — for multi-business user support |
| Customer tenant isolation | `MISSING` | `PARTIAL` | `BLOCKED` | `BLOCKED` | `BLOCKED` | Resolve and verify the backend tenant model/queries before Loyalty release; UI hiding cannot mitigate this release blocker. | Yes — backend release blocker before Loyalty |

W2A workspace and scanner-context isolation is complete and verified. Owner A → logout → Owner B clears workspace-scoped state, and late Owner A scanner results are discarded. Evidence: `f9abd774386a71b786459ab15bda329d1aadc3a0`.

Remaining pre-release scanner and Loyalty security work is a broader audit of staff authorization, mutation boundaries, customer and loyalty-card tenant ownership, token replay or rotation, rate limiting, abuse resistance, and end-to-end negative tests. This does not reopen W2A workspace or scanner-context isolation.

## Evidence basis

The classifications above were checked against:

- [Owner Dashboard backend mapping](01-owner-dashboard/backend-data-contract.md), [Menu backend mapping](02-menu-management/backend-data-contract.md), and [Product Editor backend mapping](03-product-editor/backend-data-contract.md);
- [Product Editor validation](03-product-editor/validation-contract.md) and all screen interaction/state contracts;
- the full canonical API contract in `docs/05-api-contract.md`;
- current Flutter dashboard, menu, QR, loyalty, scanner, subscription, workspace-session, and test source;
- current API menu, media, loyalty, scanner, business-access, DTO, and Prisma source; and
- the product/security decisions supplied for this lock, including mandatory W2A, multi-business fail-closed behavior, and the unresolved customer tenant-isolation gate.

## Important boundaries

- `AVAILABLE` backend support does not mean a V3 Flutter screen is implemented.
- `AVAILABLE` frontend support may describe the current pre-V3 behavior; it does not confer V3 visual approval.
- A `MISSING`, `PARTIAL`, or `DEFERRED` capability does not block the visual-system lock when it can be omitted or disabled honestly.
- The release-blocker column is scoped to the named capability/release. The lock itself remains `VISUAL_SYSTEM_LOCKED_WITH_DOCUMENTED_GAPS`.
