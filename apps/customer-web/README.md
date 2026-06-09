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
```

Server-side fetching also supports `API_BASE_URL` if you want to avoid exposing the base URL in a browser bundle later.

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
