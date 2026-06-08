# Admin Dashboard

`apps/admin-web` is the internal dashboard for Tavrix Menu service owners.

It is not for restaurant or cafe owners. Business owners, managers, and staff use the Flutter app.

## Auth

Admin web will use Clerk for login plus backend admin verification.

Rules:

- Frontend route protection is helpful but not enough.
- Backend admin endpoints must verify admin access.
- Do not trust frontend-only admin state.

## Pages

- Dashboard
- Businesses
- Subscriptions
- Logs

## Current Foundation

The dashboard currently uses mock data. It shows placeholders for:

- Total businesses.
- Active subscriptions.
- AI usage.
- Loyalty cards.
- Recent logs.
- Business table.
- Subscription status.

## Future Admin Capabilities

- View businesses.
- Suspend or reactivate a business.
- See subscription status.
- See AI usage.
- See errors and logs.
- Manual plan override later.
- Support and operational tools later.

Admin actions that change business state must create audit logs.
