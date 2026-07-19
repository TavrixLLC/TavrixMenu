# Sprint 10G Team Workflow & Collaboration Guide

This document outlines the development workflow, ownership structure, and security boundaries for the Tavrix Menu team.

## Ownership Structure
To maintain a high standard of security, efficiency, and code quality, team responsibilities are distributed as follows:

* **Person 1 (Backend & Infra Owner):**
  * Controls the core NestJS API backend.
  * Owns the infrastructure configuration (Docker, Prisma migrations, local tunnels).
  * Acts as the sole custodian of all secrets, certificates, and credentials (including Apple Developer certificates, Stripe secrets, and Google Wallet service accounts).

* **Person 2 (Mobile App Owner):**
  * Controls the Flutter mobile application.
  * Owns the staff camera scanning workflow.
  * Does not have access to backend production/staging secrets or private wallet certificates.

* **Person 3 (Web Applications Owner):**
  * Controls the customer-web (Next.js) and admin-web frontends.
  * Owns the user interface, loyalty enrollment layouts, and styling.
  * Does not have access to backend private keys or certificates.

## Security & Isolation Rules
To protect sensitive development and production credentials:
1. **Zero Secret Sharing:** Secrets, private keys, `.p12`/`.pem` certificates, and database password strings must **never** be shared in chat logs, emails, repositories, or pull requests.
2. **Branch Separation:** Each person must work on their respective feature or sprint branches. Cross-boundary code modifications (e.g. mobile devs altering backend modules) are strictly prohibited.
3. **Planned Automated Audit Pipeline:** Automated pull-request and branch auditing is planned, but no tracked pipeline currently establishes it as an active merge gate. Until one is implemented and verified, required reviews and checks remain explicit human workflow steps.
4. **Staging Environment Shift:** Moving forward, local laptop-bound development dependencies (like local reverse proxies and tunnels) must be replaced with a persistent staging VPS environment. This prevents Wi-Fi dropouts or local power outages from disrupting E2E mobile and customer tests.
