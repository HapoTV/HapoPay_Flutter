# HapoPay — Progress Report

**Date:** July 15, 2026
**Target Release:** v1.0.0 — May 2026 (past due)

---

## App Overview

HapoPay is a parent-student money management / smart spending platform. Built with Flutter 3.22+ using Riverpod for state management, GoRouter for navigation, and a layered Clean Architecture. Backend is Django REST + Supabase for realtime.

---

## Progress by Feature Area

| Area | Status | Completion |
|------|--------|-----------|
| **Architecture & Setup** | Feature-first Clean Architecture, folder structure, Material 3 dark/light theme, GoRouter routing, env config via `--dart-define-from-file` | **100%** |
| **Auth — Login** | Full Clean Architecture auth layer: domain entities (`AppUser`, `AuthSession`, `AuthTokens`), DTOs, `AuthRemoteDataSource`, `AuthRepositoryImpl`, `AuthNotifier` with session restore, `AuthInterceptor` for JWT injection + silent token refresh with deduplication, `AuthEventBus` for force-logout, `SecureStorageService` (Android Keystore / iOS Keychain), role-based route redirect | **~80%** |
| **Auth — Registration** | DTOs and data source method exist, `AuthNotifier.register()` is a stub, **no UI or flow** | **~10%** |
| **Auth — Biometric** | `BiometricAuthService` wraps `local_auth` with PIN fallback, preference persisted in secure storage, **not yet integrated into the login screen** | **~40%** |
| **Parent Dashboard** | Screen layout with greeting and 3 `ActionCard`s (Family Ledger, Spending Limits, Card Lock). **All `onTap` callbacks are empty.** No real data, no controls, no Supabase realtime feed | **~15%** |
| **Student Dashboard** | Layout with greeting, gradient balance card (**hardcoded** `$120.50`), Pay with QR / My QR Code buttons (**empty `onTap`**), live Rewards summary card pulling from `rewardsProvider` with shimmer loading | **~25%** |
| **Rewards System** | `RewardModel` (tiers: bronze/silver/gold/platinum), `AchievementModel` with progress tracking, `MilestoneModel`, full `RewardsRepository` + `RewardsProvider` (AsyncNotifier with refresh + optimistic claim), `RewardsScreen` with hero card, tier ladder, stats row, animated achievement grid, loading skeleton, error + retry, demo fallback data. **Feature-complete on the Flutter side** | **~90%** |
| **QR Payments** | `qr_flutter` and `mobile_scanner` declared as dependencies. **No implementation** — no QR generation, no scanner integration, no merchant handshake | **~0%** |
| **Supabase Realtime** | Initialized in `main.dart` (gated on env var presence). **Not wired into any feature** | **~5%** |
| **Error Handling & Resilience** | `ApiException` sealed class hierarchy, `ApiResult<T>` Success/Failure union, `AuthInterceptor` for 401 handling + retry, `DioClient` with timeouts and debug logging. Offline caching not implemented | **~80%** |
| **Tests** | Only the default Flutter counter smoke test (does not match the actual app). **No meaningful tests** | **~0%** |
| **Deployment Readiness** | Build commands documented in README. No signing config tested, no Play Store / App Store metadata, no CI/CD | **~10%** |

---

## Overall Completion: ~42%

---

## Remaining Work Summary

### High Priority (Blocking v1.0.0)
- **QR Payment Engine** — QR code generation + `mobile_scanner` integration + signed payload + Django handshake
- **Parent Dashboard Controls** — Spending limit sliders, card lock toggle, PATCH endpoint integration
- **Registration Flow** — UI screen + backend integration for new user sign-up
- **Supabase Realtime** — Wire real-time transaction feed into parent dashboard

### Medium Priority
- **Biometric Login** — Integrate `BiometricAuthService` into the login screen
- **Balance & Transaction Data** — Replace hardcoded values with real API responses
- **Tests** — Unit tests for repositories/providers, widget tests for screens
- **Deployment** — Verify `flutter build appbundle` / `flutter build ipa`, configure signing

### Low Priority / Polish
- Shimmer loading skeletons on all screens
- Haptic feedback and custom animations
- Accessibility audit (font scaling, contrast)
- `tokens.dart` generator script
- Reusable `AppPrimaryButton` widget
- Onboarding flow with design tokens

---

## Timeline Outlook

Given the current pace and scope, a realistic v1.0.0 release is **2–3 months away** from this date (i.e., late September to mid-October 2026), assuming focused effort on the high-priority items above.

---

*For detailed architecture, see [ARCHITECTURE.md](ARCHITECTURE.md). For features, see [docs/FEATURES.md](docs/FEATURES.md). For pending tasks, see [issues.md](issues.md).*
