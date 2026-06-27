# Sprint 13 Media Upload E2E Closeout

## Decision

`MEDIA_UPLOAD_END_TO_END_READY_FOR_PILOT`

This closeout records the Sprint 13 media upload pilot path using sanitized
labels only. Do not add real customer data, account identifiers, card
references, cookies, auth sessions, uploaded file URLs, or database
identifiers to this file.

## Scope Closed

- Media Upload API deployed for the pilot upload flow.
- Admin Media Upload UI merged to `dev`.
- Local admin-web smoke against the staging API passed.
- `OWNER_TEST_USER` upload passed.
- `STAFF_TEST_USER` forbidden response passed.
- Invalid file rejection passed.
- Oversized file rejection passed.
- Public menu image render passed for `PILOT_TEST_BUSINESS`.

## Sanitized Smoke Summary

| Check | Result | Notes |
| --- | --- | --- |
| API health | Passed | Health returned 200 during closeout verification. |
| Staging auth mode | Passed | Staging was restored to production-mode auth before closeout. |
| Dev auth rejection | Passed | Dev-style access was rejected in the restored staging gate. |
| Owner upload | Passed | `OWNER_TEST_USER` uploaded pilot-safe images. |
| Staff forbidden | Passed | `STAFF_TEST_USER` could not use the upload endpoint. |
| Invalid file | Passed | Unsupported file type returned a friendly rejection path. |
| Oversized file | Passed | Oversized upload returned a friendly rejection path. |
| Public menu render | Passed | Uploaded images rendered on the public menu. |
| Admin hosted staging | Pending | No hosted admin staging service exists yet. |
| Admin DNS | Pending | Hosted admin dashboard DNS is not configured yet. |

## Redaction Rules Used

- Test owner label: `OWNER_TEST_USER`
- Test staff label: `STAFF_TEST_USER`
- Test business label: `PILOT_TEST_BUSINESS`
- Uploaded image label: `REDACTED_PUBLIC_UPLOAD_URL`

The smoke notes intentionally exclude real emails, Clerk user identifiers,
database identifiers, exact upload URLs, cookies, auth sessions, local
filesystem paths, QR payloads, card references, and customer PII.

## Pilot Operations Notes

- The upload endpoint stores pilot media on the local VPS upload volume.
- The local VPS upload volume is temporary pilot storage, not final production
  storage architecture.
- Back up the upload volume before bulk pilot image entry.
- Back up the upload volume again after pilot menu images are complete.
- Keep database backup and upload-volume backup timestamps together in the
  private pilot log.
- Object storage migration remains a later ops-hardening task.

## Hosted Admin Dashboard Boundary

The Sprint 13 smoke used local admin-web pointed at the staging API. This was
enough to verify the owner upload flow, permission handling, save flow, and
public menu render without introducing new DNS or deployment scope.

Hosted admin dashboard decisions remain separate:

- Do not add an admin staging service in this closeout.
- Do not change DNS in this closeout.
- Before owner-facing hosted admin testing, decide whether admin-web should be
  deployed as a dedicated service or folded into an existing web deployment
  path.

## Remaining Pilot Gate

Before real pilot image entry, run the count-only API log safety scan from an
authorized server/log access path. Report counts only, with expected result
zero sensitive hits.
