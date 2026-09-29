# Setup & Installation Guide

This repository is the **HapoPay Flutter app only**. It is not a `mobile/` subdirectory of another project.

HapoPay is a parent–student money app: parents set allowances and spending limits; students pay with QR codes and earn gamified rewards. The production API is Django REST. Supabase is optional (realtime / future OAuth). You do **not** need Django or Supabase to run a local UI demo.

## Prerequisites

| Tool | Version | Required? | Notes |
|------|---------|-----------|--------|
| Flutter SDK | **stable** (Dart 3.x) | Yes | CI uses `subosito/flutter-action` on the `stable` channel, unpinned. `pubspec.yaml` allows `sdk: ">=3.0.0 <4.0.0"`. |
| JDK | **17** | Yes, for Android | Android Gradle Plugin in this repo needs JDK 17+. |
| Android SDK + emulator | API 35 recommended | Yes, to run on Android | Android Studio is optional. Command-line tools are enough. |
| Xcode | 15+ | macOS only | Not used on Linux. This project cannot run the iOS Simulator on Linux. |
| Django API | default `http://localhost:8000/api` | Only for live API | Skip this for UI demos (`USE_MOCK_API=true`). |
| Supabase project | URL + anon key | Optional | `lib/main.dart` skips `Supabase.initialize` when `SUPABASE_URL` is empty. |

Verify Flutter after installing it:

```bash
flutter doctor
```

Accept Android licenses if `flutter doctor` asks:

```bash
flutter doctor --android-licenses
```

## 1. Clone this repository

Remote: `git@github.com:HapoTV/HapoPay_Flutter.git`

```bash
git clone git@github.com:HapoTV/HapoPay_Flutter.git
cd HapoPay_Flutter
```

HTTPS:

```bash
git clone https://github.com/HapoTV/HapoPay_Flutter.git
cd HapoPay_Flutter
```

Do **not** `cd` into `hapo-pay/mobile` — that path does not exist here.

## 2. Install Flutter dependencies

```bash
flutter pub get
```

This is the only package install the app needs. There is no Node, Python, Docker, or Django install in this repo.

## 3. Configure environment files

Env vars are injected at **compile time** with `--dart-define-from-file`. They are not read from a runtime `.env` loader.

```bash
cp .env.example .env.dev
```

`.env.dev` and `.env.prod` are gitignored. Never commit them.

### UI demo (recommended first run — no backend)

Edit `.env.dev`:

```bash
SUPABASE_URL=
SUPABASE_ANON_KEY=
API_BASE_URL=http://10.0.2.2:8000/api
USE_MOCK_API=true
```

With `USE_MOCK_API=true`, Dio mounts `MockInterceptor` and never needs a running Django server. `API_BASE_URL` is unused in that mode but still must be a valid string.

### Live Django API

```bash
USE_MOCK_API=false
# Android emulator → host machine loopback
API_BASE_URL=http://10.0.2.2:8000/api
# iOS Simulator or `flutter run -d chrome` on the host
# API_BASE_URL=http://localhost:8000/api
# Physical device on the same LAN
# API_BASE_URL=http://192.168.x.x:8000/api
```

Full variable reference: **[SETUP_ENV.md](SETUP_ENV.md)**.

## 4. Code generation (only when Riverpod annotations change)

Generated `*.g.dart` files for student rewards/account providers are **already committed**. You only need `build_runner` after editing `@riverpod` annotations:

```bash
dart run build_runner build --delete-conflicting-outputs
```

(`flutter pub run build_runner` still works but is the older form. The `Makefile` `build` target already uses `dart run`.)

## 5. Run the app

`flutter run` with no device flag used to pick **Linux desktop**, which this repo does not support. That is the "No supported devices connected" error.

From a **new** terminal in this repo, `flutter run` now boots the `hapopay` emulator first (via `tool/bin/flutter`). Always pass the env file:

```bash
flutter run --dart-define-from-file=.env.dev
```

Equivalent commands:

```bash
./tool/ensure_android_emulator.sh
flutter run -d emulator --dart-define-from-file=.env.dev

# or
make android
```

Open a new terminal after pulling these scripts so `tool/bin` is on `PATH`. If `which flutter` still points only at `$HOME/flutter/bin/flutter`, either open a new Cursor terminal or:

