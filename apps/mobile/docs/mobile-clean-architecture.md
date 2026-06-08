# Tavrix Menu Mobile Clean Architecture

## Architecture goals

The Tavrix Menu Flutter app uses Clean Architecture with BLoC/Cubit for state management.

Goals:

- Keep business rules outside widgets.
- Keep API details outside presentation code.
- Make features easy to test.
- Make feature boundaries clear.
- Keep Sprint 1 simple while leaving room for dependency injection and testing later.
- Use Cubit for simple feature state and Bloc only for complex event-driven flows.

Do not use Riverpod. Do not use Provider as the official app state management approach.

## Folder structure

Recommended structure:

```text
lib/
  main.dart
  app/
    tavrix_menu_app.dart
    router/
      app_router.dart
      route_names.dart
    di/
      injection.dart
    config/
      app_config.dart

  core/
    constants/
      app_colors.dart
      app_spacing.dart
      app_radius.dart
      app_shadows.dart
    theme/
      app_theme.dart
    network/
      api_client.dart
      auth_interceptor.dart
      api_exception.dart
    auth/
      token_provider.dart
      clerk_token_provider.dart
      dev_token_provider.dart
    errors/
      failures.dart
      exceptions.dart
    utils/
      money_formatter.dart
      responsive.dart
    localization/

  shared/
    widgets/
      app_button.dart
      app_card.dart
      app_text_field.dart
      app_scaffold.dart
      loading_view.dart
      error_view.dart
      empty_state.dart
      section_header.dart
      status_badge.dart

  features/
    auth/
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        bloc/
        pages/
        widgets/

    business_setup/
      data/
      domain/
      presentation/

    dashboard/
      data/
      domain/
      presentation/

    menu/
      data/
      domain/
      presentation/

    qr/
      data/
      domain/
      presentation/

    subscription/
      data/
      domain/
      presentation/

    staff_scanner/
      data/
      domain/
      presentation/
```

## Layer responsibilities

Clean Architecture separates code by responsibility.

- Presentation layer contains pages, widgets, Cubits/Blocs, and states.
- Domain layer contains entities, repository interfaces, and use cases.
- Data layer contains API models, remote data sources, and repository implementations.
- Core contains app-wide infrastructure, constants, networking, auth, errors, utilities, theme, and localization.
- Shared widgets contain reusable UI components that are not owned by one feature.

Dependency direction should flow inward:

```text
UI -> Cubit/Bloc -> Use case -> Repository interface -> Repository implementation -> Remote data source -> ApiClient
```

## Core layer

The `core` layer contains app-wide foundations.

Use it for:

- Theme tokens such as colors, spacing, radius, shadows, and typography.
- Network infrastructure such as `ApiClient`, auth interceptors, and API exceptions.
- Token providers for Clerk and local development.
- Shared error and failure types.
- App utilities such as money formatting and responsive helpers.
- Localization setup.

Rules:

- Core code should not depend on feature implementation details.
- Core networking should read base URLs from config or environment.
- Core auth should provide tokens through abstractions.

## Shared widgets layer

The `shared/widgets` layer contains reusable UI primitives.

Examples:

- `AppButton`
- `AppCard`
- `AppTextField`
- `AppScaffold`
- `LoadingView`
- `ErrorView`
- `EmptyState`
- `AppSectionHeader`
- `StatusBadge`
- `RoleBadge`

Rules:

- Shared widgets use official design tokens.
- Shared widgets do not call Dio or APIs directly.
- Shared widgets do not contain feature business logic.
- Shared widgets can receive callbacks, values, and display models from feature presentation code.

## Feature structure

Each feature owns its data, domain, and presentation code.

Recommended feature folders:

- `auth`
- `business_setup`
- `dashboard`
- `menu`
- `qr`
- `subscription`
- `staff_scanner`

Feature rules:

- Keep feature-specific widgets inside that feature.
- Move only truly reusable widgets into `shared/widgets`.
- Keep Cubits/Blocs close to the feature they serve.
- Do not create a giant global app state for all features.

## Data layer rules

The data layer handles external data access and mapping.

It contains:

- API DTOs and models
- Remote data sources
- Repository implementations

Rules:

- Repository implementations call remote data sources.
- Remote data sources call `ApiClient`.
- Map API DTOs into domain entities before returning to domain or presentation.
- Keep API URL paths out of widgets.
- Use the official business and item endpoints.
- The mobile app never accesses the database directly.

## Domain layer rules

The domain layer holds business meaning without Flutter or API framework details.

