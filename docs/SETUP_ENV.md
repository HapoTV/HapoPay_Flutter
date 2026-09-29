# Environment Setup Guide

This guide is the source of truth for `.env.dev` / `.env.prod`. For Flutter install, emulator, and run commands, see [SETUP.md](SETUP.md).

## Overview

HapoPay injects config at **compile/run time** with Flutter's `--dart-define-from-file` flag. `lib/core/config/env_config.dart` reads:

- `SUPABASE_URL` (optional)
- `SUPABASE_ANON_KEY` (optional)
- `API_BASE_URL`
- `USE_MOCK_API`
- `SENTRY_DSN` (optional — empty skips Sentry)

There is no runtime dotenv loader. If you omit `--dart-define-from-file`, you get the Dart defaults (`USE_MOCK_API=false`, `API_BASE_URL=http://localhost:8000/api`).

Release builds call `EnvConfig.assertReleaseSafe()`: `USE_MOCK_API=true` or a localhost / `10.0.2.2` API host will throw.

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
| `SENTRY_DSN` | No | Sentry project DSN. Empty skips crash reporting. | leave empty | prod DSN |

`--dart-define-from-file` only accepts `KEY=VALUE` lines (optional `#` comments). Do not wrap values in quotes unless the quotes are part of the value.

### Local demo `.env.dev`

```bash
SUPABASE_URL=
SUPABASE_ANON_KEY=
API_BASE_URL=http://10.0.2.2:8000/api
USE_MOCK_API=true
SENTRY_DSN=
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
SENTRY_DSN=https://yoursentrydsn
```

Replace placeholders with real prod values before store builds or tag-triggered [`.github/workflows/release.yml`](../.github/workflows/release.yml).

## 3. Running with environment files

**Local development:**

```bash
flutter run --dart-define-from-file=.env.dev
```

**Release builds:**

```bash
flutter build appbundle --release --dart-define-from-file=.env.prod
flutter build apk --release --dart-define-from-file=.env.prod
flutter build ipa --release --dart-define-from-file=.env.prod
```

CI: [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) still builds debug / unsigned iOS without dart-defines. Release AAB + unsigned iOS release use `release.yml` with secrets → `.env.prod`.

## 4. Common pitfalls

### Emulator host loopback (`Connection refused`)

On the Android emulator, `localhost` is the emulator, not your PC. For a Django server on the host:

```
API_BASE_URL=http://10.0.2.2:8000/api
```

On a physical device, use the host LAN IP (`http://192.168.x.x:8000/api`). `10.0.2.2` is emulator-only.

This does not matter when `USE_MOCK_API=true`. Do **not** use these hosts in `.env.prod` — release asserts will fail.

### Forgot `--dart-define-from-file`

Symptoms: login tries a real HTTP call; mock accounts do not work. Always pass the file on `flutter run` / `flutter build`.

### Realtime subscription fails / Supabase replication (prod)

Only relevant if you set `SUPABASE_URL`. On the **production** Supabase project:

1. **Database → Replication** — enable tables the client watches (at least `public.transactions`).
2. Confirm **RLS** so one family cannot see another’s rows.
3. Smoke-test parent live feed after a student payment.

### Invalid JWT

Only relevant when sharing tokens between Django SimpleJWT and Supabase. Signing secrets must match.

### Android keystore / `key.properties`

`android/.gitignore` ignores `key.properties` and `*.jks`. Release signing loads `android/key.properties` when present; otherwise Gradle warns and uses debug keys.

Generate locally (interactive passwords, or `STORE_PASSWORD` / `KEY_PASSWORD` env vars):

```bash
./tool/generate_android_keystore.sh
```

Creates `android/keys/upload-keystore.jks` and `android/key.properties` (paths relative to `android/`; Gradle loads `storeFile` via `rootProject.file`):

```properties
storePassword=your-android-keystore-password
keyPassword=your-android-key-password
keyAlias=upload
storeFile=keys/upload-keystore.jks
```

Do not follow `Makefile` `android-release-keystore` — it targets a different app (`jtc-release.keystore`) and embeds a password.

For CI, base64-encode the keystore into secret `ANDROID_KEYSTORE_BASE64` (see `release.yml`).

### Camera viewport blank (QR scanner)

- **Android:** main `AndroidManifest.xml` does **not** yet declare `CAMERA`. Debug builds have `INTERNET` only in the debug/profile manifests.
- **iOS:** `NSCameraUsageDescription` is set in `ios/Runner/Info.plist`.

### Application IDs

| Platform | Value in repo |
|----------|----------------|
| Android `applicationId` / `namespace` | `com.hapopay.hapoPay` |
| iOS bundle ID | `com.hapopay.hapoPay` |

## 5. iOS notes (owner)

iOS Simulator and `flutter build ipa` require macOS, Xcode, and signing assets. On Linux you can only run Android (emulator or device).

Before App Store IPA:

1. Enroll in the Apple Developer Program.
2. Register App ID `com.hapopay.hapoPay`.
3. Create distribution certificate + App Store provisioning profile.
4. Set `DEVELOPMENT_TEAM` in Xcode for the Runner target (or supply Team secrets to `ios-build.yml`).
5. `flutter build ipa --release --dart-define-from-file=.env.prod`

## 6. Version bump

```bash
dart run tool/bump_version.dart build   # 1.0.0+1 → 1.0.0+2
dart run tool/bump_version.dart patch   # 1.0.0+1 → 1.0.1+2
dart run tool/bump_version.dart minor
dart run tool/bump_version.dart major
```

Tag `v1.0.0` (or run **Release builds** workflow) after bumping for store artifacts.

## Summary checklist

- [ ] `.env.dev` copied from `.env.example` (and `.env.prod` with **real** prod values for release)
- [ ] `USE_MOCK_API=true` for UI demos **or** Django reachable at `API_BASE_URL`
- [ ] Every `flutter run` / `flutter build` uses `--dart-define-from-file=...`
- [ ] Android emulator uses `10.0.2.2` when talking to host Django
- [ ] Supabase keys + **Replication** enabled only if you use realtime
- [ ] `./tool/generate_android_keystore.sh` before Play upload
- [ ] Optional `SENTRY_DSN` for production crash reporting
