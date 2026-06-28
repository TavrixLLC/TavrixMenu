# Sprint 14 Paid Readiness / Minimum Ops Plan

## A) Sprint 14 Objective

Sprint 14 is the paid readiness and minimum operations sprint for Waflo.

It is not a billing implementation sprint. Sprint 14 should prove that the team can safely select, configure, support, and operate a first real merchant pilot before accepting money or onboarding a paying restaurant.

Sprint 14 must produce a clear go/no-go decision for the first paid restaurant based on operational readiness, not on new subscription code.

Primary objective:

- Select one real merchant candidate.
- Validate that real merchant content works in the current product.
- Verify the end-to-end customer, owner, and staff flows on real devices.
- Establish support, backup, rollback, and triage routines.
- Decide whether Waflo is ready to accept money for a controlled first restaurant.

## B) Required Gates Before Accepting Money

No money should be accepted until all required gates below are complete.

- [ ] Real merchant selected and recorded privately.
- [ ] Merchant identity redacted in public docs as `PILOT_MERCHANT`.
- [ ] Real merchant menu collected.
- [ ] Real logo, cover image, and item images collected.
- [ ] Business profile configured.
- [ ] Categories, items, descriptions, prices, and sold-out examples reviewed.
- [ ] Template choice selected and verified.
- [ ] Owner/staff test session scheduled.
- [ ] Staff account assignment verified.
- [ ] Staff APK/device readiness verified.
- [ ] QR table test completed.
- [ ] Public menu verified on a real phone.
- [ ] Loyalty enrollment verified.
- [ ] Apple Wallet or Google Wallet add/open verified on the relevant phone.
- [ ] Staff scan, add stamp, and redeem flow verified.
- [ ] Uploaded media backup completed before pilot traffic.
- [ ] Uploaded media backup completed after final menu image entry.
- [ ] API log safety scan count equals `0`.
- [ ] Support channel ready.
- [ ] Issue triage process ready.
- [ ] Rollback plan ready.
- [ ] Go/no-go decision recorded before accepting payment.

## C) Real Merchant Pilot Checklist

Use this checklist for the first real merchant pilot. Keep private merchant names, staff names, phone numbers, emails, IDs, and upload URLs out of public docs.

### Merchant Setup

- [ ] Merchant name recorded privately and redacted as `PILOT_MERCHANT` in docs.
- [ ] Business profile configured.
- [ ] Slug reviewed with merchant.
- [ ] Currency and language reviewed.
- [ ] Opening status and public menu availability reviewed.

### Menu Content

- [ ] Categories created.
- [ ] Menu items created.
- [ ] Prices verified by merchant.
- [ ] Descriptions reviewed for customer clarity.
- [ ] Sold-out behavior tested with safe sample data.
- [ ] Logo uploaded.
- [ ] Cover image uploaded.
- [ ] Item images uploaded.
- [ ] Public menu checked on a real phone at table distance.

### Visual Choice

- [ ] Template selected from the enabled catalog.
- [ ] Template preview checked without persisting accidental changes.
- [ ] Final template saved intentionally.
- [ ] No horizontal overflow on mobile.
- [ ] Logo visible on mobile.
- [ ] Price readability verified.
- [ ] Arabic/RTL content sanity checked if merchant content uses Arabic.

### Loyalty And Wallet

- [ ] Loyalty enrollment works for a fresh customer.
- [ ] Returning same-device customer state works.
- [ ] Wallet add/open works on the pilot phone.
- [ ] Live web card progress is visible.
- [ ] Wallet refresh timing caveat explained clearly.
- [ ] Staff scan finds the correct card.
- [ ] Add stamp works.
- [ ] Redeem works when eligible.
- [ ] Wrong-business or invalid QR remains blocked.

### Staff And QR Operations

- [ ] Staff account configured with least privilege.
- [ ] Staff device tested.
- [ ] Staff scanner opens reliably.
- [ ] QR code printed or displayed in a safe pilot format.
- [ ] QR table placement tested.
- [ ] Customer scan from table distance tested.
- [ ] Staff knows what to do when scan fails.

### Pilot Notes And Decision

- [ ] Bugs recorded with severity.
- [ ] Merchant feedback recorded privately.
- [ ] Support owner assigned.
- [ ] Backup timestamp recorded privately.
- [ ] Rollback target recorded privately.
- [ ] Go/no-go decision recorded.

## D) Commercial Readiness Without Billing Code

