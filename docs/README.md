# Tavrix Menu Documentation

Use this folder as the team handoff source. Keep docs updated when API behavior, schema, workflow, or product rules change.

## Index

- [00-overview.md](00-overview.md): product overview, users, modules, current stage, and not-yet-built areas.
- [01-team-workflow.md](01-team-workflow.md): team ownership, branch rules, PR rules, and daily workflow.
- [02-local-development.md](02-local-development.md): local setup, ports, env files, Docker, API, web, and Flutter commands.
- [03-architecture.md](03-architecture.md): high-level system architecture and multi-tenant rules.
- [04-database-schema.md](04-database-schema.md): current Prisma models, relations, and future model plan.
- [05-api-contract.md](05-api-contract.md): planned API contract with auth, examples, and error rules.
- [06-auth-clerk.md](06-auth-clerk.md): Clerk usage, backend verification, role rules, and future guards.
- [07-business-and-menu.md](07-business-and-menu.md): business creation, roles, menu categories, menu items, and demo seed.
- [08-customer-web.md](08-customer-web.md): public customer web responsibilities, routes, and UI rules.
- [09-mobile-app.md](09-mobile-app.md): Flutter app responsibilities, routes, API client, and role-based UI.
- [10-admin-dashboard.md](10-admin-dashboard.md): internal admin dashboard purpose, pages, and future capabilities.
- [11-stripe-billing.md](11-stripe-billing.md): Basic/Pro plans, Stripe checkout, portal, and webhook rules.
- [12-ai-recommendations.md](12-ai-recommendations.md): future AI pairing rules and data model direction.
- [13-loyalty-system.md](13-loyalty-system.md): future loyalty flows, card rules, and models.
- [14-qr-system.md](14-qr-system.md): QR use cases, URL rules, scan tracking, and future models.
- [15-security.md](15-security.md): backend security rules, validation, tokens, webhooks, and audit requirements.
- [16-devops-deployment.md](16-devops-deployment.md): staging, production, domains, migrations, backups, and observability.
- [17-testing-strategy.md](17-testing-strategy.md): testing plan and required PR checks.
- [18-production-checklist.md](18-production-checklist.md): readiness checklist by product area.
- [19-codex-prompts.md](19-codex-prompts.md): reusable scoped prompts for Codex work.
- [20-roadmap.md](20-roadmap.md): sprint roadmap and acceptance criteria.
- [21-sprint-12-launch-readiness.md](21-sprint-12-launch-readiness.md): Sprint 12 scope lock — launch readiness, go/no-go checklist, pilot restaurant prep.
- [glossary.md](glossary.md): key Tavrix Menu terms.

## Legacy Docs

These original docs remain available:

- [api-contract.md](api-contract.md)
- [clerk-setup.md](clerk-setup.md)
- [database.md](database.md)
- [env-vars.md](env-vars.md)
- [stripe-plans.md](stripe-plans.md)
- [tasks.md](tasks.md)

Prefer the numbered docs for new work. Update legacy docs only when they are still used by a team workflow.
