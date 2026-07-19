# Waflo Mobile Instructions

Inherit all repository instructions from the root `AGENTS.md`.

## Mobile authority and UI

- Flutter UI is Arabic-first and RTL.
- Use `docs/design/stitch/waflo-mobile-redesign/` as Mobile UI V3 authority.
- Resolve an exact screen in this order: approved visual, `states.md`, form
  validation contract, interaction contract, backend data contract, responsive
  rules, `DESIGN.md`, then older references. Security, accessibility,
  responsive behavior, and backend truth override raster details.
- Focused editor screens have no bottom navigation. Top-level workspace screens
  use five equal tabs in the locked order.
- Do not use screenshot coordinates, raster-extracted UI, or hardcoded sample
  business, category, product, metric, or identity content.

## State and workspace safety

- Model real Cubit loading, error, empty, and success states; a failed load is
  never an empty state.
- Discard late asynchronous results after principal or workspace changes.
- Clear all workspace-scoped state before rendering a new principal/workspace.
- Never use `businesses.first` or any list-position fallback.
- Preserve W2A workspace/scanner-context isolation and its regression coverage.

## Product input constraints

- Use deterministic, integer-safe IQD parsing; never infer cents or use binary
  floating point for normal IQD entry.
- Do not assume image upload while support remains partial.
- Omit or disable Save as Draft; availability is not a draft state.

## Required checks

- Run `dart format` only on changed Dart files.
- Run `flutter analyze`.
- Run the relevant Flutter tests.
- Run `git diff --check`.
- Final UI implementation acceptance requires human visual QA.
