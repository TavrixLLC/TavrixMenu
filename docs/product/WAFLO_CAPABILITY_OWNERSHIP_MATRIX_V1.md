# Waflo Capability Ownership Matrix V1

Status: canonical capability ownership and current-reality matrix.

Read this with
[WAFLO_PRODUCT_SURFACE_SPLIT_V1.md](WAFLO_PRODUCT_SURFACE_SPLIT_V1.md). Ownership
does not imply implementation. Current status is based on reviewed repository
behavior, not design concepts.

## Vocabulary

Surface ownership uses only:

- `PRIMARY`: the main configuration or administration surface.
- `QUICK_OPERATION`: a bounded daily operation, not full administration.
- `READ_ONLY`: status or results may be consumed without owning mutation.
- `CUSTOMER_SURFACE`: the restaurant-customer experience.
- `ENFORCEMENT`: authoritative persistence, authorization, or policy.
- `NOT_PRESENT`: the capability must not appear on that surface.

Current status uses `IMPLEMENTED`, `PARTIAL`, `MISSING`, `BLOCKED`, or
`DEFERRED` as defined in the canonical split.

## Matrix

| Capability | Web Studio | Mobile Operations | Customer Web | Platform Backend | Current status | Security or release blocker | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Workspace onboarding | PRIMARY | QUICK_OPERATION | NOT_PRESENT | ENFORCEMENT | PARTIAL | Authoritative membership is mandatory. | Mobile can create a simple workspace; full Studio onboarding is not established. |
| Business profile | PRIMARY | QUICK_OPERATION | READ_ONLY | ENFORCEMENT | PARTIAL | Role and tenant checks apply to every update. | Mobile supports bounded setup/profile work; advanced administration belongs in Studio. |
| Categories | PRIMARY | QUICK_OPERATION | READ_ONLY | ENFORCEMENT | PARTIAL | Business ownership must be enforced. | M1P1 supports daily category creation/viewing; bulk and advanced web management are missing. |
| Products | PRIMARY | QUICK_OPERATION | READ_ONLY | ENFORCEMENT | PARTIAL | Business/category ownership must be enforced. | M1P1 supports a bounded product flow; advanced edit and Studio workflows remain incomplete. |
| Quick product creation | NOT_PRESENT | QUICK_OPERATION | NOT_PRESENT | ENFORCEMENT | IMPLEMENTED | Requires authoritative workspace, category, permission, and confirmed save. | Finalized M1P1 supports simple category, IQD price, and availability input without drafts or images. |
| Bulk editing | PRIMARY | NOT_PRESENT | NOT_PRESENT | ENFORCEMENT | MISSING | Mutations must remain tenant-scoped and atomic where appropriate. | Intended for Web Studio only. |
| Availability | PRIMARY | QUICK_OPERATION | READ_ONLY | ENFORCEMENT | IMPLEMENTED | Customer Web must show confirmed current state. | Mobile availability mutation and owner visibility are implemented for M1P1. |
| Pricing | PRIMARY | QUICK_OPERATION | READ_ONLY | ENFORCEMENT | PARTIAL | Server validation and currency semantics remain authoritative. | M1P1 creates and displays whole-dinar IQD prices; a dedicated edit surface is not complete. |
| Product media | PRIMARY | NOT_PRESENT | READ_ONLY | ENFORCEMENT | PARTIAL | Upload authorization, file validation, storage safety, and tenant ownership. | A backend/admin upload path exists; mobile image upload and a Studio media library do not. |
| Product image upload | PRIMARY | NOT_PRESENT | READ_ONLY | ENFORCEMENT | PARTIAL | Same media controls as above; no fake picker or upload success. | Explicitly absent from M1P1. |
| Media library | PRIMARY | NOT_PRESENT | NOT_PRESENT | ENFORCEMENT | MISSING | Tenant ownership and deletion/reference safety are required. | No canonical library exists. |
| Media cropping | PRIMARY | NOT_PRESENT | NOT_PRESENT | ENFORCEMENT | MISSING | Original media and transformed assets need safe ownership/lifecycle rules. | No reviewed implementation. |
| Menu appearance | PRIMARY | QUICK_OPERATION | READ_ONLY | ENFORCEMENT | PARTIAL | Only enabled templates and permitted changes may be saved. | Template catalog, preview, API, and bounded mobile/admin controls exist; full Studio designer does not. |
| Public menu | READ_ONLY | READ_ONLY | CUSTOMER_SURFACE | ENFORCEMENT | IMPLEMENTED | Public response must stay business-scoped and exclude administration. | Customer Web has public menu and item routes with template rendering. Full localization is separate. |
| QR | PRIMARY | QUICK_OPERATION | CUSTOMER_SURFACE | ENFORCEMENT | PARTIAL | QR must resolve to a real authoritative public URL. | Current mobile QR page is not visually accepted; fallback or decorative QR behavior is forbidden. |
| Customer preview | PRIMARY | QUICK_OPERATION | CUSTOMER_SURFACE | ENFORCEMENT | PARTIAL | Preview must not persist appearance or bypass tenant scope. | Query-based template preview exists; canonical Studio side-by-side preview is missing. |
| Loyalty builder | PRIMARY | READ_ONLY | CUSTOMER_SURFACE | ENFORCEMENT | BLOCKED | Customer tenant isolation and broader Loyalty security audit. | Backend and legacy UI foundations exist; current mobile Loyalty page is not visually accepted. |
| Stamp-card design | PRIMARY | READ_ONLY | CUSTOMER_SURFACE | ENFORCEMENT | PARTIAL | Loyalty release blockers still apply. | Program/style and Wallet foundations exist; complete Studio designer/live preview does not. |
| Custom stamp icons | PRIMARY | NOT_PRESENT | READ_ONLY | ENFORCEMENT | PARTIAL | File safety and tenant ownership are required for custom uploads. | Preset support exists; a complete custom asset studio does not. |
| Card media | PRIMARY | NOT_PRESENT | CUSTOMER_SURFACE | ENFORCEMENT | PARTIAL | Media ownership and Wallet/customer rendering must be validated. | Some palette/pass/media foundations exist; complete configurable media slots are missing. |
| Enrollment fields | PRIMARY | NOT_PRESENT | CUSTOMER_SURFACE | ENFORCEMENT | MISSING | Consent, validation, enumeration resistance, and PII handling. | Existing enrollment inputs are fixed; no dynamic field builder exists. |
| Customers | PRIMARY | QUICK_OPERATION | CUSTOMER_SURFACE | ENFORCEMENT | BLOCKED | Customer tenant isolation is a Loyalty release blocker. | Customer/membership foundations exist; release remains blocked until ownership queries are audited. |
| Scanner | NOT_PRESENT | PRIMARY | NOT_PRESENT | ENFORCEMENT | BLOCKED | Broader scanner/Loyalty security audit remains required. | Camera/manual scanning and W2A workspace isolation exist; current mobile scanner is not visually accepted by the V3 archive. |
| Stamp mutation | NOT_PRESENT | PRIMARY | READ_ONLY | ENFORCEMENT | PARTIAL | Staff authorization, card ownership, replay/abuse controls, and negative tests. | Real mutation foundations exist, but the broader release audit is not closed. |
| Reward redemption | NOT_PRESENT | PRIMARY | READ_ONLY | ENFORCEMENT | PARTIAL | Same scanner/Loyalty security boundary as stamp mutation. | Real redemption foundation exists; release acceptance remains pending. |
| Manual notifications | PRIMARY | QUICK_OPERATION | NOT_PRESENT | ENFORCEMENT | MISSING | Consent, audience isolation, rate limits, and delivery audit. | Mobile must not simulate sends. |
| Automated notifications | PRIMARY | NOT_PRESENT | NOT_PRESENT | ENFORCEMENT | DEFERRED | Consent, opt-out, safe triggers, rate limits, and auditability. | Post-MVP automation work. |
| Work locations | PRIMARY | READ_ONLY | READ_ONLY | ENFORCEMENT | DEFERRED | Location consent, ownership, and platform behavior must be defined. | Multi-location administration is not current scope. |
| Staff | PRIMARY | READ_ONLY | NOT_PRESENT | ENFORCEMENT | PARTIAL | Authoritative membership, role, status, and workspace scope. | Membership endpoints and mobile staff mode exist; complete Studio invitation flow is not established. |
| Roles | PRIMARY | READ_ONLY | NOT_PRESENT | ENFORCEMENT | PARTIAL | Backend role checks, not client labels, decide permission. | Fixed OWNER/MANAGER/STAFF foundations exist; complex permission administration does not. |
| Reports | PRIMARY | READ_ONLY | NOT_PRESENT | ENFORCEMENT | MISSING | Aggregates must remain tenant-scoped and distinguish failure from zero. | No reviewed reporting product exists. |
| Analytics | PRIMARY | READ_ONLY | NOT_PRESENT | ENFORCEMENT | DEFERRED | Same tenant and data-truth boundary as reports. | Advanced analytics is post-MVP. |
| Billing | PRIMARY | READ_ONLY | NOT_PRESENT | ENFORCEMENT | MISSING | Verified Stripe webhook and server-side entitlements are required. | Billing module is a runtime stub; schema/API-contract foundations are not checkout. |
| Invoices | PRIMARY | READ_ONLY | NOT_PRESENT | ENFORCEMENT | MISSING | Billing-provider identity and workspace authorization. | No reviewed invoice surface or synchronized runtime. |
| Entitlements | READ_ONLY | READ_ONLY | NOT_PRESENT | ENFORCEMENT | MISSING | Unknown entitlement must fail closed. | No authoritative entitlement evaluator is implemented. |
| Plan quotas | READ_ONLY | READ_ONLY | NOT_PRESENT | ENFORCEMENT | MISSING | Quota changes must be tenant-scoped and atomic. | No reviewed usage-counter/quota enforcement exists. |
| Wallet installation | NOT_PRESENT | READ_ONLY | CUSTOMER_SURFACE | ENFORCEMENT | IMPLEMENTED | Loyalty release blockers remain; signing/auth material must stay server-side. | Customer Web and Apple/Google Wallet backends provide real installation flows. |
| Review links | PRIMARY | READ_ONLY | CUSTOMER_SURFACE | ENFORCEMENT | MISSING | Links require validation and business ownership. | No reviewed configurable review-link product exists. |
| External links | PRIMARY | READ_ONLY | CUSTOMER_SURFACE | ENFORCEMENT | MISSING | Validate allowed schemes and avoid unsafe redirects. | Not a complete configurable capability today. |
| Audit logs | PRIMARY | NOT_PRESENT | NOT_PRESENT | ENFORCEMENT | PARTIAL | Logs must be tenant-scoped, access-controlled, and free of secret/PII leakage. | Audit persistence exists for limited business activity; no complete Studio audit surface exists. |
| Draft products | PRIMARY | NOT_PRESENT | NOT_PRESENT | ENFORCEMENT | MISSING | Availability must never be repurposed as draft state. | Drafts are unsupported and must be omitted or disabled. |
| Full localization | PRIMARY | QUICK_OPERATION | CUSTOMER_SURFACE | ENFORCEMENT | PARTIAL | Locale must not change identifiers, validation, or authorization. | Arabic-first work exists; complete Arabic, Kurdish Sorani, and English coverage does not. |
| Multi-business selection | PRIMARY | QUICK_OPERATION | NOT_PRESENT | ENFORCEMENT | BLOCKED | Fail closed until an authoritative selector exists. | Never select a business by list position. |

## Preserved release boundaries

- Customer tenant isolation remains a release blocker before Loyalty release.
- The broader scanner/Loyalty security audit remains required even though W2A
  workspace and scanner-context isolation is complete.
- Multi-business selection remains fail closed until an authoritative selector
  exists.
- Product image upload is partial; M1P1 contains no fake image upload.
- Drafts are unsupported.
- Full localization is incomplete.
- Current mobile Loyalty and QR pages are not visually accepted as V3-complete.

`IMPLEMENTED` applies only to the bounded capability stated in its row. It does
not imply that adjacent Web Studio configuration, localization, release
security, or visual acceptance is complete.
