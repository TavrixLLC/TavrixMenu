# Waflo Product Surface Split V1

Status: canonical product-surface ownership doctrine.

This document defines where Waflo capabilities belong. It prevents the Web
Studio and Mobile Operations app from becoming competing administration
products, keeps Customer Web free of owner controls, and preserves the Platform
Backend as the authority for workspace, security, and commercial state.

This doctrine supplements the product experience and walkthrough documents. It
does not invalidate completed Mobile V3 work: the Dashboard, daily Menu
Management, simple Product Editor, and staff scanner remain valid operational
surfaces.

## Product model

Waflo consists of four cooperating layers:

1. **Waflo Web Studio** for building, configuring, administering, analyzing,
   and paying.
2. **Waflo Mobile Operations** for fast daily work by owners, managers, and
   staff.
3. **Waflo Customer Web** for restaurant guests and loyalty customers.
4. **Waflo Platform Backend** for authoritative data, authorization,
   entitlements, and integrations.

Web Studio and Mobile Operations use the same authenticated workspace,
backend, database, permissions, and entitlements. Customer Web is public or
customer-authenticated according to the specific flow. No surface invents its
own product, customer, loyalty, billing, or workspace truth. The Platform
Backend remains authoritative for authorization and plan enforcement.

## Waflo Web Studio

### Primary purpose

Build, configure, customize, administer, analyze, and pay.

Web Studio is the primary owner surface for workflows that need space,
comparison, precision, or sustained administration:

- business onboarding and full workspace configuration
- advanced menu management and bulk category or product editing
- product media upload, media library, cropping, and replacement
- menu appearance design and side-by-side public menu preview
- real QR generation and printable exports
- loyalty program building and wallet-card design
- stamp count, layout, active/inactive appearance, built-in icons, and custom
  stamp uploads
- card media slots, colors, labels, terms, rewards, review links, and external
  links
- dynamic enrollment fields and customer/CRM administration
- notification campaigns and automation
- work locations and location-based behavior
- staff invitations, roles, and permission administration
- reporting and analytics
- plan comparison, subscription checkout, billing portal, invoices, payment
  methods, entitlements, and quota visibility
- audit-sensitive administration

These workflows belong on the web because they benefit from a larger
workspace, keyboard and mouse input, drag-and-drop, side-by-side preview, bulk
editing, advanced uploads, complex forms, dense tables, and a safer billing
flow.

Web Studio is an ownership target, not a claim that every listed workflow is
implemented. The repository currently contains partial web administration
foundations; it does not yet contain a complete canonical Web Studio.

## Waflo Mobile Operations

### Primary purpose

Fast daily operation by owners, managers, and staff.

Mobile Operations owns:

- an operational Dashboard
- viewing categories and products
- searching products
- quick product creation
- quick price changes when a supported edit contract and UI exist
- product availability toggles
- sharing a confirmed public menu link or real QR
- staff scanner access and customer-card verification
- adding stamps and redeeming rewards
- customer lookup for authorized operational flows
- operational alerts
- simplified business status
- read-only subscription and entitlement status
- role-appropriate staff mode
- logout and safe account/workspace switching

Mobile Operations must not become a second full Web Studio. It does not own:

- an advanced menu or wallet-card designer
- a stamp asset studio
- complex media editing or a media library
- bulk product administration
- full CRM tables
- notification automation building
- work-location administration
- a complex staff permission matrix
- a full analytics suite
- checkout or advanced billing administration
- destructive account administration

For advanced work, Mobile may show a disabled or informational state, explain
briefly that the task is managed through Waflo Studio, or offer a
store-policy-safe handoff when that handoff is explicitly approved. An external
payment or Studio link must not be assumed permissible in every store build.

## Waflo Customer Web

### Primary purpose

Customer-facing restaurant experiences that do not require the owner app.

Customer Web owns:

- the public restaurant menu and category browsing
- confirmed product availability, restaurant branding, and customer-facing
  item information
- loyalty enrollment and customer consent
- customer loyalty-card access
- Apple Wallet and Google Wallet installation handoff
- reward and stamp balance presentation
- terms, review links, and approved external links
- customer-facing QR destinations

Customer Web must never expose owner, manager, staff, billing, or platform
administration.

## Waflo Platform Backend

The Platform Backend owns:

- authentication verification and authoritative workspace selection
- tenant isolation, memberships, roles, and permissions
- business, category, product, customer, and loyalty ownership
- persisted mutations and confirmed state
- staff authorization
- entitlements, quotas, and subscription state
- audit logs
- webhook verification and idempotency
- abuse protection and rate limits
- public URL truth and real QR destinations

**UI hiding is not authorization.** Every protected operation must be enforced
server-side, tenant-scoped, and role-aware. A client may improve clarity by
hiding an unavailable action, but that cannot be the security boundary.

## Cross-surface workflows

