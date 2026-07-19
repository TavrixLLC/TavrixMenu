# Menu Management — Approved Populated-State Direction

## Visual authority

Use [populated-approved.png](populated-approved.png) as the visual reference for the exact populated Menu Management state. Preserve its Arabic-first RTL hierarchy and the same Waflo Mobile UI V3 language established by the Owner Dashboard and Menu Empty references.

The raster is a visual direction reference only. It does not define fixed coordinates, fixed card heights, production food assets, implementation code, or runtime data.

## Approved scenario

- An authoritative active restaurant workspace exists.
- Several real categories belong to that business.
- The real category `المقبلات` is visibly selected.
- The selected category contains real product records.
- Owner product cards expose supported name, description, IQD price, image, availability, and edit intent only when backed by real data and contracts.
- Available and unavailable products remain visible to the authorized owner.
- Category selection, search, category creation, and product creation operate on real business-scoped records.
- Customer preview opens only through a real public menu route.
- Bottom navigation remains five equal tabs and `المنيو` is selected using the canonical treatment in `DESIGN.md`.

## Visual direction

- Soft Background semantic color: `#F7F9FF`.
- Primary semantic color: `#AE3115`.
- Accent semantic color: `#FF6B4A`.
- Product surfaces are white with soft, restrained shadows.
- Card radii remain within 16–24px.
- Every interactive target is at least 48px.
- The selected category is visually obvious without relying on color alone.
- Search filters real loaded records and never fabricates results.
- Availability reflects confirmed backend state.
- Edit actions target real product records.
- Prices use the active business currency and show IQD only when IQD is authoritative.

## Data and scope constraints

- Product names, food photographs, descriptions, and prices visible in the raster are visual sample content only and must never be hard-coded.
- Do not create fake products, analytics, totals, availability, QR codes, preview routes, or mutation success.
- Do not add order or sales features; none are approved by this visual.
- Do not copy product data or imagery from the screenshot into fixtures, production assets, or fallback content.
- All runtime values come from the authoritative active business and supported business-scoped backend contracts.
- When a visual field is not present in the owner backend response, show honest unavailability or wait for the contract; never fill it with raster sample content.
