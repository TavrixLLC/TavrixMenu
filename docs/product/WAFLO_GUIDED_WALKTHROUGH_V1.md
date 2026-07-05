# Waflo Guided Walkthrough Doctrine V1

Status: source of truth for walkthrough, onboarding, and guided dashboard work.

This document extends `docs/product/WAFLO_PRODUCT_UX_V2.md`. It defines how Waflo should guide a restaurant owner from first signup to a usable, sellable QR menu product. It is product and UX doctrine only. It is not a request to implement mock screens, simulated progress, fake staff, fake upload, fake QR, fake billing, fake Google, or human-review-only production routes.

## 1. Decision Record

- The V2 Owner Guided Dashboard visual attempt failed human visual review.
- The failed dashboard attempt must not be committed as production work.
- The failed dashboard attempt may be preserved only as a failed visual reference.
- Product direction is now full guided walkthrough first, then screens.
- Old dashboard UI and old admin-panel patterns are considered disposable.
- Existing backend, auth, API, menu, business, loyalty, scanner, and billing logic should be reused only when it represents real capability.
- DeepSeek strategy is treated as product strategy only, not as permission to ship simulated UI.
- No production route may contain fake progress, fake QR, fake upload, fake staff, fake billing, fake Google, or human visual review screens.

## 2. Product Promise

Waflo is an Arabic-first premium SaaS for Iraqi restaurants and cafes.

Waflo helps restaurant owners:

- create a restaurant workspace
- build a QR menu
- add categories and products
- set prices in IQD
- preview the customer menu
- share a real QR link
- manage loyalty when real loyalty features are available
- add staff later through real staff management
- use the scanner for customer loyalty cards
- subscribe later through real Stripe integration

The owner should feel that Waflo is guiding them toward a live customer menu, not asking them to operate a generic admin panel.

## 3. Walkthrough Types

### First-run onboarding wizard

Use only for a new owner, or an owner with no business/workspace setup.

Rules:

- The wizard starts after successful signup or first authenticated entry when no business exists.
- The wizard should complete the minimum path to a real workspace and first usable menu foundation.
- Critical setup steps may be required. Non-critical steps should allow `لاحقاً`.
- The wizard must resume from the exact incomplete step if the user exits midway.

### Guided dashboard checklist

Use after a business exists and the owner has entered the main app shell.

Rules:

- The checklist persists until core setup is complete.
- Checklist progress is derived from real business, menu, dashboard, and public menu state.
- No fake completion and no hardcoded success state.
- After QR/menu is published, collapse the checklist into a compact health/status surface.

### Contextual coach marks and tooltips

Use sparingly for first-time orientation after a milestone.

Rules:

- Maximum 3 coach marks per screen.
- Never repeat after dismissal.
- Never block a core workflow unless the user explicitly starts a walkthrough.
- Coach marks explain a visible real action only.

### Empty states

Use when a section has no real data yet.

Rules:

- Empty states must teach the first useful action.
- Empty states must be honest about unavailable features.
- Empty states must not promise upload, QR, billing, staff, Google, or loyalty behavior before it is real.

### Returning-user continuation prompts

Use when an owner returns with incomplete setup.

Rules:

- Continue from the exact incomplete state.
- Show one gentle prompt, not a modal stack.
- If the owner dismisses it, keep the next action available in the dashboard checklist.

## 4. New Owner First-Run Journey

