# Play Console — Data safety draft

Paste answers into Play Console → App content → Data safety. Align with the hosted Privacy Policy once published. This is a **draft based on the current Flutter client**, not a legal sign-off.

## Overview questions

| Question | Draft answer |
|----------|----------------|
| Does the app collect or share user data? | **Yes** — collected for app functionality; shared with service providers as processors (API host, optional Supabase, optional Sentry). |
| Is all data encrypted in transit? | **Yes** (HTTPS/TLS to Django / Supabase / Sentry). |
| Can users request deletion? | **Yes** — document the path in the Privacy Policy (support email / in-app once built). |

## Data types (typical HapoPay collection)

Mark **Collected** (and **Shared** only if a third party uses data for their own purposes — usually processors are “collected” not “sold”).

| Category | Data | Purpose | Optional? | Ephemeral? |
|----------|------|---------|-----------|------------|
| Personal info | Name, email | Account management, app functionality | Required for account | No |
| Financial info | Purchase history / spend activity, user payment info as shown in-app (balances, limits) | App functionality | Required for wallet features | No |
| App activity | In-app actions (login, pay, lock/limit changes) as needed for the product | App functionality | — | No |
| App info and performance | Crash logs (if `SENTRY_DSN` set) | Analytics / diagnostics | Optional (only when Sentry configured) | No |
| Device or other IDs | May apply via crash SDK / OS; avoid advertising IDs | Diagnostics | Optional | No |

**Usually not collected by this client today:** precise location, contacts, photos library (camera is for QR scan — declare **Photos and videos** only if you store images; otherwise describe camera use under permissions / policy without claiming photo library collection), SMS, health.

## Camera

Declare the **Camera** permission for QR pay/scan. State in the policy that frames are used for scanning, not for a social photo feed.

## Biometrics

`local_auth` uses the OS biometric APIs. The app does **not** receive fingerprint/face templates. Declare biometric unlock in the Privacy Policy; Data safety typically does **not** treat templates as collected by the app.

## Data deletion

Provide a working deletion request channel before launch. Until in-app deletion exists, use support email + backend wipe procedure.

## Consistency checks

- [ ] Matches Privacy Policy checklist ([`../legal/PRIVACY_POLICY_CHECKLIST.md`](../legal/PRIVACY_POLICY_CHECKLIST.md))
- [ ] No “we don’t collect financial info” if balances/transactions sync from the API
- [ ] Sentry declared only if production builds ship a non-empty `SENTRY_DSN`
