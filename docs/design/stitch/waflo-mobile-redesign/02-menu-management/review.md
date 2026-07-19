# Menu Management Review Record

## Approved directions

The empty, one-category, zero-product direction in [empty-approved.png](empty-approved.png) is approved as the reference for that exact state. It establishes an Arabic-first RTL management screen with a readiness summary, visible category selection, full-width search, a strong first-product call to action, an explicitly disabled customer preview, and five equal navigation tabs.

[populated-approved.png](populated-approved.png) is authoritative for the populated state. It adds real category selection, searchable owner-visible product cards, availability and edit controls, product creation, and the same five-tab shell. The sample product data and embedded food photography are visual reference content, not production data or assets.

## Known decisions and open visual work

- `إضافة أول منتج` is primary; category editing is secondary.
- The customer preview is fully muted and explained while unavailable.
- Category selection reflects real backend records only.
- Search does not convert an empty result into the onboarding empty state.
- The selected bottom-navigation treatment follows `DESIGN.md` consistently across Menu, Dashboard, and every other shell screen.
- Disabled preview must use the canonical disabled style from `DESIGN.md`.
- The populated product grid may reflow responsively.
- Embedded food photographs are reference-only and may not be extracted from the raster.
- Sample product names, descriptions, prices, counts, and availability are not production data.
- No orders or sales behavior is approved.
- Loading and error visuals are documented only and remain subject to future human review.

## Known implementation concerns

- Two-column product cards may become too narrow on smaller devices.
- Implementation may use one-column cards below an appropriate content-driven width.
- Long Arabic product names and descriptions must truncate or reflow safely without hiding critical state.
- Availability controls must remain accessible and cannot rely on color alone.
- Edit actions must provide at least 48px touch targets.

## Acceptance boundary

Implementation has not started. Human visual implementation QA remains required at supported widths and on representative devices. Codex may report mismatches but must not declare `HUMAN_VISUAL_PASS`.
