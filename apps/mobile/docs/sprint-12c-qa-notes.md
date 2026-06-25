# Sprint 12C Mobile QA Notes

## Product Owner Runtime QA

- Camera works on the tested real device/emulator path.
- Custom OTP authentication works.
- The custom Waflo authentication UI works.
- Google native account picker remains pending configuration, not blocked by UI code.

## Google Native Sign-In Configuration

The Google button must remain safe when config is missing. Missing config should show:

> Google sign-in is not configured yet.

Required build-time values:

- `GOOGLE_CLIENT_ID`
- `GOOGLE_SERVER_CLIENT_ID` when required by the current Google/Clerk setup

Do not print Google tokens, Clerk tokens, JWTs, phone/email, or other PII while validating this flow. The app must continue using Clerk session management; do not create a parallel auth path.

## Menu Template Picker QA

- Menu Appearance loads the catalog from `GET /menu-templates`.
- Current appearance loads from `GET /businesses/:businessId/appearance`.
- Save sends `PATCH /businesses/:businessId/appearance` with only `menuTemplateId`.
- Preview opens `/m/:slug?previewTemplateId=<template-id>` and does not save.
- Backend `403` is the source of truth for save permission and should show a polished permission message.
- Arbitrary custom CSS upload is not part of Sprint 12C mobile scope.

## Role Context QA

- Missing or unknown role displays neutral operator copy.
- The app must not label an unknown authenticated business member as Staff.
- Active business membership opens the dashboard path even when onboarding flags are incomplete.
- Scanner remains reachable for staff/operator workflows; scanner token validation logic is unchanged.
