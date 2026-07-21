# Waflo Billing and Entitlements V1

Status: target architecture and product boundary; not evidence of implemented
billing.

This document defines how future Waflo billing state becomes enforceable
product access. It does not create a Stripe integration, database migration,
price, subscription, entitlement, invoice, or approved commercial policy.

## Source of truth

- Stripe is authoritative for external billing events, invoices, payments,
  subscription lifecycle, and hosted Checkout results.
- The Waflo database is authoritative for fast product-side entitlement
  evaluation after verified synchronization from Stripe.
- Mobile and Web clients must not treat local cache, button state, redirect
  result, or optimistic UI as subscription truth.
- The Platform Backend is authoritative for the effective plan, entitlements,
  usage, and authorization applied to a Waflo workspace.

Stripe billing truth and Waflo product truth have different responsibilities.
Stripe reports what happened commercially; Waflo maps that verified state into
the capabilities and limits its product enforces.

## Target flow

1. An authorized owner selects a plan on Waflo Web.
2. Web requests a server-authorized Stripe Checkout Session for the current
   workspace and approved price.
3. The owner pays through Stripe-hosted Checkout.
4. Stripe sends a signed webhook to Waflo.
5. Waflo verifies the signature and processes the event idempotently.
6. Waflo maps the Stripe subscription, product, and price to an approved Waflo
   plan.
7. Waflo updates internal subscription references and effective entitlement
   records in a transactionally safe way.
8. The API returns effective entitlements and limits for the authoritative
   workspace.
9. Web and Mobile refresh their presentation from the API.
10. The backend rejects operations outside the effective entitlement even when
    a client shows or submits the action.

A Checkout success redirect is not proof of payment. A webhook must not grant
access until its signature, event identity, mapping, and workspace relationship
are verified.

## Logical concepts

The architecture needs the following logical concepts. They are not a claim
that matching database tables currently exist:

- `Plan`: Waflo's commercial product tier.
- `PlanFeature`: a named capability associated with a plan.
- `PlanLimit`: a numeric or bounded allowance associated with a plan.
- `WorkspaceSubscription`: the workspace's normalized subscription state.
- `EffectiveEntitlement`: the computed allow/deny result for one capability.
- `UsageCounter`: authoritative current use for quota evaluation.
- `BillingCustomerReference`: a protected mapping to the billing customer.
- `BillingSubscriptionReference`: a protected mapping to the external
  subscription.
- `BillingEvent`: a uniquely identified, verified event and processing result.
- `EntitlementEvaluation`: the role-aware, workspace-scoped decision made for
  an operation.
- `GracePeriod`: an explicitly approved temporary-access policy, if any.
- `CancellationState`: requested, scheduled, and effective cancellation
  semantics.
- `TrialState`: trial start, end, eligibility, and effective access.

The existing repository has `Plan` and `Subscription` schema foundations and a
documented API direction, but its billing module is a runtime stub. It does not
currently provide a complete Checkout, portal, webhook, reconciliation, or
entitlement system.

## Entitlement keys

Entitlements should use stable product-facing keys rather than UI labels or
Stripe price identifiers. Candidate keys include:

- `menu.products.max`
- `menu.categories.max`
- `staff.max`
- `locations.max`
- `loyalty.enabled`
- `loyalty.programs.max`
- `loyalty.customBranding`
- `notifications.manual`
- `notifications.automation`
- `media.upload`
- `analytics.advanced`
- `wallet.apple`
- `wallet.google`

Boolean features and numeric limits must remain distinguishable. Unknown keys,
missing mappings, invalid values, or ambiguous workspace state must fail closed
for the protected operation while producing a safe diagnostic for operators.

## Enforcement requirements

Entitlement enforcement must be:

