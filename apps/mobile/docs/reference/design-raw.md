# Flutter Mobile App README

> Mobile-first design system and implementation guide for a Flutter café / restaurant ordering app inspired by the warm Starbucks-style visual language. This README is written for a Flutter mobile app, not a web landing page.

## Purpose

This project uses a warm café visual identity built around cream surfaces, deep green brand areas, rounded cards, pill buttons, product photography, and a persistent ordering action. The goal is to make the mobile app feel like a premium coffeehouse product: clean, calm, tactile, and easy to use with one hand.

Use this README as the source of truth for:

- Flutter theme tokens
- App folder structure
- Reusable widgets
- Mobile navigation patterns
- Product/menu screen rules
- Rewards/loyalty UI rules
- Asset and typography setup
- Development and quality checklist

## Mobile App Experience

The Flutter app should feel native, not like a website squeezed into a phone. The interface should be built around fast ordering, menu browsing, loyalty, QR/menu sharing, and restaurant management flows if the app has an admin side.

Core mobile principles:

- Use a warm cream app canvas instead of pure white.
- Use dark green for premium brand sections, loyalty moments, and important headers.
- Use bright green only for primary actions.
- Keep buttons pill-shaped everywhere.
- Use 12px rounded cards for menu items, rewards cards, settings panels, and forms.
- Keep shadows soft and layered.
- Use bottom navigation or a shell layout instead of desktop top navigation.
- Keep every important touch target at least 44px high.
- Make product cards photo-first, with price and CTA clearly visible.
- Make the order/cart action persistent and reachable with the thumb.

## Recommended App Screens

### Customer App

- Splash screen
- Onboarding / brand introduction
- Login / sign up
- Home
- Menu categories
- Product list
- Product details
- Product customization
- Cart
- Checkout / order summary
- Rewards / loyalty card
- Gift cards or offers
- Order history
- Profile
- Store selector
- Notifications

### Restaurant/Admin App

- Admin login
- Restaurant dashboard
- Menu manager
- Category manager
- Product editor
- Product image uploader
- QR code / website link screen
- Loyalty card generator
- Orders overview
- Branch settings
- Domain connection settings
- AI recommendation settings

## Flutter Project Structure

Recommended structure:

```text
lib/
  main.dart
  app.dart

  core/
    constants/
      app_colors.dart
      app_spacing.dart
      app_radius.dart
      app_shadows.dart
      app_typography.dart
    theme/
      app_theme.dart
    utils/
      responsive.dart
      money_formatter.dart

  shared/
    widgets/
      app_scaffold.dart
      app_button.dart
      app_card.dart
      app_text_field.dart
      app_cached_image.dart
      quantity_stepper.dart
      section_header.dart
      floating_cart_button.dart
      empty_state.dart
      loading_view.dart
      error_view.dart

  features/
    auth/
      presentation/
      data/
      domain/
    home/
      presentation/
    menu/
      presentation/
      data/
      domain/
    product/
      presentation/
      data/
      domain/
    cart/
      presentation/
      data/
      domain/
    rewards/
      presentation/
      data/
      domain/
    profile/
      presentation/
    admin/
      presentation/
      data/
      domain/
```

For small projects, you can simplify this, but keep theme tokens and shared widgets separated from screens.

## Design Tokens for Flutter

### Colors

Create `lib/core/constants/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand greens
  static const starbucksGreen = Color(0xFF006241);
  static const greenAccent = Color(0xFF00754A);
  static const houseGreen = Color(0xFF1E3932);
  static const greenUplift = Color(0xFF2B5148);
  static const greenLight = Color(0xFFD4E9E2);

  // Rewards / loyalty
  static const gold = Color(0xFFCBA258);
  static const goldLight = Color(0xFFDFC49D);
  static const goldLightest = Color(0xFFFAF6EE);
  static const rewardsGreen = Color(0xFF33433D);

  // Surfaces
  static const white = Color(0xFFFFFFFF);
  static const neutralCool = Color(0xFFF9F9F9);
  static const neutralWarm = Color(0xFFF2F0EB);
  static const ceramic = Color(0xFFEDEBE9);
  static const black = Color(0xFF000000);

  // Text
  static const textBlack = Color(0xDE000000); // 87% black
  static const textBlackSoft = Color(0x94000000); // 58% black
  static const textWhite = Color(0xFFFFFFFF);
  static const textWhiteSoft = Color(0xB3FFFFFF); // 70% white

  // Semantic
  static const error = Color(0xFFC82014);
  static const warning = Color(0xFFFBBC05);
  static const successTint = Color(0x55D4E9E2);
  static const errorTint = Color(0x0DC82014);
}
```

Color usage rules:

| Use case | Color |
|---|---|
| App background | `neutralWarm` or `ceramic` |
| Main CTA | `greenAccent` |
| Brand headings | `starbucksGreen` |
| Dark feature/header bands | `houseGreen` |
| Card background | `white` |
| Loyalty/rewards accent | `gold` |
| Body text | `textBlack` |
| Secondary text | `textBlackSoft` |
| Error | `error` |

Do not use gold as a normal accent color. It should mean loyalty, reward level, premium badge, or points.

### Spacing

Create `lib/core/constants/app_spacing.dart`:

```dart
class AppSpacing {
  AppSpacing._();

  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
  static const xxxl = 56.0;
  static const section = 64.0;
}
```

Mobile spacing rules:

- Screen horizontal padding: `16px`
- Large phone/tablet horizontal padding: `24px`
- Card padding: `16px` or `24px`
- Section gap: `32px` to `40px`
- Button internal padding: at least `14px vertical` for mobile touch comfort

### Radius

Create `lib/core/constants/app_radius.dart`:

```dart
class AppRadius {
  AppRadius._();

  static const sm = 4.0;
  static const md = 12.0;
  static const lg = 20.0;
  static const pill = 50.0;
  static const circle = 999.0;
}
```

Usage:

- Cards: `12px`
- Modals / bottom sheets: `20px` top corners
- Buttons: `50px`
- Floating buttons: circle
- Inputs: `12px` for modern mobile forms, or `4px` for product customization selector boxes

### Shadows

Create `lib/core/constants/app_shadows.dart`:

```dart
import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const card = [
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 1,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 0.5,
      offset: Offset(0, 0),
    ),
  ];

  static const floating = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 6,
      offset: Offset(0, 0),
    ),
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 12,
      offset: Offset(0, 8),
    ),
  ];

  static const appBar = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 2,
      offset: Offset(0, 2),
    ),
  ];
}
```

Avoid heavy single shadows. Use subtle layered shadows.

## Theme Setup

Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.neutralWarm,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.greenAccent,
        primary: AppColors.greenAccent,
        secondary: AppColors.gold,
        surface: AppColors.white,
        error: AppColors.error,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          height: 1.15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.16,
          color: AppColors.textBlack,
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.16,
          color: AppColors.textBlack,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          height: 1.3,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.16,
          color: AppColors.starbucksGreen,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          height: 1.35,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          color: AppColors.textBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.1,
          color: AppColors.textBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.1,
          color: AppColors.textBlackSoft,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          height: 1.2,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenAccent,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.greenAccent,
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: const BorderSide(color: AppColors.greenAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFD6DBDE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFD6DBDE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.greenAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
```

In `app.dart`:

```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cafe App',
      theme: AppTheme.light(),
      home: const SizedBox(),
    );
  }
}
```

## Fonts

Do not use Starbucks proprietary fonts in production unless you have rights to them.

Recommended mobile-safe substitutes:

- `Inter` for clean premium UI
- `Manrope` for warmer rounded UI
- `Nunito Sans` for friendlier café feel
- `Lora` only for special rewards/editorial headings
- `Kalam` only for decorative handwritten loyalty/cup-name details

Example `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

## Core Widgets

### AppButton

Use one reusable button instead of styling buttons separately on every screen.

```dart
enum AppButtonVariant { filled, outlined, dark, inverted }
```

Rules:

- Filled: green background, white text.
- Outlined: green border, green text.
- Dark: black background, white text.
- Inverted: white background, green text, used on dark green surfaces.
- All variants use pill radius.
- All variants should animate slightly smaller on tap, around `scale: 0.95`.
- Minimum height should be `48px` on mobile.

### AppCard

Use for product tiles, loyalty cards, settings cards, and admin panels.

Visual rules:

- Background: white
- Radius: 12px
- Shadow: `AppShadows.card`
- Padding: 16px or 24px
- Place cards on warm cream background

### FloatingCartButton

Mobile replacement for the web floating CTA.

Rules:

- Size: `56px`
- Shape: circle
- Background: `greenAccent`
- Icon: white shopping bag/cart
- Position: bottom right, above safe area and bottom nav
- Shadow: `AppShadows.floating`
- Optional badge for item count
- Taps navigate to cart

### ProductCard

Used in menu grids/lists.

Required content:

- Product image
- Product name
- Short description or category
- Price
- Add button
- Optional loyalty points badge

Mobile layout:

- In list mode: image left, text middle, CTA right/bottom.
- In grid mode: image top, content bottom.
- Keep product images clean and photo-first.
- Avoid too much text inside the card.

### ProductDetailsScreen

Recommended sections:

1. Dark green product hero
2. Product image
3. Product name
4. Price
5. Rewards cost pill if applicable
6. Size selector
7. Add-ins/customization selectors
8. Quantity stepper
9. Add to cart button
10. Nutrition/ingredients accordion
11. AI recommendation card, if enabled

