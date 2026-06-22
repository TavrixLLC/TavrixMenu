# Runbook: Staging Waflo Domains & Infrastructure Setup

This runbook documents the mapping and persistent routing configurations for the Waflo staging environment.

## Domain Mapping Layout
The public subdomains under `waflo.app` are structured as follows:

* **API Services (Backend):**
  * Domain: `https://api.waflo.app`
  * Internal Port: Local port `3000` (NestJS)
  * Responsibilities: Serves public endpoints, health checks, scanner APIs, and the Apple Wallet update web service (`/apple-wallet/v1`).

* **Customer Web (Frontend):**
  * Domain: `https://card.waflo.app`
  * Internal Port: Local port `3001` (Next.js)
  * Responsibilities: Serves customer loyalty program cards, enrollment interfaces, and proxies pass downloads.

## Staging & VPS Transition Strategy
1. **Current Local Setup (Temporary):**
  * Dev services run locally via `pnpm dev:api` and `pnpm dev:customer`.
  * Traffic is routed from public subdomains via a local Cloudflare Tunnel configured in `C:\Users\DELL\.cloudflared\config.yml`.
  * This is highly sensitive to local machine state (power, OS sleep) and Wi-Fi connection health.
2. **Target Staging Setup (Contabo VPS):**
  * Migrate the API and Customer Web services to run persistently inside Docker containers on a Contabo VPS.
  * Run `cloudflared` as a system service (systemd) on the VPS, binding to the container ports.
  * This removes laptop dependencies, guaranteeing stable public availability for E2E device registrations and APNs testing.
