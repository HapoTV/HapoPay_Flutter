# Setup & Installation Guide

Follow these steps to get the HapoPay mobile application running on your local machine.

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Flutter SDK | 3.22.0+ | Install via [flutter.dev](https://flutter.dev) |
| Dart | 3.4.0+ | Bundled with Flutter SDK |
| Android Studio | Hedgehog+ | For Android emulator & SDK manager |
| Xcode | 15+ | macOS only — required for iOS builds |
| Django Backend | Running | API layer, default `http://localhost:8000/api` |

## Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/HapoTV/hapo-pay.git
   cd hapo-pay/mobile
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**

   Create a `.env.dev` file from the example:
   ```bash
   cp .env.example .env.dev
   ```

   Fill in `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `API_BASE_URL`.

   > For the full variable reference, per-environment values (dev vs. prod), and common setup pitfalls (emulator loopback, keystore config), see **[SETUP_ENV.md](SETUP_ENV.md)**.

4. **Run code generation**

   HapoPay uses Riverpod with code generation. Run this command to generate the necessary files:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Running the App

```bash
# Verify environment health
flutter doctor

# Run on a connected device or emulator
flutter run --dart-define-from-file=.env.dev
```

## Troubleshooting

This guide covers Flutter/toolchain setup issues only. For `.env` / environment-variable issues specifically (emulator loopback IPs, Supabase replication, JWT mismatches, Android keystore errors), see the full troubleshooting table in **[SETUP_ENV.md](SETUP_ENV.md)**.

| Issue | Quick Fix |
|-------|-----------|
| `flutter doctor` reports missing licenses | Run `flutter doctor --android-licenses` and accept all |
| `build_runner` conflicts on generated files | Re-run with `--delete-conflicting-outputs` |
| App won't launch on iOS Simulator | Confirm Xcode command line tools: `xcode-select --install` |

## Next Steps

Once your environment is running, see [NEXT_STEPS.md](NEXT_STEPS.md) for the project roadmap and current milestone status.