| Step | Arabic title | Arabic subtitle | Primary CTA | Secondary CTA | Skip allowed | Completion condition | Screen/action target | If user exits midway |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1. Welcome after signup | أهلاً بك في Waflo | خلّينا نجهّز مطعمك ونخلي المنيو جاهز للزبائن بخطوات واضحة. | ابدأ تجهيز المطعم | لاحقاً | No | owner is authenticated and walkthrough starts | onboarding welcome | return to welcome or exact next incomplete step |
| 2. Create restaurant workspace | أنشئ مساحة مطعمك | هذه المساحة تجمع المنيو والـ QR والولاء والفريق. | أنشئ مساحة المطعم | لاحقاً | No if no business exists | business/workspace record exists | business setup start | return to workspace creation |
| 3. Restaurant name/type | معلومات المطعم | اكتب اسم المطعم واختر النوع حتى يظهر بشكل صحيح للزبائن. | حفظ والمتابعة | لاحقاً | No for name, yes for optional fields | required restaurant fields persisted | restaurant info form | return to incomplete restaurant info |
| 4. Choose template/look | اختر شكل المنيو | اختر ستايل يناسب مطعمك. تقدر تغيّره لاحقاً. | اختيار هذا الشكل | لاحقاً | Yes | selected template persisted if real template API exists | menu appearance selection | return to next incomplete step, with template step still available |
| 5. Add first category | أضف أول قسم | مثل مشروبات، وجبات، فطور، حلويات، أو عروض. | أضف قسم | لاحقاً | Yes | at least one real category exists | menu category creation | dashboard continues with category step active |
| 6. Add first product | أضف أول منتج | ابدأ بمنتج مشهور حتى يصبح المنيو مفيداً للزبائن. | أضف منتج | لاحقاً | Yes | at least one real product/item exists | product creation | dashboard continues with product step active |
| 7. Price in IQD | حدّد السعر بالدينار | اكتب السعر بالدينار العراقي بشكل واضح بدون تعقيد. | حفظ السعر | لاحقاً | No once product creation started | product has valid IQD price | product editor price field | return to product draft or product step |
| 8. Product image | صورة المنتج | أضف صورة حقيقية إذا كانت ميزة رفع الصور جاهزة. إذا لم تكن جاهزة، سنعرض حالة صادقة بدون صورة وهمية. | إضافة صورة | لاحقاً | Yes | real uploaded image is attached, or step is honestly skipped when upload is not wired | product media section | product remains valid without fake image |
| 9. Preview customer menu | عاين منيو الزبائن | شاهد كيف يظهر المنيو للزبون قبل المشاركة. | معاينة المنيو | لاحقاً | Yes | preview opens real customer menu or real local preview backed by current data | customer preview | dashboard suggests preview after first product |
| 10. Publish/share QR | شارك QR المنيو | شارك الرابط أو QR فقط عندما يكون المنيو العام جاهزاً فعلياً. | مشاركة QR | لاحقاً | Yes until real QR is ready | real public menu URL/QR exists | QR/share screen | if not ready, dashboard shows honest disabled state |
| 11. Return to dashboard | لوحة مطعمك جاهزة للمتابعة | كمل الإعداد أو ابدأ بإدارة المنيو والولاء والفريق حسب الجاهزية. | فتح اللوحة | لا حاجة | No | owner lands on dashboard with progress derived from real state | الرئيسية | dashboard shows exact next state |

## 5. Returning Owner State Machine

| State | Hero message Arabic | Next best action | Checklist state | Quick action priority | Hide | Coach marks |
| --- | --- | --- | --- | --- | --- | --- |
| A. no business | خلّينا نبدأ بمطعمك | إنشاء مساحة مطعم | 0 percent, workspace required | Create workspace | menu tools, QR, loyalty, staff, billing | one mark explaining why workspace is first |
| B. business exists, no categories | مطعمك موجود، نحتاج أول قسم | إضافة أول قسم | business complete, category active | Menu categories | QR share, product preview, billing prompts | one mark on category action |
| C. categories exist, no products | ممتاز، أضف أول منتج | إضافة أول منتج | category complete, product active | Add product | QR share as primary, billing prompts | one mark on product action |
| D. products exist, no public QR/menu link | المنيو بدأ يجهز، عاينه قبل المشاركة | preview then publish/share QR | product complete, preview/QR active | Preview menu, QR | subscription blocking, fake download | up to two marks for preview and share |
| E. QR/menu published, loyalty not active | منيوك جاهز للزبائن | introduce loyalty when real | core setup complete, loyalty optional | QR, menu edit, loyalty intro | intrusive setup wizard | no coach unless owner opens loyalty |
| F. loyalty active, no staff | الولاء جاهز، جهّز الفريق عند الحاجة | add staff when real staff management exists | staff optional | scanner, loyalty, staff setup if real | fake staff invite | one mark on scanner if staff/scanner is real |
| G. staff active, no subscription | فريقك جاهز، راقب قيمة Waflo | review plan/trial when Stripe UI is real | subscription optional | plan/trial status | fake invoices, fake payment success | none unless trial near end |
| H. fully configured | مطعمك يعمل على Waflo | manage daily operations | collapsed checklist/status | menu updates, QR, loyalty, scanner | first-run wizard | no coach marks by default |

