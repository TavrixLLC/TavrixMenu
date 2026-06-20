# Apple Wallet Real Certificate Smoke

## Scope

This procedure validates the Sprint 10A backend-only Apple Wallet foundation
with a real Apple Pass Type ID certificate. It does not add a public endpoint,
Apple Wallet update web service, schema change, or frontend/mobile behavior.

Never paste certificate contents, passwords, private keys, QR values, or the
generated pass into chat, tickets, source files, or command output.

## Required Apple Developer Items

Prepare these items in the Apple Developer account and local keychain or
certificate tooling:

1. The Apple Developer Team ID.
2. A registered Pass Type Identifier, such as a `pass.` identifier owned by
   that team.
3. The Pass Type ID signing certificate issued for that identifier.
4. The private key paired with the signing certificate.
5. The Apple Worldwide Developer Relations intermediate certificate used by
   the signer implementation.
6. A local PKCS#12 bundle containing the pass certificate and matching private
   key.
7. The local password protecting that PKCS#12 bundle.

The current backend reads the signer certificate and private key from one
PKCS#12 bundle and reads the WWDR certificate separately. It accepts the WWDR
certificate in PEM or DER form.

## Secure Local Files

Use a directory outside the repository, recommended:

```text
D:\secure\apple-wallet\
```

Store the local PKCS#12 bundle and WWDR certificate there. Restrict the folder
to the current Windows account. Do not place certificate material under the
TavrixMenu checkout, even temporarily.

Never commit `.p12`, `.pfx`, `.pem`, `.cer`, `.key`, `.env`, or generated
`.pkpass` files. The mobile, customer-web, and admin-web applications must
never receive Apple signing material.

## Local Environment

Configure `apps/api/.env` locally. The values below are placeholders only:

```dotenv
APPLE_WALLET_ENABLED=true
APPLE_WALLET_TEAM_ID=<APPLE_TEAM_ID>
APPLE_WALLET_PASS_TYPE_IDENTIFIER=<APPLE_PASS_TYPE_IDENTIFIER>
APPLE_WALLET_ORGANIZATION_NAME=<ORGANIZATION_NAME>
APPLE_WALLET_CERTIFICATE_PATH=D:\secure\apple-wallet\<PASS_CERTIFICATE>.p12
APPLE_WALLET_CERTIFICATE_PASSWORD=<LOCAL_PKCS12_PASSWORD>
APPLE_WALLET_WWDR_CERTIFICATE_PATH=D:\secure\apple-wallet\<APPLE_WWDR>.cer
WALLET_SCAN_TOKEN_SECRET=<LOCAL_SECRET_WITH_AT_LEAST_32_CHARACTERS>
```

Do not paste real values into chat, documentation, shell history, or committed
files. Prefer editing the ignored local `.env` directly.

## Run The Smoke

From the repository root:

```powershell
pnpm apple-wallet:smoke-test
```

The command refuses to write inside the repository unless the output path is
ignored by git. It writes one pass under
`apps/api/public/generated/apple-wallet/` and prints only:

- Pass Type Identifier suffix.
- Whether the Team ID is present.
- Serial number suffix.
- Output byte size.

It does not print the output path, certificate password, private key, raw QR
scan token, or pass contents.

Confirm the generated file is ignored before transferring it:

```powershell
git check-ignore -v -- apps/api/public/generated/apple-wallet/<GENERATED>.pkpass
git status --short
```

## Verify On iPhone

1. Transfer only the generated test pass to the test iPhone using a controlled
   channel such as the user's private iCloud Drive. Treat the pass as
   sensitive because its QR code contains a live scan token.
2. Open the pass on the iPhone from Files or the controlled transfer channel.
3. Confirm iOS recognizes it as an Apple Wallet pass and displays the Add
   action without a signature error.
4. Add it to Wallet and verify the Waflo logo, generic loyalty wording, stamp
   progress, reward text, and QR barcode.
5. Do not publish or share the generated pass. Sprint 10A has no public Apple
   download endpoint.

Record only a pass/fail result and the safe metadata printed by the smoke
command. Do not include screenshots that expose the QR value.

## Cleanup

After device verification, delete the exact generated test pass unless it is
temporarily needed for the controlled iPhone transfer:

```powershell
Remove-Item -LiteralPath 'D:\install\business\TavrixMenu\apps\api\public\generated\apple-wallet\<GENERATED>.pkpass'
git status --short
```

Keep the real Apple certificates only in the secure directory. If a pass, raw
QR value, private key, or certificate password is exposed, stop testing and
rotate the affected material before continuing.
