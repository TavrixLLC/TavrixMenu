# Product Editor Responsive Rules

- Support viewport widths from approximately 360px through 430px.
- Use natural vertical scrolling; never implement the approved raster as a fixed-height screen.
- Respect top and bottom safe areas.
- Do not show bottom navigation on this focused editor screen.
- Keep the back button reachable and at least 48px in both dimensions.
- Input labels, values, validation, and selection remain RTL.
- Large text scaling must not overlap controls, suffixes, switches, or actions.
- The image area may reduce in height on smaller devices while retaining a clear 48px picker target.
- Input and selector controls remain at least 48px high.
- The multiline description grows within sensible limits and remains internally scrollable or naturally expandable without forcing a fixed screenshot height.
- A sticky primary action may be used only when it does not hide fields, validation messages, or keyboard-accessible content.
- Keyboard appearance and inset handling must keep the final actions reachable.
- Price and currency remain readable together without overlap or ambiguous association.
- Validation messages wrap and reflow safely in Arabic.
- Unsaved-change confirmation remains accessible with large text and screen readers.
