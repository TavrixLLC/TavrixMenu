# Apple Wallet Registration Route Spec Spike

Date: 2026-06-22

## Finding

Apple defines the pass update endpoints relative to `webServiceURL` and adds
the `/v1` path itself. A pass containing:

```text
https://api.waflo.app/apple-wallet/v1
```

can therefore lead Wallet to request:

```text
/apple-wallet/v1/v1/devices/...
```

The API controller listens on `/apple-wallet/v1/...`. The correct value
embedded in `pass.json` is:

```text
https://api.waflo.app/apple-wallet
```

The environment validator now removes a legacy terminal `/v1` before the pass
is signed.

## Route Comparison

| Apple expected route | Current API route | Status | Risk |
| --- | --- | --- | --- |
| `POST {webServiceURL}/v1/devices/{deviceLibraryIdentifier}/registrations/{passTypeIdentifier}/{serialNumber}` | `POST /apple-wallet/v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier/:serialNumber` | Match when `webServiceURL=https://api.waflo.app/apple-wallet` | A `webServiceURL` ending in `/v1` duplicates the version segment and misses the controller |
| `GET {webServiceURL}/v1/devices/{deviceLibraryIdentifier}/registrations/{passTypeIdentifier}?passesUpdatedSince={tag}` | `GET /apple-wallet/v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier` | Match | Query value must remain opaque and must not be logged |
| `GET {webServiceURL}/v1/passes/{passTypeIdentifier}/{serialNumber}` | `GET /apple-wallet/v1/passes/:passTypeIdentifier/:serialNumber` | Match | Requires `ApplePass` authorization and returns `application/vnd.apple.pkpass` |
| `DELETE {webServiceURL}/v1/devices/{deviceLibraryIdentifier}/registrations/{passTypeIdentifier}/{serialNumber}` | `DELETE /apple-wallet/v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier/:serialNumber` | Match | Requires the same corrected base URL |
| `POST {webServiceURL}/v1/log` | `POST /apple-wallet/v1/log` | Match | Pass daemon messages must be sanitized before logging |

## Runtime Logging

All requests under `/apple-wallet` are logged after response completion,
including 404 responses. Logs contain only:

- HTTP method
- redacted path shape
- status code
- duplicate-version detection
- query parameter count and update-tag presence
- request duration

Headers, bodies, query values, full identifiers, tokens, and PII are excluded.

## Public Reachability

On 2026-06-22, method-correct requests with dummy identifiers reached the
Cloudflare edge with a valid TLS certificate, but the edge returned HTTP 502
for every route:

| Probe | Result |
| --- | --- |
| Registration route | `502` |
| Serial-list route | `502` |
| Updated-pass route | `502` |
| Log route | `502` |
| Suspected duplicated `/v1/v1` registration route | `502` |
| `/health` control route | `502` |

The uniform `/health` failure shows that this result is an unavailable tunnel
origin, not an Apple controller response. An independent in-app browser probe
was blocked before reaching the domain, so this spike does not claim a
successful off-workstation reachability check.

## Staging Boundary

The current `api.waflo.app` path is routed through a Cloudflare Tunnel running
on the local Windows development machine. This is not a stable physical-device
test target. After deploying the corrected pass base URL and logging, the next
iPhone test should use the persistent VPS staging topology described in
`docs/runbooks/staging-waflo-domains.md`.

Classification after this spike:

```text
WEB_SERVICE_URL_PATH_MISMATCH found and corrected locally
NEEDS_STABLE_STAGING before another physical iPhone callback test
```

## Apple References

- https://developer.apple.com/documentation/walletpasses/adding-a-web-service-to-update-passes
- https://developer.apple.com/documentation/walletpasses/register-a-pass-for-update-notifications
- https://developer.apple.com/documentation/walletpasses/get-the-list-of-updatable-passes
- https://developer.apple.com/documentation/walletpasses/send-an-updated-pass
- https://developer.apple.com/documentation/walletpasses/unregister-a-pass-for-update-notifications
- https://developer.apple.com/documentation/walletpasses/log-a-message
