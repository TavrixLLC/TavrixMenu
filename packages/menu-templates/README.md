# Menu Template Registry

This package is the shared Waflo-managed registry for public menu templates.

To add a future template:

1. Add a CSS file under `apps/customer-web/app/styles/menu-templates/`.
2. Add metadata to `packages/menu-templates/manifest.cjs`.
3. Add preview metadata and thumbnail URLs when available.
4. Run API, customer-web, and admin-web tests/builds.

Business owners cannot upload arbitrary CSS in this sprint. Template CSS is reviewed and versioned by Waflo.
