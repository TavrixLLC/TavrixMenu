# Menu Management Interaction Contract

Enabled actions assume the authenticated user has the required permission and the real route or mutation is wired. Otherwise the honest fallback applies.

| Visible action | State behavior | Destination or expected intent | Prerequisite | Honest fallback |
| --- | --- | --- | --- | --- |
| Add category / `إضافة قسم` | Enabled only when the real mutation is available | Open the real category workflow, persist through the documented business-scoped category endpoint, and refresh category data after confirmed success | Authoritative active business and category-management permission | Disable with an availability or permission explanation; never add a local fake category |
| Select category | Enabled after a successful real category load | Select one returned category and show only products whose real category association matches it; never default from unordered records by arbitrary position | Category belongs to the active business | Keep selection unavailable during loading/error; category selection never invents categories and the selected category remains visually obvious |
| Edit category / `تعديل القسم` | Enabled for a real selected category | Open editing and persist through the documented category update contract | Selected real category and category-management permission | Disable without selection/permission; no success state until the mutation succeeds |
| Search / `ابحث عن منتج` | Enabled after a successful product load | Filter the selected category's real loaded records by product name and other explicitly supported searchable fields; clearing restores the selected category product list | Successfully loaded business-scoped products | On no match, show `SEARCH_EMPTY_RESULT` and allow clearing; do not show onboarding empty copy |
| Add first product / `إضافة أول منتج` | Enabled in `EMPTY_ONE_CATEGORY` only when product creation is real | Open product creation for the selected real category | Authoritative active business, selected real category, menu permission, and wired product mutation | Disable and explain unavailability; never fabricate a product or success toast |
| Add product / `إضافة منتج` | Enabled under the same real-data conditions | Open Product Editor in create mode for the authoritative active business and selected category | Authoritative active business, selected real category, menu permission, and wired Product Editor | Disable until a real category and real creation flow exist |
| Availability control | Enabled for an owner or other role authorized by the real API | Send the documented product update mutation for the selected real product; disable repeated taps while pending and show success only after confirmation | Authoritative business/product record and update permission | Preserve the last confirmed value while pending; on failure restore or refresh confirmed state and show an honest error |
| Edit product | Enabled for an authorized real product | Open Product Editor with the selected real product record identifier | Product belongs to the authoritative active business and Product Editor is implemented | Never open sample content; disable if the real record or editor is unavailable |
| Product overflow menu | Visible only when at least one real action is implemented | Expose only implemented, permission-checked actions for the selected real product | Real product and at least one supported action | Hide the menu; do not show fake duplicate, archive, or delete actions |
| Customer menu preview / `معاينة منيو الزبائن` | Disabled in the approved empty state; conditionally enabled when populated | Open the real public preview/menu URL | Real public URL plus backend-confirmed menu readiness | Remain fully muted with helper text; no fake phone preview and no QR until a real public URL exists |
| Bottom navigation | Enabled only for real shell destinations | Navigate among `الرئيسية`, `المنيو`, `المسح`, `الولاء`, and `الإعدادات` | Authenticated shell and a real route for the selected tab | Keep unavailable destinations clearly disabled or informational |

## Mutation and navigation rules

- Category selection never invents categories.
- Add product requires a real selected category.
- Preview requires a real public route; no QR is shown until a real public URL exists.
- No success toast or success state appears unless the corresponding mutation succeeds.
- Every category or product mutation requires explicit loading, success, and error handling.
- Prevent duplicate mutations from repeated taps.
- Workspace changes and logout clear selection, search, pending results, and prior-business menu data.
