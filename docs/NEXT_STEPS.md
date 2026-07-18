# Project Milestones: HapoPay Flutter

This document outlines the roadmap for the HapoPay mobile application, focusing on Django backend integration, feature completion, and UI/UX refinement.


## Milestone 1: Authentication & Secure Session Bridge
**Goal:** Establish the core security layer and connect the Flutter app to the Django backend.
- **Django Integration:** Configure Django REST Framework (DRF) to handle JWT exchanges and user registration.
- **Flutter Auth Flow:** Build the Login and Registration screens with validation logic.
- **Secure Storage:** Implement `flutter_secure_storage` to persist tokens and integrate `local_auth` for biometric (FaceID/Fingerprint) login.
- **Session Sync:** Ensure the Supabase client is initialized using the Django-provided context for real-time features.

## Milestone 2: Parent Financial Dashboard
**Goal:** Build the primary interface for parents to monitor and control student spending.
- **Control Center:** Implement "Spending Limit" sliders and the "Card Lock" toggle, connecting them to Django `PATCH` endpoints.
- **Real-time Feed:** Integrate Supabase Postgres streams to display a live, interactive transaction history that updates instantly as students spend.
- **Data Visualization:** Use charts or progress indicators to show weekly spending vs. limits.

## Milestone 3: Student Payment & Rewards System
**Goal:** Enable the payment execution logic and the gamified rewards experience.
- **QR Payment Engine:** Build the dynamic QR code generator (for receiving) and the `mobile_scanner` viewport (for paying) with signed authorization payloads.
- **Transaction Logic:** Finalize the Django handshake for payment processing, ensuring atomic updates to the ledger.
- **Gamification:** Rewards Tracker UI implemented, with visual progress bars and tier ladder linked to the `/api/rewards/` Django route. See [`rewards_system.md`](rewards_system.md) for the full implementation writeup.

## Milestone 4: UI/UX Refinement & Aesthetic Polish
**Goal:** Transform the functional prototype into a high-fidelity, premium experience.
- **Visual Identity:** Apply a consistent design language using Google Fonts, custom gradients, and a refined Material 3 dark theme.
- **Micro-interactions:** Add smooth transitions and feedback animations (e.g., success checkmarks for payments, haptic feedback on card locking).
- **Interactive State:** Implement "Shimmer" loading effects and optimistic UI updates to make the app feel "instant."

## Milestone 5: Optimization & Deployment Readiness
**Goal:** Finalize the application for production release on Android and iOS.
- **Resilience:** Implement Dio interceptors for global error handling, retry logic, and offline data caching via `shared_preferences`.
- **Security Audit:** Validate token expiration flows, deep-linking security, and secure environment variable handling (`.env.dev` vs `.env.prod` — see [`SETUP_ENV.md`](SETUP_ENV.md)).
- **Launch Prep:** Configure App Store/Play Store metadata, set up deployment flavors, and run final performance profiling on physical devices.
- **CI/CD Pipeline:** Set up a CI/CD pipeline (build, `flutter analyze`, test suite) that must pass before a release build is cut — all automated tests green as a hard gate for deployment.

---

*Status markers above reflect what's documented as shipped elsewhere in `docs/` as of this update (e.g. `rewards_system.md`). Update them as each item lands — this file is only as accurate as the last person who edited it.*
