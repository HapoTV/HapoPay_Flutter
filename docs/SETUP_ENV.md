# Environment Setup Guide

This guide explains how to configure `.env.dev` and `.env.prod` for HapoPay's Flutter app, along with common pitfalls you may run into during setup.

> For general project setup (Flutter SDK, dependencies, code generation), see [SETUP.md](SETUP.md). This doc covers environment variables specifically and is the single source of truth for them — SETUP.md links here rather than repeating the details.

## Overview

HapoPay uses **compile-time environment injection** via Flutter's `--dart-define-from-file` flag. Environment variables are never hardcoded into the app — they're injected at build/run time from `.env.dev` (local development) or `.env.prod` (release builds).

## 1. Creating Your Environment Files

Copy the sample configuration to create your own environment files:

```bash
cp .env.example .env.dev
cp .env.example .env.prod
```

Both files are gitignored and should **never** be committed to source control.

## 2. Required Variables

| Variable | Description | Example (dev) | Example (prod) |
|---|---|---|---|
| `SUPABASE_URL` | Your Supabase project URL | `https://your-instance.supabase.co` | Same, pointing to prod project |
| `SUPABASE_ANON_KEY` | Public anon key for Supabase client | `your-supabase-public-anon-key` | Prod project's anon key |
| `API_BASE_URL` | Base URL for the Django REST API | `http://10.0.2.2:8000/api` (Android emulator) | `https://api.yourdomain.com/api` |

> **Note:** The values above are placeholders from `.env.example`. Use your own project's Supabase and Django instance values.

## 3. Running with Environment Files

**Local development:**
```bash
flutter run --dart-define-from-file=.env.dev
```

**Production builds:**
```bash
# Android App Bundle (recommended for Google Play Console)
flutter build appbundle --release --dart-define-from-file=.env.prod

# Android APK
flutter build apk --release --dart-define-from-file=.env.prod

# iOS distribution archive
flutter build ipa --release --dart-define-from-file=.env.prod
```

## 4. Common Pitfalls

### Emulator host loopback (`Connection refused` on Android Emulator)
On the Android emulator, `localhost` / `127.0.0.1` refers to the emulator itself, not your host machine. If your Django API runs on your host machine, point `API_BASE_URL` in `.env.dev` to the special Android host-routing IP instead:

```
API_BASE_URL=http://10.0.2.2:8000/api
```

On physical devices, use your machine's local network IP instead (e.g. `http://192.168.x.x:8000/api`), since `10.0.2.2` only works in the emulator.

### Realtime subscription fails
Supabase replication must be explicitly enabled per table. Check **Database > Replication** in the Supabase Console and ensure the relevant tables are toggled on.

### Invalid JWT token
If tokens are shared directly between Django and Supabase, their signing keys must match. Verify your Django `SimpleJWT` configuration aligns with Supabase's JWT secret.

### Android keystore compilation failure
Production Android builds require `android/key.properties`, which is **not** committed to source control. Create it locally:

```properties
storePassword=your-android-keystore-password
keyPassword=your-android-key-password
keyAlias=upload
storeFile=../keys/upload-keystore.jks
```

Make sure `storeFile` points to a valid `.jks` keystore file, and that the file itself exists at that path.

### Camera viewport blank (QR scanner)
Missing camera permissions. Check:
- **Android:** `CAMERA` permission in `AndroidManifest.xml`
- **iOS:** `NSCameraUsageDescription` in `Info.plist`

## 5. iOS Notes

iOS release builds additionally require valid provisioning profiles and code-signing assets configured in Xcode — these are separate from `.env.prod` and must be set up per-developer or via a shared signing certificate.

## Summary Checklist

- [ ] `.env.dev` and `.env.prod` created from `.env.example`
- [ ] `SUPABASE_URL` and `SUPABASE_ANON_KEY` set for each environment
- [ ] `API_BASE_URL` correctly set (`10.0.2.2` for Android emulator in dev)
- [ ] `android/key.properties` created locally (not committed) for release builds
- [ ] Camera permissions configured on both platforms
- [ ] Supabase replication enabled for tables needing realtime updates
