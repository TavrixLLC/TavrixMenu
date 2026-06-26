# Tavrix Menu Mobile

Flutter app for Tavrix Menu business owners and operators.

Customers do not use this app. Customers browse menus through customer-web. Customer ordering, cart, and checkout are not part of the Flutter app.

## Architecture

The mobile app uses Clean Architecture with BLoC/Cubit state management. Use Cubit for simple feature state and Bloc only for complex event-driven flows.

## Documentation

- [Mobile Design System](docs/mobile-design-system.md)
- [Mobile Clean Architecture](docs/mobile-clean-architecture.md)
- [Raw Design Reference](docs/reference/design-raw.md)

## Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Product Owner QA Debug APK

Build the debug APK with the staging operator auth configuration supplied as
Dart defines. Use the real staging values locally, but do not commit them:

```bash
flutter build apk --debug \
  --dart-define=API_BASE_URL=<staging-api-url> \
  --dart-define=CLERK_PUBLISHABLE_KEY=<staging-clerk-publishable-key> \
  --dart-define=CUSTOMER_WEB_BASE_URL=<staging-customer-web-url>
```

## Environment variables

- `API_BASE_URL`
- `CLERK_PUBLISHABLE_KEY`
- `CUSTOMER_WEB_BASE_URL`
