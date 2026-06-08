# Production Checklist

Use this checklist by readiness milestone. Product-area headings are kept inside each milestone so ownership stays clear.

## Required before first paid restaurant

### Auth

- [ ] Clerk token verification in backend.
- [ ] Internal user sync from Clerk user ID.
- [ ] Business role guard.

### Database

- [ ] Prisma migrations committed.
- [ ] Business-owned queries filter by `business_id`.
- [ ] Seed or setup path for initial plans.

### Billing

- [ ] Stripe products and price IDs configured.
- [ ] Checkout session creation.
- [ ] Webhook signature verification.
- [ ] Subscription state updated only from webhook.

### Security

- [ ] No real secrets committed.
- [ ] DTO validation.
- [ ] Staff permission checks.

### Public Website

- [ ] Real public menu API integration.
- [ ] Loading, error, and not-found states.
- [ ] Mobile-first QA.

### Mobile App

- [ ] Clerk mobile auth.
- [ ] Business setup.
- [ ] Menu management.

### QR

- [ ] Public menu URL works from QR.

### Deployment

- [ ] Staging environment.

### Support Operations

- [ ] Support contact path.

## Required before public launch

### Auth

- [ ] Admin guard.
- [ ] No development auth fallback in production.

### Database

- [ ] Backup policy.

### Billing

- [ ] Customer portal.

### Security

- [ ] Rate limiting for public endpoints.
- [ ] Audit logs for sensitive actions.

### Public Website

- [ ] Basic SEO and metadata.

### Mobile App

- [ ] Subscription screen.

### Admin Dashboard

- [ ] Real admin auth.
- [ ] Business list.
- [ ] Subscription visibility.

### QR

- [ ] QR download.

### Observability

- [ ] API error logging.
- [ ] Stripe webhook logging.

### Backups

- [ ] Managed DB backups.
- [ ] Restore plan.

### Deployment

- [ ] Production environment.
- [ ] Migration process.
- [ ] Rollback plan.

### Legal and Compliance Basics

- [ ] Privacy policy.
- [ ] Terms of service.
- [ ] Billing cancellation language.

### Support Operations

- [ ] Admin view for business status.

## Later

### Database

- [ ] Branch schema.

### Public Website

- [ ] Custom domains.

### Mobile App

- [ ] Staff scanner.

### Admin Dashboard

- [ ] Manual plan override.

### AI

- [ ] Pairing generation.
- [ ] Owner approval flow.
- [ ] Usage logs.

### Loyalty

- [ ] Loyalty program setup.
- [ ] Customer card page.
- [ ] Staff scan flow.
- [ ] Loyalty transactions.

### QR

- [ ] Scan tracking.
- [ ] Table and branch QR codes.

### Observability

- [ ] Dashboards and alerts.

### Backups

- [ ] Scheduled restore drills.

### Legal and Compliance Basics

- [ ] Data retention policy.

### Support Operations

- [ ] Internal support notes.