## 6. Tab Walkthrough Map

### الرئيسية

- First-time explanation: هنا تتابع جاهزية مطعمك وتعرف الخطوة التالية.
- Empty state: show exact missing setup state.
- First useful action: create workspace, add category, add product, preview, or publish QR depending on real state.
- Coach marks: 1 to 3 for checklist, quick actions, and QR only when relevant.
- Help stops: after QR/menu is published and checklist collapses.
- Returning behavior: show compact continuation prompt if setup is incomplete.

### المنيو

- First-time explanation: هنا تبني أقسام المنيو والمنتجات والأسعار بالدينار.
- Empty state: no categories means teach adding first category.
- First useful action: add first category, then first product.
- Coach marks: category list, add product, availability toggle if real.
- Help stops: after first category and first product exist.
- Returning behavior: open to the most incomplete menu task.

### الولاء

- First-time explanation: الولاء يساعدك ترجع الزبائن من خلال كروت ومكافآت حقيقية.
- Empty state: explain loyalty only if backend capability is real; otherwise show honest prepared/disabled state.
- First useful action: configure a real loyalty program or view real current loyalty status.
- Coach marks: program status, enrollment link, customer lookup if real.
- Help stops: after loyalty program is active or owner dismisses intro.
- Returning behavior: show active program, members, and next real action.

### المسح

- First-time explanation: امسح كارت ولاء الزبون أو أدخل الرمز يدوياً.
- Empty state: show permission or setup requirement honestly.
- First useful action: scan real card or use manual code entry.
- Coach marks: camera scan, manual fallback, result safety.
- Help stops: after first successful real scan or dismissal.
- Returning behavior: direct scanner workflow, no owner onboarding clutter.

### الإعدادات

- First-time explanation: هنا تعدّل معلومات المطعم والصلاحيات والإعدادات المتاحة.
- Empty state: show only real editable settings.
- First useful action: complete missing restaurant details.
- Coach marks: business profile, appearance, account/sign out if needed.
- Help stops: after restaurant info is complete.
- Returning behavior: settings list ordered by real capabilities and permissions.

## 7. Staff / Cashier Rules

- Staff should not see owner onboarding.
- Staff should not access menu editing, owner settings, billing, or owner setup.
- Staff should see scanner-only flow when real staff auth exists.
- If staff auth or staff management is not built, do not show a fake staff entry.
- Owner may see staff as a future or disabled setup step only if the copy is honest.
- Staff scanner must remain focused and must not become a partial owner dashboard.
- Staff permissions must be enforced by existing auth/session/business permission logic, not by visual hiding alone.

## 8. Customer / Public Menu Understanding

Owner-facing explanation must make this clear:

- The customer scans the restaurant QR.
- The customer opens a web menu.
- No customer app install is required.
- The customer sees categories, products, prices in IQD, and photos if real photos are available.
- Loyalty and wallet behavior may appear later only when real.
- The owner should preview the customer menu before sharing the QR.
- The owner should understand whether the menu is draft, incomplete, or public.

## 9. Billing / Subscription Rules

- Value comes first. Do not block first setup too early.
- A trial message may appear after workspace creation if product/business decision confirms it.
- Upgrade prompts appear only when relevant to a real limit, real plan, or real value moment.
- Basic, Pro, and Premium plan UI may be shown only as honest plan UI tied to real billing rules or clearly staged read-only information.
- No fake Stripe checkout.
- No fake payment success.
- No fake subscription state.
- No fake invoices or fake payment methods.
- Billing must not be used as decoration in onboarding.

## 10. Timing Rules