### Menu customization

1. Web Studio uploads images, reorders the full menu, customizes appearance,
   and previews the public result.
2. During service, Mobile Operations temporarily marks an item unavailable.
3. Customer Web reflects only the backend-confirmed current availability.

### Loyalty program

1. Web Studio builds and activates the program and card design.
2. Customer Web obtains consent, enrolls the customer, and offers Wallet
   installation.
3. Mobile Operations scans customer cards, adds stamps, and redeems rewards.
4. The Platform Backend enforces customer, card, staff, and workspace ownership
   at every step.

### Subscription

1. The owner selects a plan on Waflo Web.
2. Stripe-hosted Checkout handles payment.
3. Stripe reports lifecycle changes through signed webhooks.
4. The Platform Backend verifies and applies each event idempotently, then
   computes the effective Waflo entitlements.
5. Web and Mobile read the resulting status; Mobile does not invent or purchase
   the subscription locally.

This is the target architecture. The current billing runtime is not complete.

### Staff

1. Web Studio invites staff and configures supported roles.
2. The Platform Backend persists membership and enforces permissions.
3. Mobile Operations gives the staff member only authorized scanner and daily
   operation tools.

## Current product reality

Status words in this section and the ownership matrix have strict meanings:

- `IMPLEMENTED`: reviewed runtime support exists for the stated bounded scope.
- `PARTIAL`: supporting behavior exists, but an important surface, state, or
  integration is incomplete.
- `MISSING`: no reviewed implementation exists.
- `BLOCKED`: implementation exists or is planned, but a safety/release gate
  prevents release.
- `DEFERRED`: intentionally postponed beyond the current product boundary.

Current high-level reality:

- Mobile Dashboard, operational Menu Management, simple Product creation,
  search, availability, and IQD display are implemented for their bounded V3
  slices.
- Mobile Product editing, image selection/upload, drafts, and advanced menu
  administration are not complete.
- Customer Web public menu and wallet/loyalty routes exist, but Loyalty release
  remains blocked by customer tenant-isolation work.
- Staff scanning and loyalty mutations have real foundations, while the broader
  scanner/Loyalty security audit remains required before release.
- Menu appearance, media upload, loyalty configuration, staff administration,
  and owner web tooling have partial foundations; a canonical Web Studio is
  still missing.
- The billing module is a runtime stub. Existing API-contract or schema
  foundations do not constitute implemented checkout, webhook processing, or
  entitlement enforcement.
- Full Arabic, Kurdish Sorani, and English localization is incomplete.
- Multi-business selection remains fail closed until an authoritative selector
  exists.

The detailed current-state classification is in
[WAFLO_CAPABILITY_OWNERSHIP_MATRIX_V1.md](WAFLO_CAPABILITY_OWNERSHIP_MATRIX_V1.md).

## Product boundaries

### MVP

The sellable MVP boundary is:

- authenticated owner Web Studio
- business setup and menu administration
- media sufficient for a professional public menu
- public menu and real QR truth
- Mobile Operations for daily work
- staff scanner
- simple Loyalty only after tenant safety and the broader security audit pass
- web billing
- server-side entitlement enforcement

An MVP item is not release-ready merely because a route, visual, or schema
exists. Required security, end-to-end behavior, and human gates still apply.

### Post-MVP

Post-MVP work includes:

- advanced media library and cropping
- custom stamp asset studio and advanced card media
- dynamic enrollment-field builder
- CRM depth, campaigns, and notification automation
- advanced analytics and reporting
- multiple work locations and location-based behavior
- complex role matrices
- advanced billing administration in clients

### Release blockers

- Customer tenant isolation must be resolved before Loyalty release.
- Broader scanner/Loyalty security auditing remains required, including staff
  authorization, mutation boundaries, card ownership, replay/rotation, rate
  limits, abuse resistance, and negative tests.
- Multi-business users remain fail closed until an authoritative selector is
  implemented.
- Billing cannot gate a paid product until verified webhook synchronization and
  backend entitlement enforcement exist.
- Real public QR destinations must be confirmed; a decorative or fallback QR is
  not product truth.
- Loading failures must never be presented as empty data or successful state.

## Recommended implementation roadmap

1. Product Surface Split V1
2. Localization foundation: Arabic, Kurdish Sorani, and English
3. Web Studio foundation
4. Web business and menu administration
5. Media upload and library
6. Public Menu and real QR truth
7. Loyalty domain security: customer tenant isolation, staff authorization, and
   card ownership
8. Web Loyalty Builder and live preview
9. Stripe Billing and Entitlements
10. Mobile entitlement consumption
11. Staff operational hardening
12. Notifications and automation
13. Analytics and work locations

This sequence establishes ownership and security before multiplying UI
surfaces. Each implementation slice must re-check current runtime truth rather
than treating this roadmap as evidence that a capability already exists.
