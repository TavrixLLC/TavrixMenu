# Product Editor States

Only the Create Product visual in [create-product-approved.png](create-product-approved.png) is approved. Edit behavior and non-default states are documented behavior only.

## `CREATE_INITIAL`

- No product exists.
- A selected category may be passed from Menu Management only when it is a real category in the authoritative active business.
- Editable fields begin empty except for a valid passed category and the documented availability default.
- Image is optional.
- The primary create action remains disabled until all required fields are valid.

## `CREATE_VALID`

- Required fields are valid.
- An authoritative category is selected.
- A valid IQD price has been entered without ambiguous numeric conversion.
- The primary create action is enabled.
- Availability reflects the user's actual choice and the value that will be submitted.

## `CREATE_SUBMITTING`

- Form controls and the primary action are protected against duplicate submission.
- The primary action shows restrained progress.
- The submitted availability and other field values remain visually consistent with the pending request.
- Back navigation warns only when unsaved changes exist.
- No success message appears before backend confirmation.

## `CREATE_SUCCESS`

- A real backend product was created and the response contains authoritative product identity.
- Return to Menu Management and refresh products for the selected category.
- Show success feedback only after backend confirmation.
- Clear pending submission state and do not retain any raster sample product in state.

## `CREATE_ERROR`

- Preserve entered data and the last confirmed local image selection.
- Show an honest inline or form-level error and allow retry.
- Do not issue a duplicate create request.
- Do not show fake success or navigate away unless the user chooses.

## `VALIDATION_ERROR`

- Errors appear near the relevant fields.
- Focus or scroll to the first invalid field.
- Preserve valid user input and the selected authoritative category.

## `IMAGE_SELECTING`

- Native image selection is in progress.
- Prevent duplicate picker presentation.
- No fake uploaded URL or permanent merchant asset exists.

## `IMAGE_SELECTED_LOCAL`

- A local preview may be shown.
- The image is not considered uploaded yet.
- Allow the user to replace or remove it.

## `IMAGE_UPLOADING`

- Enter this state only through the real supported upload contract.
- Prevent repeated upload and show progress honestly.
- Other validated form data remains preserved.

## `IMAGE_UPLOAD_ERROR`

- Preserve all other form fields.
- Allow retry, replace, or remove.
- Product creation follows the real backend media requirement; an optional-image failure must not be disguised as a successful upload.

## `EDIT_EXISTING`

- Behavior is documented only; no approved edit-state visual exists.
- Load a real business-scoped product by its record identifier or an explicitly supported business-scoped source.
- Never display product or category data from another business.
- Preserve the Create Product visual system where practical without implying edit visual approval.

## `UNSAVED_CHANGES`

- Back requests confirmation when the form has changed.
- Do not show confirmation when the form is unchanged.
- Confirmation describes discard intent honestly and does not save a draft.

## `DRAFT_UNAVAILABLE`

- Save as Draft is disabled or omitted.
- Helper text may explain that drafts are not available.
- Do not simulate persistence, show a fake toast, or claim draft success.