Sprint 14 may prepare manual commercial operations, but it must not implement app billing.

Allowed manual readiness work:

- Draft pricing proposal.
- Draft pilot agreement.
- Draft manual invoice/payment process as an operations note.
- Define who can approve a paid pilot.
- Define when payment can be requested.

Required boundary:

- Do not collect money before the real merchant gate passes.
- Do not implement Stripe.
- Do not implement subscriptions.
- Do not add billing screens.
- Do not add entitlement enforcement.
- Do not add automated invoicing.

Billing v1 and manual payments belong to Sprint 16.

## E) Admin Dashboard Decision Gate

Hosted admin dashboard remains deferred.

Decision gate:

- If the merchant owner must self-manage menu, media, staff, or appearance, then `admin.waflo.app` or an equivalent hosted admin staging path becomes required before paid onboarding.
- If the Waflo team manages setup manually through a local admin-web connected to staging, hosted admin can remain deferred for the first controlled pilot.

Before money is accepted, the team must explicitly choose one operating model:

- [ ] Merchant self-service requires hosted admin.
- [ ] Team-managed setup is acceptable for this controlled pilot.

## F) Minimum Ops Runbook Requirements

Sprint 14 should confirm these runbooks are usable before paid onboarding:

- Backup before pilot content entry.
- Backup after completing pilot menu images.
- Public menu rollback steps.
- Staff scanner fallback steps.
- Wallet update delay explanation.
- Support escalation path.
- Issue triage policy.
- Go/no-go checklist.

## G) Backup And Rollback Requirements

Uploaded media is currently stored on local VPS storage for the pilot. This is acceptable for a controlled pilot only if backups are run and recorded privately.

Backup requirements:

- [ ] Back up uploaded media before bulk image entry.
- [ ] Back up uploaded media after final pilot menu images are uploaded.
- [ ] Confirm database backup before pilot traffic.
- [ ] Record restore owner privately.
- [ ] Record rollback target commit privately.

Rollback scenarios:

- If public menu breaks, roll back customer-web to the last verified staging commit.
- If menu data is wrong, fix content through the admin workflow or restore from backup if necessary.
- If staff scanner fails, use live web card verification and record the issue as pilot blocking.
- If wallet update appears delayed, tell the merchant that the live web card is the source of truth and installed wallet refresh timing is platform controlled.

## H) Issue Triage Policy

Use these severities during Sprint 14 pilot operations:

- `P0`: Security issue, data leak, wrong merchant data exposed, wallet/card access leak, or total public menu outage.
- `P1`: Staff scan, add stamp, redeem, wallet add, or public menu core flow broken.
- `P2`: Owner/admin confusion, image/content setup friction, unclear copy, or recoverable device-specific issue.
- `P3`: Visual polish, spacing, wording, or non-blocking template improvement.

P0 and P1 issues block paid onboarding until resolved or explicitly accepted by the owner.

## I) Ops Risks

- Local VPS upload storage is temporary pilot storage.
- Object storage migration remains a later ops hardening task.
- Arabic/RTL real merchant content QA is still pending.
- Hosted admin dashboard is not currently available.
- First merchant support burden may be high.
- Real staff device variability may expose scanner or permission issues.
- Wallet platform behavior varies by device, OS, and background refresh timing.
- Apple Wallet and Google Wallet refreshes must not be promised as instant.
- Manual setup may scale poorly beyond the first controlled merchant.

## J) Sprint 14 Deliverables

Sprint 14 should produce:

- Real merchant pilot evidence.
- Paid readiness checklist.
- Support and rollback runbook.
- Backup proof recorded privately.
- Staff/device test evidence.
- Customer QR table test evidence.
- Go/no-go decision for first paid restaurant.

## K) Explicit Non-Goals

Sprint 14 must not include:

- Billing implementation.
- Stripe integration.
- Subscription management.
- Multi-branch support.
- Localization v1.
- Loyalty v2.
- Template marketplace.
- Hosted admin dashboard implementation unless separately approved as a blocker.
- New wallet signing, APNs, recovery, transfer, or scanner validation behavior.

## L) Closeout Criteria

Sprint 14 can close only when:

- All required gates are complete or explicitly waived by the owner.
- The real merchant pilot evidence is recorded with sensitive details redacted.
- API log safety scan count is `0`.
- Backup proof exists privately.
- Support and rollback instructions are usable by the team.
- The owner records a go/no-go decision for the first paid restaurant.
