# Menu Management Interaction Contract

Enabled actions assume the authenticated user has the required permission and the real route or mutation is wired. Otherwise the honest fallback applies.

| Visible action | State behavior | Destination or expected intent | Prerequisite | Honest fallback |
| --- | --- | --- | --- | --- |
| Add category / `إضافة قسم` | Enabled only when the real mutation is available | Open category creation and persist through the documented business-scoped category endpoint | Authoritative active business and category-management permission | Disable with an availability or permission explanation; never add a local fake category |
| Select category | Enabled after a successful real category load | Select one returned category and load/filter its real products | Category belongs to the active business | Keep selection unavailable during loading/error; category selection never invents categories |
| Edit category / `تعديل القسم` | Enabled for a real selected category | Open editing and persist through the documented category update contract | Selected real category and category-management permission | Disable without selection/permission; no success state until the mutation succeeds |
| Search / `ابحث عن منتج` | Enabled after a successful product load | Filter the real loaded product records without changing the selected category | Successfully loaded business-scoped products | On no match, show `SEARCH_EMPTY_RESULT` and allow clearing; do not show onboarding empty copy |
| Add first product / `إضافة أول منتج` | Enabled in `EMPTY_ONE_CATEGORY` only when product creation is real | Open product creation for the selected real category | Authoritative active business, selected real category, menu permission, and wired product mutation | Disable and explain unavailability; never fabricate a product or success toast |
| Add product / `إضافة منتج` | Enabled under the same real-data conditions | Open product creation for the selected real category | Same prerequisites as Add first product | Disable until a real category and mutation exist |
| Customer menu preview / `معاينة منيو الزبائن` | Disabled in the approved empty state | Open the real public customer-menu route | Real public URL plus backend-confirmed menu readiness | Remain fully muted with helper text; do not show QR until a real public URL exists |
| Bottom navigation | Enabled only for real shell destinations | Navigate among `الرئيسية`, `المنيو`, `المسح`, `الولاء`, and `الإعدادات` | Authenticated shell and a real route for the selected tab | Keep unavailable destinations clearly disabled or informational |

## Mutation and navigation rules

- Category selection never invents categories.
- Add product requires a real selected category.
- Preview requires a real public route; no QR is shown until a real public URL exists.
- No success toast or success state appears unless the corresponding mutation succeeds.
- Every category or product mutation requires explicit loading, success, and error handling.
- Prevent duplicate mutations from repeated taps.
- Workspace changes and logout clear selection, search, pending results, and prior-business menu data.
