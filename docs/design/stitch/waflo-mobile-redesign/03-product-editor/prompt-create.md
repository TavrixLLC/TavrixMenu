# Product Editor — Create Product Approved Direction

## Screen

Product Editor — Create Product

Use [create-product-approved.png](create-product-approved.png) as the authoritative visual direction for this exact create state. The raster is a reference for hierarchy and visual language, not fixed coordinates, implementation code, production assets, or runtime values.

## Approved scenario

- An authoritative active restaurant workspace exists.
- An owner or other authorized menu manager opens Product Editor from Menu Management to create a real product.
- A real category may be passed from Menu Management; the approved example category is `المقبلات`.
- No product record exists until the backend create mutation succeeds.
- Image is optional.
- Product name, category, and price are required.
- Description is optional under the current backend contract.
- Currency in the approved scenario is Iraqi dinar.
- Availability is an explicit user choice.
- The primary action creates the product only after validation.
- Draft behavior is not implemented by the current backend and must not be simulated.

## Visual direction

- Arabic-first RTL, in the same Waflo Mobile UI V3 family as Dashboard and Menu Management.
- Soft Background semantic color `#F7F9FF`.
- Primary semantic color `#AE3115`.
- Supporting Accent semantic color `#FF6B4A`.
- White input surfaces and near-black semantic text.
- Refined, restrained shadows and rounded controls.
- Minimum 48px touch targets.
- A focused editor flow with no bottom navigation.
- A clear, reachable back action.
- Natural vertical scrolling instead of a fixed screenshot-height layout.

## Visible structure and labels

- Back button
- Title: `إضافة منتج`
- Supporting description: `أضف تفاصيل المنتج اللي راح تظهر للزبائن`
- Optional image area: `رفع صورة`, `اختياري`
- Product name: `اسم المنتج`
- Description: `الوصف`
- Category selector: `القسم`
- Approved example selected category: `المقبلات`
- Price field: `السعر`, with `د.ع`
- Availability control: `متوفر للزبائن`
- Secondary action: `حفظ كمسودة`
- Primary action: `إضافة المنتج`

Field labels in the image are authoritative visual labels, subject to accurate Arabic copy review during implementation.

## Honesty constraints

- Sample field values, category data, and business context from the raster must never be hard-coded.
- No fake success, image upload, draft, category, product identity, or product record.
- `حفظ كمسودة` is visible in the reference but is **not currently wired**. Implementation must disable or omit it and must not show a draft-success message.
- A selected local image is not an uploaded merchant asset until the real backend upload succeeds and its returned media reference is used by confirmed product creation.
- The visual never authorizes unsupported behavior.
