# Loyalty System

Loyalty is a future module. It must be web-based for customers because customers do not download an app.

## Initial Loyalty Types

- Stamp Card
- Points Card
- Product-specific Card
- Coupon
- Birthday Reward
- Visit Card

## Customer Flow

1. Customer opens the public menu website.
2. Customer joins loyalty from the menu website.
3. Customer enters simple details such as name and phone later.
4. Customer receives a web loyalty card with a QR token.
5. Customer can open the card from `/card/[cardToken]`.
6. Later, customer can add the card to Apple Wallet or Google Wallet.

Customers do not use Clerk.

## Staff Flow

1. Staff signs in to the Flutter app.
2. Staff opens scanner.
3. Staff scans customer card QR.
4. Staff can add stamps, add points, or redeem rewards depending on permissions.
5. Backend creates a loyalty transaction for every action.

Staff must not be able to edit loyalty rules unless explicitly allowed later.

## QR Token Rule

The loyalty card QR token must not contain sensitive data. It should be random, unguessable, and mapped to a server-side card record.

## Future Models

- `LoyaltyProgram`
- `Customer`
- `CustomerLoyaltyCard`
- `LoyaltyTransaction`
- `Reward`
- `RewardRedemption`
- `WalletPass`

## Security Rules

- Every loyalty record belongs to a `business_id`.
- Staff actions require backend permission checks.
- Redemptions must be idempotent where possible.
- Sensitive actions must be audited.
