# Menu Management Review Record

## Approved direction

The empty, one-category, zero-product direction in [empty-approved.png](empty-approved.png) is approved as the reference for that exact state. It establishes an Arabic-first RTL management screen with a readiness summary, visible category selection, full-width search, a strong first-product call to action, an explicitly disabled customer preview, and five equal navigation tabs.

## Known decisions and open visual work

- `إضافة أول منتج` is primary; category editing is secondary.
- The customer preview is fully muted and explained while unavailable.
- Category selection reflects real backend records only.
- Search does not convert an empty result into the onboarding empty state.
- The selected bottom-navigation treatment must later match the Dashboard and every other shell screen.
- Disabled preview must use the canonical disabled style from `DESIGN.md`.
- A populated Menu Management visual is still required.
- Loading and error visuals are documented only and remain subject to future human review.

## Acceptance boundary

Implementation has not started. Human visual review is required after implementation at supported widths and on representative devices. Codex may report mismatches but must not declare `HUMAN_VISUAL_PASS`.
