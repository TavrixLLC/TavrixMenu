# Waflo UI/UX Principles

This document defines the standing UI/UX quality gate for Waflo. It applies to
all future UI work across Flutter mobile, customer web, admin/owner surfaces,
public loyalty enrollment, wallet/card previews, menu templates, loading/error
states, navigation, and onboarding flows.

It is not a redesign brief and it does not replace the existing brand theme,
public menu HTML contract, or CSS-first template architecture. Use it to keep
incremental UI work alive, clear, premium, usable, and consistent without
starting a full redesign.

External design-skill repositories were reviewed for inspiration only:

- `nextlevelbuilder/ui-ux-pro-max-skill`: useful framing for priority-based UI review, especially accessibility, touch targets, responsive layout, form feedback, and motion limits.
- `emilkowalski/skills`: useful framing for invisible polish, restrained animation, responsive press feedback, and the idea that small details compound into trust.

Do not copy external code, assets, palettes, or component implementations into
Waflo without a separate approval.

## Product Feeling

Waflo should feel:

- Warm, local, and restaurant-first.
- Fast enough for a cashier counter during a busy shift.
- Clear enough for a customer scanning a table QR for the first time.
- Premium enough that a restaurant owner is proud to show the menu and Wallet card.
- Simple enough that a non-technical owner knows what changed and what to do next.

By surface:

- Customer-facing QR menu: appetizing, fast, visual, and easy to scan.
- Owner/admin screens: calm, trustworthy, efficient, and business-like.
- Staff mobile screens: fast, direct, touch-friendly, and impossible to misunderstand.
- Wallet/loyalty flows: safe, rewarding, and clear.

Waflo must avoid:

- Generic SaaS dashboard polish that ignores restaurant/cafe workflows.
- Full redesigns during launch readiness.
- New brand colors or external visual systems.
- Decorative motion that slows repeated cashier tasks.
- Hidden primary actions, nested buttons, or competing CTAs.
- Phone-only card recovery language that sounds like authentication.
- Claiming Apple Wallet installed-pass updates are instant.
- Visual-only work that changes backend behavior, OpenAPI, Wallet signing, or schema.

## Standing Design Quality Gate

Every UI change must pass these checks before it is accepted:

- Product fit: the screen matches the job of its user and surface.
- Visual hierarchy: one obvious primary action, weaker secondary actions, and grouped important data.
- Interaction: clear pressed/active feedback, no hover-only critical actions, loading buttons prevent duplicate submits, and errors explain recovery.
- Motion: purposeful only, usually 150ms to 250ms, no `transition: all`, prefer transform/opacity, and respect reduced motion.
- Responsive: mobile-first, no horizontal scroll, no fixed-width layouts that break at 375px.
- RTL readiness: Arabic/RTL labels wrap gracefully; alignment, icon direction, spacing, and layout order make sense.
- Typography: readable body copy, consistent type scale, prices and numbers easy to scan, no tiny low-contrast helper text.
- Components: buttons, cards, inputs, badges, tabs, sheets, modals, and toasts feel like one system.
- State quality: loading, empty, error, success, offline, permission, and no-business states have calm copy and a next action.
- Security: no raw tokens, QR payloads, card references, wallet payloads, phone/email, PII, or implementation secrets in UI, screenshots, logs, docs, or debug output.

This gate is mandatory for:

- Flutter mobile UI.
- Customer QR menu.
- Admin-web and owner dashboard.
- Public loyalty enrollment.
- Wallet/card previews.
- Menu templates and template picker.
- Navigation and onboarding flows.
- Loading, error, empty, success, and offline states.

## Brand And Color Rules

Use the existing Waflo palette from `docs/brand-theme.md`.

- Coral is the primary action color: join, continue, scan, save, apply.
- Green is reserved for success, progress, rewards, and safe completion.
- Cream is for warm customer-facing menu backgrounds.
- White is for readable cards, panels, admin surfaces, and staff workflows.
- Gold is for reward and premium moments only.
- Red is for errors and destructive actions only.
- Official Apple Wallet and Google Wallet badges must not be recolored.

Premium does not mean more decoration. For Waflo, premium means better spacing,
clearer hierarchy, calmer states, stronger defaults, and fewer confusing choices.

## Restaurant/Cafe Owner Mental Model

Owners think in operational questions:

- Is my menu live?
- What will customers see when they scan the QR?
- How do I change a price, item, image, template, or loyalty rule?
- Can my staff scan quickly without breaking anything?
- Did the customer get the stamp?
- Is the Wallet card safe and professional?

Admin and mobile UI should answer those questions directly. Avoid internal
terms unless the owner needs them. Prefer "Menu appearance", "Wallet Scan",
"Add stamp", and "Open live menu" over implementation terms.

## Button Hierarchy

Each screen or panel should have one clear primary action.

- Primary: filled coral, one per decision area.
- Success primary: green only after the action is already safe or complete.
- Secondary: outlined or soft surface action.
- Tertiary: text/link action for low-risk navigation.
- Destructive: red, visually separated, requires confirmation when data changes.
- Wallet badges: use official-style Apple/Google badge treatment and keep clear spacing.

Buttons must:

- Keep visible labels, not icon-only controls for critical actions.
- Show loading state during async operations.
- Prevent double-submit where duplicate actions are risky.
- Explain disabled states when the reason is not obvious.
- Keep tap targets at least 44px on web/iOS and 48dp on Android.

## Card, Layout, And Spacing Rules

Use an 8px spacing rhythm, with 4px only for tight internal alignments.

- Page padding: 16px minimum on mobile, 24px or 32px on larger surfaces.
- Card padding: 16px minimum for compact operational cards, 20px to 24px for customer-facing hero cards.
- Card radius: consistent within a surface; avoid mixing sharp, pill, and blob shapes randomly.
- Card grouping: one card equals one concept. Do not mix enrollment, wallet actions, and recovery warnings into one visual lump.
- Section rhythm: heading, short helper text, action/content. Avoid walls of explanatory copy.
- Desktop public menu: expand gracefully, but do not pretend desktop is a phone wallet flow.
- Mobile staff screens: keep the primary action above the gesture area and away from screen edges.

## Typography Hierarchy

Waflo typography should prioritize readability over novelty.

- Body text should be at least 16px on customer and mobile surfaces.
- Labels can be 12px to 14px when contrast is strong and the context is clear.
- Use weight, size, and spacing to create hierarchy before adding color.
- Prices should be easy to scan and use stable numeric alignment where practical.
- Avoid clipping business names, program names, customer names, or reward text.
- Prefer wrapping over truncation in customer-facing content.
- If truncation is unavoidable in admin/mobile lists, provide enough surrounding context.

## Public Customer Menu

The public menu is the customer's first trust moment.

- Show business identity first, then loyalty CTA, then categories and items.
- Menu item names, prices, images, and sold-out states must be immediately readable.
- Category navigation must be usable with touch and keyboard.
- Template variation must remain CSS-first against the stable HTML contract.
- Missing images need polished placeholders, not broken-looking gaps.
- Empty menus must explain the business has not published items yet.
- Errors must offer refresh/back behavior without exposing technical details.
- Loyalty CTA must feel like part of the menu, not an unrelated ad block.
- No cart, ordering, checkout, delivery, pickup, or order-history UI unless explicitly scoped later.

## Wallet And Loyalty Enrollment

Enrollment should feel short, safe, and device-aware.

- First-time customers see a short explanation, phone-first form, optional email where supported, and clear validation.
- Same-device returning customers see the live card and wallet actions immediately.
- New-device customers must not unlock by phone/email alone.
- "I already joined" must clearly separate old-device transfer from lost-access staff help.
- The live web card is the source of truth for current progress.
- Apple Wallet may refresh shortly; do not promise instant installed-pass updates.
- iPhone should prioritize Apple Wallet; Android should prioritize Google Wallet; desktop should guide the customer to open the link on a phone.

## Admin/Owner Dashboard

Admin surfaces should be calm and task-led.

- Show live status and next action before secondary metrics.
- Keep owner actions separate from staff operational actions.
- Use plain language for permissions: "Only owners can save menu appearance."
- Surface audit-sensitive changes as confirmations, not noisy alerts.
- Empty states should teach the next setup step.
- Loading states should reserve space to avoid layout jumps.
- Dashboard cards should answer owner questions, not decorate the page.

## Menu Template Picker

The template picker is a confidence tool, not a design playground in Sprint 12.

- Always show current template, draft selection, preview, and save as separate states.
- Preview must not save.
- Save must confirm success and keep the owner oriented.
- Staff can view but must understand why they cannot save.
- Template cards should use API catalog metadata and avoid hardcoded duplicate lists.
- Mini previews should be honest enough to set expectations, but the full public preview is the source of truth.
- Do not allow arbitrary CSS upload in Sprint 12.

## Mobile Staff App

The staff app is an operational tool for a fast counter.

