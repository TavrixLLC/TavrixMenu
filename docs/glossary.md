# Glossary

## Business

A tenant in Tavrix Menu. The first business types are restaurants and cafes, but the platform is designed to support other business types later.

## Owner

The main business user. Owners can manage business settings, menu, staff, QR, and billing.

## Manager

A business user with operational permissions. Managers can manage menu and business workflows depending on backend permissions.

## Staff

A limited business user. Staff will mainly use scanner and activity tools later.

## Customer

A person browsing the public menu or using a loyalty card. Customers do not use Clerk and do not need an app.

## Public Menu

The customer-facing menu website available from QR codes and public links.

## Business App

The Flutter app for business owners, managers, and staff.

## Admin Dashboard

The internal web dashboard for Tavrix service owners.

## Clerk

Authentication provider used for business owners, managers, staff, and admins only.

## Stripe

Billing provider used for subscriptions, checkout, billing portal, and webhooks.

## business_id

The tenant isolation key for business-owned records. Use `business_id` everywhere for tenant data.

## QR Menu

A QR code that opens a public Tavrix Menu URL for a business menu.

## Loyalty Card

A future customer web card with a random QR token used for stamps, points, or rewards.

## AI Pairing

A future approved recommendation that links one existing menu item to another existing menu item with a short reason.

## Wallet Pass

A future Apple Wallet or Google Wallet pass for a customer loyalty card.

## Staff Scanner

A future Flutter app feature that lets staff scan customer loyalty cards and apply allowed loyalty actions.
