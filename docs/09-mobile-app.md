# Mobile App

`apps/mobile` is the Flutter app for business owners, managers, and staff.

It is not a customer app.

## Responsibilities

- Business owner app.
- Manager tools.
- Staff scanner later.
- Clerk mobile sign-in.
- API integration.
- Business setup.
- Menu management.
- QR screen.
- Subscription screen.

## Routes and Screens

- Login
- Dashboard
- Business setup
- Menu
- QR
- Subscription
- Staff scanner

## API Client

The mobile app uses `API_BASE_URL` from `apps/mobile/.env`.

Rules:

- Send Clerk token in `Authorization` header for authenticated API calls.
- Never access the database directly.
- Use the API contract as the source of truth.
- Handle loading, error, unauthorized, and forbidden states.

## Role-Based UI

- Owner sees all business tools.
- Manager sees menu, customers, and staff areas depending on backend permissions.
- Staff sees scanner and own activity later.

The UI can hide actions, but the backend must enforce permissions.

## Clerk

Clerk Flutter SDK integration belongs under `lib/core/auth`.

Customers must not be added to the Flutter app.
