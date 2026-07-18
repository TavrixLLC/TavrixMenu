# Owner Dashboard Interaction Contract

The table defines action intent for the approved zero-product state. “Enabled” always assumes the authenticated user has the required permission and that the real destination or mutation is wired. When those conditions are false, the honest fallback applies.

| Visible action | Approved-state behavior | Destination or expected intent | Prerequisite | Honest fallback |
| --- | --- | --- | --- | --- |
| Add product / `إضافة منتج` | Enabled only when the real creation flow is available | Open the real product-creation flow for a real selected category | Authoritative active business, menu-management permission, one real selected category, and a wired product mutation | Disable and explain that product creation is unavailable; never show a success result |
| Open menu / `فتح المنيو` | Disabled with zero products | Open a real public customer preview or real menu route | A real public URL and menu readiness backed by at least one public product | Show an honest unavailable state and direct the owner to add the first product |
| Create loyalty card / `إنشاء بطاقة ولاء` | Disabled until the real builder exists | Open the real loyalty-program builder | Eligible role, authoritative business, and a wired loyalty builder using the real loyalty contract | Disable or mark clearly unavailable; never claim a card or program was created |
| Manage categories / `إدارة الأقسام` | Enabled only when its real route is wired | Open category management for the active business | Authoritative business context and category-management permission | Disable with an availability or permission explanation; never invent categories |
| Scan card / `مسح بطاقة` | Disabled in this no-program state | Open the real staff scanner for an existing customer loyalty card | Active loyalty program, scanner permission, real scanner route, and business-scoped scan behavior | Explain that a loyalty program/card is required; do not simulate a scan |
| Send notification / `إرسال إشعار` | Disabled while customer count is zero | Open a real notification composer and send through a real backend capability | At least one authoritative customer plus an implemented notification contract and permission | Keep fully muted with helper text; must not simulate sending or show a success toast |
| Bottom navigation | Enabled only for real shell destinations | Navigate among `الرئيسية`, `المنيو`, `المسح`, `الولاء`, and `الإعدادات` | Authenticated shell and a real route for the selected tab | Keep unavailable tabs clearly disabled or informational; never use a dead active-looking tab |

## Shared action rules

- Every asynchronous action requires an explicit loading state, a success state based on a real result, and an honest error state.
- Repeated taps must not create duplicate mutations.
- Navigation and mutations must preserve authoritative active-business context.
- Logout or workspace change clears pending results and disables actions until the new context loads.
- A visual reference never authorizes a fake destination, fake result, or unsupported feature.
