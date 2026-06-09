# HapoPay — Flutter Mobile Application
### Technical Documentation · v1.0.0 · May 2026

> Cross-platform mobile app built with Flutter, powered by a Django REST API & Supabase

| Platform | Flutter SDK | Dart | API Backend | Database / Realtime | Release |
|----------|-------------|------|-------------|---------------------|---------|
| iOS & Android | 3.22+ | 3.4+ | Django REST | Supabase | May 2026 |

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Getting Started](#2-getting-started)
3. [Project Structure](#3-project-structure)
4. [Architecture & Design Patterns](#4-architecture--design-patterns)
5. [Features & Screens](#5-features--screens)
6. [Backend & Supabase Integration](#6-backend--supabase-integration)
7. [Dependencies](#7-dependencies)
8. [Configuration & Environment Variables](#8-configuration--environment-variables)
9. [Build & Deployment](#9-build--deployment)
10. [Troubleshooting & FAQs](#10-troubleshooting--faqs)
11. [Changelog](#11-changelog)

---

## 1. Project Overview

HapoPay is a parent-student money management and smart spending platform. The mobile application, built with Flutter, provides parents with the tools to manage their children's allowances, adjust transaction limits, and monitor spending in real time. For students, it provides a safe payment interface using dynamic QR codes, biometric authorization, and a gamified financial education hub. 

The application utilizes a hybrid backend model: Django serves as the primary business logic and transaction gateway, while Supabase provides real-time transaction updates, persistent database hosting, and storage.

### 1.1 Key Features

- **JWT Authentication Flow** — Custom authentication using Django's SimpleJWT framework, securely synchronized with Supabase's client-side session.
- **Parent Dashboard & Controls** — Real-time tracking of children's spending, transaction limit controls (PATCH API calls), and instant card/payment locking.
- **Student QR Payments** — Dynamic, time-sensitive, and secure QR code generation for payments (`qr_flutter`) and scan integration (`mobile_scanner`).
- **Real-Time Feeds** — Instant UI updates of transaction feeds using Supabase Realtime CDC (Change Data Capture) channels.
- **Biometric Security** — Integration with iOS FaceID/TouchID and Android BiometricPrompt via `local_auth` for payment verification.
- **Gamification Hub** — Points and achievements tracked and served through Django endpoints to motivate good financial habits.
- **Secure Token Caching** — Encrypted device-level token caching utilizing Keystore (Android) and Keychain (iOS) via `flutter_secure_storage`.

### 1.2 Platform Support

| Platform | Min Version | Status |
|----------|-------------|--------|
| Android | API 21 (Android 5.0) | Fully Supported |
| iOS | iOS 13.0+ | Fully Supported |

---

## 2. Getting Started

### 2.1 Prerequisites

Ensure the following tools are installed before setting up the project:

| Tool | Version | Notes |
|------|---------|-------|
| Flutter SDK | 3.22.0+ | Install via [flutter.dev](https://flutter.dev) |
| Dart | 3.4.0+ | Bundled with Flutter SDK |
| Android Studio | Hedgehog+ | For Android emulator & SDK manager |
| Xcode | 15+ | macOS only — required for iOS builds |
| Django Backend | Running | API layer on `http://localhost:8000/api` |

### 2.2 Installation

Clone the repository and install the mobile app dependencies:

```bash
# 1. Clone the repository
git clone https://github.com/HapoTV/hapo-pay.git
cd hapo-pay/mobile

# 2. Install Flutter dependencies
flutter pub get

# 3. Create environment config
cp .env.example .env.dev

# 4. Fill in credentials in .env.dev
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=your-anon-key
# API_BASE_URL=http://localhost:8000/api
```

### 2.3 Running the App

```bash
# Verify environment health
flutter doctor

# Run build_runner to compile state notifiers
flutter pub run build_runner build --delete-conflicting-outputs

# Run on a connected device or emulator
flutter run --dart-define-from-file=.env.dev
```

---

## 3. Project Structure

The project follows a clean, feature-first folder structure. Within each feature directory, logic is organized by layer to maintain isolation.

```
mobile/
├── lib/
│   ├── main.dart                  # App entry point, Supabase init
│   ├── core/
│   │   ├── router/                # GoRouter setup (app_router.dart)
│   │   └── theme/                 # Styling system (app_theme.dart)
│   ├── features/
│   │   ├── auth/                  # Authentication & Registration
│   │   │   ├── presentation/      # login_screen.dart
│   │   │   └── providers/         # Auth controllers & notifiers
│   │   ├── parent/                # Parent dashboards & children management
│   │   │   ├── presentation/      # parent_dashboard_screen.dart
│   │   │   └── providers/         # Limit handlers & transaction feeds
│   │   └── student/               # Student features (QR scanner/milestones)
│   │       ├── presentation/      # student_dashboard_screen.dart
│   │       └── providers/         # QR generation & achievements states
│   └── shared/
│       ├── widgets/               # App-wide UI widgets (inputs, buttons)
│       └── services/              # Secure storage & API clients (Dio)
├── assets/
│   ├── images/                    # Graphic assets & logos
│   └── icons/                     # SVG & PNG UI indicators
├── pubspec.yaml                   # Package dependencies
└── .env.example                   # Local configuration template
```

---

## 4. Architecture & Design Patterns

### 4.1 Overview

HapoPay uses a Clean Layered Architecture designed around feature modules. This limits cross-coupling and allows independent development.

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                   │
│   Widgets / Screens       ◄──►      Riverpod State      │
└────────────────────────┬────────────────────────────────┘
                         │ Ref watches / Notifier triggers
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    Repository Layer                     │
│               Business Rule Integrations                │
└────────────────────────┬────────────────────────────────┘
                         │ API / SDK Request Maps
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    Data Source Layer                    │
│      Dio HTTP Client      │    Supabase Realtime/Storage│
└───────────────────────────┴─────────────────────────────┘
```

### 4.2 State Management — Riverpod

The app uses Riverpod 2.x for state management. Providers and Notifiers are annotated to generate highly-optimized code using the `riverpod_generator`.

```dart
// Example: Asynchronous transaction stream notifier using CodeGen
@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build() async {
    final repo = ref.read(transactionRepositoryProvider);
    return repo.fetchTransactions();
  }

  Future<void> addTransaction(Transaction tx) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionRepositoryProvider).createTransaction(tx);
      return ref.read(transactionRepositoryProvider).fetchTransactions();
    });
  }
}
```

### 4.3 Navigation — GoRouter

Navigation is declared globally using GoRouter. Deep-linking, route parameters, and auth-state redirection are handled cleanly within the router definition.

```dart
final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final authState = ref.read(authProvider);
    final isLoggingIn = state.matchedLocation == '/login';

    if (authState.jwtToken == null) {
      return '/login';
    }
    if (isLoggingIn) {
      return authState.userRole == Role.parent ? '/parent' : '/student';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/parent', builder: (_, __) => const ParentDashboardScreen()),
    GoRoute(path: '/student', builder: (_, __) => const StudentDashboardScreen()),
  ],
);
```

---

## 5. Features & Screens

### 5.1 Authentication

All credential validations and registrations are completed using Django REST token paths.

- **Login Screen** — Inputs for email and password. Coordinates JWT exchanges with Django, caches tokens securely in device hardware, and syncs sessions to the local Supabase client.
- **Biometric Integration** — Option to cache credentials locally and authorize sessions using iOS FaceID or Android Fingerprint verification via `local_auth`.

### 5.2 Parent Dashboard

Provides primary oversight controls for the family ledger.

- **Limit Adjustments** — Slider and form inputs allowing immediate edits to a student's daily or weekly spending limits via PATCH requests to `/api/children/{id}/`.
- **Card Lock Switch** — Quick toggling mechanism that sets a student's limit to `$0`, suspending payment capability instantly.
- **Real-Time Transaction Feed** — Interactive transaction list displaying incoming payments from students, backed by Supabase postgres streams.

### 5.3 Student Dashboard

Features centered around payment executions and saving achievements.

- **QR Payment Creator** — Generates signed, dynamic QR payment markers containing expiring authorization credentials.
- **QR Payment Scanner** — Camera viewport powered by `mobile_scanner` that enables payment processing at merchant portals.
- **Gamified Rewards Tracker** — Visual progress tracking for milestone achievements, linking to the `/api/rewards/` Django route.

---

## 6. Backend & Supabase Integration

### 6.1 Backend API Layer (Django)

All operations involving accounting adjustments, debit authorizations, registrations, and database mutations are handled by the Django REST framework to ensure validation and consistency.
The Flutter client utilizes **Dio** to interface with these API endpoints. A customized interceptor handles:
1. Attaching authorization headers (`Bearer <token>`).
2. Monitoring token expirations (intercepting `401 Unauthorized` responses) and performing token refreshes automatically.

### 6.2 Supabase Realtime Channels

To display live payment events without manual reloading, the mobile client subscribes directly to Supabase's database streaming service.

```dart
final transactionChannel = supabase
    .channel('public:transactions')
    .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'transactions',
      callback: (payload) {
        // Force state notifier to invalidate and pull new transactions from API
        ref.invalidate(transactionListProvider);
      },
    )
    .subscribe();
```

### 6.3 Secure Session Setup

When a user logs in via Django, the JWT is synchronized to the Supabase client. This allows the client to authenticate websocket and storage connections safely.

```dart
Future<void> syncSupabaseSession(String jwtToken) async {
  await Supabase.instance.client.auth.setSession(jwtToken);
}
```

---

## 7. Dependencies

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

## 8. Configuration & Environment Variables

### 8.1 Environment Files

The application requires environment properties to be injected during the build phase. Create a `.env.dev` or `.env.prod` file from the repository's sample configuration.

```bash
# .env.example -> Copy values to target environment profiles
SUPABASE_URL=https://your-supabase-instance.supabase.co
SUPABASE_ANON_KEY=your-supabase-public-anon-key
API_BASE_URL=http://localhost:8000/api
```

### 8.2 Safe Environment Injection

Pass variables directly to compile commands to prevent hardcoding configuration strings into project scripts:

```bash
# Inject local development configs
flutter run --dart-define-from-file=.env.dev
```

---

## 9. Build & Deployment

### 9.1 Android Signing

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

### 9.2 iOS Deployment

iOS distribution builds require provisioning profiles and code-signing assets within Xcode.

```bash
# Compile distribution archive
flutter build ipa --release --dart-define-from-file=.env.prod
```

---

## 10. Troubleshooting & FAQs

| Error / Symptom | Likely Cause | Solution |
|-----------------|-------------|---------|
| `Connection refused` on Android Emulator | `localhost` points to emulator loopback, not the host machine | Modify `API_BASE_URL` in `.env.dev` to target `10.0.2.2` (Android host routing IP) instead of `localhost` / `127.0.0.1`. |
| Realtime subscription fails | Replication configuration not toggled on targets | Ensure tables in Supabase Console are active under **Database > Replication**. |
| Invalid JWT token | Supabase and Django token alignment issue | Verify that the signing keys of the Django SimpleJWT configuration and Supabase match if sharing tokens directly. |
| Keystore compilation failure | Missing `key.properties` configuration | Ensure `key.properties` exists in the `android/` directory and points to a valid `.jks` file. |
| Camera viewport blank | Permissions configurations omitted | Check iOS `Info.plist` and Android `AndroidManifest.xml` for `NSCameraUsageDescription` and `CAMERA` permissions. |

---

## 11. Changelog

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
*End of Document — HapoPay Mobile v1.0.0*
