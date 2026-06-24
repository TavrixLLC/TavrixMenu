# Waflo Brand Theme Implementation Notes

Waflo is a Business Loyalty Platform. The restaurant and cafe QR menu plus loyalty experience is the first vertical. Visual work must not introduce cart, checkout, ordering, delivery, pickup, or order-history behavior.

## Core Palette

| Token | Hex | Usage |
| --- | --- | --- |
| Primary Coral | `#FF6B4A` | Primary actions, join, scan, claim, continue |
| Primary Coral Dark | `#D94B2B` | Pressed and high-emphasis coral states |
| Fresh Green | `#43A047` | Success, loyalty progress, rewards |
| Fresh Green Dark | `#2E7D32` | Strong success text and icons |
| Warm Cream | `#FFF8F2` | Customer menu backgrounds |
| Surface White | `#FFFFFF` | Cards, panels, readable areas |
| Text Dark | `#1F2933` | Primary text |
| Muted Text | `#6B7280` | Secondary text |
| Soft Border | `#F1E2D6` | Borders and subtle dividers |
| Reward Gold | `#F59E0B` | Reward and premium moments only |
| Danger Red | `#DC2626` | Errors and destructive actions only |

## Implemented Locations

- Customer web tokens: `apps/customer-web/app/lib/waflo-design.ts`
- Customer web Tailwind aliases: `apps/customer-web/tailwind.config.ts`
- Admin web Tailwind aliases: `apps/admin-web/tailwind.config.ts`
- Flutter tokens: `apps/mobile/lib/core/constants/app_colors.dart`
- Flutter theme: `apps/mobile/lib/core/theme/app_theme.dart`

## Rules

- Coral is the primary action color.
- Green is reserved for success, progress, loyalty, and reward state.
- Cream is for warm customer-facing menu backgrounds.
- White is for readable cards and admin surfaces.
- Gold is only for reward or premium moments.
- Red is only for errors and destructive actions.
- Official Apple Wallet and Google Wallet button artwork must not be recolored.
