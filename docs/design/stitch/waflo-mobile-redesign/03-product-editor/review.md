# Product Editor Review Record

## Approved direction

[create-product-approved.png](create-product-approved.png) is authoritative for Create Product. The approved direction is a focused single-screen editor with clean hierarchy, Arabic RTL, image-first structure, clear product fields, primary and secondary actions, and no bottom navigation.

The secondary draft action is visual reference content but is not currently supported by the backend. Behavioral contracts override its active appearance: implementation must disable or omit it.

## Known implementation refinements

- The back control should follow the final Waflo app-bar language.
- The category selector affordance must be unmistakable and expose only real active-business categories.
- The price field needs a clear numeric placeholder and unambiguous IQD treatment.
- Availability needs accessible state semantics and cannot rely on color or switch position alone.
- Image behavior requires selected, replacing, removing, uploading, and failed states.
- Final Arabic copy requires implementation review.
- Human visual QA is required after Flutter implementation at supported widths and text scales.

## Authority boundary

- No visual is approved yet for Edit Product.
- Edit Product should reuse the system where practical but remains documented behavior only.
- Implementation may improve accessibility and responsive behavior without copying screenshot coordinates.
- Sample values, category choices, and upload artwork in the raster are never production data or assets.
- This approval does not claim implementation visual QA has passed.
