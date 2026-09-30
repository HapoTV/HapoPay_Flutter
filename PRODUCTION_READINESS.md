# Production Readiness Checklist — HapoPay Flutter

## Overview
This document tracks remaining work to ship HapoPay v1.0.0 to App Store and Google Play.

**Actionable runbook:** [`docs/PROD_NEXT_STEPS.md`](docs/PROD_NEXT_STEPS.md)

**Reliability / scale (not store listing):** [`docs/PRODUCTION_OPERATIONS.md`](docs/PRODUCTION_OPERATIONS.md)

---

## ✅ Completed
- [x] Authentication (Login, Register, Biometrics, JWT, Secure Storage)
- [x] Parent Dashboard (Spending limits, Card lock, Real-time feed)
- [x] Student Dashboard (QR Payment generator, QR Scanner)
- [x] Rewards System (Gamified tracker, redesigned tiers / achievements / streak UX)
- [x] Clean Architecture (Riverpod, GoRouter, Dio interceptors)
- [x] Supabase Realtime integration
- [x] Theme system (Light/Dark, Material 3)
- [x] CI/CD: Analysis, tests, debug builds
- [x] Environment config via `--dart-define-from-file`
- [x] Android `applicationId` / `namespace` → `com.hapopay.hapoPay`
- [x] Android release signing wired via `android/key.properties` (debug fallback if missing)
- [x] Mock API gated behind `USE_MOCK_API` (default off for release; release assert forbids mock/localhost)
- [x] Sentry (`sentry_flutter`) gated on `SENTRY_DSN`
- [x] Release CI workflow (AAB + unsigned iOS) + `tool/bump_version.dart`
- [x] Store listing / Data safety / content-rating **drafts** under `docs/store/` + legal checklists under `docs/legal/`

---

## 🔴 Critical (Blockers for Store Submission)

### 1. Android Production Signing
- [x] Generate upload keystore (`upload-keystore.jks`) — local / gitignored (`./tool/generate_android_keystore.sh`)
- [x] Create `android/key.properties` (gitignored)
- [x] Update `android/app/build.gradle.kts` to use release signing config
- [x] Test release signing config (`./gradlew :app:signingReport` → upload keystore). Owner: `flutter build appbundle --release --dart-define-from-file=.env.prod`

### 2. iOS Production Signing
- [ ] Apple Developer Program enrollment
- [ ] Create App ID in Apple Developer Console
- [ ] Generate distribution certificate & provisioning profile
- [ ] Configure Xcode: Team, Bundle ID, Signing (Release) — set `DEVELOPMENT_TEAM`
- [ ] Test `flutter build ipa --release --dart-define-from-file=.env.prod`

### 3. App Identity
- [x] Change Android `applicationId` → `com.hapopay.hapoPay`
- [x] iOS `PRODUCT_BUNDLE_IDENTIFIER` → `com.hapopay.hapoPay`
- [ ] Reserve bundle ID in Apple Developer / Google Play Console

### 4. Production Environment
- [ ] Fill `.env.prod` with **real** production values (file template exists locally; gitignored):
  - `SUPABASE_URL` (prod project)
  - `SUPABASE_ANON_KEY` (prod anon key)
  - `API_BASE_URL` (prod Django API URL)
  - `USE_MOCK_API=false`
  - `SENTRY_DSN` (optional)
- [ ] Verify Supabase replication enabled for prod tables (see `docs/SETUP_ENV.md`)
- [ ] Verify Django CORS/ALLOWED_HOSTS includes prod domains *(owner / backend)*

### 5. App Assets
- [x] App icons (Android: adaptive icons, iOS: 1024×1024 + all sizes) — `dart tool/generate_app_icons.dart`
- [x] Launch/Splash screens (Android: `launch_background.xml`, iOS: `LaunchScreen.storyboard`) — pending device / Xcode check
- [ ] Play Store feature graphic (1024×500)
- [ ] App Store screenshots (iPhone 6.7", 6.5", 5.5", iPad Pro)
- [ ] Remove `.gitkeep` from `assets/images/` and `assets/icons/`, add real assets
- [ ] Update `pubspec.yaml` with actual asset paths

---

## 🟡 High (Required for Quality Release)

### 6. Release CI/CD Pipeline
- [x] Add `build-android-release` job: `flutter build appbundle --release --dart-define-from-file=.env.prod`
- [x] Add `build-ios-release` job: unsigned `flutter build ios --release --no-codesign` (signed IPA via `ios-build.yml`)
- [x] Store build artifacts as GitHub Actions artifacts
- [x] Add version bump automation (`dart run tool/bump_version.dart …`)
- [ ] Optional: Fastlane integration for automated store uploads

### 7. Store Metadata & Legal
- [ ] Privacy Policy (hosted URL required by both stores) — checklist in `docs/legal/`
- [ ] Terms of Service — checklist in `docs/legal/`
- [x] App descriptions (short + long) for both stores — `docs/store/LISTING_COPY.md`
- [x] Keywords / search tags — `docs/store/LISTING_COPY.md`
- [x] Content rating questionnaire notes (Play) — `docs/store/CONTENT_RATING_NOTES.md`
- [x] Data safety form draft (Play Store) — `docs/store/PLAY_DATA_SAFETY.md`
- [ ] App Store Connect: App Information, Pricing, Age Rating *(deferred)*

### 8. Error Monitoring & Analytics
- [x] Integrate Sentry (`sentry_flutter`)
- [x] Configure release tracking (version + build number)
- [ ] Add basic analytics events (optional but recommended)

### 9. Deep Links / Universal Links
- [ ] Android: `assetlinks.json` + `AndroidManifest.xml` intent filters
- [ ] iOS: Associated Domains + `apple-app-site-association` file
- [ ] Configure GoRouter to handle deep link routes

---

## 🟢 Medium (Post-Launch / Iteration)

### 10. Test Coverage Expansion
- [ ] Unit tests for repositories, providers, services
- [ ] Widget tests for key screens (Login, Dashboard, QR flow)
- [ ] Integration test: full auth → dashboard → payment flow
- [ ] Target: >80% coverage on business logic

### 11. Push Notifications
- [ ] Firebase Cloud Messaging setup
- [ ] APNs configuration (iOS)
- [ ] Backend integration (Django → FCM/APNs)
- [ ] In-app notification handling + permissions flow

### 12. Performance & Polish
- [ ] Profile on physical devices (flutter build --profile)
- [ ] Optimize image assets (WebP, correct sizes)
- [ ] Reduce app size (analyze with `flutter build appbundle --analyze-size`)
- [ ] Accessibility audit (semantics, contrast, dynamic type)

---

## 📋 Execution Order

Follow [`docs/PROD_NEXT_STEPS.md`](docs/PROD_NEXT_STEPS.md):

| Phase | Focus |
|-------|--------|
| **1** | Identity & signing (Android done in repo; iOS owner) |
| **2** | `.env.prod` + mock off + backend checks |
| **3** | Store assets |
| **4** | Legal + listings |
| **5** | Crash reporting + release CI |
| **6** | Device QA |

---

## Notes
- `key.properties`, `.env.prod`, keystore files, provisioning profiles — **never commit** these
- Use `--dart-define-from-file=.env.prod` for all release builds (`USE_MOCK_API=false`)
- Test on physical devices before submitting
- Keep `flutter doctor -v` clean
