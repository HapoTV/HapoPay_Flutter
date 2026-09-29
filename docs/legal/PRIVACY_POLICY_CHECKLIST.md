# Privacy Policy checklist (not legal advice)

Draft and host a public HTTPS Privacy Policy before App Store / Play submission.
This file lists what HapoPay’s policy should cover given the current Flutter client.
Have counsel review before publishing. Settings links stay inert until a real URL exists.

## Must include

- **Who we are** — Legal entity name, support / privacy contact (e.g. `conduct@hapopay.com` or a dedicated `privacy@…`).
- **What the app does** — Campus student spending wallet with parent oversight (limits, card lock, family ledger), rewards/achievements, optional biometric unlock, QR pay.
- **Personal data collected**
  - Account: name, email, role (parent / student), auth tokens (JWT).
  - Financial activity: balances, spending limits, transaction history, payment attempts.
  - Device / security: biometric preference (not the biometric template itself — OS handles that), app version, crash diagnostics if Sentry is enabled.
  - Optional: camera for QR scan (processed on device / for payment flow; state whether images are stored).
- **Sources** — Data entered by the user; data returned by the Django API; optional Supabase Realtime fan-out of transaction events (read path only — ledger source of truth is the API).
- **Purposes** — Provide the wallet and parent controls, prevent fraud/abuse, support, improve reliability (crash reports), legal compliance.
- **Legal bases** (where GDPR/UK GDPR apply) — Contract, legitimate interests, consent where required (e.g. marketing, certain analytics).
- **Children / teens** — HapoPay targets students with parent accounts. State minimum age, parental role, and COPPA / regional kids rules if applicable. Do not claim “not directed to children” if under-13 users are expected.
- **Sharing** — Hosting providers (API, Supabase, Sentry), app stores, law enforcement when required. No sale of personal data (or state clearly if that changes).
- **International transfers** — Regions where servers and processors sit; SCCs or equivalent if needed.
- **Retention** — How long account, ledger, and crash data are kept; what happens on account deletion.
- **Security** — TLS in transit; tokens in secure storage; release builds must not use mock API.
- **User rights** — Access, correction, deletion, export, objection, complaint to a regulator.
- **Account / data deletion** — Concrete path (in-app + email) and timeline.
- **Policy changes** — How users are notified; effective date.
- **Contact** — Privacy and support emails.

## Store requirements

| Store | Requirement |
|-------|-------------|
| Google Play | Public Privacy Policy URL on the store listing + Data safety form consistency ([`../store/PLAY_DATA_SAFETY.md`](../store/PLAY_DATA_SAFETY.md)). |
| Apple App Store | Privacy Policy URL in App Store Connect; Privacy Nutrition Labels must match this policy. |

## Hosting (owner)

1. Publish the reviewed HTML/Markdown at a stable HTTPS URL (e.g. `https://hapopay.com/privacy`).
2. Wire Settings → Privacy Policy and registration copy to that URL (`url_launcher`).
3. Keep the URL in store consoles and in any deep-link / website footer.
