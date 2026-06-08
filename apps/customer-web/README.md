# Tavrix Menu Customer Web

Public Next.js App Router website for customer menu browsing.

Customers do not authenticate here and do not need to download an app.

## Run

From the repository root:

```bash
pnpm dev:customer
```

Mock menu route:

```text
http://localhost:3001/m/tavrix-cafe
```

## Environment

Copy `.env.example` to `.env` and set `NEXT_PUBLIC_API_BASE_URL` when the API integration begins.

Current pages use mock data only.
