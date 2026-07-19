# Waflo Repository Instructions

These instructions apply across the repository. Nested `AGENTS.md` files add
only rules specific to their subtree.

## Product and authority

- Waflo is an Arabic-first, RTL SaaS for Iraqi restaurants.
- Keep owner, staff, customer, and platform roles distinct.
- Implement only real next actions. Unsupported features must be disabled,
  omitted, or clearly informational.
- Use these sources instead of copying their contents into prompts:
  - Product doctrine: `docs/product/WAFLO_PRODUCT_UX_V2.md` and
    `docs/product/WAFLO_GUIDED_WALKTHROUGH_V1.md`
  - API truth: `docs/05-api-contract.md`
  - Mobile V3 design truth: `docs/design/stitch/waflo-mobile-redesign/`

## Security and tenant isolation

- The active workspace must come from authoritative membership and role data.
- Never select a business by list position. Fail closed when multi-business
  state is ambiguous.
- Never retain or display stale cross-session or cross-business data.
- W2A workspace and scanner-context isolation is complete; preserve it and its
  late-result protections as a regression invariant.
- Customer tenant isolation remains a release blocker before Loyalty release.

## Backend honesty

- A loading failure is not an empty or zero state.
- Show success only after backend confirmation.
- Do not fake previews, uploads, drafts, notifications, billing, QR behavior,
  or Loyalty mutations.

## Git and scope

- Use one writing agent per bounded branch and implementation slice.
- Stage explicit reviewed paths only; never use `git add .`.
- Avoid unrelated formatting and hidden backend, API, or schema expansion.
- Do not commit when the task explicitly requires human review first.

## Human gates

- Codex cannot issue `HUMAN_VISUAL_PASS`.
- Human approval is required for visual acceptance, merge, deployment,
  migrations, live financial actions, customer notifications, and store
  submissions.
