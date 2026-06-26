# Sprint 12 UI/UX Reality Audit

Date: 2026-06-26

Decision: UI_UX_LAUNCH_BLOCKERS_FOUND

Scope: audit only. No product code, API contract, schema, dependency, wallet signing, APNs, recovery, transfer, or scanner-token logic was changed.

## References

- `docs/design/waflo-ui-ux-principles.md`
- `docs/design/sprint-12-ui-ux-launch-polish-audit.md`
- [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill), used only for design-review mindset and interaction-quality inspiration.
- [emilkowalski/skills](https://github.com/emilkowalski/skills), used only for motion, taste, and design-engineering principles.

No external code, assets, colors, or templates were copied.

## Files Inspected

Mobile:

- `apps/mobile/lib/features/auth/presentation/pages/login_screen.dart`
- `apps/mobile/lib/features/business_setup/presentation/pages/business_setup_screen.dart`
- `apps/mobile/lib/features/dashboard/presentation/pages/dashboard_screen.dart`
- `apps/mobile/lib/features/staff_scanner/presentation/pages/staff_scanner_screen.dart`
- `apps/mobile/lib/features/staff_scanner/presentation/widgets/wallet_qr_camera_scanner.dart`
- `apps/mobile/lib/features/menu_appearance/presentation/pages/menu_appearance_screen.dart`
- `apps/mobile/lib/shared/widgets/waflo_button.dart`
- `apps/mobile/lib/shared/widgets/app_button.dart`

Customer web:

- `apps/customer-web/app/components/PublicMenuTemplateView.tsx`
- `apps/customer-web/app/components/ProductCard.tsx`
- `apps/customer-web/app/components/WalletActions.tsx`
- `apps/customer-web/app/components/AppleWalletButton.tsx`
- `apps/customer-web/app/m/[slug]/(menu)/page.tsx`
- `apps/customer-web/app/m/[slug]/item/[itemId]/page.tsx`
- `apps/customer-web/app/m/[slug]/loyalty/LoyaltyEnrollmentClient.tsx`
- `apps/customer-web/app/m/[slug]/loyalty/card/LoyaltyCardClient.tsx`
- `apps/customer-web/app/styles/public-menu-contract.css`
- `apps/customer-web/app/styles/templates/waflo-warm.css`

Admin web:

- `apps/admin-web/app/page.tsx`
- `apps/admin-web/app/components/AdminShell.tsx`
- `apps/admin-web/app/components/AuthState.tsx`
- `apps/admin-web/app/components/OwnerWorkflowPanel.tsx`
- `apps/admin-web/app/components/OwnerContextPanel.tsx`
- `apps/admin-web/app/components/WalletAppearancePanel.tsx`
- `apps/admin-web/app/components/LoyaltyPanel.tsx`
- `apps/admin-web/app/globals.css`

## Findings

| Surface | Problem | Why it matters | Suggested fix | Owner | Priority | Sprint |
| ------- | ------- | -------------- | ------------- | ----- | -------- | ------ |
| Customer QR menu item detail | Public error states can show API URLs or backend-style failure details. | Customers should never see internal plumbing during a restaurant pilot. It hurts trust and can leak implementation context. | Replace public error details with friendly copy, hide API URLs, and keep technical diagnostics in logs only. | Web | Critical before Sprint 13 | 12 |
| Customer QR menu item detail | Sold-out items can appear in the menu list, but the detail page can fall back to "Item not found." | A customer tapping a visible sold-out item should understand it is unavailable, not think the menu is broken. | Add a clear unavailable/sold-out detail state that preserves item context where safe. | Web | Critical before Sprint 13 | 12 |
| Customer QR menu page | Public menu fetch failures mention API reachability and returned errors. | Restaurant customers need simple recovery language, not infrastructure wording. | Use customer-facing copy such as "We could not load this menu right now" with retry/open-home actions. | Web | Critical before Sprint 13 | 12 |
| Admin owner dashboard | Owner workflow contains internal Sprint/API/backend wording. | A pilot restaurant owner should feel they are using a product, not testing backend milestones. | Remove Sprint names, endpoint references, and implementation notes from owner-facing UI. | Web | Critical before Sprint 13 | 12 |
| Admin auth/context states | Some admin states expose config names, API URLs, JWT wording, or raw auth troubleshooting language. | These are useful to developers but damaging if an owner or operator sees them. | Convert to role-aware product copy and keep debug details behind internal logs. | Web | Critical before Sprint 13 | 12 |
| Admin menu management | Menu editing, public sharing, appearance, categories, items, restore, and diagnostics are packed into large panels. | Owners need a clear next action. Dense panels increase training time before the first pilot. | Split the owner flow visually into "Share menu", "Edit menu", and "Appearance" task cards with one primary action per section. | Web | Critical before Sprint 13 | 12 |
| Mobile auth/OTP | Google sign-in/config pending states can read like setup problems rather than normal login choices. | Mobile QA already found auth routing confusion. Launch login must feel intentional and reliable. | Hide unconfigured auth options or show calm fallback copy; verify owner and staff routing after clean install. | Mobile | Critical before Sprint 13 | 12 |
| Mobile business onboarding | Business setup is functional but does not preview what customers will see. | New owners need confidence that setup creates a real public menu, not just a database record. | Add simple "Your public menu will use this name and city" guidance and clearer validation messages. | Mobile | Critical before Sprint 13 | 12 |
| Mobile staff scanner | Manual token entry is prominent and uses technical "wallet token" language. | Staff should think "scan customer card", not "handle token." Manual entry should feel like a fallback. | Make camera scan the primary mental model, rename manual fallback to "Enter code manually", and keep token wording out of staff UI. | Mobile | Critical before Sprint 13 | 12 |
| Mobile scan result | Add-stamp success does not clearly set expectations for Apple Wallet delay. | Staff may tell customers the Wallet pass should update instantly, causing confusion. | Keep "Stamp added successfully" and add a short note that the live card updates online first and Wallet may refresh shortly. | Mobile | Critical before Sprint 13 | 12 |
| Mobile staff scanner | Redeem reward path is not visually clear from the scanner result. | If a customer has a reward, staff need an obvious next action at the counter. | Show reward status with a clear disabled/enabled redeem action, or explicitly mark redeem as not yet available for pilot. | Mobile | Critical before Sprint 13 | 12 |
| Mobile menu template picker | Preview explanation exposes the implementation URL pattern. | Owners care about previewing their menu, not query strings. | Replace query-string copy with "Preview opens your public menu without saving changes." | Mobile | Critical before Sprint 13 | 12 |
| Customer loyalty enrollment | Recovery screen is secure but text-heavy and can feel like a dead end. | A customer who lost access needs a calm path, not a warning wall. | Keep the three choices, but simplify hierarchy: old device transfer, lost access staff help, different phone join. | Web | Critical before Sprint 13 | 12 |
| Customer loyalty card | Missing-token and fetch-error states use technical "token" language. | Customers do not understand card references or tokens. | Use "We could not open this card on this browser" and offer transfer or staff-help guidance. | Web | Critical before Sprint 13 | 12 |
| Customer public menu | Category navigation is sticky and useful but does not clearly show the active category. | Customers browsing on phones need orientation in longer menus. | Add active-category state tied to scroll or tap selection. | Web | Important after first pilot | 13 |
| Customer public menu | Item cards are clean but still feel generic when images are missing. | Food and cafe menus need appetite appeal even before full media upload. | Improve placeholder treatment with warm gradients, category labels, and stronger price/title hierarchy. | Web | Important after first pilot | 13 |
| Customer public menu | Mobile layout can hide the business logo. | The logo is a trust anchor for a scanned QR menu. | Keep a compact logo/avatar on mobile when available. | Web | Important after first pilot | 13 |
| Customer public menu | RTL exists structurally, but Arabic typography and spacing need real visual QA. | Arabic will be a launch-critical trust signal in Iraq. | Add Arabic font stack, RTL spacing review, and real Arabic sample data checks. | Web | Defer to Sprint 15 | 15 |
| Customer loyalty flow | Loyalty enrollment and live card styling feel separate from the menu template system. | Customers move from menu to loyalty; the experience should feel like one brand journey. | Reuse menu template tokens for loyalty surfaces while preserving wallet-specific CTA rules. | Web | Important after first pilot | 13 |
| Customer loyalty card | Live card shows metrics in a dashboard-like way. | Customers want a rewarding card, not analytics. | Make progress, next reward, and wallet actions the visual center; move lifetime metrics lower. | Web | Important after first pilot | 13 |
| Wallet actions desktop | Desktop fallback is safe but could be more helpful. | A desktop viewer needs a quick way to move the flow to a phone. | Add a copy-link and optional QR handoff pattern once QR display rules are reviewed. | Web | Important after first pilot | 13 |
| Mobile dashboard | Dashboard has many stacked action cards competing for attention. | Staff and owners need different mental models; too many equal cards slow the first task. | Make role-based primary action dominant: staff scan, owner manage menu, manager review operations. | Mobile | Important after first pilot | 13 |
| Mobile dashboard | Error summaries can mention business access and internal context too directly. | Users should understand what to do, not parse access state. | Use role-aware recovery copy such as "Ask the owner to add you to this business." | Mobile | Important after first pilot | 13 |
| Mobile component system | UI mixes older `App*` widgets with newer `Waflo*` widgets. | Mixed component layers create subtle inconsistency in spacing, loading, and hierarchy. | Standardize future screens on Waflo primitives while keeping compatibility wrappers thin. | Mobile | Important after first pilot | 13 |
| Mobile scanner permission states | Permission fallback is practical, but the route back to manual entry/settings can be more guided. | Camera permission failure is common during testing and first use. | Add one clear primary action for settings and one secondary action for manual code entry. | Mobile | Important after first pilot | 13 |
| Admin menu appearance | Template preview cards are schematic rather than appetizing. | Owners choose based on how their customers will feel, not layout wireframes. | Use richer mini previews with real menu-like content while keeping templates CSS-first. | Web | Important after first pilot | 13 |
| Admin wallet appearance | Panel labels emphasize Google Wallet while Apple pass polish is also important. | Owners may assume Apple Wallet is secondary or unsupported. | Rename to platform-neutral wallet appearance and explain platform-specific rendering boundaries. | Web | Important after first pilot | 13 |
| Admin wallet appearance | Demo/smoke text appears in wallet preview. | Demo wording makes the product feel unfinished. | Replace with neutral sample business/card content. | Web | Important after first pilot | 13 |
| Admin web touch targets | Many admin buttons use compact padding and may miss 44px mobile target guidance. | Owners may use tablets or phones in-store. | Audit critical admin actions for minimum 44px height and clear hit areas. | Web | Important after first pilot | 13 |
| Admin shell | Navigation lacks a strong active state and product hierarchy. | Owners need to know where they are and what area they are managing. | Add active nav styling and group owner tasks by mental model. | Web | Important after first pilot | 13 |
| Admin permission states | Permission failures are technically correct but not always actionable. | Staff/manager/owner differences must feel intentional. | Show "You can view this, but only owner/manager can save" with next action where appropriate. | Web | Important after first pilot | 13 |
| Motion and micro-interactions | Motion is present in buttons but not consistently used for loading, saving, and scan success. | Small feedback moments make Waflo feel alive without a redesign. | Define a tiny motion set: press, save success, scanner success, and template selection. | Web/Mobile | Defer to Sprint 22 | 22 |
| Accessibility | Some custom interactive cards need systematic keyboard/focus/aria review. | Accessibility issues become product quality issues, especially in admin workflows. | Run a focused accessibility pass on cards, template picker, scanner controls, and wallet actions. | Web/Mobile | Important after first pilot | 13 |
| Menu template system | Full template marketplace, thumbnail asset pipeline, and advanced previews are not Sprint 12 scope. | Starting this now risks delaying the pilot. | Keep Sprint 12 to contract-safe polish; schedule broader template work for Sprint 19. | Web/Mobile | Defer to Sprint 19 | 19 |
| Localization | Full Arabic copy, pluralization, and locale-specific formatting are not complete. | The product can launch a pilot with careful English/Arabic samples, but full localization needs dedicated work. | Track complete i18n and RTL acceptance in Sprint 15. | Web/Mobile/API | Defer to Sprint 15 | 15 |
| Ops hardening | Design QA tooling, screenshot baselines, and release gates are not fully automated. | Manual QA is enough for Sprint 12, but not for scale. | Add visual regression and accessibility gates later. | Web/Mobile | Defer to Sprint 22 | 22 |

## Critical Before Sprint 13

The highest-risk issues are not about brand colors or a redesign. They are about product trust:

- Public customer screens should stop showing API/internal wording.
- Owner/admin surfaces should stop exposing Sprint, endpoint, and JWT/config language.
- Mobile staff scan should read as "scan customer card" instead of "handle wallet token."
- Scanner result should clarify stamp success and avoid promising instant Apple Wallet refresh.
- Customer loyalty recovery should stay secure while becoming easier to understand.
- The pilot owner setup and dashboard should make the next action obvious.

## Important After First Pilot

These are worth doing soon after the first restaurant pilot starts:

- Stronger active category state on QR menus.
- Better food/item placeholder visuals.
- Platform-neutral wallet appearance language in admin.
- Cleaner live loyalty card hierarchy.
- More consistent Waflo mobile primitives.
- Better admin touch targets for tablet and phone use.
- Focused accessibility review of custom cards and controls.

## Deferred Items

- Sprint 15: full Arabic/RTL localization, font stack, and real Arabic content QA.
- Sprint 19: template marketplace, richer preview assets, and additional public menu templates.
- Sprint 22: visual regression gates, accessibility automation, and broader motion system.

## Impact Summary

Mobile impact:

- No API change is required for the UI issues found.
- Main work is copy, hierarchy, role-specific dashboard priority, scanner result clarity, and template picker wording.

Web impact:

- Customer-web has the most visible Sprint 12 launch polish work because it is public-facing.
- Admin-web needs owner-facing copy cleanup before a real restaurant owner uses it without developer guidance.

API impact:

- No backend or OpenAPI change is recommended from this audit.
- API work should only be considered if frontend cannot distinguish safe public states from existing responses.

## Recommended First Implementation Branch

`codex/sprint-12-ui-ux-critical-polish`

Suggested first scope:

- Customer-web public error and sold-out/detail states.
- Customer loyalty missing-token/error/recovery copy hierarchy.
- Admin-web removal of Sprint/API/JWT/config wording from owner-facing states.
- Mobile copy-only polish for scanner result, manual entry wording, and menu template preview explanation.

Keep this branch code-only for UI polish and avoid API, schema, OpenAPI, wallet signing, APNs, recovery, transfer, and scanner-token behavior changes.