It contains:

- Entities
- Repository interfaces
- Use cases

Rules:

- Domain code should not import Flutter UI packages.
- Domain code should not know about Dio, JSON DTOs, or HTTP details.
- Use cases should express business actions clearly.
- Repository interfaces should use business language and backend contract names.
- Use business identifiers from the API contract.

## Presentation layer rules

The presentation layer owns UI state and rendering.

It contains:

- Pages
- Feature widgets
- Cubits/Blocs
- State classes

Rules:

- UI must not call Dio or `ApiClient` directly.
- UI must call a Cubit or Bloc.
- Cubit/Bloc calls use cases.
- No business logic inside widgets.
- No API URLs hardcoded inside UI.
- Keep states explicit and easy to render.
- Every remote screen should handle loading, error, empty, and success states.

## BLoC/Cubit rules

Use BLoC/Cubit from the Flutter BLoC ecosystem as the official state management approach.

Rules:

- Use Cubit for simple screen state.
- Use Bloc for complex event-driven flows.
- State classes should be immutable.
- Each feature owns its own Cubit or Bloc.
- Avoid giant global app state.
- Do not use Riverpod.
- Do not use Provider as official app state management.

Example naming:

- `AuthCubit` / `AuthState`
- `BusinessSetupCubit` / `BusinessSetupState`
- `DashboardCubit` / `DashboardState`
- `MenuCubit` / `MenuState`
- `QrCubit` / `QrState`
- `SubscriptionCubit` / `SubscriptionState`
- `StaffScannerBloc` / `StaffScannerEvent` / `StaffScannerState` later

## Dependency injection plan

Prepare for `get_it` or `injectable` later without over-engineering Sprint 1.

Rules:

- Keep constructors injectable and testable.
- Pass dependencies through constructors.
- Avoid creating service locators inside widgets.
- Keep `app/di/injection.dart` as the future home for dependency registration.
- Do not add DI packages until implementation work actually needs them.

## API integration rules

The mobile app talks only to the backend API. The backend is the source of truth.

Rules:

- `API_BASE_URL` comes from config or environment.
- Clerk token provider supplies the auth token later.
- `ApiClient` adds `Authorization: Bearer <token>` later.
- Use the official business and menu item endpoint contract.
- Use business identifiers from the API contract.
- Mobile code never accesses the database directly.
- Keep API response mapping inside the data layer.

Example paths:

```text
GET /me
POST /businesses
GET /businesses/me
PATCH /businesses/:id
POST /businesses/:id/categories
GET /businesses/:id/categories
POST /businesses/:id/items
GET /businesses/:id/items
PATCH /items/:id
DELETE /items/:id
```

## Error handling

Errors should be predictable from API to UI.

Rules:

- Convert network exceptions into app-level failures.
- Keep raw API exceptions out of widgets.
- Cubits/Blocs should expose user-friendly error states.
- Forms should show field-level validation where possible.
- Retry actions should be available for recoverable failures.
- Auth failures should route users back to the auth flow when appropriate.

## Testing strategy

Testing should grow with risk and feature maturity.

Rules:

- `flutter analyze` must pass.
- Cubits should have unit tests later.
- Use cases should be unit testable with mocked repositories later.
- Widgets should have smoke tests later.
- API client should be testable with a mocked HTTP client later.
- Keep constructors and dependencies test-friendly from the start.

## Naming conventions

Use business-first names that match the API contract where code crosses the network boundary.

- Use business setup, menu, QR, subscription, and staff scanner language.
- Name Cubits, Blocs, states, and use cases after the feature action they represent.
- Keep API DTO names separate from domain entity names when they differ.
- Use `MenuItem` for backend item entities and DTOs.

Examples:

- `Business`
- `BusinessSetupCubit`
- `MenuItem`
- `MenuRepository`
- `GetBusinessMenuUseCase`
- `UpdateMenuItemUseCase`
- `QrCubit`

## What not to do

Do not:

- Build customer ordering flows in the Flutter app.
- Add cart, checkout, customer order history, or customer profile screens.
- Add customer rewards app navigation.
- Call Dio or `ApiClient` directly from widgets.
- Hardcode API URLs inside UI.
- Access the database directly from mobile code.
- Use legacy restaurant endpoint naming.
- Use product endpoint naming for API routes; the backend model is `MenuItem`, so routes use items.
- Use Riverpod.
- Use Provider as official app state management.
- Add packages during documentation-only tasks.
- Modify backend, customer web, admin web, root docs, or root package files from mobile documentation work.
