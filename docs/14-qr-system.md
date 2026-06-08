# QR System

QR codes connect physical customer actions to Tavrix public URLs.

## QR Use Cases

- Menu QR
- Table QR
- Branch QR
- Loyalty join QR
- Customer loyalty card QR later

## URL Rules

QR codes should point to Tavrix public URLs.

Examples:

```text
https://tavrixmenu.com/m/tavrix-cafe
https://tavrixmenu.com/m/tavrix-cafe?table=12
https://tavrixmenu.com/card/random-card-token
```

Do not put sensitive data inside QR codes.

## Scan Tracking Later

QR scans should be tracked later for analytics:

- Which QR code was scanned.
- Business ID.
- Branch or table if applicable.
- Timestamp.
- Basic device context if safe.

Avoid collecting unnecessary personal data.

## Downloads Later

The business app should later support downloadable:

- PNG QR image.
- PDF print sheet.
- Table card template.

## Future Models

- `QRCode`
- `QRScan`

Every QR code owned by a business should include `business_id`.
