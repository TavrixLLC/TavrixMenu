# Waflo API Instructions

Inherit all repository instructions from the root `AGENTS.md`.

- Tenant-scope every business-owned query and mutation.
- Verify authoritative membership and role permissions server-side.
- Verify that category and product identifiers belong to the active business.
- Do not assume global `Customer` ownership. Customer tenant isolation remains
  a release blocker before Loyalty release.
- Keep DTOs, implementation, tests, OpenAPI, and documentation consistent.
- Do not hide schema changes inside feature work. Never run a destructive
  migration or database reset.
- Report mutation success only after persistence is confirmed.
- Add negative authorization tests for security-sensitive changes.
- Never print secrets or PII in logs, tests, reports, or tool output.