- Wizard appears once for a new owner or no-business state.
- Continuation prompt appears until core setup is complete.
- Coach marks appear once after a relevant milestone.
- No more than one intrusive prompt per session.
- After a 24-hour return, show a gentle continue prompt if setup is incomplete.
- After QR is published, collapse the checklist.
- After first product is added, suggest preview.
- After trial is near end, show upgrade prompt only if Stripe-backed billing state is real.

## 11. UX Rules

- Arabic-first.
- RTL always.
- Maximum one main CTA per guided step.
- Allow `لاحقاً` unless a step is critical.
- No clutter.
- No developer wording.
- No fake features.
- No old admin panel layout.
- No repeated popups.
- No English except `Waflo` or technical necessities that users already recognize.
- No QA/test labels visible to users.
- No raw API errors, internal config keys, tokens, IDs, or debug state.
- No feature should look enabled unless it works or clearly says it is not ready.

## 12. Arabic Copy Library

### Welcome after signup

- Title: أهلاً بك في Waflo
- Body: خلّينا نجهّز مطعمك ونخلي المنيو جاهز للزبائن بخطوات بسيطة.
- CTA: ابدأ تجهيز المطعم

### Continue setup

- Title: كمّل تجهيز مطعمك
- Body: بقيت خطوة صغيرة حتى يصبح المنيو جاهز للمشاركة.
- CTA: متابعة الإعداد

### Complete restaurant info

- Title: أكمل معلومات المطعم
- Body: اسم المطعم ونوعه يساعدان الزبائن يفهمون هويتك من أول زيارة.
- CTA: حفظ المعلومات

### Add first category

- Title: أضف أول قسم
- Body: ابدأ بقسم واضح مثل المشروبات، الوجبات، الفطور، أو الحلويات.
- CTA: إضافة قسم

### Add first product

- Title: أضف أول منتج
- Body: اختر منتجاً معروفاً وضع اسمه وسعره حتى يبدأ المنيو يأخذ شكله.
- CTA: إضافة منتج

### Add image

- Title: أضف صورة حقيقية
- Body: الصورة تساعد الزبون يختار بسرعة. إذا رفع الصور غير جاهز حالياً، سنعرض المنتج بدون صورة وهمية.
- CTA: إضافة صورة
- Secondary: لاحقاً

### Preview menu

- Title: عاين منيو الزبائن
- Body: شاهد المنيو كما سيراه الزبون قبل مشاركة QR.
- CTA: معاينة المنيو

### Publish QR

- Title: شارك QR المنيو
- Body: عندما يكون المنيو العام جاهزاً، شارك QR على الطاولات أو مع الزبائن.
- CTA: مشاركة QR

### Loyalty intro

- Title: فعّل الولاء عندما تكون جاهزاً
- Body: كروت الولاء تساعدك ترجع الزبائن وتكافئهم بعد الزيارات.
- CTA: إعداد الولاء

### Staff intro

- Title: جهّز الفريق لاحقاً
- Body: عندما تكون صلاحيات الفريق جاهزة، تقدر تعطي الكاشير وصولاً محدوداً للمسح فقط.
- CTA: إدارة الفريق

### Scanner intro

- Title: امسح كارت الزبون
- Body: استخدم الكاميرا أو الإدخال اليدوي لتسجيل زيارة الزبون بأمان.
- CTA: بدء المسح

### Subscription intro

- Title: اختر الخطة المناسبة عند الحاجة
- Body: بعد ما تشوف قيمة Waflo في مطعمك، تقدر تختار الخطة التي تناسب حجم عملك.
- CTA: عرض الخطط

### Empty states

- No categories: لا توجد أقسام بعد. أضف أول قسم حتى يصبح المنيو مرتباً.
- No products: لا توجد منتجات بعد. أضف أول منتج حتى يبدأ الزبائن بتصفح المنيو.
- No public QR: QR غير جاهز بعد. أكمل المنيو ثم عاينه قبل المشاركة.
- No loyalty: الولاء غير مفعل بعد. فعّله فقط عندما تكون جاهزاً لاستخدامه.
- No staff: لا يوجد فريق بعد. أضف الفريق عندما تكون إدارة الصلاحيات جاهزة.

### Completed setup celebration