- server-side, never dependent only on disabled buttons
- tenant-scoped to the authoritative workspace
- role-aware, so a paid feature never bypasses staff authorization
- atomic where quota-changing operations occur
- safe under repeated webhooks
- safe under delayed and out-of-order events
- idempotent by external event identity and internal mutation intent
- fail closed for unknown or invalid entitlement state
- auditable without logging secrets, payment data, or unnecessary PII

For a quota-changing mutation, the backend must evaluate current usage and
reserve or apply the change within the same safe boundary. A client-side count
followed by an unrestricted create is not quota enforcement.

Entitlements add a commercial gate; they never replace authentication,
workspace ownership, tenant isolation, role checks, resource ownership, rate
limits, or abuse protection.

## Subscription states

Waflo must normalize Stripe lifecycle state into explicit product behavior.
The commercial owner must approve the exact access policy before release.

| State | Honest product behavior |
| --- | --- |
| `trialing` | Apply only the approved trial entitlements until the verified trial end. |
| `active` | Apply the mapped active-plan entitlements after verified synchronization. |
| `past_due` | Show a clear billing status; access policy depends on an approved grace-period decision. |
| `unpaid` | Do not assume continued paid access; use the approved restriction policy. |
| `paused` | Apply an explicit paused-subscription policy, not the previous cached state. |
| `canceled` | Respect whether cancellation is immediate or effective at period end, based on verified fields. |
| `incomplete` | Do not treat Checkout initiation as active paid access. |
| `incomplete_expired` | Do not grant the attempted plan; offer an authorized web retry path when approved. |
| Grace period | Exists only if product/commercial policy defines duration, features, messaging, and exit behavior. |

Waflo does not yet have an approved grace-period business policy. Duration,
eligible states, retained capabilities, owner messaging, and final restriction
behavior are required commercial decisions, not engineering guesses.

## Synchronization and recovery

The billing implementation must eventually define:

- verified webhook signature handling
- event deduplication and durable processing state
- safe handling of out-of-order subscription and invoice events
- periodic reconciliation against Stripe
- explicit mapping for unknown product/price identifiers
- retry and dead-letter operational handling
- observability without sensitive payload leakage
- a repair process that does not require editing client-local state

Until that exists, Waflo must not advertise paid enforcement as complete.

## Surface behavior

### Waflo Web Studio

Web Studio owns plan comparison, authorized Checkout creation, billing status,
portal access, invoices, payment-method administration, and detailed quota
visibility. All actions call the backend; the browser does not choose arbitrary
workspace, price, or entitlement identifiers.

### Waflo Mobile Operations

Mobile is primarily a companion and operational client. It may consume
read-only effective plan, entitlement, and quota status. It must not infer paid
access, create its own billing state, or silently turn an entitlement failure
into success.

Existing paid access may be consumed after a web purchase. Payment links,
upgrade calls to action, portal links, and external purchase language must be
reviewed per store, region, and build. Do not universally hardcode external
Stripe Checkout links into iOS or Android applications. Billing UI may differ
by platform policy. This is a product-engineering boundary, not a legal
guarantee.

### Waflo Customer Web

Customer Web does not expose owner billing. It may reflect customer-facing
features enabled for a restaurant, but it cannot evaluate or override the
restaurant's subscription locally.

### Waflo Platform Backend

The backend verifies billing events, maps plans, computes effective access,
enforces entitlements and quotas, and returns safe status to clients. UI hiding
is not authorization or entitlement enforcement.

## Current implementation boundary

- Do not expose the current admin mock subscription page as product truth.
- Do not present the mobile subscription screen as active billing.
- Do not claim the schema's Stripe reference fields prove a synchronized
  subscription.
- Do not claim API contract text proves its endpoint runtime exists.
- Do not gate a paid launch on an entitlement system until Checkout, signed
  webhooks, synchronization, evaluation, enforcement, and recovery have passed
  end-to-end review.

Billing and entitlements remain future implementation work in the sequence
defined by
[WAFLO_PRODUCT_SURFACE_SPLIT_V1.md](WAFLO_PRODUCT_SURFACE_SPLIT_V1.md).
