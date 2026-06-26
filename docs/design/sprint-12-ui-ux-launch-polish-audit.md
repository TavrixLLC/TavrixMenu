# Sprint 12 UI/UX Launch Polish Audit

This audit plan is for Sprint 12 launch readiness only. It is not a full
redesign, template marketplace, localization project, or backend feature plan.

Use this checklist to identify launch-critical polish issues across customer
web, admin web, and mobile staff workflows. API work should only be requested
when a UI/UX issue truly needs a contract, data, permission, or validation
change.

## Decision Rules

- Critical before Sprint 13: blocks or seriously confuses the first restaurant pilot.
- Important but not blocking: improves trust and perceived quality, but the pilot can start with a known workaround.
- Defer: belongs to Sprint 15 localization, Sprint 19 templates, Sprint 22 ops hardening, or a later redesign.

## Critical Before Sprint 13

| Surface | Problem | Why it matters | Suggested fix | Owner | Sprint | Blocking |
| --- | --- | --- | --- | --- | --- | --- |
| Mobile staff scanner | Full installed-app scanner E2E must remain verified after recent mobile redesign and picker merges. | The first pilot depends on staff scanning a customer Wallet QR and adding a stamp at the counter. | Run physical Android E2E: staff login, business context, scan valid Wallet QR, add stamp, invalid token, cross-business rejection, no raw token logs. | Mobile | 12 | yes |
| Authentication and business context states | Google native sign-in/config is still pending, and bad auth context can route staff to setup or offline states. | Staff cannot operate the scanner if login or business context is unreliable. | Verify configured Google/Clerk login on the pilot build; `/me` and business context load; no dev auth in staging/production; errors distinguish offline, auth, permission, and missing business. | Mobile / API only if contract fails | 12 | yes |
| Mobile scan result | Scan success must show enough safe context and a clear Add Stamp path. | Cashiers need confidence they scanned the right card before changing loyalty progress. | Verify result displays customer name, safe phone display if available, program, progress, reward state, and separated Add Stamp/Redeem actions. | Mobile | 12 | yes |
| Mobile scan result | Add Stamp success must be immediate and not wait on Wallet provider refresh. | Waiting for Apple Wallet installed-pass update will confuse staff and customers. | Show "Stamp added successfully" and updated progress from API response; optionally mention live card is current. | Mobile | 12 | yes |
| Customer loyalty enrollment / add to wallet | Device-aware wallet CTA must remain correct after template and UX changes. | iPhone customers expect Apple Wallet first; Android customers expect Google Wallet first; desktop should not pretend to be a phone wallet flow. | Smoke iPhone Safari, Android Chrome, and desktop for `/m/:slug/loyalty`; confirm Apple/Google/web card priority and no wallet request during render. | Web | 12 | yes |
| Customer loyalty enrollment / add to wallet | Recovery copy must not imply phone-only access. | Phone numbers are not proof of ownership and must not unlock cards. | Verify "I already joined" separates trusted old-device transfer, lost-all-devices staff help, and different-phone new enrollment. | Web / API only if response leaks access | 12 | yes |
| Customer public menu | Public menu must render selected template without breaking core menu browsing. | The table QR menu is the first customer impression and must not feel broken on pilot day. | Smoke known slugs on mobile and desktop; verify `appearance.effectiveTemplateId`, categories, prices, sold-out state, loyalty block, no horizontal scroll, and no runtime errors. | Web | 12 | yes |
| Mobile menu template picker | Picker runtime smoke is still pending. | Owners may demo or use template selection during launch readiness; a broken save/preview flow harms trust. | Verify catalog load, current template, draft selection, preview URL, save success for allowed role, 403 handling for STAFF, and invalid-template fallback. | Mobile / API only if contract fails | 12 | yes |
| Admin-web menu appearance | Admin picker must not diverge from API catalog or allow unsafe customization. | Owners need one clear way to choose a Waflo-managed template without arbitrary CSS risk. | Verify admin consumes `GET /menu-templates`, saves via appearance endpoint, previews `/m/:slug?previewTemplateId=...`, and shows STAFF permission messaging. | Web | 12 | yes |
| Authentication and business context states | Missing business, no active role, or permission failures must be understandable. | Pilot staff/owner accounts can get stuck if the app says only "something went wrong." | Audit login landing, business setup, role denied, and no-context states; provide one clear next action. | Web / Mobile | 12 | yes |

## Important But Not Blocking