- Title: مطعمك جاهز للزبائن
- Body: المنيو وQR جاهزان. تقدر الآن تحدّث المنتجات وتتابع الولاء والفريق حسب الحاجة.
- CTA: فتح اللوحة

### Returning owner greeting

- Title: أهلاً بعودتك
- Body: نكمل من آخر خطوة توقفت عندها.
- CTA: متابعة الآن

## 13. State / Data Architecture Concept

Do not write code from this section directly. This is a conceptual model.

Walkthrough state should be modeled per user and per business/workspace.

Conceptual fields:

- `WalkthroughProgress`
- `wizardCompleted`
- `skippedSteps`
- `dismissedCoaches`
- `lastStateSnapshot`
- `lastLoginTimestamp`

Rules:

- Progress is derived from real business, menu, dashboard, loyalty, scanner, and public menu data.
- Local persistence may be acceptable for dismissed hints and one-device coach marks.
- Server persistence is needed later for cross-device consistency.
- The app must not create fake production state to make progress look better.
- A skipped step is not the same as a completed step.
- If real backend state contradicts local walkthrough state, real backend state wins.

## 14. P0 Product/Data Issues To Investigate

P0 issue: during human review, the scanner currently showed `Waflo QA Restaurant` for multiple or all accounts.

Risk:

- This may indicate fixture/default business leakage.
- This may indicate wrong business context in scanner loading.
- This may indicate stale QA data or account/business association confusion.

Rule:

- Codex must diagnose this separately before scanner/staff polish.
- Do not hide this issue with UI.
- Do not rename the displayed restaurant to mask the context bug.
- Do not proceed with scanner/staff polish until the business context source is understood.

## 15. AI Implementation Rules

- Antigravity is UI/UX implementation only.
- Codex is guard, tests, build, security, and commits.
- Human owns visual/manual approval.
- No commit before human PASS.
- Do not ask AI to judge whether a screen is sellable or visually approved.
- No fake upload.
- No fake QR.
- No fake billing.
- No fake staff.
- No fake Google.
- No mock data in production routes.
- No human visual review screens in production routes.
- No dev auth in QA/staging APKs.
- No secrets, tokens, IDs, emails, QR payloads, card references, or PII in reports or docs.

## 16. Delivery Order

1. V2-W0 Doctrine
2. V2-W1 First-run wizard shell
3. V2-W2 Returning-owner dashboard state machine
4. V2-W3 Menu empty states + first category/product guided flow
5. V2-W4 Product editor polished flow
6. V2-W5 Customer preview + QR honest flow
7. V2-W6 Loyalty onboarding
8. V2-W7 Staff management/scanner
9. V2-W8 Billing/trial/subscription
10. V2-W9 Full polish/sellable QA

## 17. Human Acceptance Criteria

### New owner

- Owner understands Waflo within the first screen.
- Owner can create a restaurant workspace.
- Owner knows why name/type/template/category/product/price matter.
- Owner can leave non-critical steps for later.
- Returning to the app resumes the exact incomplete step.
- No fake upload, QR, billing, staff, Google, or progress appears.

### Returning owner

- Dashboard shows the exact next best action.
- Checklist progress matches real data.
- Completed setup collapses into daily operations.
- No repeated modal prompts.
- No old admin-panel layout appears.

### Staff

- Staff does not see owner onboarding.
- Staff does not see owner settings, menu editing, or billing.
- Staff sees scanner-only flow when real staff auth exists.
- Staff permissions are enforced and visible.

### Customer preview and QR understanding

- Owner understands customer scans QR and opens web menu without app install.
- Preview reflects real current menu data.
- QR share is enabled only when real public menu/QR exists.
- Missing images are honest and neutral.

### Billing

- Billing appears only after value is clear or when a real limit requires it.
- Stripe-backed behavior is real.
- No fake checkout, invoices, payment methods, or subscription state.

### General Arabic/RTL/no fake features

- Arabic is the primary UI language.
- RTL layout is consistent.
- Main CTA is clear and singular on guided steps.
- No developer wording or QA labels are visible.
- No fake features are presented as real.
- Human visual review is required before commit.
