# Roadmap

Do not start AI, loyalty, wallet integration, or custom domains before Sprint 1 and Sprint 2 acceptance criteria are done.

## Sprint 0: Foundation

Status: done.

Completed:

- Monorepo structure.
- API shell.
- Prisma schema.
- Customer web mock pages.
- Admin web mock pages.
- Flutter placeholder app.
- Docker Compose.
- Initial documentation.

## Sprint 1: Auth, Business, Menu, Public Menu

Goals:

- Clerk auth for business users and admins.
- Internal user sync.
- Business creation.
- Business membership and roles.
- Menu category CRUD.
- Menu item CRUD.
- Public menu API.
- Customer web consumes real public menu.
- Demo seed data.

Acceptance:

- Owner can sign in and create a business.
- Owner or manager can create categories and items.
- Staff cannot edit menu.
- Public menu route loads from API.
- Customer can browse without login.

## Sprint 2: QR, Images, Menu Polish, Stripe Basic/Pro

Goals:

- QR generation for public menu.
- Image upload foundation.
- Better menu UI.
- Stripe Basic and Pro checkout.
- Stripe webhook subscription updates.
- Subscription screen in Flutter.

Acceptance:

- Business can download a menu QR.
- Business can subscribe to Basic or Pro in Stripe test mode.
- Subscription state comes from webhook.
- Public menu supports images.

## Sprint 3: AI Pairings

Goals:

- AI pairing generation for existing menu items.
- Store pairings.
- Owner/manager approval flow.
- Customer web displays approved pairings.

Acceptance:

- AI never invents products.
- Unavailable items are not shown.
- Pairings can be approved or rejected.

## Sprint 4: Loyalty Core and Staff Scanner

Goals:

- Loyalty program model.
- Customer join flow from web.
- Customer card page.
- Staff scanner in Flutter.
- Loyalty transactions.

Acceptance:

- Customer can join without app download.
- Staff can scan card and apply allowed action.
- All actions create transactions.

## Sprint 5: Admin Dashboard Real Monitoring

Goals:

- Real business list.
- Real subscription list.
- Logs view.
- Business suspend/reactivate.
- AI and loyalty usage visibility.

Acceptance:

- Admin access is backend enforced.
- Sensitive admin actions are audited.

## Sprint 6: Production Hardening and Deployment

Goals:

- Staging.
- Production deployment.
- Backups.
- Logging.
- Error tracking.
- Rate limiting.
- Security review.

Acceptance:

- First paid business can safely onboard.
- Rollback and backup plans exist.

## Sprint 7: Wallet and Custom Domains

Goals:

- Apple Wallet and Google Wallet passes.
- Custom domain support.
- Advanced loyalty and analytics.

Acceptance:

- Wallet passes work for supported platforms.
- Custom domains are validated and secure.