- Wallet Scan must be reachable quickly from the staff/dashboard area.
- Scanner permission, camera, offline, and invalid-token states must be direct and recoverable.
- A successful scan should show customer name, safe phone display when allowed, program name, progress, and reward status.
- Add stamp and redeem actions should be large, separated, and state-aware.
- After Add Stamp, show immediate success and updated progress from the API response.
- Do not make staff wait for Apple/Google Wallet installed-pass refresh.
- Avoid long animations in scan, add stamp, redeem, or login paths.

## Error, Loading, And Empty States

Every non-happy path needs a recovery route.

- Loading under 300ms can be simple; longer loading should use skeletons or stable placeholders.
- Field errors appear near the field and say how to fix the value.
- Global errors should explain whether to retry, sign in, choose a business, or ask an owner.
- Empty states should include the next useful action.
- Offline states must be accurate. Do not show "offline" for auth, permission, or server validation failures.
- Security-sensitive errors must stay generic and never reveal tokens, card references, PII, or whether a phone exists globally.

## Motion And Micro-Interactions

Motion is allowed when it improves clarity or perceived responsiveness.

Allowed:

- Button press feedback around 100ms to 160ms.
- Small state transitions around 150ms to 250ms.
- Sheets, dialogs, and toasts around 200ms to 300ms.
- Skeleton shimmer or subtle loading indicators when content takes longer than a moment.
- Short success feedback after add stamp, save, enroll, or wallet action.

Avoid:

- Animation on high-frequency staff actions.
- Animation that delays a scan, stamp, redeem, login, or save.
- Decorative motion with no state meaning.
- Animating layout-heavy properties such as width, height, top, left, margin, or padding.
- Motion that ignores reduced-motion preferences.

Motion should use transform and opacity where possible, stay interruptible, and
respect platform expectations.

## UI Review Format

When reviewing UI changes, report issues in this table format:

| Surface | Before | After | Why | Priority |
| --- | --- | --- | --- | --- |
| Example surface | Current problem or risk | Recommended change | User or product reason | Critical before Sprint 13 |

Allowed priority values:

- Critical before Sprint 13
- Important after pilot
- Defer to Sprint 15
- Defer to Sprint 19
- Defer to Sprint 22

Keep the table practical. Each row should identify a real user-facing issue,
not a vague preference. API work should only appear in the table when a real
contract, data, permission, or security gap is proven.

## Arabic And RTL Readiness

Sprint 15 owns full localization, but Sprint 12 work must not make RTL harder.

- Use logical CSS properties where practical: `margin-inline`, `padding-inline`, `inset-inline`, `border-inline`.
- Do not hardcode left/right in reusable layout rules unless there is an RTL override.
- Keep source order meaningful even if CSS changes visual placement.
- Arabic, Kurdish, Persian, and Hebrew contexts must set `dir="rtl"` and `data-dir="rtl"` where the public menu contract expects it.
- Buttons and cards must support longer Arabic labels without clipping.
- Icons that imply direction should mirror or be replaced in RTL contexts.
- Prices and numbers should remain legible in mixed-direction text.

## Accessibility Rules

Launch polish cannot reduce accessibility.

- Normal text contrast should meet WCAG AA contrast expectations.
- Focus outlines must remain visible on every template and dashboard surface.
- Icon-only buttons require accessible labels.
- Forms need visible labels, not placeholder-only labels.
- Error messages need semantic announcement where practical.
- Keyboard order should match visual/source order.
- Do not disable zoom on mobile web.
- Touch targets must meet the platform minimums.
- Color must not be the only indicator for success, error, sold out, reward ready, or current selection.

## Responsive Rules

Waflo should feel native to the screen it is on.

- Design customer and staff flows mobile-first.
- Avoid horizontal scrolling on phone widths.
- Public menu desktop should become more spacious, not more complex.
- Admin desktop can use denser layouts, but mobile admin must still preserve the main action.
- Bottom navigation should stay limited and labeled.
- Fixed bars need safe-area padding.
- Preview URLs should work on both phone and desktop without changing data.

## Sprint 12 Acceptance Check

Before any UI polish change is accepted in Sprint 12, also verify:

- It keeps Waflo brand colors and identity.
- It does not copy external code or assets.
- It does not change backend behavior, OpenAPI, schema, wallet signing, or APNs.
- It improves a real pilot workflow or removes confusion.
- It keeps focus, contrast, touch targets, loading states, and error states intact.
- It is tested on the relevant real surface: phone for staff scanner, iPhone for Apple flow, Android for Google flow, and desktop for owner/admin.
