# Stripe Billing

Stripe will manage Tavrix Menu subscriptions. The backend owns billing state and updates subscriptions from verified Stripe webhooks.

## Plans

### Tavrix Menu Basic

- 19 USD monthly
- 190 USD yearly
- 100 menu items
- 1 branch
- 3 staff users
- QR menu
- Basic analytics
- No wallet integration initially
- No custom domain initially

### Tavrix Menu Pro

- 49 USD monthly
- 490 USD yearly
- 500 menu items
- 5 branches
- 15 staff users
- AI suggestions
- Loyalty later
- Custom domain later
- Wallet integration later
- Advanced analytics later

Actual Stripe product IDs and price IDs will be configured later.

## Checkout Flow

1. Owner selects a plan in the Flutter app.
2. Flutter calls `POST /billing/checkout`.
3. Backend verifies the user is owner for the business.
4. Backend creates a Stripe Checkout Session.
5. Backend returns `checkoutUrl`.
6. Flutter opens the checkout URL.
7. Stripe redirects the user after payment.
8. Stripe sends webhook events to the backend.
9. Backend updates `Subscription` only from verified webhook events.

Never trust the frontend to activate a subscription.

## Customer Portal Flow

1. Owner taps manage billing.
2. Flutter calls `POST /billing/portal`.
3. Backend verifies owner access and Stripe customer ID.
4. Backend creates a Stripe customer portal session.
5. Flutter opens the portal URL.

## Webhook Security

Stripe webhooks must:

- Use the raw request body.
- Verify `STRIPE_WEBHOOK_SECRET`.
- Ignore unverified events.
- Be idempotent.
- Update subscription state from Stripe event data.
- Log important billing events.

## Environment Variables

API:

- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`

Plan IDs:

- Store Stripe price IDs in `Plan.stripeMonthlyPriceId`.
- Store Stripe price IDs in `Plan.stripeYearlyPriceId`.

Do not commit real Stripe secrets.