| Surface | Problem | Why it matters | Suggested fix | Owner | Sprint | Blocking |
| --- | --- | --- | --- | --- | --- | --- |
| Customer public menu | Template cards may look inconsistent across menu lengths and image availability. | Good content should look intentional even with missing photos or short menus. | Review one image-rich, one text-only, and one empty/short menu per template; polish placeholders and spacing. | Web | 12 | no |
| Customer public menu | Category navigation can become cramped on small phones. | Customers browse by category under real restaurant lighting and one-handed use. | Ensure category chips are touch-friendly, horizontally scroll smoothly, and preserve focus. | Web | 12 | no |
| Loyalty enrollment / add to wallet | Form helper copy may be too long or visually heavy. | Customers decide quickly whether joining is worth it. | Keep explanation to one short paragraph plus field-level help; avoid nested cards. | Web | 12 | no |
| Loyalty enrollment / add to wallet | Apple Wallet refresh caveat may be hidden after stamp changes. | Customers may expect the installed pass to update instantly. | Keep copy visible on live card: online card is current, Apple Wallet may refresh shortly. Do not suggest toggling Automatic Updates. | Web | 12 | no |
| Admin-web owner dashboard | Dashboard cards may not map cleanly to owner jobs. | Owners need "what is live" and "what to do next" before analytics. | Reorder cards around menu live status, loyalty status, template status, and next setup action. | Web | 12 | no |
| Admin-web owner dashboard | Empty states may be too generic. | A pilot owner should not need support for basic setup. | Add action-led empty states: add first category, add first item, open live menu, invite staff. | Web | 12 | no |
| Admin-web menu appearance | Template preview cards may not communicate current vs draft vs saved. | Owners can confuse previewing with publishing. | Use explicit badges: Current, Previewing, Unsaved; keep Save visually distinct from Preview. | Web | 12 | no |
| Mobile staff scanner | Permission and camera error states may lack a direct recovery action. | Staff need to recover at the counter without technical support. | Provide open-settings action, retry, manual token fallback if available, and clear copy. | Mobile | 12 | no |
| Mobile scan result | Reward-ready state may not be visually distinct enough. | Cashiers must know whether to add a stamp or redeem. | Use green/gold reward status with text, not color alone; separate Add Stamp from Redeem. | Mobile | 12 | no |
| Mobile menu template picker | Mini previews may not match the public web preview closely enough. | Owners may distrust the picker if saved results look different. | Label mini previews as approximate and make full preview easy to open. | Mobile | 12 | no |
| Authentication and business context states | Offline copy can appear for non-network failures. | Misleading copy sends the team debugging the wrong thing. | Split network unavailable, unauthorized, forbidden, no business, server error, and config missing states. | Mobile / Web | 12 | no |
| All surfaces | Focus rings and reduced-motion behavior may be inconsistent. | Accessibility regressions are often created during polish work. | Audit keyboard focus, screen-reader labels, reduced motion, and color contrast on changed screens. | Web / Mobile | 12 | no |
| All surfaces | Touch targets may be visually small even when buttons look clean. | Pilot users are on phones, often one-handed. | Verify 44px web/iOS and 48dp Android targets, with at least 8px spacing between controls. | Web / Mobile | 12 | no |

## Defer

| Surface | Problem | Why it matters | Suggested fix | Owner | Sprint | Blocking |
| --- | --- | --- | --- | --- | --- | --- |
| Customer public menu | Full Arabic/Kurdish/English localization and content translation. | Local language support is strategically important but larger than launch polish. | Keep RTL-safe CSS now; implement full localization strings, language switcher, and QA matrix in Localization v1. | Web / Mobile / API if data needed | 15 | no |
| Customer public menu | Full custom template marketplace or merchant-uploaded template builder. | Templates need governance, preview QA, safety, and support. | Keep Waflo-managed CSS-first templates now; plan custom/private templates later. | Web / API | 19 | no |
| Admin-web menu appearance | Arbitrary CSS upload or owner-authored template code. | Unsafe styling can break accessibility, expose data, and create support load. | Defer to controlled template governance; do not add in Sprint 12. | Web / API | 19 | no |
| Wallet/loyalty enrollment | OTP or staff-assisted recovery backend. | Lost-all-devices recovery needs verified identity, not phone-only lookup. | Keep staff-help placeholder now; design OTP/staff recovery with audit logs later. | API / Web / Mobile | 22 | no |
| Admin-web owner dashboard | Advanced analytics charts and retention dashboards. | Useful for paid maturity, but not required to prove first pilot operations. | Defer to later analytics/ops hardening; keep Sprint 12 dashboard action-led. | Web / API | 22 | no |
| Mobile staff app | Deep animation system, advanced haptics, and gesture-driven scanner flows. | Nice polish, but high-frequency cashier tasks should stay fast and simple. | Keep subtle press/success feedback now; revisit after real staff usage. | Mobile | 22 | no |
| All surfaces | Full design system rewrite across admin, customer web, and Flutter. | Too large for launch readiness and risks regressions. | Document principles now; apply incremental fixes only where launch-blocking. | Web / Mobile | 22 | no |
| Public menu and wallet | Cart, ordering, delivery, pickup, checkout, and order-history UX. | These are outside the current Waflo scope and would change product behavior. | Do not introduce in template or menu polish work. | Product / API / Web | 22 | no |

## API Owner Notes

Do not request API work for visual polish alone.

API work is justified only if:

- A screen cannot distinguish auth, permission, missing business, or server failures from the current contract.
- Menu template catalog or appearance data is missing a field that mobile/admin cannot safely infer.
- A UI flow requires secure server-side validation, such as recovery, transfer, staff actions, or duplicate prevention.
- Backend currently leaks data or fails to redact tokens/PII in a response or log.

API work is not justified for:

- Spacing, color, typography, card shape, or micro-interactions.
- Reordering sections on customer web or mobile.
- Mini preview styling.
- Copy changes that use existing response states.
- Template CSS polish within the existing HTML contract.

## Required Sprint 12 Audit Smokes

Before recommending Sprint 13:

1. Customer public menu: smoke `/m/happy-birthday-2`, `/m/chocolate-saray`, and one template preview URL on phone and desktop.
2. Loyalty enrollment: smoke iPhone, Android, and desktop CTA priority.
3. Recovery/transfer: verify phone-only recovery stays blocked and old-device transfer still works.
4. Admin menu appearance: verify catalog, preview, save, permission denied, and public menu result.
5. Mobile scanner: physical Android installed-app scan and Add Stamp E2E.
6. Mobile template picker: catalog, preview, save, and 403 handling.
7. Auth/business context: owner and staff accounts land on the correct surfaces with clear errors.
8. Security: no QR payloads, scan tokens, card references, transfer tokens, JWTs, phone/email, or PII appear in screenshots, logs, or docs.

## Sprint 12 Close Recommendation Template

Use this shape after the audit:

- Critical issues remaining:
- Important non-blocking polish:
- Deferred items:
- API contract impact:
- Web impact:
- Mobile impact:
- Recommended decision:
