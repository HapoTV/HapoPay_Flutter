## HapoPay Mobile Design System (Mobile-first)

This document focuses on mobile application capabilities and Flutter implementation. It consolidates color tokens, spacing, text styles, component patterns and Flutter-ready snippets so maintainers and engineers can implement a consistent, agile mobile UI.

### Goals
- Mobile-first token set for fast iteration and consistent theming.
- Small, composable Flutter widgets and ThemeData examples.
- Clear mapping from tokens → `ThemeData` / `TextStyle` / constants.

---

## 1. Core Tokens (mobile)

### Colors (stable palette optimized for accessibility)
- Primary: #0066FF — primary CTA and interactive accents
- Primary-700: #0052CC — pressed / emphasis
- Secondary: #00BFA6 — supportive actions
- Accent: #FFB020 — highlights and badges
- Success: #16A34A
- Warning: #F59E0B
- Danger: #EF4444

Neutral scale (mobile-friendly contrast):
- Neutral-900: #111827
- Neutral-700: #374151
- Neutral-500: #6B7280
- Neutral-300: #D1D5DB
- Neutral-100: #F3F4F6

Dark mode tokens (mirror with semantic names):
- surfaceDark: #0F1724
- backgroundDark: #0B1220
- textDark: #E6EEF8

### Spacing (8pt baseline)
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px

### Radii
- small: 6px
- medium: 12px
- pill: 999px

### Elevation (Material friendly)
- elevation-1: 2dp shadow
- elevation-2: 6dp shadow

---

## 2. Flutter ThemeData (example)

Use this as the starting point in `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

final Color primary = Color(0xFF0066FF);
final Color secondary = Color(0xFF00BFA6);

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: primary),
  primaryColor: primary,
  scaffoldBackgroundColor: Color(0xFFF3F4F6),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(fontSize: 16, height: 1.5),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  ),
);
```

Notes:
- Keep tokens in a small constants file for easy overrides and CI-safe updates.
- Prefer `ColorScheme` and `ThemeExtensions` for custom tokens.

---

## 3. Typography (mobile sizes)
- Display / Headline: 24sp — 28sp (bold for headers)
- Title: 18sp — 20sp (semibold)
- Body: 14sp — 16sp (regular)
- Small / Caption: 12sp

Use `height` around 1.3–1.6 for better readability on small screens.

---

## 4. Components (Flutter mapping)
- Buttons: Use `ElevatedButton` with `elevatedButtonTheme` for primary CTAs. Secondary actions use `OutlinedButton`.
- Cards: Use `Card` with `margin: EdgeInsets.all(12)` and `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))`.
- Inputs: `TextFormField` with `InputDecoration` and 12–16px vertical padding. Show inline error text using `FormField` validators.
- App Bars: `AppBar` with `centerTitle: false`, `elevation: 0`, rounded bottom when needed.
- Bottom Navigation: use `BottomNavigationBar` with 3–5 items; prefer icons + label, active color = primary.
- Modals & Sheets: prefer `showModalBottomSheet` for flows that require context retention. Use full-screen dialogs for onboarding/critical flows.
- Toasts: use `ScaffoldMessenger.of(context).showSnackBar(...)` with compact height and action buttons.

---

## 5. Dark Mode
- Mirror semantic tokens into dark variants. Use `ThemeMode.system` and test contrast with small text (14sp) at 4.5:1.

---

## 6. Accessibility & Localization
- Color contrast: aim for WCAG AA for body text; test on-device with accessibility settings.
- Font scaling: test with `MediaQuery.textScaleFactor` up to 1.5.
- RTL support: keep layout direction aware (`Directionality` widget).

---

## 7. Assets & Tokens pipeline
- Store icons and SVGs in `assets/icons/` and declare them in `pubspec.yaml`.
- Consider exporting tokens as a small JSON (src/tokens.json) and add a tiny generator to produce `lib/core/theme/tokens.dart`.

Example tokens JSON snippet:

```json
{
  "color": {"primary":"#0066FF","secondary":"#00BFA6","neutral-900":"#111827"},
  "space": {"sm":8,"md":16,"lg":24},
  "radius": {"md":12}
}
```

---

## 8. Implementation notes & best practices
- Keep tokens in `lib/core/theme/` and export a single `tokens.dart` for app code.
- Use Riverpod/Provider to expose runtime theme toggles and `ThemeMode` state.
- Prefer composition over inheritance: small widgets (e.g., `AppPrimaryButton`) wrap Material widgets and read tokens.

---