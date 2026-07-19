# Waflo Mobile UI V3 Visual Foundation

This directory is the visual and behavioral source of truth for Waflo Mobile UI V3.

It contains approved raster references, screen-state definitions, interaction intent, mappings to existing backend contracts, responsive rules, and asset-provenance constraints. It is documentation and design evidence only; approved PNGs are not production assets or generated implementation specifications.

## Authority order

When sources disagree, use this order:

1. Approved visual for the exact screen and state
2. The screen's `states.md`
3. For form screens, the screen's `validation-contract.md`
4. The screen's interaction contract
5. The screen's backend data contract
6. The screen's responsive rules
7. [DESIGN.md](DESIGN.md)
8. Older design references

An approved visual does **not** override:

- security;
- tenant isolation;
- real backend behavior;
- accessibility;
- responsive behavior; or
- honest feature states.

## Review and implementation rules

- Human review owns final visual acceptance.
- Codex may report visual mismatches but must not declare `HUMAN_VISUAL_PASS`.
- No visual may introduce fake features or fake data.
- Unwired features must be disabled with an honest explanation or presented as informational only.
- A visual may show an action that the backend does not yet support.
- Unsupported actions must be disabled, omitted, or documented as unavailable.
- A raster visual never authorizes fake behavior.
- Success is shown only after a real operation succeeds.
- Missing future visuals are recorded as missing; they are never replaced with fabricated screenshots or placeholder PNGs.

## Benchmark boundary

Btaqa is a product benchmark only. Do not copy Btaqa branding, assets, text, layout, or proprietary visuals.

## Archive map

- [SCREEN_INDEX.md](SCREEN_INDEX.md) records approved and missing screen states.
- [01-owner-dashboard/](01-owner-dashboard/) contains the returning-owner dashboard foundation.
- [02-menu-management/](02-menu-management/) contains the approved empty and populated menu-management foundation.
- [03-product-editor/](03-product-editor/) contains the approved Create Product direction and form contracts.
