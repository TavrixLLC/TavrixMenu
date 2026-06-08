# Codex Prompts

Use these prompts to keep work scoped and reviewable.

## A. Backend Developer Generic Prompt

```text
You are working in the Tavrix Menu monorepo.

Scope:
- Only edit apps/api and backend docs.
- Do not modify apps/mobile, apps/customer-web, or apps/admin-web.
- Do not add secrets.
- Do not implement unrelated features.

Task:
[describe backend task]

Requirements:
- Update docs/05-api-contract.md if API behavior changes.
- Update database docs if Prisma schema changes.
- Preserve business_id multi-tenancy.
- Enforce permissions in backend.

Run checks:
- corepack pnpm --filter tavrix-menu-api prisma:generate
- corepack pnpm --filter tavrix-menu-api build
- corepack pnpm --filter tavrix-menu-api lint

Final report:
- Summary
- Files changed
- Checks run
- Risks or TODOs
```

## B. Flutter Developer Generic Prompt

```text
You are working in the Tavrix Menu monorepo.

Scope:
- Only edit apps/mobile.
- Do not modify backend or web apps.
- Do not add secrets.

Task:
[describe Flutter task]

Requirements:
- Use docs/05-api-contract.md as the API source of truth.
- Use API_BASE_URL from app config.
- Send Clerk token in Authorization header where required.
- Do not build a customer app.

Run checks:
- cd apps/mobile
- flutter analyze
- flutter test

Final report:
- Summary
- Screens changed
- Checks run
- API assumptions
```

## C. Web Developer Generic Prompt

```text
You are working in the Tavrix Menu monorepo.

Scope:
- Only edit apps/customer-web and apps/admin-web.
- Do not modify backend or mobile app.
- Do not add secrets.

Task:
[describe web task]

Requirements:
- Use docs/05-api-contract.md as the API source of truth.
- Customer web must remain public and must not use Clerk.
- Admin web is for Tavrix service owners only.

Run checks:
- corepack pnpm --filter @tavrix-menu/customer-web build
- corepack pnpm --filter @tavrix-menu/admin-web build

Final report:
- Summary
- Routes changed
- Checks run
- API assumptions
```

## D. Sprint 1 Backend Prompt

```text
You are working in the Tavrix Menu monorepo.

Scope:
- Only edit apps/api and docs.
- Do not modify Flutter or web app source.

Implement Sprint 1 backend:
- Clerk auth guard with development fallback allowed only in NODE_ENV=development.
- CurrentUser decorator.
- GET /me with internal User sync from Clerk user ID.
- Business creation.
- GET /businesses/me.
- Menu category CRUD.
- Menu item CRUD.
- Public menu endpoints.
- Seed demo business tavrix-cafe with Tavrix Cafe, Hot Drinks, Desserts, Turkish Coffee, Tamriya, Baklava.

Rules:
- Customers do not use Clerk.
- Roles live in business_users.
- Use business_id for tenant isolation.
- Staff cannot edit menu.
- Update docs/05-api-contract.md.

Run backend checks before final.
```

## E. Sprint 1 Flutter Prompt

```text
You are working in the Tavrix Menu monorepo.

Scope:
- Only edit apps/mobile.
- Do not modify backend or web apps.

Implement Sprint 1 Flutter shell:
- Clerk auth shell.
- API client with API_BASE_URL.
- GET /me integration.
- Business setup flow.
- Dashboard connected to current business state.
- Menu shell ready for categories/items.

Rules:
- This is not a customer app.
- Use docs/05-api-contract.md.
- Handle loading, error, unauthorized, and forbidden states.

Run flutter analyze and flutter test.
```

## F. Sprint 1 Web Prompt

```text
You are working in the Tavrix Menu monorepo.

Scope:
- Only edit apps/customer-web and apps/admin-web.
- Do not modify backend or mobile app.

Implement Sprint 1 web:
- customer-web consumes GET /public/m/:slug.
- customer-web product pages consume GET /public/m/:slug/items/:itemId.
- customer-web handles loading, error, and not-found states.
- AI suggestion cards remain mock unless public pairings endpoint exists.
- admin-web remains an internal shell with Clerk placeholders.

Rules:
- Customer web has no auth.
- Never expose business-only or admin data.
- Use docs/05-api-contract.md.

Run relevant Next.js builds.
```

## G. Bugfix Prompt Template

```text
You are working in the Tavrix Menu monorepo.

Issue:
[describe bug]

Reproduction:
[steps to reproduce]

Scope:
[allowed files/apps]

Requirements:
- Fix the bug with minimal scope.
- Do not include unrelated changes.
- Add or update a test if practical.
- Update docs only if behavior changes.

Run checks:
[list relevant commands]

Final report:
- Root cause
- Fix summary
- Checks run
- Remaining risk
```

## H. PR Review Prompt

```text
Review the changed files in this Tavrix Menu branch.

Focus on:
- Bugs and regressions.
- Scope violations.
- Security issues.
- business_id tenant isolation.
- API backward compatibility.
- Clerk and Stripe safety.
- Whether docs were updated when needed.
- Missing tests.

Return:
- Findings first, ordered by severity.
- File and line references.
- Open questions.
- Test gaps.
```
