# DevOps and Deployment

Tavrix Menu should deploy to staging first and production later.

Current local infrastructure uses Docker Compose only.

## Suggested Domains

- API: `api.tavrixmenu.com`
- Customer menu: `menu.tavrixmenu.com` or `tavrixmenu.com/m/[slug]`
- Admin dashboard: `admin.tavrixmenu.com`

## Deployment Components

- API container.
- Managed PostgreSQL database.
- Redis.
- Customer web app.
- Admin web app.
- Flutter Android and iOS builds.
- Object storage later for images and assets.
- Environment variable management.
- Database migrations.
- Backups.
- Logging.
- Error tracking.

## Staging

Staging should exist before production.

Staging requirements:

- Separate database.
- Separate Redis.
- Separate Clerk app or environment.
- Separate Stripe test mode configuration.
- Safe test data.
- Automatic deploy from `dev` later.

## Production

Production requirements:

- Deploy only from stable branch or release tag.
- Managed database with backups.
- HTTPS everywhere.
- Real domain configuration.
- Secret manager or protected environment variables.
- Migration process.
- Rollback plan.
- Error monitoring.
- Access control for admin dashboard.

## Database Migrations

Rules:

- Migrations must be reviewed.
- Do not edit applied production migrations.
- Test migrations on staging before production.
- Back up production before risky migrations.

## Observability

Add later:

- API logs.
- Request IDs.
- Error tracking.
- Stripe webhook logs.
- Background job logs.
- Public endpoint rate metrics.

## Backups

Production needs:

- Automated database backups.
- Restore testing.
- Backup retention policy.
- Clear owner for restore operations.
