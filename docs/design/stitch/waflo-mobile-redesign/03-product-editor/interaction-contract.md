# Product Editor Interaction Contract

All actions operate within the authoritative active workspace. An approved visual may show an action that is unavailable in the backend; unavailable behavior remains disabled or omitted.

| Control | Real behavior | Prerequisite | Honest fallback |
| --- | --- | --- | --- |
| Back | Return to Menu Management | Editor opened from a real route | If the form changed, request discard confirmation; never silently discard changes or pretend to save a draft |
| Image area | Open the real supported native image picker | Platform picker and permission flow are available | Handle permission denial honestly; no fake picker, upload, or URL |
| Product name | Required RTL text input with appropriate keyboard action behavior | None beyond form availability | Show field validation; preserve the entered value |
| Description | Multiline RTL input, optional under the current contract | None beyond form availability | Use natural/controlled growth rather than an uncontrolled fixed height |
| Category selector | List only real categories for the active business; preserve a valid category passed from Menu Management | Authoritative active business and loaded category list | Reject stale or unauthorized category records; if empty, route toward real category creation without fabricated options |
| Price | Numeric input with visible IQD treatment in this scenario and deterministic parsing | Authoritative business currency and supported numeral parser | Do not assume decimal/cents behavior beyond the contract; show validation without clearing valid fields |
| Availability | Set the availability value included in the create request | User has create permission | Do not send a standalone availability mutation during create unless the actual API changes to require it |
| Save as Draft / `حفظ كمسودة` | `MISSING` — not currently wired | No draft field, state, or route exists | Disable or omit with optional helper text; never simulate draft persistence or show a fake toast |
| Add Product / `إضافة المنتج` | Validate once, upload optional media through the real supported flow when selected, then submit one real create mutation | Required fields valid, authoritative business/category, authorized role, and no submission pending | Preserve the form on failure; success appears only after backend confirmation |

## Image lifecycle

- A selected image can be replaced or removed before submission.
- Local selection is not a permanent merchant asset.
- A backend-confirmed upload returns the only media reference that may be sent with product creation.
- Upload failure preserves form data and allows retry, replace, remove, or image-free creation when the contract permits.

## Submission and navigation

- Prevent repeated taps while create or upload is pending.
- Disable or protect mutable controls that could make the pending payload ambiguous.
- On confirmed success, return to Menu Management and refresh the selected category's product list.
- On failure, remain in Product Editor and show an honest error.
- No bottom navigation appears on this focused editor screen.