### AI Recommendation Card

For the feature that suggests items with a drink, show the recommendation as a card.

Required card content:

- Suggested item image
- Item name
- Price
- Short reason, for example: `Pairs well with Turkish coffee`
- Add button

Visual rules:

- White card on warm cream background
- 12px radius
- Soft shadow
- Product image should preserve the real product cutout/shadow style
- Do not show AI text as a chat bubble unless the screen is specifically an assistant screen

Example card copy:

```text
Recommended with Turkish Coffee
Date cookie
2,500 IQD
A sweet bite that balances the strong coffee flavor.
```

## Navigation for Flutter Mobile

Use mobile navigation patterns instead of web navigation.

Recommended customer app navigation:

- Home
- Menu
- Rewards
- Orders
- Profile

Recommended Flutter components:

- `NavigationBar` for Material 3 bottom navigation
- `ShellRoute` if using `go_router`
- `FloatingCartButton` above bottom nav
- `SliverAppBar` for scrollable product/menu pages
- Modal bottom sheets for filters, size selection, branch selector, and customization

Avoid desktop-style top nav links like `Menu · Rewards · Gift Cards` on mobile.

## Screen Layout Rules

### Home Screen

Use this rhythm:

1. Warm cream background
2. Header with greeting and branch/store selector
3. Dark green feature card for main promotion
4. Horizontal category chips
5. Recommended products
6. Popular products
7. Rewards summary card

### Menu Screen

Rules:

- Sticky or pinned category selector near the top
- Search field at the top
- Product list grouped by category
- Floating cart button always visible when cart has items
- Use shimmer/skeleton loading for images

### Product Details

Rules:

- Hero can be dark green for premium feel
- Product photo should be large and centered
- Customization options should appear as clear mobile rows
- The final `Add to Cart` button should be sticky at the bottom if the page is long

### Rewards Screen

Rules:

- Use dark green and gold carefully
- Gold means reward status, stars, level, premium badge, or loyalty ceremony
- Show points/stars clearly at the top
- Use cards for reward levels
- Show progress with a simple progress bar or circular progress indicator

### Admin Screens

Admin screens can use the same visual system, but should prioritize speed and clarity.

Rules:

- Use white cards over cream background
- Use green CTA for save/publish actions
- Use red only for destructive actions
- Use bottom sheets for quick edit actions
- Use clear empty states for missing menu items/products
- QR code screen should have a large preview card and share/download buttons

## Mobile Responsive Rules

Flutter does not use CSS breakpoints, so use constraints and device width.

Suggested helper:

```dart
class Responsive {
  static bool isCompact(BuildContext context) => MediaQuery.sizeOf(context).width < 600;
  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 1024;
  }
  static bool isExpanded(BuildContext context) => MediaQuery.sizeOf(context).width >= 1024;
}
```

Rules:

| Width | Behavior |
|---|---|
| `< 360px` | Single column, reduce horizontal padding to 12px if needed |
| `360–599px` | Standard phone layout, 16px padding |
| `600–1023px` | Large phone/tablet, 24px padding, optional 2-column product grid |
| `1024px+` | Tablet/desktop layout, max content width, side panels possible |

Use `SafeArea` on screens with bottom buttons, floating buttons, or notches.

## Interaction Rules

- Button active feedback: scale to `0.95`.
- Image fade-in: use `FadeInImage`, `CachedNetworkImage`, or `Image` with animated opacity.
- Accordions: animate around `300ms`.
- Bottom sheets: rounded top corners with 20px radius.
- Loading: use skeleton cards for product lists, not only spinners.
- Empty states: use short friendly text and one clear CTA.
- Errors: show concise message plus retry action.

## Assets

Recommended asset structure:

```text
assets/
  fonts/
  images/
    products/
    categories/
    rewards/
    onboarding/
  icons/
  lottie/
```

Image rules:

- Product images should use clean backgrounds or transparent cutouts.
- Preserve natural product shadows when available.
- Do not mix many illustration styles in one screen.
- Category icons should be simple and consistent.
- Rewards imagery can feel more ceremonial and premium.

`pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/images/products/
    - assets/images/categories/
    - assets/images/rewards/
    - assets/icons/
```

## State Management

Any of these can work:

- Riverpod for scalable apps
- Bloc/Cubit for strict enterprise style
- Provider for smaller apps

Recommended for this app: Riverpod.

Suggested feature state:

- Auth state
- Current restaurant/branch
- Menu categories
- Products
- Cart
- Rewards profile
- Orders
- Admin draft menu edits
- Upload progress

## API Integration Notes

Recommended backend contracts:

