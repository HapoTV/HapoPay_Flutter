# HapoPay Flutter Mobile Application
### Technical Documentation · v1.0.0 · August 2026

> Cross-platform Flutter app. Production API is Django REST; Supabase is optional. Local UI demos use `USE_MOCK_API=true` and need neither backend.

| Platform | Flutter SDK | Dart | API Backend | Realtime | Status |
|----------|-------------|------|-------------|----------|--------|
| Android (Linux/macOS/Windows) · iOS (macOS) | stable (CI) | 3.x (`>=3.0.0 <4.0.0`) | Django REST, or in-app mock | Optional Supabase | Production prep |

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Documentation](#2-documentation)
3. [Project Structure](#3-project-structure)
4. [Dependencies](#4-dependencies)
5. [Configuration & Environment Variables](#5-configuration--environment-variables)
6. [Build & Deployment](#6-build--deployment)
7. [Troubleshooting & FAQs](#7-troubleshooting--faqs)
8. [Changelog](#8-changelog)
9. [Contributing](#9-contributing)
10. [Code of Conduct](#10-code-of-conduct)

---

## 1. Project Overview

HapoPay is a parent-student money management and smart spending platform. The Flutter app gives parents tools to manage allowances, adjust spending limits, and monitor transactions in real time. Students get a safe payment flow with dynamic QR codes, biometric auth, and a gamified rewards hub (tiers, streaks, claimable achievements).

**Backend model:** Django owns business logic and the payment gateway. Supabase is optional (`Supabase.initialize` is skipped when `SUPABASE_URL` is empty). With `USE_MOCK_API=true`, Dio serves an in-memory catalog so you can demo without any server.

**App stack:** Riverpod 3 (state + codegen), GoRouter (navigation), Dio (HTTP + auth/retry/mock interceptors), Material 3 light/dark theming via `lib/core/theme/`.

**Clone:** `git clone git@github.com:HapoTV/HapoPay_Flutter.git` — this *is* the Flutter app root (there is no `mobile/` subfolder). Setup: **[docs/SETUP.md](docs/SETUP.md)**.

---

## 2. Documentation

| Doc | Description |
|-----|-------------|
| **[Setup & Installation](docs/SETUP.md)** | Clone this repo, Flutter, mock vs live API, Android emulator, demo logins |
| **[Environment Variables](docs/SETUP_ENV.md)** | `.env.dev` / `.env.prod`, `USE_MOCK_API`, emulator loopback, keystore |
| **[Architecture](docs/ARCHITECTURE.md)** | Clean layers, Riverpod, GoRouter |
| **[Features & Screens](docs/FEATURES.md)** | Auth, parent dashboard, student QR & rewards routes |
| **[Rewards System](docs/rewards_system.md)** | Catalog, tiers, claim UX, API contract, mock flow |
| **[Project Roadmap](docs/NEXT_STEPS.md)** | Milestones and build status |
| **[Production Checklist](PRODUCTION_READINESS.md)** | Store-submission blockers and completed work |
| **[Production Runbook](docs/PROD_NEXT_STEPS.md)** | Ordered phases for signing, env, assets, legal, QA |
| **[Production operations](docs/PRODUCTION_OPERATIONS.md)** | Latency, traffic, errors, maintenance, workflows, scale, client performance |

---

## 3. Project Structure

```
lib/
├── main.dart / app.dart
├── core/                 # config, network, router, theme, storage, realtime
├── features/
│   ├── auth/             # login, register, JWT session, biometrics
│   ├── parent/           # dashboard, ledger, spending limits
│   ├── student/          # dashboard, rewards catalog / claim
│   └── qrcode/           # pay QR + my QR screens
└── shared/               # shared widgets (buttons, cards, theme toggle)
test/                     # unit / widget tests by feature
docs/                     # setup, architecture, features, rewards, prod runbook
```

---

## 4. Dependencies

Primary packages from `pubspec.yaml`:

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` / `riverpod_annotation` | State management + codegen |
| `go_router` | Declarative navigation & role redirects |
| `dio` | HTTP client, auth / mock / retry interceptors |
| `supabase_flutter` | Realtime subscriptions & client init |
| `flutter_secure_storage` | Hardware-backed token storage |
| `shared_preferences` | Lightweight local settings cache |
| `qr_flutter` / `mobile_scanner` | QR generation and camera scanning |
| `local_auth` | Face ID / fingerprint |
| `google_fonts` / `intl` | Typography and localization |

---

## 5. Configuration & Environment Variables

### 5.1 Environment files

Copy the sample and fill in values (files are gitignored — never commit secrets):

```bash
cp .env.example .env.dev
cp .env.example .env.prod
```

```bash
# .env.example (compile-time KEY=VALUE; no quotes)
SUPABASE_URL=
SUPABASE_ANON_KEY=
API_BASE_URL=http://10.0.2.2:8000/api
USE_MOCK_API=false
SENTRY_DSN=
```

| Variable | Notes |
|----------|--------|
| `SUPABASE_URL` | Optional. Empty skips Supabase init |
| `API_BASE_URL` | `http://10.0.2.2:8000/api` on the Android emulator when talking to host Django |
| `USE_MOCK_API` | `true` for local UI demos without Django; **must be `false` for release** |
| `SENTRY_DSN` | Optional. Empty skips Sentry init |

Every `flutter run` / `flutter build` must pass `--dart-define-from-file`. Full reference: **[docs/SETUP_ENV.md](docs/SETUP_ENV.md)**.

### 5.2 Run / build with env injection

```bash
# UI demo (set USE_MOCK_API=true in .env.dev)
flutter run --dart-define-from-file=.env.dev

# Codegen — only after changing @riverpod annotations (*.g.dart is already committed)
dart run build_runner build --delete-conflicting-outputs
```

---

## 6. Build & Deployment

### 6.1 Android signing

`applicationId` / `namespace`: `com.hapopay.hapoPay`. Release builds load `android/key.properties` when present (otherwise debug keys + Gradle warning).

```bash
./tool/generate_android_keystore.sh
flutter build appbundle --release --dart-define-from-file=.env.prod
flutter build apk --release --dart-define-from-file=.env.prod
```

Version bump: `dart run tool/bump_version.dart build|patch|minor|major`. Tag `v*` triggers [`.github/workflows/release.yml`](.github/workflows/release.yml).

### 6.2 iOS deployment

Requires Apple Developer enrollment, App ID, distribution cert, provisioning profile, and `DEVELOPMENT_TEAM` in Xcode. Bundle ID is already `com.hapopay.hapoPay`.

```bash
flutter build ipa --release --dart-define-from-file=.env.prod
```

Store-readiness checklist and phased runbook: **[PRODUCTION_READINESS.md](PRODUCTION_READINESS.md)** · **[docs/PROD_NEXT_STEPS.md](docs/PROD_NEXT_STEPS.md)**. Legal / listing drafts: **[docs/legal/](docs/legal/)** · **[docs/store/](docs/store/)**.

---

## 7. Troubleshooting & FAQs

| Error / Symptom | Likely Cause | Solution |
|-----------------|--------------|----------|
| `Connection refused` on Android emulator | `localhost` is the emulator, not the host | Set `API_BASE_URL` to `http://10.0.2.2:8000/api` |
| Realtime subscription fails | Replication not enabled | Enable tables under Supabase **Database → Replication** |
| Invalid JWT | Django / Supabase signing mismatch | Align SimpleJWT secret with Supabase JWT secret if sharing tokens |
| Keystore / signing failure | Missing or wrong `key.properties` | Run `./tool/generate_android_keystore.sh`; keep backups offline |
| Camera viewport blank | Main AndroidManifest has no `CAMERA` yet | iOS already has `NSCameraUsageDescription`; Android still needs the permission |
| Unexpected mock responses in release | `USE_MOCK_API=true` | Set `USE_MOCK_API=false` in `.env.prod` |

---

## 8. Changelog

### v1.0.0 — in progress (August 2026)

- Auth: Django JWT login/register path, secure storage, biometric service, role-based GoRouter redirects
- Parent: dashboard, family ledger, spending limits, card lock; Supabase realtime feed wiring
- Student: dashboard, QR pay / my QR screens, rewards hub (tiers, streak panel, optimistic claim)
- Rewards catalog shared across mock, demo, and UI — see [docs/rewards_system.md](docs/rewards_system.md)
- Networking: Dio interceptors (auth, retry, errors); mock API gated by `USE_MOCK_API`
- Theme: Material 3 light/dark tokens in `lib/core/theme/`
- Android / iOS identity: `com.hapopay.hapoPay`; release signing via `key.properties`
- Sentry (optional DSN), release CI (AAB + unsigned iOS), version bump tool
- CI: analyze, tests, debug builds; release workflow on `v*` tags

### Upcoming

- Interactive parent budget charts
- Push notifications (FCM / APNs)
- Store assets; host Privacy / Terms URLs; paste Play Data safety
- Broader unit / widget / integration coverage

---

## 9. Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for workflow, linting, tests, PRs, and commit conventions.

## 10. Code of Conduct

This project follows a [Code of Conduct](CODE_OF_CONDUCT.md). Report unacceptable behavior to the maintainers.

---

*HapoPay Mobile · v1.0.0*
