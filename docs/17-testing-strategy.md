# Testing Strategy

Testing should grow with risk. Early sprints can use focused smoke tests and type checks, then add deeper coverage around auth, billing, and tenant isolation.

## Backend

Add:

- Unit tests.
- Service tests.
- E2E tests.
- Auth guard tests.
- Business isolation tests.
- Public menu tests.
- Stripe webhook tests later.

Critical backend test cases:

- User cannot access another business.
- Staff cannot edit menu.
- Public endpoint hides inactive categories and unavailable items.
- Stripe webhook rejects invalid signatures.
- Admin endpoint rejects non-admin users.

## Customer Web

Add:

- Component tests later.
- Route smoke tests.
- API integration states.
- Loading state.
- Error state.
- Not-found state.

Customer web should be tested on mobile-size viewports.

## Admin Web

Add:

- Auth state tests later.
- Dashboard smoke tests.
- Table rendering tests.
- API error state tests.

## Flutter

Run:

```bash
flutter analyze
flutter test
```

Add:

- Widget tests.
- API client tests.
- Navigation tests.
- Role-based UI tests later.

## Required Checks Before PR

Run the checks that match the files changed:

Backend:

```bash
corepack pnpm --filter tavrix-menu-api prisma:generate
corepack pnpm --filter tavrix-menu-api build
corepack pnpm --filter tavrix-menu-api lint
```

Customer web:

```bash
corepack pnpm --filter @tavrix-menu/customer-web build
```

Admin web:

```bash
corepack pnpm --filter @tavrix-menu/admin-web build
```

Flutter:

```bash
cd apps/mobile
flutter analyze
flutter test
```

Full JS workspace:

```bash
corepack pnpm lint
corepack pnpm build
```
