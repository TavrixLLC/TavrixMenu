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

## Populated-state rules

- Two-column product cards are allowed only when product content, availability, and actions remain readable.
- Use one-column cards on narrow widths or when large text scaling makes two columns unsafe.
- Do not use a fixed product-card height.
- Food images preserve a consistent aspect ratio without stretching or forcing card overflow.
- Arabic product names may wrap safely.
- Descriptions may use a controlled line limit with an accessible path to the full value where required.
- Prices remain visible and must not be displaced by long text.
- Availability and edit controls must not overlap and each interactive target remains at least 48px.
- Horizontal category chips may scroll while the selected category remains obvious.
- Add Product remains reachable without covering product content.
- Product content and controls must not be hidden behind bottom navigation.
- Safe-area support is required at top and bottom across approximately 360–430px widths.
