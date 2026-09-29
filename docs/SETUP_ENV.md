# Environment Setup Guide

This guide is the source of truth for `.env.dev` / `.env.prod`. For Flutter install, emulator, and run commands, see [SETUP.md](SETUP.md).

## Overview

HapoPay injects config at **compile/run time** with Flutter's `--dart-define-from-file` flag. `lib/core/config/env_config.dart` reads:

- `SUPABASE_URL` (optional)
- `SUPABASE_ANON_KEY` (optional)
- `API_BASE_URL`
- `USE_MOCK_API`

There is no runtime dotenv loader. If you omit `--dart-define-from-file`, you get the Dart defaults (`USE_MOCK_API=false`, `API_BASE_URL=http://localhost:8000/api`).

`Makefile` `android` / `ios` targets pass `--dart-define-from-file=.env.dev`. Do not use the leftover JTC/Serverpod make targets.

## 1. Creating environment files

```bash
cp .env.example .env.dev
cp .env.example .env.prod
```

Both files are gitignored (`/.gitignore` ignores `.env.*` except `.env.example`). Never commit them.

## 2. Variables

| Variable | Required? | Description | Local demo | Production |
|---|---|---|---|---|
| `SUPABASE_URL` | No | Supabase project URL. Empty string skips `Supabase.initialize` in `lib/main.dart`. | leave empty | prod project URL |
| `SUPABASE_ANON_KEY` | Only if URL set | Public anon key | leave empty | prod anon key |
| `API_BASE_URL` | Yes (string) | Django REST base path. Ignored when the mock interceptor is on, but still compiled in. | `http://10.0.2.2:8000/api` on Android emulator | `https://api.yourdomain.com/api` |
| `USE_MOCK_API` | Yes | When `true`, Dio mounts `MockInterceptor` (offline UI). | `true` | **`false`** |

`--dart-define-from-file` only accepts `KEY=VALUE` lines (optional `#` comments). Do not wrap values in quotes unless the quotes are part of the value.

### Local demo `.env.dev`

```bash
SUPABASE_URL=
SUPABASE_ANON_KEY=
API_BASE_URL=http://10.0.2.2:8000/api
USE_MOCK_API=true
```

Mock login (any non-empty password):

- Parent: email contains `parent` → `parent@hapopay.com`
- Student: any other email → `student@hapopay.com`

### Production `.env.prod`

```bash
SUPABASE_URL=https://your-prod.supabase.co
SUPABASE_ANON_KEY=your-prod-anon-key
API_BASE_URL=https://api.yourdomain.com/api
USE_MOCK_API=false
```

## 3. Running with environment files

**Local development:**

```bash
flutter run --dart-define-from-file=.env.dev
```

**Release builds** (once signing is actually wired — see below):

```bash
flutter build appbundle --release --dart-define-from-file=.env.prod
flutter build apk --release --dart-define-from-file=.env.prod
flutter build ipa --release --dart-define-from-file=.env.prod
```

CI (`.github/workflows/ci.yml`) currently builds a **debug APK** and iOS `--no-codesign` **without** `--dart-define-from-file`.

## 4. Common pitfalls

### Emulator host loopback (`Connection refused`)

On the Android emulator, `localhost` is the emulator, not your PC. For a Django server on the host:

```
API_BASE_URL=http://10.0.2.2:8000/api
```

On a physical device, use the host LAN IP (`http://192.168.x.x:8000/api`). `10.0.2.2` is emulator-only.

This does not matter when `USE_MOCK_API=true`.

### Forgot `--dart-define-from-file`

Symptoms: login tries a real HTTP call; mock accounts do not work. Always pass the file on `flutter run` / `flutter build`.

### Realtime subscription fails

Only relevant if you set `SUPABASE_URL`. Enable the tables under Supabase **Database → Replication**.

### Invalid JWT

Only relevant when sharing tokens between Django SimpleJWT and Supabase. Signing secrets must match.

### Android keystore / `key.properties`

`android/.gitignore` ignores `key.properties` and `*.jks`. **Today's Gradle file does not load `key.properties`.** Release builds use the **debug** signing config:

```kotlin
signingConfig = signingConfigs.getByName("debug")
```

When release signing is added, create `android/key.properties` locally (paths relative to `android/`):

```properties
storePassword=your-android-keystore-password
keyPassword=your-android-key-password
keyAlias=upload
storeFile=keys/upload-keystore.jks
```

Do not follow `Makefile` `android-release-keystore` — it targets a different app (`jtc-release.keystore`) and embeds a password.

### Camera viewport blank (QR scanner)

- **Android:** main `AndroidManifest.xml` does **not** yet declare `CAMERA`. Debug builds have `INTERNET` only in the debug/profile manifests.
- **iOS:** `NSCameraUsageDescription` is set in `ios/Runner/Info.plist`.

### Application IDs

| Platform | Value in repo |
|----------|----------------|
| Android `applicationId` | `com.example.hapopay` |
| iOS bundle ID | `com.hapopay.hapoPay` |

## 5. iOS notes

iOS Simulator and `flutter build ipa` require macOS, Xcode, and signing assets. On Linux you can only run Android (emulator or device).

## Summary checklist

- [ ] `.env.dev` copied from `.env.example` (and `.env.prod` if you are cutting a release)
- [ ] `USE_MOCK_API=true` for UI demos **or** Django reachable at `API_BASE_URL`
- [ ] Every `flutter run` / `flutter build` uses `--dart-define-from-file=...`
- [ ] Android emulator uses `10.0.2.2` when talking to host Django
- [ ] Supabase keys only if you actually use realtime / OAuth
- [ ] Do not expect `android/key.properties` to be required for `flutter run`
