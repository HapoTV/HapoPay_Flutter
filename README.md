# HapoPay — Flutter Mobile Application
### Technical Documentation · v1.0.0 · May 2026

> Cross-platform mobile app built with Flutter, powered by a Django REST API & Supabase

| Platform | Flutter SDK | Dart | API Backend | Database / Realtime | Release |
|----------|-------------|------|-------------|---------------------|---------|
| iOS & Android | 3.22+ | 3.4+ | Django REST | Supabase | May 2026 |

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Documentation](#2-documentation)
3. [Dependencies](#3-dependencies)
4. [Configuration & Environment Variables](#4-configuration--environment-variables)
5. [Build & Deployment](#5-build--deployment)
6. [Troubleshooting & FAQs](#6-troubleshooting--faqs)
7. [Changelog](#7-changelog)
8. [Design & Theming](#design--theming-mobile)
9. [Contributing — Issues & Maintainers](#contributing--issues--maintainers)

---

## 1. Project Overview

HapoPay is a parent-student money management and smart spending platform. The mobile application, built with Flutter, provides parents with the tools to manage their children's allowances, adjust transaction limits, and monitor spending in real time. For students, it provides a safe payment interface using dynamic QR codes, biometric authorization, and a gamified financial education hub.

The application utilizes a hybrid backend model: Django serves as the primary business logic and transaction gateway, while Supabase provides real-time transaction updates, persistent database hosting, and storage.

---

## 2. Documentation

For detailed information, please refer to the following documents in the `docs/` folder:

- **[Setup & Installation](docs/SETUP.md)**: Step-by-step guide to setting up your local environment and running the app.
- **[Environment Variables Setup](docs/SETUP_ENV.md)**: Configuring `.env.dev` / `.env.prod`, required variables, and troubleshooting common environment issues (emulator loopback, keystore setup).
- **[Architecture & Design](docs/ARCHITECTURE.md)**: Deep dive into the clean layered architecture, state management with Riverpod, and navigation with GoRouter.
- **[Features & Screens](docs/FEATURES.md)**: Walkthrough of the authentication flow, parent dashboard, and student payment features.
- **[Design & Theming](docs/DESIGNS.md)**: Mobile design system, color tokens, and component mappings.
- **[Project Roadmap](docs/NEXT_STEPS.md)**: Milestones and current build status.
- **[Rewards System](docs/rewards_system.md)**: Implementation detail for the student gamification/rewards feature.

---

## 3. Dependencies

Below are the primary packages declared in the application's configuration:

| Package | Version | Purpose |
|---------|---------|---------|
| `supabase_flutter` | ^2.6.0 | Client wrapper for realtime subscription events and storage. |
| `flutter_riverpod` | ^2.5.1 | State management framework. |
| `riverpod_annotation`| ^2.3.5 | Code generation annotations for Riverpod state managers. |
| `go_router` | ^14.2.7 | Declarative system navigation. |
| `dio` | ^5.7.0 | HTTP client with cookie support, interceptors, and robust request routing. |
| `flutter_secure_storage`| ^9.2.2 | Enforceable hardware-backed (Keychain/Keystore) encrypted storage. |
| `shared_preferences` | ^2.3.2 | Lightweight configuration/settings caching. |
| `qr_flutter` | ^4.1.0 | Dynamically generated QR graphics on-screen. |
| `mobile_scanner` | ^5.2.3 | Integrated camera viewports and QR code decoding. |
| `google_fonts` | ^6.2.1 | Typographical layout styles. |
| `intl` | ^0.19.0 | Currency and localized date parsing. |

---

## 4. Configuration & Environment Variables

### 4.1 Environment Files

The application requires environment properties to be injected during the build phase. Create a `.env.dev` or `.env.prod` file from the repository's sample configuration.

```bash
# .env.example -> Copy values to target environment profiles
SUPABASE_URL=https://your-supabase-instance.supabase.co
SUPABASE_ANON_KEY=your-supabase-public-anon-key
API_BASE_URL=http://localhost:8000/api
```

> For a full walkthrough of these variables, per-environment values, and common pitfalls, see **[docs/SETUP_ENV.md](docs/SETUP_ENV.md)**.

### 4.2 Safe Environment Injection

Pass variables directly to compile commands to prevent hardcoding configuration strings into project scripts:

```bash
# Inject local development configs
flutter run --dart-define-from-file=.env.dev
```

---

## 5. Build & Deployment

### 5.1 Android Signing

Set up the key details locally in `android/key.properties`. Ensure this file is never tracked in source control.

```properties
storePassword=your-android-keystore-password
keyPassword=your-android-key-password
keyAlias=upload
storeFile=../keys/upload-keystore.jks
```

Build commands:

```bash
# Build production bundle (recommended for Google Play Console)
flutter build appbundle --release --dart-define-from-file=.env.prod

# Build stand-alone APK
flutter build apk --release --dart-define-from-file=.env.prod
```

### 5.2 iOS Deployment

iOS distribution builds require provisioning profiles and code-signing assets within Xcode.

```bash
# Compile distribution archive
flutter build ipa --release --dart-define-from-file=.env.prod
```

---

## 6. Troubleshooting & FAQs

| Error / Symptom | Likely Cause | Solution |
|-----------------|-------------|---------|
| `Connection refused` on Android Emulator | `localhost` points to emulator loopback, not the host machine | Modify `API_BASE_URL` in `.env.dev` to target `10.0.2.2` (Android host routing IP) instead of `localhost` / `127.0.0.1`. |
| Realtime subscription fails | Replication configuration not toggled on targets | Ensure tables in Supabase Console are active under **Database > Replication**. |
| Invalid JWT token | Supabase and Django token alignment issue | Verify that the signing keys of the Django SimpleJWT configuration and Supabase match if sharing tokens directly. |
| Keystore compilation failure | Missing `key.properties` configuration | Ensure `key.properties` exists in the `android/` directory and points to a valid `.jks` file. |
| Camera viewport blank | Permissions configurations omitted | Check iOS `Info.plist` and Android `AndroidManifest.xml` for `NSCameraUsageDescription` and `CAMERA` permissions. |

For a deeper breakdown of environment-related issues specifically, see **[docs/SETUP_ENV.md](docs/SETUP_ENV.md)**.

---

## 7. Changelog

### v1.0.0 — May 2026
- Core authentication logic integration using Django JWT tokens.
- Parent dashboard layout with real-time transaction tracking.
- Student QR payment screen and scanner viewports.
- Integrated biometrics (`local_auth`) and secure storage (`flutter_secure_storage`).

### Upcoming — v1.1.0
- Interactive dashboard charts for parent budget tracking.
- Push notifications via backend-triggered messages.
- Advanced achievement badges and student savings goals.

---

## Design & Theming (Mobile)

This repo ships a mobile-first design system tailored for Flutter. See the mobile design guide in [docs/DESIGNS.md](docs/DESIGNS.md) which contains:

- Tokenized color palette and dark-mode variants.
- Flutter `ThemeData` starter example and recommended `tokens.dart` pipeline.
- Component mappings (Buttons, Cards, Inputs, AppBar, Bottom Navigation) and accessibility guidance.

Quick commands to run the app with environment files:

```bash
# development
flutter run --dart-define-from-file=.env.dev

# production build
flutter build appbundle --release --dart-define-from-file=.env.prod
```

Recommended implementation notes:
- Keep token overrides in `lib/core/theme/tokens.dart` and import that from `app_theme.dart`.
- Use Riverpod to expose runtime theme toggles and `ThemeMode` state.
- Store icons in `assets/icons/` and declare them in `pubspec.yaml`.

---

## Contributing — Issues & Maintainers

We track actionable work in `issues.md` at the repository root. Maintainers should use it to triage and assign tasks. Key expectations:

- Prefix issue branches with `feat/`, `fix/`, or `chore/` and include the issue number.
- Open PRs should reference the issue number and include a short testing checklist.
- Add `BREAKING` to PR title when changes modify public APIs or tokens.

See `issues.md` for initial tasks and priorities.

---

*End of Document — HapoPay Mobile v1.0.0*
