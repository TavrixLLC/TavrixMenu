# Security and Release Gates

Status: `Planned`. Customer tenant isolation and loyalty mutation security are release blockers, not backlog polish.

## 1. Threat model summary

Protected assets include customer identity, membership balances, rewards, Wallet passes, staff authority, business media/designs, transaction history, and audit evidence. Primary threats are cross-Business access, role escalation, QR/token theft, replay or duplicated mutations, offline conflict, enumeration, forged amounts/products, theme/media substitution, and incomplete audit trails.

Trust boundaries:

- Flutter mobile device and camera input are untrusted clients.
- Customer Web links and QR codes may be copied or exposed.
- Clerk proves an application identity; Waflo membership proves Business/role authority.
- Wallet providers are external systems with provider-specific signing and update credentials.
- Background jobs and schedulers require the same tenant, idempotency, and audit guarantees as interactive requests.

## 2. Business and branch isolation

`Existing and verified`: API business access helpers and Flutter fail-closed active-business resolution exist; W2A logout/workspace/scanner-context clearing and late-result protections have regression tests.

`Release blockers`:

1. Resolve the active Business only from current authoritative memberships.
2. Require explicit selection when more than one active membership exists; never select index zero.
3. Scope each Prisma query by `businessId`, including lookups by supposedly unique IDs.
4. Add `branchId` only after checking that the active membership is allowed to act at that branch.
5. Clear customer lists, scanner context, drafts, cached metrics, and media/theme previews when Business/session changes.
6. Add negative integration tests for every V1 resource: program, rule, reward, customer, membership, ledger, redemption, media, design, theme, Wallet pass, and audit event.
7. Treat missing or ambiguous context as authorization failure, not an empty state.

## 3. Customer identity scope and privacy

`Existing risk`: current Customer contact fields are globally unique and the same Customer row can be reused across Businesses.

Before Loyalty release:

- Store and query a Business-scoped CustomerAccount.
- Define normalized phone/email uniqueness within Business scope.
- Separate authentication/contact verification from a merchant’s loyalty profile.
- Do not reveal whether a contact exists in another Business.
- Require explicit recovery/transfer verification and rate-limit attempts.
- Define retention, export, deletion, and consent behavior for Iraqi operating requirements with legal/product review.
- Redact phone/email/token data in logs and analytics.

## 4. Roles and permissions

Authorization is enforced server-side for every command. UI visibility is convenience, not a security control.

Minimum policy:

| Capability | Owner | Manager | Staff |
|---|---|---|---|
| Manage Business/memberships | Yes | By explicit permission only | No |
| Create/publish loyalty program | Yes | By explicit permission | No |
| Edit/publish CardDesign/VisualTheme | Yes | By explicit permission | No |
| Scan and record earning | Yes | Yes | Yes, assigned branches only |
| Redeem reward | Yes | Yes | Yes, within policy/branch limits |
| Manual adjustment/reversal | Yes | Restricted and reasoned | No by default |
| View reports/customers | Yes | Scope-limited | Minimal transaction context |

Invitations, role changes, program publication, manual adjustments, design/theme publication, redemptions, and credential rotation must be audited.

## 5. QR signing and token lifecycle

`Existing and verified`: signed/hashed, Business-bound, versioned scanner/card token foundations exist.

`Existing risk`: explicit expiry and mutation-level replay/idempotency controls were not verified.

Required design:

- Sign canonical payloads with a versioned algorithm and managed key ID.
- Include purpose, Business, subject/presentation ID, issued-at, expiry, and random nonce or server-side token reference.
- Use constant-time signature comparison and reject unknown versions/keys.
- Never embed customer PII, balance, reward readiness, or authority as trusted clear-text state.
- Rotate/revoke tokens through auditable server state.
- Use short-lived scanner presentations where practical; long-lived customer card identifiers must resolve to fresh server state.
- QR Poster join links and customer scanner tokens use different purposes and validation paths.

## 6. Replay prevention and idempotency

Every loyalty mutation accepts a client-generated idempotency key bound to Business, actor/device, command type, and normalized payload hash.

Server behavior:

1. Reserve the key transactionally.
2. Return the original result for an exact retry.
3. Reject reuse with a different payload.
4. Lock or atomically update the affected membership/ledger projection.
5. Record presentation/nonce consumption when the policy is single-use.
6. Emit ledger, redemption, audit, and outbox records in one transaction.

The unique key and retention period are server-enforced. A disabled Flutter button is not replay protection.

## 7. Offline scanner risks

V1 default is `offline read-only`; earning and redemption require server confirmation. Cached customer/program information is labeled stale and contains the minimum necessary data.

Offline writes remain `Deferred` until there is an approved model for:

- Device registration and revocation.
- Signed local authority and expiry.
- Per-device sequence numbers.
- Amount/product evidence and fraud limits.
- Conflict resolution and duplicate prevention.
- Secure queue storage and logout/Business-switch clearing.
- Redemption reservation without double spend.

Network failure must not appear as zero balance, empty results, or completed earning/redemption.

## 8. Input, rate, and fraud controls

- Validate amount, currency, product/service, branch, program version, reward eligibility, and actor permission on the server.
- Rate-limit login/recovery, public join, card transfer, customer search, token resolution, scan attempts, earning, redemption, media upload, and preview generation.
- Apply tighter rules by token/IP/device/Business when abuse signals justify them without blocking legitimate shared networks.
- Prevent customer enumeration using uniform public responses and bounded searches.
- Enforce media MIME, extension, decoded format, pixel dimensions, size, malware policy, and Business ownership.
- Use transaction/adjustment thresholds and mandatory reason codes for risky staff operations.
- Monitor impossible velocity, repeated reversal, cross-branch anomalies, and token guessing.

## 9. Audit logs and observability

`Existing`: an AuditLog model and limited verified writes.

`Release requirement`: append-only, queryable coverage for authentication-sensitive and loyalty state changes.

Each entry includes Business, branch where relevant, actor User/membership/role, target type/ID, action, result, reason, request/correlation ID, idempotency key, safe before/after metadata, IP/device signals where lawful, and timestamp. Secrets, raw QR tokens, contact values, and provider credentials are excluded or redacted.

Critical alerts include cross-tenant authorization failures, duplicate-key conflicts, replay rejection, ledger imbalance, abnormal staff velocity, scheduler conflict, Wallet signing/update failure, and audit-write failure. A critical mutation must fail closed if its mandatory audit record cannot be committed transactionally.

## 10. Wallet token and provider security

- Store Apple certificates/private keys and Google service credentials in an approved secret manager; never in Git or mobile assets.
- Separate development, staging, and production credentials/identifiers.
- Apply least privilege, rotation, expiry monitoring, and access audit.
- Hash customer pass access/authentication tokens at rest where protocol behavior permits.
- Authenticate Apple device registration/update endpoints and validate provider request semantics.
- Do not expose signing endpoints directly to untrusted mobile input without a validated server projection.
- Revoke/rotate compromised tokens without changing loyalty balances.
- Validate installed-pass updates on real devices before public release.

## 11. CardDesign, Campaign, and VisualTheme security

- Every media, design, campaign, theme, and assignment is Business-scoped.
- A design/theme publish command requires role authorization, current revision, idempotency, validation, and audit.
- Preview endpoints must not publish or update Wallet passes.
- Theme scheduler workers use database leases/unique execution keys so activation and expiry run once safely.
- Resolve overlaps deterministically using approved priority rules; do not depend on job arrival order.
- Store Business timezone plus UTC instants; reject `endAt <= startAt`.
- Expiry falls back to the published base design even if a worker retries.
- Theme/Campaign payloads cannot reference earning rules, balance deltas, or redemption commands.
- QR Poster templates must preserve QR quiet zones and cannot overlay untrusted content on the code.

## 12. Release gates

### Gate A — code and data isolation

- Positive and negative Business/branch authorization tests pass for every V1 endpoint.
- CustomerAccount scope is implemented; global contact uniqueness no longer leaks or couples merchants.
- Multi-business selection is explicit and session switches clear state.

### Gate B — loyalty integrity

- Append-only ledger, balance reconciliation, concurrency, idempotency, replay, reversal, and redemption double-spend tests pass.
- Rules are versioned and historical entries retain the applied version.
- No client can submit an authoritative resulting balance or reward readiness.

### Gate C — scanner and Wallet

- Token purpose, signature, expiry/revocation, replay policy, rate limits, and audit behavior pass a security review.
- Online and failure-state device tests pass.
- Apple/Google provider sandboxes and real target devices confirm pass issuance/update behavior.

### Gate D — privacy and operations

- Logs are redacted; retention/export/deletion policies are approved.
- Monitoring, alerts, backup/restore, incident response, key rotation, and support runbooks are exercised.
- Pilot rollback has been rehearsed without deleting ledger history.

### Gate E — experience and release authority

- Arabic/Sorani/English functional and accessibility tests pass.
- Human visual approval exists for mobile, customer web, Wallet, and printable QR output.
- Product/security/data owners approve the pilot.
- Deployment, migrations, customer notifications, financial actions, and store submissions receive their required human approvals.

Failure of any applicable gate blocks launch. Automated tests cannot substitute for provider, security, legal, operational, or human visual approval.