```text
GET    /restaurants/:id
GET    /restaurants/:id/menu
GET    /restaurants/:id/products
GET    /products/:id
POST   /cart/price-preview
POST   /orders
GET    /orders
GET    /loyalty/profile
POST   /loyalty/cards/generate
POST   /ai/recommendations
POST   /admin/products
PATCH  /admin/products/:id
DELETE /admin/products/:id
POST   /admin/assets/upload
POST   /admin/qr-code/generate
POST   /admin/domain/connect
```

The AI recommendations endpoint should return structured data, not just text:

```json
{
  "title": "Recommended with Turkish Coffee",
  "items": [
    {
      "id": "date-cookie",
      "name": "Date Cookie",
      "price": 2500,
      "currency": "IQD",
      "imageUrl": "https://example.com/date-cookie.png",
      "reason": "A sweet bite that balances the strong coffee flavor."
    }
  ]
}
```

## Accessibility

Minimum requirements:

- Touch targets at least 44px high.
- Text contrast must remain readable on green and cream surfaces.
- Do not rely on color alone for errors.
- Product images need semantic labels where useful.
- Buttons need clear labels for screen readers.
- Support dynamic text sizes without breaking cards.
- Checkout and admin forms must be keyboard-friendly.

## Localization and RTL

For Arabic/Kurdish/Iraqi market support:

- Enable localization from the start.
- Support RTL layout.
- Keep prices formatted by locale.
- Avoid hardcoded English strings in widgets.
- Product names can be bilingual.
- Admin fields should support Arabic product names and descriptions.

Example:

```dart
return MaterialApp(
  supportedLocales: const [
    Locale('en'),
    Locale('ar'),
    Locale('ku'),
  ],
  locale: const Locale('ar'),
  builder: (context, child) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: child!,
    );
  },
);
```

## Performance Rules

- Use cached network images.
- Compress product images before upload.
- Paginate long product lists.
- Avoid rebuilding entire menu pages on cart updates.
- Use const widgets where possible.
- Keep animations light.
- Preload hero/product images when navigating to product details.
- Use isolated state providers per feature.

## Development Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

## Quality Checklist

Before release:

- [ ] App theme uses centralized colors, spacing, radius, shadows, and typography.
- [ ] No screen hardcodes random greens, random radius values, or inconsistent button styles.
- [ ] All CTAs use pill radius.
- [ ] Floating cart/order button works and respects safe area.
- [ ] Product list works on small Android screens.
- [ ] Product detail page has sticky/visible add-to-cart behavior.
- [ ] Rewards screen uses gold only for loyalty moments.
- [ ] Arabic/RTL layout tested.
- [ ] Dynamic text size tested.
- [ ] Empty, loading, and error states implemented.
- [ ] Images are cached and optimized.
- [ ] Forms show validation errors clearly.
- [ ] Admin screens can create/edit/delete products safely.
- [ ] QR code generation/share flow tested.
- [ ] App passes `flutter analyze`.
- [ ] App passes unit/widget tests.
- [ ] Release build tested on a real Android device.

## Do and Don't

### Do

- Use cream surfaces as the default app background.
- Use dark green for premium sections.
- Use bright green for primary CTAs.
- Keep buttons pill-shaped.
- Keep cards softly elevated.
- Use large product photography.
- Use bottom navigation for the mobile app.
- Use bottom sheets for mobile choices.
- Use structured AI recommendation cards.

### Don't

- Do not copy desktop/web navigation into the app.
- Do not use pure white as the full app background everywhere.
- Do not use gold for normal buttons.
- Do not use square buttons.
- Do not use heavy shadows.
- Do not make product details look like a web page.
- Do not place too many actions in the app bar.
- Do not return AI suggestions as plain paragraphs when they should be products.

## Implementation Priority

Build in this order:

1. Theme tokens
2. Shared widgets
3. Navigation shell
4. Home screen
5. Menu/product list
6. Product details and customization
7. Cart
8. Rewards/loyalty
9. Admin menu management
10. QR/domain tools
11. AI recommendation cards
12. Testing and release hardening

## Notes for Designers and Developers

The original inspiration was a web design system with desktop navigation, web hero sections, gift-card grids, rewards pages, product pages, and nutrition tables. In Flutter, the same visual identity should be translated into mobile-native screens:

- Desktop top nav becomes bottom navigation.
- Web hero sections become mobile feature cards or sliver headers.
- Web floating order CTA becomes a floating cart button.
- Large web grids become horizontal lists or 1–2 column mobile grids.
- Product detail web sections become a scrollable mobile product page with sticky add-to-cart.
- Web forms become mobile-friendly text fields and bottom-sheet selectors.

The design identity should remain warm, green, premium, rounded, and café-like, but the implementation must feel like a real Flutter mobile app.
