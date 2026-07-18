# Menu Management Responsive Rules

- Support viewport widths from approximately 360px through 430px.
- Preserve hierarchy and RTL reading order rather than screenshot coordinates.
- Use the canonical 16px mobile page margin and maintain 48px minimum touch targets.
- The search field remains full-width.
- Horizontal category chips may scroll without creating horizontal page overflow or changing the selected real category.
- Readiness summary content and action groups may reflow vertically at narrow widths.
- Product cards may reflow vertically; labels, price, availability, and actions must remain readable.
- The empty illustration must scale within its container and must not force horizontal or vertical overflow.
- A sticky add action must not overlap the fixed bottom navigation.
- Bottom navigation remains five-tab, equal-width, fixed, and safe-area aware.
- Page content includes enough bottom inset that cards and actions never sit behind navigation.
- The page uses natural vertical scrolling and does not assume the approved raster's height.
- Top content respects the status-bar and device-cutout safe area.
