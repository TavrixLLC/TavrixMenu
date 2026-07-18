# Owner Dashboard Responsive Rules

- Support viewport widths from approximately 360px through 430px.
- Preserve visual hierarchy and task priority, not screenshot coordinates.
- Use the canonical 16px mobile page margin, reducing internal card padding only when necessary to preserve readable content.
- No element may create horizontal page overflow.
- The hero card may reflow vertically: illustration, progress, copy, and actions can change internal arrangement while preserving RTL reading order and the first-product action hierarchy.
- Hero actions may stack when equal-width side-by-side controls would violate touch-target or text requirements.
- Metric cards must preserve readable labels and values; use a responsive grid or vertical reflow rather than shrinking text below accessible sizes.
- Quick actions may reflow while retaining their relative priority and disabled treatment.
- The activity and loyalty sections grow naturally with localized text.
- The page uses natural vertical scrolling and never assumes the approved raster's height.
- Bottom navigation remains fixed, five-tab, equal-width, and safe-area aware.
- Scrollable content includes enough bottom inset that it never sits behind navigation.
- Top content respects the status-bar and device-cutout safe area.
