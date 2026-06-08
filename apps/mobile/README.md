# Tavrix Menu Mobile

Flutter app foundation for Tavrix Menu business owners, managers, and staff.

Customers do not use this app and do not need to download anything to browse menus.

## Install

```bash
flutter pub get
```

## Run

```bash
flutter run
```

## Environment

Copy the example env file:

```bash
cp .env.example .env
```

Configure:

- `API_BASE_URL` for the NestJS API base URL.
- `CLERK_PUBLISHABLE_KEY` for the future Clerk Flutter SDK setup.

Clerk Flutter SDK integration will be added under `lib/core/auth` for business owners, managers, and staff auth.
