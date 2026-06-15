# Tavrix Menu Mobile Design System

## Purpose

This is the official design guide for the Tavrix Menu Flutter app. It defines the visual language, shared UI rules, and quality expectations for the business-facing mobile product.

The raw design reference in `docs/reference/design-raw.md` is a reference only. It is not official product scope.

## App scope

This app is for business owners, managers, and staff only. Customers do not use this app. Customers use customer-web to browse menus.

Customer ordering, cart, and checkout are not part of the Flutter app.

Screens in scope:

- Login
- Business setup
- Dashboard
- Menu management
- Category management
- Product editor
- Product image uploader later
- QR screen
- Subscription screen
- Staff scanner later
- AI recommendation management later
- Loyalty management later

## Explicitly out of scope

The Flutter app must not include customer app flows:

- Customer home
- Customer cart
- Customer checkout
- Customer order history
- Customer profile
- Customer rewards app
- Customer product customization for ordering
- Floating cart button
- Customer bottom navigation such as Home, Menu, Rewards, Orders, or Profile
- Customer ordering APIs

## Visual identity

Tavrix Menu mobile should feel warm, clean, mobile-native, and operationally useful. The app should support fast business actions without becoming a customer ordering app.

Use:

- Warm cream or ceramic app backgrounds
- Deep green brand and premium sections
- Bright green primary CTAs
- White cards with soft layered shadows
- 12px rounded cards
- Pill-shaped buttons
- Clear product and menu management cards
- Clean admin and business management forms

Gold is reserved only for loyalty or reward moments later.

## Color tokens

Use shared theme tokens instead of hardcoded colors in screens.

| Token | Value | Usage |
| --- | --- | --- |
| `brandGreen` | `0xFF006241` | Main brand green |
| `greenAccent` | `0xFF00754A` | Primary CTAs and active states |
| `houseGreen` | `0xFF1E3932` | Premium sections, headers, dark surfaces |
| `greenLight` | `0xFFD4E9E2` | Soft green backgrounds and highlights |
| `gold` | `0xFFCBA258` | Loyalty and reward moments later only |
| `neutralWarm` | `0xFFF2F0EB` | Main warm app background |
| `ceramic` | `0xFFEDEBE9` | Secondary app background and dividers |
| `white` | `0xFFFFFFFF` | Cards and elevated surfaces |
| `textBlack` | `0xDE000000` | Primary text |
| `textBlackSoft` | `0x94000000` | Secondary text |
| `error` | `0xFFC82014` | Destructive and error states |
| `warning` | `0xFFFBBC05` | Warnings and attention states |

Rules:

- App background should usually be `neutralWarm` or `ceramic`.
- Cards should be `white` with 12px radius.
- Primary actions should use `greenAccent`.
- Premium and header sections can use `houseGreen`.
- Gold must only be used for loyalty and reward moments later.
- Do not hardcode random colors in screens.

## Spacing tokens

Use shared spacing tokens for predictable layout rhythm.

| Token | Value |
| --- | --- |
| `xxs` | `4` |
| `xs` | `8` |
| `sm` | `12` |
| `md` | `16` |
| `lg` | `24` |
| `xl` | `32` |
| `xxl` | `40` |
| `section` | `64` |

Rules:

- Use `md` as the default screen padding.
- Use `sm` or `md` inside cards and form groups.
- Use `lg` between major screen blocks.
- Use `section` only for large vertical breaks.

## Radius tokens

Use shared radius tokens. Do not invent one-off radius values in screens.

| Token | Value | Usage |
| --- | --- | --- |
| `sm` | `4` | Small chips, icons, subtle inner elements |
| `md` | `12` | Default cards, fields, panels |
| `lg` | `20` | Larger feature surfaces and sheets |
| `pill` | `50` | Buttons, segmented controls, badges |
| `circle` | `999` | Circular avatars and icon buttons |

Rules:

- Cards should use `md`.
- Buttons must be pill-shaped.
- Badges should usually use `pill`.

## Shadow tokens

Shadows should be soft and layered, never heavy or harsh.

Recommended tokens:

- `soft`: Low elevation for cards and fields.
- `medium`: Interactive surfaces, bottom sheets, menus.
- `strong`: Rare use for dialogs or blocking overlays.

Rules:

- Prefer subtle elevation over visible borders.
- Avoid dark, sharp shadows.
- Keep forms calm and easy to scan.

## Typography rules

Typography should prioritize clarity, scanning, and mobile usability.

- Use the app theme text styles instead of ad hoc font sizes.
- Use strong headings for page titles and section headers.
- Keep card titles short and scannable.
- Use secondary text for metadata, helper text, and timestamps.
- Avoid all-caps body text.
- Keep line lengths readable on small screens.
- Prepare text styles for Arabic and RTL without manual layout hacks.

## Shared widgets

Shared widgets should live under the mobile shared widgets layer and use the app tokens by default.

Required shared widgets:

- `AppScaffold`
- `AppButton`
- `AppCard`
- `AppTextField`
- `AppDropdown`
- `AppSectionHeader`
- `LoadingView`
- `ErrorView`
- `EmptyState`
- `AppCachedImage` later
- `StatusBadge`
- `RoleBadge`
- `BusinessHeaderCard`
- `MenuItemCard`
- `QRPreviewCard`

Widget rules:

- Shared widgets should be reusable across features.
- Shared widgets should not call APIs directly.
- Shared widgets should not own business logic.
- Forms should use consistent labels, validation messages, spacing, and disabled states.
- Menu cards should support business editing workflows, not customer cart actions.

## Screen layout rules

Screens must feel native to mobile.

- Respect safe areas on every screen.
- Use scrollable layouts for content that can exceed viewport height.
- Keep primary actions reachable and visually clear.
- Use warm backgrounds with white elevated content surfaces.
- Keep touch targets at least 44px.
- Avoid desktop-style dense tables on small screens.
- Use product/menu management cards for menu operations.
- Use clean forms for business setup and admin actions.
- Do not add a floating cart button.

## Navigation rules

Navigation should match business workflows.

- Use an auth shell for unauthenticated screens.
- Route business users into setup when no active business exists.
- Route business users into the dashboard when setup is complete.
- Keep menu management, QR, subscription, and staff tools easy to reach from the business app shell.
- Do not use customer bottom navigation such as Home, Menu, Rewards, Orders, or Profile.
- Do not create customer ordering navigation.

## Role-based UI rules

The UI should adapt to business roles without duplicating whole screens unless necessary.

- Owners can access business setup, subscription, staff management later, and full menu management.
- Managers can access operational dashboard and menu management where permitted.
- Staff can access staff-specific tools, including scanner features later.
- Use `RoleBadge` to show role context where helpful.
- Hide or disable actions based on backend permissions.
- Backend permissions are the source of truth.

## Localization and RTL rules

The app must be Arabic/RTL ready.

- Use localization-ready strings.
- Avoid hardcoded English inside reusable widgets where localization is expected.
- Use direction-aware padding, alignment, and icons.
- Prefer `EdgeInsetsDirectional` and direction-aware layout APIs.
- Test important screens in RTL before release.
- Do not rely on left/right assumptions for navigation or forms.

## Accessibility rules

Accessibility is part of the design system, not a late polish pass.

- Touch targets must be at least 44px.
- Text must meet readable contrast on warm and green surfaces.
- Buttons and icon actions need semantic labels.
- Disabled states must be visible and understandable.
- Error messages should be specific and tied to the related field or action.
- Loading, empty, and error states must be available for every remote screen.
- Do not communicate important state through color only.

## Performance rules

The mobile app should feel fast on everyday devices.

- Keep dashboard and menu screens lightweight.
- Lazy load large images and use caching later through `AppCachedImage`.
- Avoid unnecessary rebuilds in Cubit/Bloc state changes.
- Use pagination or incremental loading for long menu lists later.
- Compress uploaded product images later.
- Keep animations subtle and cheap.

## Quality checklist

Before a screen is considered complete:

- It uses official color, spacing, radius, shadow, and typography tokens.
- It is business-only and contains no customer ordering scope.
- It handles loading, empty, and error states.
- It is safe-area aware.
- It works with small screens.
- It is Arabic/RTL ready.
- Touch targets are at least 44px.
- Primary actions use `greenAccent`.
- Cards are white with 12px radius.
- Buttons are pill-shaped.
- No random colors or random radius values are hardcoded in the screen.
- No cart, checkout, customer profile, or customer order history UI is present.
- No Riverpod recommendation or dependency is introduced.
