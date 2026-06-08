# Team Workflow

Tavrix Menu is built by a three-person team. Each person owns a clear area to reduce merge conflicts and accidental cross-app changes.

## Ownership

Person 1 Backend owns:

- `apps/api`
- Backend docs
- NestJS
- Prisma
- Clerk backend verification
- Stripe
- APIs
- Database schema
- Security and permissions

Person 2 Flutter owns:

- `apps/mobile`
- Owner and staff mobile app
- Clerk mobile integration
- API integration
- Menu management screens
- QR screen
- Staff scanner later

Person 3 Web owns:

- `apps/customer-web`
- `apps/admin-web`
- Public menu website
- Product pages
- AI suggestion card UI
- Admin dashboard

Customer web is the web priority until the public menu is real. Admin web should stay useful but can remain simpler in early sprints.

## Strict Scope Rules

- Backend developer should not modify mobile or web apps.
- Flutter developer should not modify backend or web apps.
- Web developer should not modify backend or mobile apps.
- Cross-app changes require coordination before editing.
- Shared API changes must update the API contract before frontend integration.
- No one should implement unrelated features in a scoped task.

## Branching

- `main` is stable.
- `dev` is integration.
- Feature branches are used for work.

Branch examples:

- `feature/api-auth-foundation`
- `feature/mobile-auth-shell`
- `feature/customer-web-public-menu`
- `feature/admin-dashboard-shell`

## PR Rules

- Keep PRs small.
- Include a short summary.
- Include commands run.
- Include screenshots for UI changes when useful.
- Include API contract updates for API changes.
- Do not include unrelated formatting or generated output.
- Do not add secrets.

## Daily Workflow

1. Pull latest `dev`.
2. Create a feature branch.
3. Use Codex with a scope-limited prompt.
4. Make the smallest working change.
5. Run relevant checks.
6. Open a PR to `dev`.
7. Paste the Codex report and test output summary to the project lead.

## Codex Use

Codex should be given strict scope every time:

- Which app or docs it may edit.
- Which app or docs it must not edit.
- Which checks it must run.
- Which docs it must update.

For reusable prompts, see [19-codex-prompts.md](19-codex-prompts.md).
