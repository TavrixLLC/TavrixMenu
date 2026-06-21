# Tavrix Menu Customer Web

Public Next.js App Router website for customer menu browsing.

Customers do not authenticate here and do not need to download an app.

## Run

From the repository root:

```bash
corepack pnpm dev:customer
```

The customer site runs on port `3001` by default:

```text
http://localhost:3001/m/tavrix-cafe
```

## Environment

Copy `.env.example` to `.env.local` and set the public API base URL:

```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000
NEXT_PUBLIC_ENABLE_APPLE_WALLET_BUTTON=false
```

Server-side fetching also supports `API_BASE_URL` if you want to avoid exposing the base URL in a browser bundle later.

The Apple Wallet action is intentionally hidden by default. Set
`NEXT_PUBLIC_ENABLE_APPLE_WALLET_BUTTON=true` only for certificate and iPhone
validation. The customer-web proxy requests the pass from the backend only
after a customer clicks the button; Apple signing credentials remain backend
owned and must never be added to this app.

`NEXT_PUBLIC_*` values are embedded by Next.js when `pnpm build` runs. Set the
Apple Wallet flag in the build environment before building, and rebuild the app
when changing it. Changing only the runtime environment of an existing build
will not reliably change the customer-facing button. A server-provided runtime
configuration endpoint would be the appropriate follow-up if deployments need
to toggle this feature without rebuilding.

Wallet actions are device-aware: iPhone and iPad visitors see Apple Wallet when
the flag is enabled, Android visitors see Google Wallet, and desktop visitors
are prompted to copy the web-card link to a phone. The web card remains the
source for current stamp and reward progress.

## Local API Check

Start the API on port `3000`, then start customer-web:

```bash
corepack pnpm dev:api
corepack pnpm dev:customer
```

Open:

```text
http://localhost:3001/m/tavrix-cafe
```

The page should render the live public menu from `GET http://localhost:3000/public/m/tavrix-cafe`, including Tavrix Cafe, Hot Drinks, Desserts, Turkish Coffee, Tamriya, and Baklava.