```bash
export PATH="$PWD/tool/bin:$PATH"
```

### Do not use these Makefile targets for env

`make android` / `make ios` pass `--dart-define-from-file=.env.dev`. Other Makefile targets (`android-release-keystore`, `serverpod`, JTC bundle ids) are leftovers from another project — do not use them.

## 6. Android emulator

SDK location used on this machine (and the layout to copy elsewhere):

```bash
export JAVA_HOME="$HOME/Android/jdk"
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_USER_HOME="$HOME/.config/.android"
export ANDROID_AVD_HOME="$HOME/.config/.android/avd"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
```

List and start the project AVD (`hapopay`, API 35 / Android 15):

```bash
emulator -list-avds
emulator -avd hapopay
```

On Wayland, if the window fails to open:

```bash
QT_QPA_PLATFORM=xcb emulator -avd hapopay -no-metrics
```

Then in another terminal, from the repo root:

```bash
flutter run --dart-define-from-file=.env.dev
```

Creating a new AVD (API 35, Google APIs, x86_64):

```bash
sdkmanager --list | head
sdkmanager "platform-tools" "emulator" "build-tools;36.0.0" "platforms;android-35" "platforms;android-36" "system-images;android-35;google_apis;x86_64"
yes | sdkmanager --licenses
echo no | avdmanager create avd -n hapopay -k "system-images;android-35;google_apis;x86_64" --force
```

## Demo login (mock API)

`MockInterceptor` accepts **any password**. Role is chosen from the email string:

| Role | Email | Password |
|------|-------|----------|
| Parent | any address containing `parent` (e.g. `parent@hapopay.com`) | anything non-empty |
| Student | any other email (e.g. `student@hapopay.com`) | anything non-empty |

Flow: splash (`/splash`) → login (`/login`) → `/parent` or `/student`.

Parent screens: dashboard, family ledger (`/parent/ledger`), spending limits (`/parent/limits`).  
Student screens: dashboard, rewards (`/student/rewards`), pay QR (`/student/pay-qr`), my QR (`/student/my-qr`).

## What this repo actually builds as

These are the values in the tree today. Older docs that say otherwise are wrong.

| Item | Actual value |
|------|----------------|
| Android `applicationId` / `namespace` | `com.example.hapopay` |
| iOS `PRODUCT_BUNDLE_IDENTIFIER` | `com.hapopay.hapoPay` |
| Android release signing | **debug** keys (`android/app/build.gradle.kts`) |
| `android/key.properties` | gitignored; **not wired** in Gradle yet |
| `CAMERA` in main `AndroidManifest.xml` | **not present** (QR scanner will prompt/fail until added) |
| `INTERNET` | debug/profile manifests only |
| CI | `flutter pub get`, `dart format`, `dart analyze --fatal-infos`, `flutter test`, debug APK / iOS `--no-codesign` — **no** `--dart-define-from-file` |

Play/App Store identity `com.hapopay.hapoPay` and `key.properties` signing are still production follow-ups, not current local setup.

## Tests

There is no `test/unit/` or `integration_test/` tree. Tests live under `test/`:

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed .
```

## Troubleshooting

This guide covers toolchain and run commands. Env-specific issues (loopback IP, Supabase, JWT) are in **[SETUP_ENV.md](SETUP_ENV.md)**.

| Issue | Quick fix |
|-------|-----------|
| `flutter doctor` missing Android licenses | `flutter doctor --android-licenses` |
| `Connection refused` on emulator with mock **off** | `API_BASE_URL=http://10.0.2.2:8000/api` and a Django server on the host |
| Login hits the network / fails with mock **on** | Confirm you passed `--dart-define-from-file=.env.dev` and `USE_MOCK_API=true` |
| `build_runner` conflicts | Re-run with `--delete-conflicting-outputs` |
| No devices | Start `emulator -avd hapopay`, then `flutter devices` |
| iOS Simulator | Requires macOS + Xcode; not available on Linux |
| `make android` ignores `.env.dev` | Use `flutter run --dart-define-from-file=.env.dev` |

## Next steps

- Env variables: [SETUP_ENV.md](SETUP_ENV.md)
- Features / routes: [FEATURES.md](FEATURES.md)
- Roadmap: [NEXT_STEPS.md](NEXT_STEPS.md)
