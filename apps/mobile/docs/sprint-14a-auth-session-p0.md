# Sprint 14A Auth Session P0

## Decision

`GOOGLE_SIGN_IN_CONFIG_BLOCKED`

The mobile app includes Clerk authentication and the `google_sign_in` package, but Google Sign-In is not safe to expose until the external auth configuration is verified.

Required setup before enabling a Google button:

- Clerk Google social provider enabled for the staging/production instance.
- Android/iOS OAuth client IDs configured for the released mobile app package/bundle.
- Server client ID configured when required by Clerk's Google token strategy.
- Native redirect/deep-link behavior smoke-tested on a real device.

Until those are complete, the mobile UI should keep Google Sign-In hidden and use the existing email/phone verification flow. Do not create a fake Google sign-in path.

## Session Restore

The app relies on Clerk's persisted session support and now waits briefly for that persisted session to hydrate before deciding that a user is signed out. While this check is running, the app shows a restoring-session state instead of flashing the login screen.

## Billing Boundary

Subscription and plan wording are hidden from the owner dashboard because billing is not active in Sprint 14A.

## Security

- Do not log Clerk tokens or session values.
- Do not persist tokens outside the Clerk auth/session mechanism.
- Do not display token, JWT, or provider-debug wording to operators.
